import 'package:shared/shared.dart';

/// An mock that can be emitted.
class Mock {
  /// The handler of the mock.
  final String handler;

  /// The list of functions that should be called.
  final List<Runner> functions;

  /// The duration of the mock.
  final int intervalMs;

  /// Whether the mock should be sent to the MQTT client.
  final bool mqtt;

  /// The payload of the mock.
  final List<Param> parameters;

  Mock({
    required this.handler,
    required this.functions,
    required this.intervalMs,
    required this.parameters,
    required this.mqtt,
  });

  Duration get duration => Duration(milliseconds: intervalMs);

  factory Mock.empty() => Mock(
        handler: '',
        functions: [],
        intervalMs: 0,
        mqtt: false,
        parameters: [],
      );

  factory Mock.fromJson(Map<String, dynamic> json) => Mock(
        handler: json['handler'] as String,
        functions: (json['functions'] as List<dynamic>?)?.map((e) => Runner.fromJson(e)).toList() ?? [],
        intervalMs: json['intervalMs'] as int,
        mqtt: json['mqtt'] as bool,
        parameters: (json['parameters'] as List<dynamic>?)?.map((e) => Param.fromJson(e)).toList() ?? [],
      );

  factory Mock.fromYaml(String yaml) {
    return Mock.fromJson(Yaml.yamlToJson(yaml));
  }

  Map<String, dynamic> toJson() => {
        'handler': handler,
        'mqtt': mqtt,
        'intervalMs': intervalMs,
        'functions': functions,
        'parameters': parameters,
      };

  Mock copyWith({
    int? intervalMs,
    bool? mqtt,
    String? name,
    String? handler,
    List<Param>? parameters,
    List<Runner>? functions,
  }) {
    return Mock(
      mqtt: mqtt ?? this.mqtt,
      handler: handler ?? this.handler,
      functions: functions ?? this.functions,
      intervalMs: intervalMs ?? this.intervalMs,
      parameters: parameters ?? this.parameters,
    );
  }

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
