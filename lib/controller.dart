import 'package:flutter/foundation.dart';
import 'dart:io';

import 'API/crypter.dart';
import 'API/img.dart';
import 'API/rwm.dart';

import 'dart:io';

class Controller {
  late Crypter crypter;
  late IMG img;
  late RWM rwm;

  late String localPath;
  late String VaultName;

  Controller._create();

  static Future<Controller> create() async {
    var ctr = Controller._create();

    ctr.initAPI();

    return ctr;
  }

  void initAPI() async {
    crypter = Crypter.create();
    img = IMG();

    rwm = await RWM.create();

    localPath = rwm.localPath;
  }

  void loadApp(String AP, String VaultName, {bool fromSignup=false}) {
    VaultName = VaultName;

    // get salt path
    String saltPath = "$VaultName/app/salt.key";

    crypter.init(AP, saltPath);

    if (kDebugMode) {
      print("Controller has loaded the vault $VaultName at $localPath/$VaultName");
    }
  }

  // TODO: create function
  // think on class instanciation: when should we instantiate the class? Before Login? At Login?
  // Load App function -> will instantiate the different API
  // static Future<Controller> create() 

  void initApp(String AP, String VaultName) async {
    // Init and then load App

    // create project structure
    rwm.create_folder("$VaultName/app/");
    rwm.create_folder("$VaultName/passwords");
    
    // save hash into file
    // 1. create hash file
    rwm.create_file("$VaultName/app/AP.hash");
    // 2. save AP to hash file as hashed AP
    saveHashPassword(AP, "$VaultName/app/AP.hash");
    
    // create project structure image and delete file structure for basic loadApp
    // -> we created the project structure temporaly, to save it to .cryptedEye.tar
    // -> when we'll load the app, we will

    loadApp("structure/app/salt.key", AP, fromSignup: true);
  }


  Future<bool> isStartup() async {
    List<FileSystemEntity> files = await rwm.getListofVault();
    
    if (files.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void saveHashPassword(String AP, String hashFilePath) {
    // save hashed version of AP in the hashFile 
    rwm.write_content(hashFilePath, crypter.secureHash(AP));
  }

}

void main() {

}
