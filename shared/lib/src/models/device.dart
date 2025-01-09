import 'package:shared/src/models/model.dart';

class Device {
  final int deviceId;
  final String deviceName;
  final String creationDate;
  final Model model;
  final List<DeviceProperty> deviceProperties;

  Device({
    required this.deviceId,
    required this.deviceName,
    required this.creationDate,
    required this.model,
    required this.deviceProperties,
  });

  factory Device.empty() {
    return Device(
      deviceId: 0,
      deviceName: '',
      creationDate: '',
      model: Model.empty(),
      deviceProperties: [],
    );
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      creationDate: json['creationDate'],
      model: Model.fromJson(json['model']),
      deviceProperties:
          (json['deviceProperties'] as List).map((property) => DeviceProperty.fromJson(property)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'creationDate': creationDate,
      'model': model.toJson(),
      'deviceProperties': deviceProperties.map((property) => property.toJson()).toList(),
    };
  }
}

class DeviceProperty {
  final int devicePropertyId;
  final String name;
  final String value;

  DeviceProperty({
    required this.devicePropertyId,
    required this.name,
    required this.value,
  });

  factory DeviceProperty.fromJson(Map<String, dynamic> json) {
    return DeviceProperty(
      devicePropertyId: json['devicePropertyId'],
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'devicePropertyId': devicePropertyId,
      'name': name,
      'value': value,
    };
  }
}
