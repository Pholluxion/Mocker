import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:server/src/pipe/mqtt.dart';

export 'package:shared/shared.dart';

abstract class Message extends Object {
  Object? toJson();

  Map<String, dynamic> format();
}

/// Contract for a message.
abstract class MockMessage<T> extends Message {
  final String id;
  final String name;
  final T value;

  MockMessage({
    String? identifier,
    required this.name,
    required this.value,
  }) : id = identifier ?? const Uuid().v4();

  @override
  Map<String, dynamic> format() => {name: value};

  @override
  Object? toJson() => {'name': name, 'value': value};
}

abstract class MultiMessage extends Message {
  final List<MockMessage> messages;

  MultiMessage(this.messages);

  @override
  Map<String, dynamic> format() => Map.fromEntries(
        messages.map((e) => MapEntry(e.name, e.value)),
      );

  @override
  Object? toJson() => messages.map((message) => message.toJson()).toList();

  void add(MockMessage message) => messages.add(message);
}

/// A callback that handles an mock.
typedef EventCallback = void Function(Mock mock);

abstract class EventTransformer {
  /// method that registers a handler for an mock.
  void on(String eventKey, EventCallback callback);

  /// method that registers a handler for an mock that repeats every duration.
  void loop(String eventKey, EventCallback callback);

  /// method that registers a handler for an mock that repeats times every duration.
  void repeat(String eventKey, EventCallback callback);
}

/// An abstract class that emits states.
abstract class MessageEmitter<State extends Message> {
  /// The current state.
  State get state;

  /// method that emits a new state.
  void emit(State state);
}

/// An abstract class that writes mocks.
abstract class EventHandler {
  /// The current mock.
  Mock? get mock;

  /// method that handles an mock.
  void handle(dynamic mock);
}

/// An abstract class that closes the StateManager.
abstract class Closable {
  /// method that closes the StateManager.
  void close();

  /// Whether the StateManager is closed.
  bool get isClosed;
}

/// A class that manages the state of the application.
abstract class Pipe<State extends Message> implements MessageEmitter<State>, EventHandler, Closable, EventTransformer {
  /// The socket channel.
  final WebSocketChannel channel;

  /// The MQTT client.
  late MQTTClient _mqttClient;

  /// The message to be sent to the MQTT broker.
  late Payload _message;

  /// The subscription to the socket channel.
  late StreamSubscription? _subscription;

  /// The handlers for the mocks.
  final _handlers = <String, EventCallback>{};

  /// Whether the StateManager is closed.
  bool _isClosed = false;

  /// The current state.
  State _state;

  /// The current mock.
  Mock? _event;

  /// Override the state getter.
  @override
  State get state => _state;

  /// Override the mock getter.
  @override
  Mock? get mock => _event;

  /// Override the isClosed getter.
  @override
  bool get isClosed => _isClosed;

  Pipe(
    this.channel, {
    required State initialState,
  }) : _state = initialState {
    /// Initialize the MQTT client.
    _mqttClient = MQTTClient.defaultClient();

    /// Listen to the stream of the socket channel.
    _subscription = channel.stream.listen(handle, onDone: close);

    /// Set default handlers for the mocks.
    ///
    /// Close the pipe when the socket is closed.
    on('close', _close);

    /// Stop the pipe when the stop mock is received.
    on('stop', _stop);
  }

  /// method that closes the pipe.
  void _close(Mock mock) => close();

  /// method that stops the pipe.
  void _stop(Mock mock) {
    stdout.writeln('Stopping the pipe...');
  }

  /// method that stops the MQTT service.
  void _stopMQTTService(Mock mock) => _mqttClient.disconnect();

  /// method that starts the MQTT service.
  void _startMQTTService(Mock mock) {
    /// Connect to the MQTT broker.
    if (_mqttClient.isConnected) return;

    unawaited(_mqttClient.connect());
  }

  /// method that registers a handler for an mock.
  @override
  void on(String eventKey, EventCallback callback) {
    if (_handlers.containsKey(eventKey)) {
      throw StateError('Event $mock is duplicated.');
    }

    _handlers[eventKey] = callback;
  }

  /// method that registers a handler for an mock that repeats every duration.
  @override
  void loop(String eventKey, EventCallback callback) {
    if (_handlers.containsKey(eventKey)) {
      throw StateError('Event $mock is duplicated.');
    }

    _handlers[eventKey] = (mock) async {
      while (this.mock == mock && !isClosed) {
        callback(mock);
        await Future.delayed(mock.duration);
      }
    };
  }

  /// method that registers a handler for an mock that repeats times every duration.
  @override
  void repeat(String eventKey, EventCallback callback) {
    if (_handlers.containsKey(eventKey)) {
      throw StateError('Event $mock is duplicated.');
    }

    _handlers[eventKey] = (mock) async {
      final times = mock.getIntParam('times', defaultValue: 1);

      if (times <= 0) {
        throw StateError('Times must be greater than 0.');
      }

      for (var i = 0; i < times; i++) {
        callback(mock);
        await Future.delayed(mock.duration);
      }
    };
  }

  /// method that handles an mock.
  @override
  void handle(mock) {
    /// Check if the mock is a string.
    final newEvent = Mock.fromJson(json.decode(mock));

    /// Check if the mock is the same as the current mock.
    if (newEvent == _event) {
      return;
    }

    /// Get the handler for the mock.
    final handler = _handlers[newEvent.handler];

    if (handler != null) {
      /// Set the new mock.
      _event = newEvent;

      /// Start or stop the MQTT service.
      if (newEvent.mqtt) {
        _startMQTTService(newEvent);
      } else {
        _stopMQTTService(newEvent);
      }

      stdout.writeln('Handling mock ${newEvent.handler}...');

      /// Call the handler for the mock.
      handler(newEvent);
    } else {
      throw StateError('Event ${newEvent.handler} is not handled.');
    }
  }

  /// method that emits a new state.
  @override
  void emit(State state) {
    /// Check if the pipe is closed.
    if (isClosed) {
      throw StateError('Cannot emit state after closing the pipe.');
    }

    /// Set the new state.
    _state = state;

    /// Send the state to the socket channel.
    try {
      _sendState(state);
    } catch (e) {
      throw StateError('Cannot send state to the MQTT broker.');
    }
  }

  /// method that sends the state to the socket channel.
  void _sendState(State state) {
    try {
      // stdout.writeln('Sending state to the socket channel...${state.toJson()}');
      /// Send the state to the socket channel.
      channel.sink.add(json.encode(state.toJson()));

      /// Send the state to the MQTT broker.
      _sendToMQTTBroker(state.format());
    } catch (e) {
      stdout.writeln('Cannot send state to the socket channel - skipping. $e');
    }
  }

  /// method that sends the state to the MQTT broker.
  void _sendToMQTTBroker(Map<String, dynamic> values) {
    /// Check if the MQTT client is connected.
    if (!_mqttClient.isConnected) {
      return;
    }

    /// Get the message from the mock.
    if (_event != null) {
      _message = Payload.fromMock(_event!);
    }

    /// Get the message from the state.
    final message = _message.copyWith(values: {...values});

    /// Publish the message to the MQTT broker.
    try {
      _mqttClient.publish(_mqttClient.topic, json.encode(message));
    } catch (e) {
      stdout.writeln('Cannot send message to the MQTT broker - skipping. $e');
    }
  }

  /// method that closes the StateManager.
  @override
  void close() {
    /// Check if the pipe is closed.
    if (isClosed) {
      return;
    }
    stdout.writeln('Closing the pipe...');

    /// Set the pipe as closed.
    _isClosed = true;

    /// Cancel the subscription.
    _subscription?.cancel();

    /// Close the socket channel.
    channel.sink.close();

    /// Close the MQTT client.
    _mqttClient.disconnect();
    stdout.writeln('Pipe closed.');
  }
}
