import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:server/server.dart';

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv6;
  final port = int.parse(Platform.environment['SERVER_PORT'] ?? '8090');

  final router = Router();

  router.webSocket(
    '/continuous',
    (webSocket) => ContinuousDistributionPipe(webSocket),
  );

  router.webSocket(
    '/discrete',
    (webSocket) => DiscreteDistributionPipe(webSocket),
  );

  router.webSocket('/step', (webSocket) => StepDistribution(webSocket));

  final server = await shelf_io.serve(router.call, ip, port);
  print('Server listening on ${ip.address}:${server.port}');
}
