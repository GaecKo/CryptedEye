import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'dart:convert';
import 'dart:io';



class Crypter {
  Key? _key;
  List<int>? _salt;

  Crypter._create();

  /// Public factory, same for our instance of Crypter
  static Future<Crypter> create(String password) async {

    // Call the private constructor
    var crypter = Crypter._create();

    // Do initialization that requires async
    //await component._complexAsyncInit();
    await crypter._init(password);

    return crypter;
  }

  Future<void> _init(String password) async {
    // first, we init our _salt var, that will contain 
    // our bytes for the key later on

    _salt = await _loadSaltFromFile('salt.key');    

    if (_salt!.isEmpty || _salt == []) { // if the file is empty or inexistant, we generate it
      _salt = await _generateSalt();
      await _saveSaltToFile('salt.key', _salt!);
    }

    // Now, we can use the salt + the password to load the key
    _key = await _loadKey(password, _salt!);
  }

  Future<List<int>> _generateSalt() async {
    final random = pc.SecureRandom('Fortuna')..seed(pc.KeyParameter(Uint8List(32)));
    final salt = List<int>.generate(16, (_) => random.nextUint8());
    return salt;
  }

  Future<List<int>> _loadSaltFromFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return [];
  }

  Future<void> _saveSaltToFile(String filePath, List<int> salt) async {
    final file = File(filePath);
    await file.writeAsBytes(salt);
  }

  Future<Key> _loadKey(String password, List<int> salt) async {
  // Initialize PBKDF2 with SHA-256, HMAC, and PBKDF2 parameters
  final pbkdf2 = pc.KeyDerivator('SHA-256/HMAC/PBKDF2')
    ..init(pc.Pbkdf2Parameters(Uint8List.fromList(salt), 380000, 32));
  
  // Derive key bytes from the password using PBKDF2
  final keyBytes = pbkdf2.process(utf8.encode(password));
  
  // Create a Key object from the derived key bytes
  return Key(keyBytes);
}

  String encrypt(String toEncrypt) {
    // Generate a random initialization vector (IV)
    final iv = IV.fromSecureRandom(16);
    
    // Create an Encrypter object with AES encryption algorithm and the provided key
    final encrypter = Encrypter(AES(_key!));
    
    // Encrypt the plaintext using AES encryption algorithm and the generated IV
    final encrypted = encrypter.encrypt(toEncrypt, iv: iv);
    
    // Return the base64-encoded ciphertext concatenated with the IV
    return encrypted.base64 + ':' + base64.encode(iv.bytes);
  }

  String decrypt(String toDecrypt) {
    // Split the input string into ciphertext and IV parts
    final parts = toDecrypt.split(':');
    
    // Create an Encrypted object from the base64-decoded ciphertext
    final encrypted = Encrypted(base64.decode(parts[0]));
    
    // Create an IV object from the base64-decoded IV bytes
    final iv = IV(Uint8List.fromList(base64.decode(parts[1])));
    
    // Create an Encrypter object with AES encryption algorithm and the provided key
    final encrypter = Encrypter(AES(_key!));
    
    // Decrypt the ciphertext using AES encryption algorithm and the provided IV
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    
    // Return the decrypted plaintext
    return decrypted;
  }

}

void main() async {
  Crypter cr = await Crypter.create("test");
  print("init done");

  String to_encrypt = "coucou";

  String encrypted = cr.encrypt(to_encrypt);
  print("crypt done on $to_encrypt: $encrypted");

  String decrypted = cr.decrypt(encrypted);
  print("decrypt done: $decrypted");

}
