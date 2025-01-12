import 'package:mocker/domain/domain.dart';

abstract class MockRepository {
  Stream<List<Data>> getData();
  void sendData(Object? data);
  void connect();
  void close();
}
