import 'API/crypter.dart';
import 'API/img.dart';
import 'API/rwm.dart';

import 'dart:io';

class Controller {
  Crypter? crp;
  IMG? img;
  RWM? rwm;

  Controller._create();

  static Controller create() {
    var ctr = Controller._create();

    ctr.initAPI();

    return ctr;
  }

  void initAPI() {
    crp = Crypter.create();
    img = IMG();
    rwm = RWM();
  }

  void loadApp(String AP, String saltPath) async {
    await crp?.init(AP, saltPath);
    print("Controller has loaded the app");
  }

  // TODO: create function
  // think on class instanciation: when should we instantiate the class? Before Login? At Login?
  // Load App function -> will instantiate the different API
  // static Future<Controller> create() 

  void initApp(String AP, String saltPath) async {
    // Init and then load App
    // save hash into file
    await crp?.init(AP, "structure/app/salt.key");
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
    rwm?.write_content("structure/app/AP.hash", crp!.secureHash(AP));
  }

}

void main() {

}
