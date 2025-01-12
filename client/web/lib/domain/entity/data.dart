class Data {
  final String name;
  final dynamic value;
  final String timestamp;

  Data(this.name, this.value, this.timestamp);

  @override
  String toString() {
    return '$timestamp: [ 🤖 ] → { name: "$name", value: $value }';
  }
}
