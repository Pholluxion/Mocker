import 'package:shared/src/models/models.dart';

class Runner {
  final String handler;
  final List<Param> parameters;

  Runner({
    required this.handler,
    required this.parameters,
  });

  Runner copyWith({
    String? name,
    String? handler,
    List<Param>? parameters,
  }) {
    return Runner(
      handler: handler ?? this.handler,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() => {
        'handler': handler,
        'parameters': parameters.map((e) => e.toJson()).toList(),
      };

  factory Runner.fromJson(Map<String, dynamic> json) => Runner(
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
}
