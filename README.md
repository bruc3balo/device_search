# Device Search

Search for devices in same network

```dart
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
        },
      );
```