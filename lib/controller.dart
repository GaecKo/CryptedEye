import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

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
  late bool initialized = false;

  // variable for password management
  late Map<String, dynamic> password_data = {};
  late bool displaypassword = false;

  // variable for notes management
  late Map<String, dynamic> notes_data = {};

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

  Future<void> loadApp(String AP, String VaultName,
      {bool fromSignup = false}) async {
    this.VaultName = VaultName;

    // 1. create secure context if not from signup (otherwise its done in initApp)
    if (!fromSignup) {
      await sCtx.loadSettings(localPath);
      sCtx.applyPolicySettings();
    }

    // get salt path
    String saltPath = "$localPath/$VaultName.CryptedEye/app/salt.key";

    await crypter.init(AP, saltPath);

    if (kDebugMode) {
      print(
          "Controller has loaded the vault $VaultName at $localPath/$VaultName.CryptedEye");
    }

    // load password_data
    getPasswordsFromJson();
    loadNotesFromJson();
    initialized = true;
  }

  void closeApp() {
    print("started closing");
    if (initialized) {
      // put wifi / bluetooth back to onLaunch settings:
      sCtx.applyOnLaunchSettings();
      // save settings.json
      sCtx.writeSettingsToFile(localPath);
      // reset display password for password pages

      restDisplayPassword();
      // save password in json
      writePasswordsToJson();
      writeNotesToJson();
    }
    print(notes_data.toString());
    print("CLOSING APP");
  }

  Future<void> initApp(String AP, String VaultName, bool secureContext) async {
    // Init and then load App

    // 1. create settings.json file with secureContextSetting
    rwm.create_file("settings.json").createSync();
    this.secureContext = secureContext;

    Map<String, dynamic> initSettings =
        await sCtx.initSettings(secureContext, localPath);
    rwm.writeJSONData("settings.json", initSettings);

    // apply policy settings
    sCtx.applyPolicySettings();

    // 2. create project structure
    rwm.create_folder("$VaultName.CryptedEye/app/");
    rwm.create_folder("$VaultName.CryptedEye/passwords");
    rwm.create_folder("$VaultName.CryptedEye/notes");

    // 3. save hash into file
    //    a. create hash file
    rwm.create_file("$VaultName.CryptedEye/app/AP.hash").createSync();
    //    b. save AP to hash file as hashed AP
    saveHashPassword(AP, "$VaultName.CryptedEye/app/AP.hash");

    // 4. create key file
    rwm.create_file("$VaultName.CryptedEye/app/salt.key").createSync();

    // 5. create passwords json file
    rwm
        .create_file("$VaultName.CryptedEye/passwords/passwords.json")
        .createSync();
    rwm.writeJSONData("$VaultName.CryptedEye/passwords/passwords.json", {});

    // 5. create notes json file
    rwm
        .create_file("$VaultName.CryptedEye/notes/notes.json")
        .createSync();
    rwm.writeJSONData("$VaultName.CryptedEye/notes/notes.json", {"Directories": {"child": []}, "Notes": {}});

    // 6. load app
    await loadApp(AP, VaultName, fromSignup: true);
  }

  bool isStartup() {
    return rwm.getListofVault().isEmpty;
  }

  List<String> getListOfVault() {
    List<String> vaultsName = [];
    List<Directory> brutDir = rwm.getListofVault();

    for (var element in brutDir) {
      String dirName = element.path.toString();

      // get the last part of the path
      List<String> tmp = dirName.split("/");
      dirName = tmp[tmp.length - 1];

      // get first part
      tmp = dirName.split('.');

      vaultsName.add(tmp[0]);
    }
    print(vaultsName);

    return vaultsName;
  }

  bool verifyPassword(String AP, String vaultName) {
    return crypter.secureHash(AP) == getHashedPassword(vaultName);
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
    print("Password data is loaded");
  }

  void writePasswordsToJson() {
    // Write password_data in password.json
    // Call in closeApp()
    File file =
        File("$localPath/$VaultName.CryptedEye/passwords/passwords.json");

    String jsonContent = json.encode(password_data);
    file.writeAsStringSync(jsonContent);
  }

  void addPasswordData(String website, String username, String psw) {
    // add new password to password_data
    // call in password.dart
    password_data[crypter.encrypt(website)] = [
      crypter.encrypt(username),
      crypter.encrypt(psw)
    ];
    writePasswordsToJson();
  }

  void editPasswordData(String initialwebsite, String newwebsite,
      String newusername, String newpsw) {
    // edit password_data avec le nouveau user name et psw
    password_data.remove(initialwebsite);
    password_data[crypter.encrypt(newwebsite)] = [
      crypter.encrypt(newusername),
      crypter.encrypt(newpsw)
    ];
    writePasswordsToJson();
  }

  void deletePassword(String website) {
    print("delted");
    password_data.remove(website);
    writePasswordsToJson();
  }

  void resetPasswordJson() {
    File file =
        File("$localPath/$VaultName.CryptedEye/passwords/passwords.json");
    file.writeAsStringSync('{}');
    password_data = {};
  }

  void restDisplayPassword() {
    displaypassword = false;
  }

  void updateDisplayPassword() {
    displaypassword = true;
  }

  String generateRandomPassword() {
    const String charset =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=<>?/[]{},.:;';

    Random random = Random();
    // len of password is between 15 and 25, can be changed
    int length = random.nextInt(10) + 15;

    String password = '';

    for (int i = 0; i < length; i++) {
      int randomIndex = random.nextInt(charset.length);
      password += charset[randomIndex];
    }

    return password;
  }

  void loadNotesFromJson() {
    String path = "$VaultName.CryptedEye/notes/notes.json";

    Map<String, dynamic> jsonData = rwm.getJSONData(path);

    notes_data["Notes"] = jsonData["Notes"];
    notes_data["Directories"] = jsonData["Directories"];

    /*String uncrypted_key;
    String uncrypted_value;
    notes.forEach((key, value) {
      uncrypted_key = crypter.decrypt(key);
      uncrypted_value = crypter.decrypt(value);

      notes.remove(key);
      notes[uncrypted_key] = uncrypted_value;
    });

    directories.forEach((key, value) {
      String new_key;
      if (key != "child") {
        new_key = crypter.decrypt(key);
      } else {
        new_key = key;
      }
      List<String> childs = value;
      for (int i = 0; i < childs.length; i++) {

      }

    });*/

    print("Note data is loaded");
  }

  writeNotesToJson() {
      // Write notes_data in password.json
      // Call in closeApp()
      rwm.writeJSONData("$VaultName.CryptedEye/notes/notes.json", notes_data);

  }

  void saveNewNote(String cr_note_title, String cr_content, {String cr_dir_name = "child"}) {
    // {Notes: { "cr_title": "cr_content", ...}, Directories: ...}
    notes_data["Notes"][cr_note_title] = cr_content;

    // {Notes: ..., Directories: "child": ["cr_title", ...], "cr_dir_name": [...], ...}
    notes_data["Directories"][cr_dir_name].add(cr_note_title);
  }

  void updateNewNote(String old_cr_note, String new_cr_note, String new_cr_content, {String cr_dir_name = "child"}){

    // update note
    notes_data["Notes"].remove(old_cr_note);
    notes_data["Notes"][new_cr_note] = new_cr_content;

    // actualize note in its directory
    notes_data["Directories"][cr_dir_name].remove(old_cr_note);
    notes_data["Directories"][cr_dir_name].add(new_cr_note);
  }

  void createNewFolder(String cr_name) {
    notes_data["Directories"][cr_name] = [];
  }

  void updateFolderName(String old_cr_name, new_cr_name) {
    List<int> cor_notes = notes_data["Directories"][old_cr_name];
    notes_data["Directories"].remove(old_cr_name);
    notes_data["Directories"][new_cr_name] = [cor_notes];
  }

}

void main() {}
