import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

import 'package:mocker/domain/domain.dart';

class DocsRepositoryImpl implements DocsRepository {
  final Dio _httpClient;

  DocsRepositoryImpl(httpClient)
      : _httpClient = Dio(
          BaseOptions(
            baseUrl: 'http://localhost:8090',
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );
  @override
  Future<List<Document>> getDocs() async {
    try {
      final response = await _httpClient.get('/definitions');

      if (response.statusCode == 200) {
        final docs = (response.data as List).map((e) => Document.fromJson(e)).toList();

        return docs;
      } else {
        throw DocsException('Failed to get docs');
      }
    } catch (e) {
      throw DocsException(e.toString());
    }
  }
}
