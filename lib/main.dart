import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MainApp());
  setup();
}

void setup() async {
  // Bluetoothが有効でパーミッションが許可されるまで待機
  await FlutterBluePlus.adapterState
      .where((val) => val == BluetoothAdapterState.on)
      .first;
}

Map<String, ScanResult> mapScanResults = {};


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

String getRoomName(String str) {
  if(str.split('-').length > 1) {
    String roomName = "${str.split('-')[1]}教室";
    return roomName;
  }

  return "";
}

class RoomInfo {
  late String roomName;
  late int rssi;

  RoomInfo(this.roomName, this.rssi);
}

class _MainAppState extends State<MainApp> {
  RegExp re = RegExp(r'^SUSMAP-[0-9]{3}$');

  String _nearRoom = "確認中...";

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 1));

    int maxRssi = -1000000;
    String maxRssiSpot = "";

    FlutterBluePlus.scanResults.listen((results) {
      RegExp re = RegExp(r'^SUSMAP-[0-9]{3}$');
      for (ScanResult r in results) {
        if (re.hasMatch(r.device.platformName)) {
          if(r.rssi > maxRssi) {
            maxRssi = r.rssi;
            maxRssiSpot = r.device.platformName;
          }
        }
      }
    });

    // Restart the scan every 4 seconds to keep it continuous
    Future.delayed(const Duration(seconds: 1), () {
      String roomName = getRoomName(maxRssiSpot);

      if(_nearRoom != roomName && roomName != "") {
        setState(() {
          _nearRoom = roomName;
        });
      }

      FlutterBluePlus.stopScan();
      startScan();
    }); 
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build.");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SUSMAP'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_nearRoom, style: const TextStyle(fontSize: 50),)
            ]
          )
        ),
      ),
    );
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}
