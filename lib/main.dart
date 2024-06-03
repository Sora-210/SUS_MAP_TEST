import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MainApp());
}

Map<String, ScanResult> mapScanResults = {};


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SUSMAP'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  RegExp re = new RegExp(r'^SUSMAP-[0-9]{3}$');
                  // スキャン結果のリスナーをセットアップ
                  var subscription = FlutterBluePlus.scanResults.listen((results) {
                    if (results.isNotEmpty) {
                      for (var r in results) {
                        if (re.hasMatch(r.device.platformName)) {
                          debugPrint('======');
                          debugPrint('強度: ${r.rssi}');
                          debugPrint('デバイス名: ${r.device.platformName}');
                          debugPrint('UUID: ${r.device.remoteId}');
                        }
                      }
                    }
                  },
                  onError: (e) => debugPrint(e));

                  // Bluetoothが有効でパーミッションが許可されるまで待機
                  await FlutterBluePlus.adapterState
                      .where((val) => val == BluetoothAdapterState.on)
                      .first;

                  // スキャン開始
                  await FlutterBluePlus.startScan();
                },
                child: const Text('Start Scan'),
              ),
            ]
          )
        ),
      ),
    );
  }
}
