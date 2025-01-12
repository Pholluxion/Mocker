import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mocker/data/repository/mock.repository.dart';
import 'package:shared/shared.dart';

import 'package:mocker/domain/domain.dart';

class MockCubit extends Cubit<MockState> {
  MockCubit(
    this.endpoint,
    this._docsRepository,
  )   : _mockRepository = MockRepositoryImpl(uri: Uri.parse(endpoint)),
        super(const MockState()) {
    _subscription = _mockRepository.getData().listen(
      (event) {
        _buffer.addAll(event);
      },
    );
  }

  final DocsRepository _docsRepository;
  final MockRepository _mockRepository;
  final String endpoint;

  late StreamSubscription _subscription;
  final List<Data> _buffer = [];

  bool get isBufferEmpty => _buffer.isEmpty;

  List<Data> getDataByName(String name) => _buffer.where((e) => e.name == name).toList();

  List<Data> get buffer => _buffer;

  Stream<List<Data>> getData() => _mockRepository.getData();

  @override
  Future<void> close() {
    _mockRepository.close();
    _subscription.cancel();
    return super.close();
  }

  void add() {
    final raw = json.encode(state.getMock);
    _mockRepository.sendData(raw);
  }

  void clear() {
    stop();
    clearBuffer();
    emit(MockState(docs: state.docs));
  }

  void clearBuffer() {
    _buffer.clear();
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

  void setName(String name) {
    emit(state.copyWith(name: name));
  }

  void setHandler(String handler) {
    emit(state.copyWith(handler: handler));
  }

  void addFunction(Document doc) {
    final function = FunctionModel(
      handler: doc.path,
      parameters: doc.parameters.map((e) => Param(key: e, value: '')).toList(),
    );

    emit(state.copyWith(functions: [...state.functions, function]));
  }

  void addParameters(List<Param> parameters) {
    emit(state.copyWith(parameters: parameters));
  }

  void setMqtt(bool mqtt) {
    emit(state.copyWith(mqtt: mqtt));
  }

  void setIntervalMs(int intervalMs) {
    emit(state.copyWith(intervalMs: intervalMs));
  }

  void setDevice(Device device) {
    emit(state.copyWith(device: device, name: device.deviceName));
  }

  void setDescription(String description) {
    emit(state.copyWith(description: description));
  }

  void removeFunction(String hdlr) {
    final functions = state.functions.where((fn) => fn.handler != hdlr).toList();
    emit(state.copyWith(functions: functions));
  }

  void removeParam(Param param) {
    final parameters = state.parameters.where((e) => e.key != param.key).toList();
    emit(state.copyWith(parameters: parameters));
  }

  void updateFunctionParam(String handler, Param param) {
    final functions = state.functions.map((fn) {
      if (fn.handler == handler) {
        final parameters = fn.parameters.map((p) => p.key == param.key ? param : p).toList();
        return fn.copyWith(parameters: parameters);
      }
      return fn;
    }).toList();

    emit(state.copyWith(functions: functions));
  }

  void updateFunction(FunctionModel function) {
    final functions = state.functions.map((fn) => fn.handler == function.handler ? function : fn).toList();
    emit(state.copyWith(functions: functions));
  }

  void stop() {
    final raw = json.encode(state.getStopMock);
    _mockRepository.sendData(raw);
  }
}

class MockState extends Equatable {
  final bool mqtt;
  final String id;
  final String name;
  final String path;
  final String handler;
  final String description;
  final int intervalMs;
  final Device? device;
  final List<Document> docs;
  final List<Param> parameters;
  final List<FunctionModel> functions;

  const MockState({
    this.device,
    this.id = '',
    this.name = '',
    this.path = '',
    this.description = '',
    this.handler = '',
    this.mqtt = false,
    this.intervalMs = 1000,
    this.docs = const <Document>[],
    this.parameters = const <Param>[],
    this.functions = const <FunctionModel>[],
  });

  MockState copyWith({
    bool? mqtt,
    int? intervalMs,
    String? id,
    String? path,
    String? name,
    String? handler,
    String? description,
    Device? device,
    List<Document>? docs,
    List<Param>? parameters,
    List<FunctionModel>? functions,
  }) {
    return MockState(
      id: id ?? this.id,
      path: path ?? this.path,
      mqtt: mqtt ?? this.mqtt,
      docs: docs ?? this.docs,
      name: name ?? this.name,
      device: device ?? this.device,
      functions: functions ?? this.functions,
      description: description ?? this.description,
      intervalMs: intervalMs ?? this.intervalMs,
      parameters: parameters ?? this.parameters,
    );
  }

  Mock get getMock {
    return Mock(
      name: device?.deviceName ?? name,
      handler: 'mux',
      functions: functions,
      intervalMs: intervalMs,
      mqtt: mqtt,
      parameters: [
        ...getDeviceParams,
      ],
    );
  }

  Mock get getStopMock {
    return Mock(
      name: name,
      mqtt: mqtt,
      handler: 'stop',
      functions: [],
      parameters: [],
      intervalMs: intervalMs,
    );
  }

  Device get getDevice {
    return device ?? Device.empty();
  }

  (bool, FunctionModel?) getFunction(String hdlr) {
    final fnExists = functions.any((fn) => fn.handler == hdlr);
    if (!fnExists) {
      return (false, null);
    }
    final fn = functions.firstWhere((fn) => fn.handler == hdlr);
    return (true, fn);
  }

  bool validateFunctionParams(String hdlr) {
    return functions.any((fn) => fn.handler == hdlr && fn.parameters.every((p) => p.value.isNotEmpty));
  }

  List<Param> get getDeviceParams {
    return [
      Param(key: 'deviceUUID', value: getDevice.deviceId.toString()),
      Param(key: 'topic', value: name),
      Param(key: 'status', value: 'OK'),
      Param(key: 'alert', value: 'false'),
    ];
  }

  @override
  List<Object?> get props => [
        id,
        path,
        name,
        mqtt,
        docs,
        device,
        handler,
        functions,
        intervalMs,
        parameters,
        description,
      ];
}
