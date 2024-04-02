import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'dart:io';

import 'API/crypter.dart';
import 'API/img.dart';
import 'API/rwm.dart';
import 'API/securityContext.dart';

// TODO: tar / untar will only be done for sharing purposes
// no untar / tar operation will be done otherwise, and full file structure will always be kept and updated

// TODO: in the settings at home page, the settings will allow to change the characteristics of the secureContext

class Controller {
  late Crypter crypter;
  late IMG img;
  late RWM rwm;
  late securityContext sCtx;

  late String localPath;
  late String VaultName;
  late Map<String, dynamic> settings;
  late bool secureContext;

  late Map<String, dynamic> password_data;

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

    sCtx = await securityContext.create();
  }

  void loadApp(String AP, String VaultName, {bool fromSignup=false}) {
    this.VaultName = VaultName;
    password_data = {};

    // 1. create secure context if not from signup (otherwise its done in initApp)
    if (!fromSignup) {
      sCtx.loadSettings(localPath);
      sCtx.applyPolicySettings();
    }

    // get salt path
    String saltPath = "$localPath/$VaultName.CryptedEye/app/salt.key";

    crypter.init(AP, saltPath);

    if (kDebugMode) {
      print("Controller has loaded the vault $VaultName at $localPath/$VaultName.CryptedEye");
    }

  }

  void closeApp() {
    // put wifi / bluetooth back to onLaunch settings:
    sCtx.applyOnLaunchSettings();
    // save settings.json
    sCtx.writeSettingsToFile(localPath);


    print("CLOSING APP");
  }

  Future<void> initApp(String AP, String VaultName, bool secureContext) async {
    // Init and then load App

    // 1. create settings.json file with secureContextSetting
    rwm.create_file("settings.json").createSync();
    this.secureContext = secureContext;

    Map<String, dynamic> init_settings = await  sCtx.initSettings(secureContext, localPath);
    rwm.writeJSONData("settings.json", init_settings);

    // apply policy settings
    sCtx.applyPolicySettings();

    // 2. create project structure
    rwm.create_folder("$VaultName.CryptedEye/app/");
    rwm.create_folder("$VaultName.CryptedEye/passwords");
    
    // 3. save hash into file
    //    a. create hash file
    rwm.create_file("$VaultName.CryptedEye/app/AP.hash").createSync();
    //    b. save AP to hash file as hashed AP
    saveHashPassword(AP, "$VaultName.CryptedEye/app/AP.hash");

    // 4. create key file
    rwm.create_file("$VaultName.CryptedEye/app/salt.key").createSync();

    // 5. create passwords json file
    rwm.create_file("$VaultName.CryptedEye/passwords/passwords.json").createSync();

    // 6. load app
    loadApp(AP, VaultName, fromSignup: true);
  }

  bool isStartup() {
    return rwm.getListofVault().isEmpty;
  }

  List<Directory> getListOfVault() {
    // TODO: make it return a List<String> with just the VaultName (so not full path, and without .CryptedEye/)
    return rwm.getListofVault();
  }

  bool verifyPassword(String AP, String vaultName) {
    return crypter.secureHash(AP) == getHashedPassword(vaultName);
  }

  String getTempOnlyVault() {
    // as the app is WIP, for the first version we will only be able to create one vault at a time
    // this is used to get the String of that only vault, later we will use getListOfVault
    List<Directory> vaults = rwm.getListofVault();
    String vault = vaults[0].path;
    List<String> pathOfVault = vault.split('/');
    String name = pathOfVault[pathOfVault.length - 1];

    // name = VAULT.CryptedEye -> need to split with . and take first elem
    return name.split('.')[0];

  }

  void writeSettings(Map<String, dynamic> content) {
    rwm.writeJSONData("settings.json", content);
  }

  Map<String, dynamic> loadSettings() {
    return rwm.getJSONData("settings.json");
  }

  String getHashedPassword(String vaultName) {
    String path = "$vaultName.CryptedEye/app/AP.hash";
    return rwm.get_content(path);
  }

  void saveHashPassword(String AP, String hashFilePath) {
    // save hashed version of AP in the hashFile 
    rwm.write_content(hashFilePath, crypter.secureHash(AP));
  }


  void getPasswordsFromJson() {
    // load password infos in password_data from password.json
    // infos are crypted

    String path = "$VaultName.CryptedEye/passwords/passwords.json";
    
    Map<String, dynamic> jsonData = rwm.getJSONData(path);
    
    jsonData.forEach((key, value) {
      password_data[key] = value;
    });
  }

  void writePasswordsToJson() {
    // Write password_data in password.json
    // Call in closeApp()
    File file = File("$localPath/$VaultName.CryptedEye/passwords/passwords.json");

    String jsonContent = json.encode(password_data);
    file.writeAsStringSync(jsonContent);
  }

  void addPasswordData(String website, String username, String psw){
    // add new password to password_data
    // call in password.dart
    password_data[crypter.encrypt(website)] = [crypter.encrypt(username), crypter.encrypt(psw)];
  }
}

void main() {

}
