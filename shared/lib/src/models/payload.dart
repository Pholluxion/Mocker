import 'package:shared/src/models/models.dart';
import 'package:shared/src/utils/utils.dart';
import 'package:uuid/uuid.dart';

class Payload {
  final bool alert;
  final String id;
  final String deviceUUID;
  final String status;
  final String topic;
  final String timeStamp;
  final Map<String, dynamic> values;

  Payload({
    required this.deviceUUID,
    required this.topic,
    this.id = '',
    this.status = 'OK',
    this.alert = false,
    this.timeStamp = '',
    this.values = const {},
  });

  factory Payload.fromMock(Mock mock) {
    return Payload(
      deviceUUID: mock.getStringParam('deviceUUID'),
      topic: mock.getStringParam('topic'),
      status: mock.getStringParam('status'),
      alert: mock.getBoolParam('alert'),
      timeStamp: XDateTime.formatDateTime,
    );
  }

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        id: json['id'] as String? ?? Uuid().v4(),
        deviceUUID: json['deviceUUID'] as String,
        status: json['status'] as String,
        alert: json['alert'] as bool,
        topic: json['topic'] as String,
        timeStamp: json['timeStamp'] as String? ?? '',
        values: json['values'] as Map<String, dynamic>? ?? {},
      );

  Map<String, dynamic> toJson() => {
        'id': Uuid().v4(),
        'deviceUUID': deviceUUID,
        'status': status,
        'alert': alert,
        'topic': topic,
        'timeStamp': XDateTime.formatDateTime,
        'values': values,
      };

  Payload copyWith({
    String? id,
    String? deviceUUID,
    String? status,
    bool? alert,
    String? topic,
    String? timeStamp,
    Map<String, dynamic>? values,
  }) {
    return Payload(
      id: id ?? this.id,
      deviceUUID: deviceUUID ?? this.deviceUUID,
      status: status ?? this.status,
      alert: alert ?? this.alert,
      topic: topic ?? this.topic,
      timeStamp: timeStamp ?? this.timeStamp,
      values: values ?? this.values,
    );
  }
}
