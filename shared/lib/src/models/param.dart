class Param {
  final String key;
  final String value;

  Param({required this.key, required this.value});

  factory Param.fromJson(Map<String, dynamic> json) {
    return Param(
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}
