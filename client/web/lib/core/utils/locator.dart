import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:mocker/data/data.dart';
import 'package:mocker/domain/domain.dart';

void setupLocator() {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  GetIt.I.registerSingleton<Dio>(dio);
  GetIt.I.registerSingleton<UserRepository>(UserRepositoryImpl(GetIt.I.get<Dio>()));
  GetIt.I.registerSingleton<DocsRepository>(DocsRepositoryImpl(GetIt.I.get<Dio>()));
}
