import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:shared/shared.dart';

import 'package:mocker/data/repository/mock.repository.dart';
import 'package:mocker/domain/domain.dart';

class MockCubit extends Cubit<MockState> {
  final String endpoint;
  final DocsRepository _docsRepository;
  final MockRepository _mockRepository;

  Device? device;

  MockCubit(
    this.endpoint,
    this._docsRepository,
  )   : _mockRepository = MockRepositoryImpl(uri: Uri.parse(endpoint)),
        super(const MockState());

  Stream<Data> getDataByName(String name) {
    return _mockRepository.getData().expand((list) => list).where((data) => data.name == name);
  }

  Stream<List<Data>> getData() => _mockRepository.getData();

  @override
  Future<void> close() {
    _mockRepository.close();
    return super.close();
  }

  void add() {
    final raw = json.encode(state.getMock);
    _mockRepository.sendData(raw);
  }

  void clear() {
    stop();
    emit(MockState(docs: state.docs));
  }

  Future<void> getDocs() async {
    try {
      final docs = await _docsRepository.getDocs();

      emit(state.copyWith(docs: docs));
    } on DocsException catch (_) {
      emit(state.copyWith(docs: <Document>[]));
    } catch (e) {
      emit(state.copyWith(docs: <Document>[]));
    }
  }

  void setId(String id) {
    emit(state.copyWith(id: id));
  }

  void setPath(String path) {
    emit(state.copyWith(path: path));
  }

  void setHandler(String handler) {
    emit(state.copyWith(handler: handler));
  }

  bool toggleFunctionState(String name) {
    final isValidName = validateRepeatParam(name);

    if (!isValidName) {
      return false;
    }

    final functions = state.functions.map(
      (fn) {
        if (fn.getStringParam('name') == name) {
          return fn.copyWith(enabled: !fn.enabled);
        }
        return fn;
      },
    ).toList();

    emit(state.copyWith(functions: functions));

    add();

    return true;
  }

  bool validateRepeatParam(String name) {
    final count = state.functions.where((fn) => fn.getStringParam('name') == name).length;

    if (count == 1) {
      return true;
    }

    return false;
  }

  void addFunction(Document doc) {
    final name = doc.toRunner.getStringParam('name');
    final random = Random().nextInt(1000);
    final newName = '$name-$random';
    final newFn = doc.toRunner.copyWith(
        parameters: doc.parameters.map((p) {
      if (p.key == 'name') {
        return Param(key: p.key, value: newName);
      }
      return p;
    }).toList());

    emit(state.copyWith(functions: [...state.functions, newFn]));
  }

  void addDeviceParams(Device device) {
    device = device;
    updateOrAddParam(state.getParam('deviceUUID').copyWith(value: device.deviceId.toString()));
    updateOrAddParam(state.getParam('deviceName').copyWith(value: device.deviceName));
    updateOrAddParam(state.getParam('topic').copyWith(value: 'mocker'));
    updateOrAddParam(state.getParam('status').copyWith(value: 'OK'));
    updateOrAddParam(state.getParam('alert').copyWith(value: 'true'));
  }

  void addParameters(List<Param> parameters) {
    emit(state.copyWith(parameters: parameters));
  }

  void addParam(Param param) {
    emit(state.copyWith(parameters: [...state.parameters, param]));
  }

  void removeParamById(String id) {
    final parameters = state.parameters.where((p) => p.id != id).toList();
    emit(state.copyWith(parameters: parameters));
  }

  void removeParamByKey(String key) {
    final parameters = state.parameters.where((p) => p.key != key).toList();
    emit(state.copyWith(parameters: parameters));
  }

  void updateOrAddParam(Param param) {
    final parameters = state.parameters.map((p) => p.id == param.id ? param : p).toList();

    if (!state.parameters.any((p) => p.id == param.id)) {
      emit(state.copyWith(parameters: [...state.parameters, param]));
    } else {
      emit(state.copyWith(parameters: parameters));
    }
  }

  void updateOrAddCustomParam(Param param) {
    final customParameters = state.customParameters.map((p) => p.id == param.id ? param : p).toList();

    if (!state.customParameters.any((p) => p.id == param.id)) {
      emit(state.copyWith(customParameters: [...state.customParameters, param]));
    }

    emit(state.copyWith(customParameters: customParameters));
  }

  void addCustomParam(Param param) {
    emit(state.copyWith(customParameters: [...state.customParameters, param]));
  }

  void removeCustomParam(String id) {
    final customParameters = state.customParameters.where((p) => p.id != id).toList();
    emit(state.copyWith(customParameters: customParameters));
  }

  void removeCustomParamByKey(String key) {
    final customParameters = state.customParameters.where((p) => p.key != key).toList();
    emit(state.copyWith(customParameters: customParameters));
  }

  void setMqtt(bool mqtt) {
    emit(state.copyWith(mqtt: mqtt));
  }

  void setIntervalMs(String intervalMs) {
    final value = int.tryParse(intervalMs) ?? 1000;
    emit(state.copyWith(intervalMs: value));
  }

  void setDescription(String description) {
    emit(state.copyWith(description: description));
  }

  void removeFunction(String name) {
    final functions = state.functions.where((fn) => fn.getStringParam('name') != name).toList();
    emit(state.copyWith(functions: functions));

    if (functions.isEmpty) {
      stop();
    }

    add();
  }

  void removeParam(Param param) {
    final parameters = state.parameters.where((e) => e.key != param.key).toList();
    emit(state.copyWith(parameters: parameters));
  }

  void updateFunctionParam(Param param) {
    final functions = state.functions.map((fn) {
      final params = fn.parameters.map((p) => p.id == param.id ? param : p).toList();
      return fn.copyWith(parameters: params);
    }).toList();
    emit(state.copyWith(functions: functions));
  }

  void updateFunction(Runner function) {
    final functions = state.functions
        .map((fn) => fn.getStringParam('name') == function.getStringParam('name') ? function : fn)
        .toList();
    emit(state.copyWith(functions: functions));
  }

  void stop() {
    final raw = json.encode(state.getStopMock);
    _mockRepository.sendData(raw);
  }

  void saveYaml() async {
    String yamlFile = Yaml.jsonToYaml(state.getMock.toJson());

    List<int> yamlFileBytes = utf8.encode(yamlFile);
    Uint8List yamlAsBytes = Uint8List.fromList(yamlFileBytes);

    await FileSaver.instance.saveFile(
      name: 'mock',
      bytes: yamlAsBytes,
      ext: 'yaml',
      mimeType: MimeType.text,
    );
  }

  void loadYaml() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;

      final yamlString = utf8.decode(fileBytes!);

      final mock = Mock.fromYaml(yamlString);

      emit(
        state.copyWith(
          mqtt: mock.mqtt,
          intervalMs: mock.intervalMs,
          functions: mock.functions,
          parameters: mock.parameters,
        ),
      );

      add();
    } else {
      return;
    }
  }
}

class MockState extends Equatable {
  final int intervalMs;
  final bool mqtt;
  final String path;
  final String handler;
  final List<Document> docs;
  final List<Param> parameters;
  final List<Param> customParameters;
  final List<Runner> functions;

  const MockState({
    this.path = '',
    this.handler = '',
    this.mqtt = false,
    this.intervalMs = 1000,
    this.docs = const <Document>[],
    this.parameters = const <Param>[],
    this.functions = const <Runner>[],
    this.customParameters = const <Param>[],
  });

  MockState copyWith({
    int? intervalMs,
    bool? mqtt,
    String? id,
    String? path,
    String? handler,
    String? description,
    List<Document>? docs,
    List<Param>? parameters,
    List<Param>? customParameters,
    List<Runner>? functions,
  }) {
    return MockState(
      mqtt: mqtt ?? this.mqtt,
      path: path ?? this.path,
      docs: docs ?? this.docs,
      handler: handler ?? this.handler,
      functions: functions ?? this.functions,
      intervalMs: intervalMs ?? this.intervalMs,
      parameters: parameters ?? this.parameters,
      customParameters: customParameters ?? this.customParameters,
    );
  }

  Mock get getMock {
    return Mock(
      mqtt: mqtt,
      handler: 'mux',
      functions: functions,
      parameters: [
        ...parameters,
        ...customParameters,
      ],
      intervalMs: intervalMs,
    );
  }

  Mock get getStopMock {
    return Mock(
      mqtt: mqtt,
      handler: 'stop',
      functions: [],
      parameters: [],
      intervalMs: intervalMs,
    );
  }

  bool get isDeviceParamsValid {
    return parameters.every((p) => p.value.isNotEmpty);
  }

  bool get isFunctionParamsValid {
    return functions.every((fn) => fn.parameters.every((p) => p.value.isNotEmpty));
  }

  bool get isDeviceIdPresent {
    return parameters.any((p) => p.key == 'deviceUUID' && p.value.isNotEmpty);
  }

  bool get canEdit {
    return functions.any((fn) => fn.enabled);
  }

  String get getDeviceName {
    return parameters.firstWhere((p) => p.key == 'deviceName', orElse: () => Param(key: '', value: '')).value;
  }

  Param getParam(String key) {
    return parameters.firstWhere(
      (p) => p.key == key,
      orElse: () => Param(key: key, value: ''),
    );
  }

  (bool, Runner?) getFunction(String name) {
    final fnExists = functions.any((fn) => fn.getStringParam('name') == name);
    if (!fnExists) {
      return (false, null);
    }
    final fn = functions.firstWhere((fn) => fn.getStringParam('name') == name);
    return (true, fn);
  }

  bool validateFunctionParams(String name) {
    return functions.any(
      (fn) {
        return fn.getStringParam('name') == name &&
            fn.parameters.every(
              (p) => p.value.isNotEmpty,
            );
      },
    );
  }

  @override
  List<Object?> get props => [
        mqtt,
        path,
        docs,
        handler,
        functions,
        intervalMs,
        parameters,
        customParameters,
      ];
}
