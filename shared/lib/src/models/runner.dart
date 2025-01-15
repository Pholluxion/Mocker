import 'package:shared/src/models/models.dart';
import 'package:uuid/uuid.dart';

class Runner {
  final String id;
  final bool enabled;
  final String handler;
  final List<Param> parameters;

  Runner({
    String? identifier,
    required this.enabled,
    required this.handler,
    required this.parameters,
  }) : id = identifier ?? const Uuid().v4();

  Runner copyWith({
    bool? enabled,
    String? handler,
    List<Param>? parameters,
  }) {
    return Runner(
      identifier: id,
      enabled: enabled ?? this.enabled,
      handler: handler ?? this.handler,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'handler': handler,
        'parameters': parameters.map((e) => e.toJson()).toList(),
      };

  factory Runner.fromJson(Map<String, dynamic> json) => Runner(
        enabled: json['enabled'] as bool,
        handler: json['handler'] as String,
        parameters: (json['parameters'] as List<dynamic>).map((e) => Param.fromJson(e)).toList(),
      );

  /// get a parameter by key or return a new one with the key
  Param getParam(String key) {
    return parameters.firstWhere(
      (Param element) => element.key == key,
      orElse: () => Param(key: key, value: ''),
    );
  }

  int getIntParam(String key, {int defaultValue = 0}) {
    final param = getParam(key);
    final value = int.tryParse(param.value);

    if (param.value.isEmpty) {
      return defaultValue;
    }

    return value ?? defaultValue;
  }

  double getDoubleParam(String key, {double defaultValue = 0.0}) {
    final param = getParam(key);

    if (param.value.isEmpty) {
      return defaultValue;
    }

    final value = double.tryParse(param.value);

    return value ?? defaultValue;
  }

  String getStringParam(String key, {String defaultValue = ''}) {
    if (getParam(key).value.isEmpty) {
      return defaultValue;
    }

    return getParam(key).value;
  }

  bool getBoolParam(String key, {bool defaultValue = false}) {
    final param = getParam(key);

    if (param.value.isEmpty) {
      return defaultValue;
    }

    return param.value == 'true' ? true : defaultValue;
  }

  @override
  String toString() {
    return 'Runner{id: $id, enabled: $enabled, handler: $handler, parameters: $parameters}';
  }
}
