import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:mocker/data/data/data.model.dart';
import 'package:mocker/domain/domain.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MockRepositoryImpl implements MockRepository {
  final Uri uri;

  late final WebSocketChannel _channel;
  late final StreamSubscription _subscription;
  late final BehaviorSubject<List<Data>> _dataStream;

  MockRepositoryImpl({
    required this.uri,
  })  : _channel = WebSocketChannel.connect(uri),
        _dataStream = BehaviorSubject<List<Data>>.seeded([]) {
    _subscription = _channel.stream.listen((event) {
      final list = json.decode(event) as List<dynamic>;
      _dataStream.add(list.map((e) => DataModel.fromJson(e).entity).toList());
    });
  }

  @override
  Stream<List<Data>> getData() {
    return _dataStream.stream.asBroadcastStream();
  }

  @override
  void sendData(Object? data) async {
    try {
      await _channel.ready;
      _channel.sink.add(data);
    } on SocketException catch (e) {
      log(e.toString());
    } on WebSocketChannelException catch (e) {
      log(e.toString());
    }
  }

  @override
  void close() {
    _subscription.cancel();
    _channel.sink.close();
  }

  @override
  void connect() async {
    await _channel.ready;
  }
}
