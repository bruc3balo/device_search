import 'dart:async';

import 'package:device_search/broadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:device_search/device_search.dart';

void main() {
  test(
    'Search and Broadcast',
    () async {
      DateTime startTime = DateTime.now();
      final broadcastCompleter = Completer<void>();
      BroadcastMyDevice broadcastMyDevice = BroadcastMyDevice(
        tag: '1212',
        nickname: 'balo-discover',
      );

      broadcastMyDevice.broadcast(
        onDiscover: ({
          required String tag,
          required String nickname,
        }) {
          debugPrint("Discovered by $nickname#$tag");
          broadcastMyDevice.dispose();
          if (!broadcastCompleter.isCompleted) {
            broadcastCompleter.complete();
          }
        },
      );

      final searchCompleter = Completer<void>();

      SearchDevices searchDevices = SearchDevices(
        tag: '3434',
        nickname: 'balo-search',
      );

      searchDevices.search(
        onDiscover: ({
          required String tag,
          required String nickname,
        }) {
          debugPrint("Discovered $nickname#$tag");
          searchDevices.dispose();
          if (!searchCompleter.isCompleted) {
            searchCompleter.complete();
          }
        },
      );

      // Wait for the completer to complete or time out
      await broadcastCompleter.future.timeout(const Duration(minutes: 5));
      await searchCompleter.future.timeout(const Duration(minutes: 5));
      debugPrint(
          "Test completed in ${DateTime.now().difference(startTime).inMinutes} minute");
    },
  );
}
