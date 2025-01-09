import 'dart:convert';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// YamlParser class
abstract class YamlParser {
  /// jsonToYaml method converts a json to yaml
  static String jsonToYaml(Map<String, dynamic> data) {
    final yamlEditor = YamlEditor('');
    final jsonMap = json.decode(json.encode(data));
    yamlEditor.update([], jsonMap);

    return yamlEditor.toString();
  }

  /// yamlToJson method converts a yaml to json
  static Map<String, dynamic> yamlToJson(String yaml) {
    final yamlMap = loadYaml(yaml);

    final jsonString = jsonEncode(yamlMap);

    return jsonDecode(jsonString);
  }
}
