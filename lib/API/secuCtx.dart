import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:android_flutter_wifi/android_flutter_wifi.dart';

// highly based on https://pub.dev/documentation/airplane_mode_checker/latest/

class securityContext {
  securityContext._create();

  static Future<securityContext> create() async {
    securityContext secCtxt = securityContext._create();
    return secCtxt;
  }

  Future<bool> getAirplaneStatus() async {
    const MethodChannel _channel = MethodChannel('airplane_mode_checker');

    return await _channel.invokeMethod('checkAirplaneMode') == "ON";

  }

  void setAeroplaneStatus(bool status) {

  }

  Future<bool> getBluetoothStatus() async {
    return await FlutterBlue.instance.isAvailable && await FlutterBlue.instance.isOn;
  }

  void setBluetoothStatus(bool status) {

  }

  bool getWifiStatus() {

  }

  void setWifiStatus(bool status) {

  }

  bool getDataStatus() {
    return false;
  }

  void setDataStatus(bool status) {

  }

}




