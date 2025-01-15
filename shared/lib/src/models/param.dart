import 'package:uuid/uuid.dart';

class Param {
  final String id;
  final String key;
  final String value;

  Param({
    String? identifier,
    required this.key,
    required this.value,
  }) : id = identifier ?? const Uuid().v4();

  factory Param.fromJson(Map<String, dynamic> json) {
    return Param(
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  Param copyWith({
    String? key,
    String? value,
  }) {
    return Param(
      identifier: id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  String toString() {
    return 'Param{id: $id, key: $key, value: $value}';
  }
}
