import 'package:shared/shared.dart';

abstract class DocsRepository {
  Future<List<Document>> getDocs();
}

class DocsException implements Exception {
  DocsException(this.message);

  final String message;

  @override
  String toString() => message;
}
