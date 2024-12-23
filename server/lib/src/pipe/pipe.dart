import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared/shared.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:server/src/pipe/mqtt.dart';

export 'package:shared/shared.dart';

/// Contract for a message.
abstract class Message<T> extends Object {
  final String name;
  final T value;

  Message({
    required this.name,
    required this.value,
  });

  Map<String, dynamic> toJson();

  Map<String, dynamic> format() => {name: value};
}

/// A callback that handles an event.
typedef EventCallback = void Function(Event event);

abstract class EventTransformer {
  /// method that registers a handler for an event.
  void on(String eventKey, EventCallback callback);

  /// method that registers a handler for an event that repeats every duration.
  void loop(String eventKey, EventCallback callback);

  /// method that registers a handler for an event that repeats times every duration.
  void repeat(String eventKey, EventCallback callback);
}

/// An abstract class that emits states.
abstract class MessageEmitter<State extends Message> {
  /// The current state.
  State get state;

  /// method that emits a new state.
  void emit(State state);
}

/// An abstract class that writes events.
abstract class EventHandler {
  /// The current event.
  Event? get event;

  /// method that handles an event.
  void handle(dynamic event);
}

/// An abstract class that closes the StateManager.
abstract class Closable {
  /// method that closes the StateManager.
  void close();

  /// Whether the StateManager is closed.
  bool get isClosed;
}

/// A class that manages the state of the application.
abstract class Pipe<State extends Message>
    implements MessageEmitter<State>, EventHandler, Closable, EventTransformer {
  /// The socket channel.
  final WebSocketChannel _webSocketChannel;

  /// The MQTT client.
  late MQTTClient _mqttClient;

  /// The message to be sent to the MQTT broker.
  late MqttMessage _message;

  /// The subscription to the socket channel.
  late StreamSubscription? _subscription;

  /// The handlers for the events.
  final _handlers = <String, EventCallback>{};

  /// Whether the StateManager is closed.
  bool _isClosed = false;

  /// The current state.
  State _state;

  /// The current event.
  Event? _event;

  /// Override the state getter.
  @override
  State get state => _state;

  /// Override the event getter.
  @override
  Event? get event => _event;

  /// Override the isClosed getter.
  @override
  bool get isClosed => _isClosed;

  Pipe(this._webSocketChannel, {required State initialState})
      : _state = initialState {
    /// Initialize the MQTT client.
    _mqttClient = MQTTClient.defaultClient();

    /// Listen to the stream of the socket channel.
    _subscription = _webSocketChannel.stream.listen(handle, onDone: close);

    /// Set default handlers for the events.
    ///
    /// Close the pipe when the socket is closed.
    on('close', _close);

    /// Stop the pipe when the stop event is received.
    on('stop', _stop);

    /// Start the mqtt service when the start event is received.
    on('startMQTTService', _startMQTTService);

    /// Stop the mqtt service when the stop event is received.
    on('stopMQTTService', _stopMQTTService);
  }

  /// method that closes the pipe.
  void _close(Event event) => close();

  /// method that stops the pipe.
  void _stop(Event event) {
    stdout.writeln('Stopping the pipe...');
  }

  /// method that stops the MQTT service.
  void _stopMQTTService(Event event) => _mqttClient.disconnect();

  /// method that starts the MQTT service.
  void _startMQTTService(Event event) {
    /// Connect to the MQTT broker.
    if (_mqttClient.isConnected) return;

    this._mqttClient = MQTTClient(
      broker: event.getStringParam('brokerHost'),
      port: event.getIntParam('brokerPort'),
      topic: event.getStringParam('brokerTopic'),
    );
    unawaited(_mqttClient.connect());
  }

  /// method that registers a handler for an event.
  @override
  void on(String eventKey, EventCallback callback) {
    if (_handlers.containsKey(eventKey)) {
      throw StateError('Event $event is duplicated.');
    }

    _handlers[eventKey] = callback;
  }

  /// method that registers a handler for an event that repeats every duration.
  @override
  void loop(String eventKey, EventCallback callback) {
    if (_handlers.containsKey(eventKey)) {
      throw StateError('Event $event is duplicated.');
    }

    _handlers[eventKey] = (event) async {
      while (this.event == event && !isClosed) {
        callback(event);
        await Future.delayed(event.duration);
      }
    };
  }

  /// method that registers a handler for an event that repeats times every duration.
  @override
  void repeat(String eventKey, EventCallback callback) {
    if (_handlers.containsKey(eventKey)) {
      throw StateError('Event $event is duplicated.');
    }

    _handlers[eventKey] = (event) async {
      final times = event.getIntParam('times', defaultValue: 1);

      if (times <= 0) {
        throw StateError('Times must be greater than 0.');
      }

      for (var i = 0; i < times; i++) {
        callback(event);
        await Future.delayed(event.duration);
      }
    };
  }

  /// method that handles an event.
  @override
  void handle(event) {
    final newEvent = Event.fromJson(json.decode(event));

    if (newEvent == _event) {
      return;
    }

    final handler = _handlers[newEvent.event];

    if (handler != null) {
      _event = newEvent;

      stdout.writeln('Handling event ${newEvent.event}...');
      handler(newEvent);
    } else {
      throw StateError('Event ${newEvent.event} is not handled.');
    }
  }

  /// method that emits a new state.
  @override
  void emit(State state) {
    if (isClosed) {
      throw StateError('Cannot emit state after closing the pipe.');
    }

    _state = state;

    try {
      _sendState(state);
    } catch (e) {
      throw StateError('Cannot send state to the MQTT broker.');
    }
  }

  /// method that sends the state to the socket channel.
  void _sendState(State state) {
    try {
      _webSocketChannel.sink.add(json.encode(state.toJson()));
      _sendToMQTTBroker(state.format());
    } catch (e) {
      stdout.writeln('Cannot send state to the socket channel - skipping. $e');
    }
  }

  /// method that sends the state to the MQTT broker.
  void _sendToMQTTBroker(Map<String, dynamic> values) {
    if (!_mqttClient.isConnected) {
      return;
    }

    if (_event != null) {
      _message = MqttMessage.fromEvent(_event!);
    }

    final message = _message.copyWith(values: {...values});

    try {
      _mqttClient.publish(_mqttClient.topic, json.encode(message));
    } catch (e) {
      stdout.writeln('Cannot send message to the MQTT broker - skipping. $e');
    }
  }

  /// method that closes the StateManager.
  @override
  void close() {
    if (isClosed) {
      return;
    }
    stdout.writeln('Closing the pipe...');
    _isClosed = true;
    _subscription?.cancel();
    _webSocketChannel.sink.close();
    _mqttClient.disconnect();
    stdout.writeln('Pipe closed.');
  }
}
