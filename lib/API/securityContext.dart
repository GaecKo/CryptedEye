import 'dart:async';

import 'package:flutter/services.dart';
import 'package:android_flutter_wifi/android_flutter_wifi.dart';
import 'package:location/location.dart';
import 'package:airplane_mode_checker/airplane_mode_checker.dart';
import 'package:bluetooth_state/bluetooth_state.dart';

// highly based on https://pub.dev/documentation/airplane_mode_checker/latest/
// TODO: all function that aren't implemented, need to use many packages...
class securityContext {
  securityContext._create();

  static Future<securityContext> create() async {
    securityContext secCtxt = securityContext._create();
    return secCtxt;
  }

  Future<bool> getAirplaneStatus() async {
    return await AirplaneModeChecker.checkAirplaneMode() == AirplaneModeStatus.on;
  }

  void setAeroplaneStatus(bool status) async {

  }

  Future<bool> getBluetoothStatus() async {
    return await 
    return await FlutterBlue.instance.isAvailable && await FlutterBlue.instance.isOn;
  }

  void setBluetoothStatus(bool status) {
    BluetoothEnable.enableBluetooth.then(
    })
    FlutterBlue.instance.startScan();
  }

  Future<bool> getWifiStatus() async {
    return await AndroidFlutterWifi.isWifiEnabled();
  }

  Future<void> setWifiStatus(bool status) async {
    status ? await AndroidFlutterWifi.enableWifi(): await AndroidFlutterWifi.disableWifi();
  }

  bool getLocationStatus() {
    return LocationPlatform.instance.serviceEnabled();

  }

  void setLocationStatus(bool status) {

  }

}




