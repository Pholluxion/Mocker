import 'package:shared/shared.dart';

import 'package:mocker/domain/domain.dart';

class DataModel {
  final String name;
  final dynamic value;

  DataModel(this.name, this.value);

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
        json['name'] as String,
        json['value'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };

  Data get entity => Data(name, value, XDateTime.formatDateTime);
}
