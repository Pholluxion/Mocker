class Model {
  final int modelId;
  final String modelName;
  final String type;
  final String creationDate;
  final List<ModelProperty> modelProperties;

  Model({
    required this.modelId,
    required this.modelName,
    required this.type,
    required this.creationDate,
    required this.modelProperties,
  });

  factory Model.empty() {
    return Model(
      modelId: 0,
      modelName: '',
      type: '',
      creationDate: '',
      modelProperties: [],
    );
  }

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      modelId: json['modelId'],
      modelName: json['modelName'],
      type: json['type'],
      creationDate: json['creationDate'],
      modelProperties: (json['modelProperties'] as List).map((property) => ModelProperty.fromJson(property)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'modelName': modelName,
      'type': type,
      'creationDate': creationDate,
      'modelProperties': modelProperties.map((property) => property.toJson()).toList(),
    };
  }
}

class ModelProperty {
  final int modelPropertyId;
  final String name;
  final String value;

  ModelProperty({
    required this.modelPropertyId,
    required this.name,
    required this.value,
  });

  factory ModelProperty.fromJson(Map<String, dynamic> json) {
    return ModelProperty(
      modelPropertyId: json['modelPropertyId'],
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelPropertyId': modelPropertyId,
      'name': name,
      'value': value,
    };
  }
}
