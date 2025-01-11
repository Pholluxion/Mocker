import 'package:shared/src/models/models.dart';

class FunctionModel {
  final String handler;
  final List<Param> parameters;

  FunctionModel({
    required this.handler,
    required this.parameters,
  });

  FunctionModel copyWith({
    String? name,
    String? handler,
    List<Param>? parameters,
  }) {
    return FunctionModel(
      handler: handler ?? this.handler,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() => {
        'handler': handler,
        'parameters': parameters.map((e) => e.toJson()).toList(),
      };

  factory FunctionModel.fromJson(Map<String, dynamic> json) => FunctionModel(
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
