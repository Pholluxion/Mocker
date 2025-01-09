import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:mocker/domain/domain.dart';

class MockCubit extends Cubit<SimulationState> {
  MockCubit(this._docsRepository) : super(const SimulationState());

  static const serverPort = int.fromEnvironment('SERVER_PORT', defaultValue: 8090);
  static const serverHost = String.fromEnvironment('SERVER_HOST', defaultValue: 'localhost');

  final uri = Uri.parse('ws://$serverHost:$serverPort/continuous');
  late WebSocketChannel channel = WebSocketChannel.connect(uri);

  @override
  Future<void> close() {
    channel.sink.close();
    return super.close();
  }

  void connect() async {
    await channel.ready;

    final raw = json.encode(state.getMock);

    channel.sink.add(raw);
  }

  final DocsRepository _docsRepository;

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

  void setFunction(String function) {
    emit(state.copyWith(function: function));
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
    emit(state.copyWith(device: device));
  }

  void setDescription(String description) {
    emit(state.copyWith(description: description));
  }

  void updateParam(Param param) {
    final parameters = state.parameters.map((e) => e.key == param.key ? param : e).toList();
    emit(state.copyWith(parameters: parameters));
  }

  void stop() {
    final raw = json.encode(state.getStopMock);

    channel.sink.add(raw);
  }
}

class SimulationState extends Equatable {
  final bool mqtt;
  final String id;
  final String name;
  final String path;
  final String function;
  final String description;
  final int intervalMs;
  final Device? device;
  final List<Document> docs;
  final List<Param> parameters;

  const SimulationState({
    this.id = '',
    this.name = '',
    this.path = '',
    this.function = '',
    this.description = '',
    this.mqtt = false,
    this.intervalMs = 1000,
    this.docs = const <Document>[],
    this.parameters = const <Param>[],
    this.device,
  });

  SimulationState copyWith({
    bool? mqtt,
    int? intervalMs,
    String? id,
    String? path,
    String? name,
    String? function,
    String? description,
    Device? device,
    List<Document>? docs,
    List<Param>? parameters,
  }) {
    return SimulationState(
      id: id ?? this.id,
      path: path ?? this.path,
      mqtt: mqtt ?? this.mqtt,
      docs: docs ?? this.docs,
      name: name ?? this.name,
      device: device ?? this.device,
      function: function ?? this.function,
      description: description ?? this.description,
      intervalMs: intervalMs ?? this.intervalMs,
      parameters: parameters ?? this.parameters,
    );
  }

  Mock get getMock {
    return Mock(
      name: name,
      function: function,
      intervalMs: intervalMs,
      mqtt: mqtt,
      parameters: [
        ...parameters,
        ...getDeviceParams,
      ],
    );
  }

  Mock get getStopMock {
    return Mock(
      name: name,
      function: 'stop',
      intervalMs: intervalMs,
      mqtt: mqtt,
      parameters: [
        ...parameters,
      ],
    );
  }

  Device get getDevice {
    return device ?? Device.empty();
  }

  List<Param> get getDeviceParams {
    return [
      Param(key: 'deviceUUID', value: getDevice.deviceId.toString()),
      Param(key: 'topic', value: function),
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
        function,
        intervalMs,
        parameters,
        device,
        description,
      ];
}
