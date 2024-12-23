import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:server/src/pipe/pipe.dart';

extension XRouter on Router {
  void webSocket<T extends Pipe>(
    String path,
    T Function(WebSocketChannel) factory,
  ) {
    all(
      path,
      webSocketHandler(
        (WebSocketChannel webSocket) => factory(webSocket),
      ),
    );
  }
}

extension XDouble on double {
  double fix(int fractionDigits) {
    return double.parse(toStringAsFixed(fractionDigits));
  }
}
