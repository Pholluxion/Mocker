import 'package:shared/shared.dart';

abstract class UserRepository {
  User get user;
  List<Device> get devices;
  Future<User> signIn(String userName, String password);
  Future<List<Device>> getDevices(int userId);
  void signOut();
}

class UserException implements Exception {
  UserException(this.message);

  final String message;

  @override
  String toString() => message;
}
