class Document {
  final String id;
  final String name;
  final String path;
  final String description;
  final List<String> parameters;

  Document({
    required this.id,
    required this.path,
    required this.name,
    required this.description,
    required this.parameters,
  });

  factory Document.empty() => Document(
        id: '',
        path: '',
        name: '',
        description: '',
        parameters: [],
      );

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      parameters: List<String>.from(json['parameters'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'name': name,
        'description': description,
        'parameters': parameters,
      };
}
