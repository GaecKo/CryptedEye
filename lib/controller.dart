import 'API/crypter.dart';
import 'API/img.dart';
import 'API/rwm.dart';

class Controller {
  Crypter? crypter;
  IMG? img;
  RWM? rwm;

  Controller._create();

  // TODO: create function
  // think on class instanciation: when should we instantiate the class? Before Login? At Login?
  // Load App function -> will instantiate the different API
  // static Future<Controller> create() 

}
