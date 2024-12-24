import 'package:shared/src/models/models.dart';
import 'package:shared/src/utils/utils.dart';
import 'package:uuid/uuid.dart';

class MqttMessage {
  final bool alert;
  final String id;
  final String deviceUUID;
  final String status;
  final String topic;
  final String timestamp;
  final Map<String, dynamic> values;

  MqttMessage({
    required this.deviceUUID,
    required this.topic,
    this.id = '',
    this.status = 'OK',
    this.alert = false,
    this.timestamp = '',
    this.values = const {},
  });

  factory MqttMessage.fromEvent(Event event) {
    return MqttMessage(
      deviceUUID: event.getStringParam('deviceUUID'),
      topic: event.getStringParam('topic'),
      status: event.getStringParam('status'),
      alert: event.getBoolParam('alert'),
    );
  }

  factory MqttMessage.fromJson(Map<String, dynamic> json) => MqttMessage(
        id: json['id'] as String? ?? Uuid().v4(),
        deviceUUID: json['deviceUUID'] as String,
        status: json['status'] as String,
        alert: json['alert'] as bool,
        topic: json['topic'] as String,
        timestamp: json['timestamp'] as String? ?? '',
        values: json['values'] as Map<String, dynamic>? ?? {},
      );

  Map<String, dynamic> toJson() => {
        'id': Uuid().v4(),
        'deviceUUID': deviceUUID,
        'status': status,
        'alert': alert,
        'topic': topic,
        'timestamp': XDateTime.formatDateTime,
        'values': values,
      };

  MqttMessage copyWith({
    String? id,
    String? deviceUUID,
    String? status,
    bool? alert,
    String? topic,
    String? timestamp,
    Map<String, dynamic>? values,
  }) {
    return MqttMessage(
      id: id ?? this.id,
      deviceUUID: deviceUUID ?? this.deviceUUID,
      status: status ?? this.status,
      alert: alert ?? this.alert,
      topic: topic ?? this.topic,
      timestamp: timestamp ?? this.timestamp,
      values: values ?? this.values,
    );
  }
}
