import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

// This code includes the security context, not worked on anymore on the main branch

// TODO: create custom channel? gonna be really hard

class securityContext {
  late Map<String, dynamic> settings;

  securityContext._create();

  static late var platform;

  static Future<securityContext> create() async {
    securityContext secCtxt = securityContext._create();
    platform = const MethodChannel(
        'com.example.flutter.cryptedeye.cryptedeye/myCustomChannel');
    print("Calling java code...");
    secCtxt.TestChannel();
    return secCtxt;
  }

  void TestChannel() async {
    String response = "";
    try {
      final String result = await platform.invokeMethod(
          'customJavaMethod'); // add {"arg1": "value", ...} to add parameters
      response = result;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    print(response);
  }

  Future<Map<String, dynamic>> initSettings(
      bool secureContext, String localPath) async {
    // TODO: add many things: data + aeroplane mode + location
    settings = {
      "secureContext": {
        "wifi": {
          "onLaunch": await getWifiStatus(),
          "policy":
              !secureContext // set to False (Wifi disabled) if secure context is on, otherwise True (nothing to do)
        },
        "bluetooth": {
          "onLaunch": await getBluetoothStatus(),
          "policy":
              !secureContext // set to False (Wifi disabled) if secure context is on, otherwise True (nothing to do)
        },
      }
    };
    // return first time for init, so we can write it directly from controller (only for the first time)
    return settings;
  }

  void updateSettings(String service, bool newValue) {
    settings["secureContext"][service]["policy"] = newValue;
  }

  Future<void> loadSettings(String localPath) async {
    settings = jsonDecode(readSettingsFile(localPath));

    // update onLaunch val with current
    settings["secureContext"]["wifi"]["onLaunch"] = await getWifiStatus();
    settings["secureContext"]["bluetooth"]["onLaunch"] =
        await getBluetoothStatus();
  }

  void applyPolicySettings() {
    if (settings["secureContext"]["wifi"]["policy"] == false) {
      // if false: put wifi to false
      setWifiStatus(false);
    }
    if (settings["secureContext"]["bluetooth"]["policy"] == false) {
      // if false: put bluetooth to false
      setBluetoothStatus(false);
    }
  }

  void applyOnLaunchSettings() {
    setWifiStatus(settings["secureContext"]["wifi"]["onLaunch"]);
    setBluetoothStatus(settings["secureContext"]["bluetooth"]["onLaunch"]);
  }

  String readSettingsFile(String localPath) {
    File sett = File("$localPath/settings.json");
    return sett.readAsStringSync();
  }

  void writeSettingsToFile(String localPath) {
    File sett = File("$localPath/settings.json");

    // get new updated settings (could be changed from other source), and apply updated secureContext to it
    Map<String, dynamic> updatedSettings = jsonDecode(sett.readAsStringSync());
    updatedSettings["secureContext"] = settings["secureContext"];

    sett.writeAsStringSync(jsonEncode(updatedSettings));
  }

  // TODO: below functions are nightmares. We should create a specific channel that takes care of all of that,
  // TODO: and so go through Java code and all. Currently, it does nothing.
  Future<bool> getBluetoothStatus() async {
    return true;
    // return await BluetoothState().isBluetoothEnable;
  }

  Future<void> setBluetoothStatus(bool status) async {
    // status ? await BluetoothState().requestEnableBluetooth() : await BluetoothState().requestDisableBluetooth();
  }

  Future<bool> getWifiStatus() async {
    return true;
    // return await AndroidFlutterWifi.isWifiEnabled();
  }

  Future<void> setWifiStatus(bool status) async {
    // status ? await AndroidFlutterWifi.enableWifi(): await AndroidFlutterWifi.disableWifi();
  }
}
