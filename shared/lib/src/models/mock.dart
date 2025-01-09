import 'models.dart';

/// An mock that can be emitted.
class Mock {
  /// The name of the function that will be called.
  final String function;

  /// The name of the mock.
  final String name;

  /// The duration of the mock.
  final int intervalMs;

  /// Whether the mock should be sent to the MQTT client.
  final bool mqtt;

  /// The payload of the mock.
  final List<Param> parameters;

  Mock({
    required this.name,
    required this.function,
    required this.intervalMs,
    required this.parameters,
    required this.mqtt,
  });

  Duration get duration => Duration(milliseconds: intervalMs);

  factory Mock.empty() => Mock(
        name: '',
        function: '',
        intervalMs: 0,
        mqtt: false,
        parameters: [],
      );

  factory Mock.fromJson(Map<String, dynamic> json) => Mock(
        name: json['name'] as String,
        function: json['function'] as String,
        intervalMs: json['intervalMs'] as int,
        mqtt: json['mqtt'] as bool,
        parameters: (json['parameters'] as List<dynamic>?)?.map((e) => Param.fromJson(e)).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'intervalMs': intervalMs,
        'function': function,
        'mqtt': mqtt,
        'parameters': parameters,
      };

  Mock copyWith({
    String? name,
    String? function,
    int? intervalMs,
    List<Param>? parameters,
    bool? mqtt,
  }) {
    return Mock(
      name: name ?? this.name,
      function: function ?? this.function,
      intervalMs: intervalMs ?? this.intervalMs,
      parameters: parameters ?? this.parameters,
      mqtt: mqtt ?? this.mqtt,
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
