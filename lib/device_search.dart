import 'dart:convert';
import 'dart:io';

import 'package:device_search/search.dart';
import 'package:flutter/material.dart';

class SearchDevices {
  final String _tag;
  final String _nickname;
  bool _isSearching = true;

  SearchDevices({
    required String tag,
    required String nickname,
  })  : _tag = tag,
        _nickname = nickname;

  bool get isSearching => _isSearching;

  void search({
    required Function({
      required String tag,
      required String nickname,
    }) onDiscover,
  }) {
    _discoverAndRequest(onDiscover: onDiscover);
  }

  Future<void> _discoverAndRequest({
    required Function({
      required String tag,
      required String nickname,
    }) onDiscover,
  }) async {
    // Discover local IP address range
    final interfaces = await NetworkInterface.list();

    List<InternetAddress> addresses = interfaces.expand((i) {
      return i.addresses.where((a) {
        return a.type == InternetAddressType.IPv4 && !a.isLoopback;
      });
    }).toList();

    for (InternetAddress a in addresses) {
      final String subnet =
          a.address.substring(0, a.address.lastIndexOf('.') + 1);
      debugPrint('Scanning network on: $subnet');

      // Scan possible IPs in the network
      List<Future<void>> futures = List.generate(255, (i) {
        if (!isSearching) return null;
        return i;
      }).where((i) => i != null).map((i) async {
        final ip = '$subnet$i';
        final url = Uri.parse(
          'http://$ip:$deviceBindPort?tag=$_tag&nickname=$_nickname',
        );
        debugPrint("Sending to ${url.toString()}");

        return await _sendDiscoverRequest(
          url: url,
          ip: ip,
          onDiscover: onDiscover,
        );
      }).toList();
      Future.wait(futures);
    }
  }

  Future<void> _sendDiscoverRequest({
    required Uri url,
    required String ip,
    required Function({
      required String tag,
      required String nickname,
    }) onDiscover,
  }) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(url);
      debugPrint("Sending to ${url.toString()}");
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final String responseBody =
            await response.transform(SystemEncoding().decoder).join();
        debugPrint('Response from $ip: $responseBody');

        Map<String, dynamic> body =
            jsonDecode(responseBody) as Map<String, dynamic>;
        onDiscover(
          tag: body['tag'],
          nickname: body['nickname'],
        );
      }

      client.close();
    } catch (e) {
      // Ignore unreachable IPs
    }
  }

  void dispose() {
    _isSearching = false;
  }
}
