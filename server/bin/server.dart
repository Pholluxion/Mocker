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
    '/continuous',
    (webSocket) => ContinuousDistributionPipe(webSocket),
  );

  router.webSocket(
    '/discrete',
    (webSocket) => DiscreteDistributionPipe(webSocket),
  );

  router.webSocket(
    '/step',
    (webSocket) => StepDistribution(webSocket),
  );

  router.get(
    '/definitions',
    (request) => Response.ok(
      headers: {'Content-Type': 'application/json'},
      json.encode(
        [
          ...continuousDefinitions.map((e) => e.toJson()),
          ...discreteDefinitions.map((e) => e.toJson()),
          ...stepDefinitions.map((e) => e.toJson()),
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
    path: '/continuous',
    description: 'Parameters are mean and standard deviation (mu, sigma) ',
    parameters: ['mu', 'sigma'],
  ),
  Document(
    id: Uuid().v4(),
    name: 'uniform',
    path: '/continuous',
    description: 'Parameters are lower and upper bounds (a, b)',
    parameters: ['a', 'b'],
  ),
  Document(
    id: Uuid().v4(),
    name: 'exponential',
    path: '/continuous',
    description: 'Parameters are lambda (lambda)',
    parameters: ['lambda'],
  )
];

final List<Document> discreteDefinitions = [
  Document(
    id: Uuid().v4(),
    name: 'bernoulli',
    path: '/discrete',
    description: 'Parameters are probability of success (p)',
    parameters: ['p'],
  ),
  Document(
    id: Uuid().v4(),
    name: 'binomial',
    path: '/discrete',
    description: 'Parameters are number of trials and probability of success (n, p)',
    parameters: ['n', 'p'],
  ),
  Document(
    id: Uuid().v4(),
    name: 'poisson',
    path: '/discrete',
    description: 'Parameters are lambda (lambda) ',
    parameters: ['lambda'],
  ),
  Document(
    id: Uuid().v4(),
    name: 'uniform',
    path: '/discrete',
    description: 'Parameters are lower and upper bounds (a, b)',
    parameters: ['a', 'b'],
  )
];

final List<Document> stepDefinitions = [
  Document(
    id: Uuid().v4(),
    name: 'step',
    path: '/step',
    description: 'Parameters are step size (step)',
    parameters: ['step'],
  ),
];
