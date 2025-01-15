import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

import 'package:mocker/domain/domain.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._httpClient);

  final Dio _httpClient;

  User? _user;
  List<Device> _devices = [];

  @override
  Future<User> signIn(String userName, String password) async {
    try {
      final request = {
        'userName': userName,
        'password': password,
      };

      final response = await _httpClient.post('/admin/api/v1/user/validate', data: request);

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);

        if (!user.isValid) {
          throw UserException('Failed to sign in');
        }

        return user;
      } else {
        throw UserException('Failed to sign in');
      }
    } catch (e) {
      throw UserException(e.toString());
    }
  }

  @override
  void signOut() => _user = null;

  @override
  User get user => _user ?? User.empty();

  @override
  Future<List<Device>> getDevices(int userId) async {
    try {
      final response = await _httpClient.get('/admin/api/v1/devices/user/$userId');

      if (response.statusCode == 200) {
        final devices = (response.data as List).map((e) => Device.fromJson(e)).toList();

        _devices = devices;

        return devices;
      } else {
        throw UserException('Failed to get devices');
      }
    } catch (e) {
      throw UserException(e.toString());
    }
  }

  @override
  List<Device> get devices => _devices;
}
