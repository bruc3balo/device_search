import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_search/search.dart';
import 'package:flutter/material.dart';

class BroadcastMyDevice {
  final String _tag;
  final String _nickname;

  late final HttpServer _server;
  late final StreamSubscription<HttpRequest> _httpResponseStreamSubscription;

  int get port => _server.port;

  String get address => _server.address.address;

  BroadcastMyDevice({
    required String tag,
    required String nickname,
  })  : _tag = tag,
        _nickname = nickname;

  void broadcast({
    required Function({
      required String tag,
      required String nickname,
    }) onDiscover,
  }) {
    _startHttpServer(onDiscover: onDiscover);
  }

  Future<void> _startHttpServer({
    required Function({
      required String tag,
      required String nickname,
    }) onDiscover,
  }) async {
    // Bind to all network interfaces (including Wi-Fi) on an available port
    _server = await HttpServer.bind(InternetAddress.anyIPv4, deviceBindPort);
    debugPrint(
      'Server running on: ${_server.address.address}:${_server.port}',
    );

    _httpResponseStreamSubscription = _server.listen(
      (request) => _onRequest(
        request: request,
        onDiscover: onDiscover,
      ),
    );
  }

  void _onRequest({
    required HttpRequest request,
    required Function({
      required String tag,
      required String nickname,
    }) onDiscover,
  }) {
    if (request.method != 'GET') return;

    Uri requestUri = request.uri;
    if (!requestUri.queryParameters.containsKey('tag')) return;
    if (!requestUri.queryParameters.containsKey('nickname')) return;

    String tag = requestUri.queryParameters['tag']!;
    String nickname = requestUri.queryParameters['nickname']!;

    request.response
      ..statusCode = HttpStatus.ok
      ..write(
        jsonEncode({
          'tag': _tag,
          'nickname': _nickname,
        }),
      )
      ..close();

    onDiscover(tag: tag, nickname: nickname);
  }

  void _stopHttpServer() {
    _server.close();
    _httpResponseStreamSubscription.cancel();
    debugPrint('Server stopped');
  }

  void dispose() {
    _stopHttpServer();
  }
}
