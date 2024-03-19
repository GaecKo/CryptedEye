import 'API/crypter.dart';
import 'API/img.dart';
import 'API/rwm.dart';

import 'dart:io';

class Controller {
  Crypter? crypter;
  IMG? img;
  RWM? rwm;

  Controller._create();

  static Future<Controller> create() async {
    var ctr = Controller._create();

    ctr.initAPI();

    return ctr;
  }

  void initAPI() async {
    crypter = await Crypter.create();
    img = IMG();
    rwm = RWM();
  }

  void loadApp(String saltPath, String AP) {
    print("Controller has loaded the app");
  }

  // TODO: create function
  // think on class instanciation: when should we instantiate the class? Before Login? At Login?
  // Load App function -> will instantiate the different API
  // static Future<Controller> create() 

  void initApp(String AP) async {
    // Init and then load App
    // save hash into file
    crypter?.init(AP, "structure/app/salt.key");
    loadApp("structure/app/salt.key", AP);
  }


  bool isStartup() {
    File file = File("structure/app/AP.hash");
    if (!file.existsSync()) {
      return false;
    }
    return true;
  }

  void saveHashPassword(String AP) {
    rwm?.write_content("structure/app/AP.hash", crypter!.secureHash(AP));
  }

}

void main() {

}
