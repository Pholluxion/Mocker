import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClient {
  final String broker;
  final int port;
  final String clientId;
  final String topic;
  late MqttServerClient _client;

  MQTTClient({
    required this.broker,
    required this.port,
    required this.topic,
    this.clientId = 'mocker_server',
  }) {
    _client = MqttServerClient(broker, clientId)
      ..port = port
      ..logging(on: false)
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed;
  }

  factory MQTTClient.defaultClient() {
    final host = Platform.environment['BROKER_HOST'] ?? 'mosquitto';
    final port = int.parse(Platform.environment['BROKER_PORT'] ?? '1883');
    return MQTTClient(broker: host, port: port, topic: 'device-messages');
  }

  MQTTClient copyWith({
    String? broker,
    int? port,
    String? clientId,
    String? topic,
  }) {
    return MQTTClient(
      broker: broker ?? this.broker,
      port: port ?? this.port,
      clientId: clientId ?? this.clientId,
      topic: topic ?? this.topic,
    );
  }

  bool get isConnected =>
      _client.connectionStatus != null ? _client.connectionStatus!.state == MqttConnectionState.connected : false;

  Future<void> connect({String? username, String? password}) async {
    _client.connectionMessage =
        MqttConnectMessage().withClientIdentifier(clientId).startClean().withWillQos(MqttQos.atLeastOnce);

    try {
      print('Connecting to MQTT broker...');
      final status = await _client.connect(username, password);
      if (status?.state == MqttConnectionState.connected) {
        print('Connected to MQTT broker.');
      } else {
        print('Connection failed: ${status?.state}');
        disconnect();
      }
    } catch (e) {
      print('Error connecting to MQTT broker');
      disconnect();
    }
  }

  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    print('Subscribing to topic $topic...');
    _client.subscribe(topic, qos);
    _client.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage>> messages) {
        final message = messages.first.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
        print('Received message: $payload from topic: ${messages.first.topic}');
      },
    );
  }

  void publish(
    String topic,
    String message, {
    MqttQos qos = MqttQos.atLeastOnce,
  }) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, qos, builder.payload!);
    print('Published message: $message to topic: $topic');
  }

  void disconnect() {
    if (!isConnected) return;

    print('Disconnecting from MQTT broker...');
    _client.disconnect();
  }

  // Callbacks
  void _onDisconnected() {
    print('Disconnected from MQTT broker.');
  }

  void _onConnected() {
    print('Connected to MQTT broker with client ID: $clientId');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }
}
