import 'models.dart';

/// An event that can be emitted.
class Event {
  /// The name of the event.
  final String event;

  /// The payload of the event.
  final List<Param> parameters;

  Event({required this.event, required this.parameters});

  Duration get duration =>
      Duration(milliseconds: getIntParam('duration', defaultValue: 1000));

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        event: json['event'] as String,
        parameters: (json['parameters'] as List<dynamic>?)
                ?.map((e) => Param.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {'event': event, 'parameters': parameters};

  /// Obtiene un parámetro por nombre. Devuelve un valor predeterminado si no se encuentra.
  Param getParam(String key) {
    return parameters.firstWhere(
      (Param element) => element.key == key,
      orElse: () => Param(key: key, value: ''),
    );
  }

  int getIntParam(String key, {int defaultValue = 0}) {
    final param = getParam(key);
    final value = int.tryParse(param.value);

    return value ?? defaultValue;
  }

  double getDoubleParam(String key, {double defaultValue = 0.0}) {
    final param = getParam(key);
    final value = double.tryParse(param.value);

    return value ?? defaultValue;
  }

  String getStringParam(String key, {String defaultValue = ''}) {
    return getParam(key).value;
  }

  bool getBoolParam(String key, {bool defaultValue = false}) {
    final param = getParam(key);
    return param.value == 'true' ? true : defaultValue;
  }
}
