import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';

import 'API/crypter.dart';
import 'API/img.dart';
import 'API/rwm.dart';

class Controller {
  late Crypter crypter;
  late IMG img;
  late RWM rwm;

  late String localPath;
  late String VaultName;

  Controller._create();

  static Future<Controller> create() async {
    var ctr = Controller._create();

    await ctr.initAPI();

    return ctr;
  }

  Future<void> initAPI() async {
    crypter = Crypter.create();
    img = IMG();

    rwm = await RWM.create();

    localPath = rwm.localPath;
  }

  void loadApp(String AP, String VaultName, {bool fromSignup=false}) {
    VaultName = VaultName;
    // untar image
    img.unTarFile("$localPath/$VaultName.CryptedEye.tar", "$localPath/$VaultName");

    // get salt path
    String saltPath = "$localPath/$VaultName/app/salt.key";

    crypter.init(AP, saltPath);

    if (kDebugMode) {
      print("Controller has loaded the vault $VaultName at $localPath/$VaultName");
    }
  }

  void closeApp() {
    img.createTarFile("$localPath/$VaultName", "$localPath/$VaultName.CryptedEye.tar");
    rwm.deleteDirectory("$VaultName");
  }

  void initApp(String AP, String VaultName) async {
    // Init and then load App

    // create project structure
    rwm.create_folder("$VaultName/app/");
    rwm.create_folder("$VaultName/passwords");
    
    // save hash into file
    // 1. create hash file
    rwm.create_file("$VaultName/app/AP.hash").createSync();
    // 2. save AP to hash file as hashed AP
    saveHashPassword(AP, "$VaultName/app/AP.hash");

    // create key file
    rwm.create_file("$VaultName/app/salt.key").createSync();

    // create project structure image and delete file structure for basic loadApp
    // -> we created the project structure temporaly, to save it to .cryptedEye.tar
    // -> when we'll load the app, we will again untar it

    img.createTarFile("$localPath/$VaultName", "$localPath/$VaultName.CryptedEye.tar");
    rwm.deleteDirectory(VaultName);

    loadApp(AP, VaultName, fromSignup: true);
  }

  bool isStartup() {
    return rwm.getListofVault().isEmpty;
  }

  void saveHashPassword(String AP, String hashFilePath) {
    // save hashed version of AP in the hashFile 
    rwm.write_content(hashFilePath, crypter.secureHash(AP));
  }

}

void main() {

}
