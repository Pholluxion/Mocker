import 'models.dart';

/// An mock that can be emitted.
class Mock {
  /// The handler of the mock.
  final String handler;

  /// The list of functions that should be called.
  final List<FunctionModel> functions;

  /// The name of the mock.
  final String name;

  /// The duration of the mock.
  final int intervalMs;

  /// Whether the mock should be sent to the MQTT client.
  final bool mqtt;

  /// The payload of the mock.
  final List<Param> parameters;

  Mock({
    required this.handler,
    required this.name,
    required this.functions,
    required this.intervalMs,
    required this.parameters,
    required this.mqtt,
  });

  Duration get duration => Duration(milliseconds: intervalMs);

  factory Mock.empty() => Mock(
        handler: '',
        name: '',
        functions: [],
        intervalMs: 0,
        mqtt: false,
        parameters: [],
      );

  factory Mock.fromJson(Map<String, dynamic> json) => Mock(
        handler: json['handler'] as String,
        name: json['name'] as String,
        functions: (json['functions'] as List<dynamic>?)?.map((e) => FunctionModel.fromJson(e)).toList() ?? [],
        intervalMs: json['intervalMs'] as int,
        mqtt: json['mqtt'] as bool,
        parameters: (json['parameters'] as List<dynamic>?)?.map((e) => Param.fromJson(e)).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'handler': handler,
        'name': name,
        'intervalMs': intervalMs,
        'functions': functions,
        'mqtt': mqtt,
        'parameters': parameters,
      };

  Mock copyWith({
    int? intervalMs,
    bool? mqtt,
    String? name,
    String? handler,
    List<Param>? parameters,
    List<FunctionModel>? functions,
  }) {
    return Mock(
      name: name ?? this.name,
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
