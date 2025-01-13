import 'dart:convert';
import 'dart:io';

import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:server/server.dart';
import 'package:uuid/uuid.dart';

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv6;
  final port = int.parse(Platform.environment['SERVER_PORT'] ?? '8090');

  final router = Router();

  router.webSocket(
    '/distribution',
    (webSocket) => DistributionPipe(webSocket),
  );

  router.get(
    '/definitions',
    (request) => Response.ok(
      headers: {'Content-Type': 'application/json'},
      json.encode(
        [
          ...continuousDefinitions.map((e) => e.toJson()),
          ...discreteDefinitions.map((e) => e.toJson()),
        ],
      ),
    ),
  );

  final overrideHeaders = {
    ACCESS_CONTROL_ALLOW_ORIGIN: '*',
    'Content-Type': 'application/json;charset=utf-8',
  };

  var handler = const Pipeline().addMiddleware(corsHeaders(headers: overrideHeaders)).addHandler(router.call);

  final server = await shelf_io.serve(handler, ip, port);
  print('Server listening on ${ip.address}:${server.port}');
}

final List<Document> continuousDefinitions = [
  Document(
    id: Uuid().v4(),
    name: 'normal',
    path: '/continuous/normal',
    description: 'Parameters are mean and standard deviation (mu, sigma) ',
    parameters: [
      Param(key: 'mu', value: '0'),
      Param(key: 'sigma', value: '1'),
      Param(key: 'name', value: 'normal-continuous'),
    ],
  ),
  Document(
    id: Uuid().v4(),
    name: 'uniform',
    path: '/continuous/uniform',
    description: 'Parameters are lower and upper bounds (a, b)',
    parameters: [
      Param(key: 'a', value: '0'),
      Param(key: 'b', value: '1'),
      Param(key: 'name', value: 'uniform-continuous'),
    ],
  ),
  Document(
    id: Uuid().v4(),
    name: 'exponential',
    path: '/continuous/exponential',
    description: 'Parameters are lambda (lambda)',
    parameters: [
      Param(key: 'lambda', value: '1'),
      Param(key: 'name', value: 'exponential-continuous'),
    ],
  )
];

final List<Document> discreteDefinitions = [
  Document(
    id: Uuid().v4(),
    name: 'bernoulli',
    path: '/discrete/bernoulli',
    description: 'Parameters are probability of success (p)',
    parameters: [
      Param(key: 'p', value: '0.5'),
      Param(key: 'name', value: 'bernoulli-discrete'),
    ],
  ),
  Document(
    id: Uuid().v4(),
    name: 'binomial',
    path: '/discrete/binomial',
    description: 'Parameters are number of trials and probability of success (n, p)',
    parameters: [
      Param(key: 'n', value: '10'),
      Param(key: 'p', value: '0.5'),
      Param(key: 'name', value: 'binomial-discrete'),
    ],
  ),
  Document(
    id: Uuid().v4(),
    name: 'poisson',
    path: '/discrete/poisson',
    description: 'Parameters are lambda (lambda) ',
    parameters: [
      Param(key: 'lambda', value: '1'),
      Param(key: 'name', value: 'poisson-discrete'),
    ],
  ),
  Document(
    id: Uuid().v4(),
    name: 'uniform',
    path: '/discrete/uniform',
    description: 'Parameters are lower and upper bounds (a, b)',
    parameters: [
      Param(key: 'a', value: '0'),
      Param(key: 'b', value: '1'),
      Param(key: 'name', value: 'uniform-discrete'),
    ],
  )
];
