import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/pointycastle.dart' as pc;



class Crypter {
  late Key _key;
  late List<int> _salt;

  bool initialized = false;

  late String saltPath;

  Crypter._create();

  /// Public factory, same for our instance of Crypter
  static Crypter create() {

    // Call the private constructor
    var crypter = Crypter._create();

    return crypter;
  }

  Future<void> init(String password, String salt_path) async {
    // first, we init our _salt var, that will contain 
    // our bytes for the key later on
    initialized = true;
    saltPath = salt_path;

    // TODO: temp code: for demo purpose
    _salt = await _loadSaltFromFile(salt_path);

    if (_salt.isEmpty || _salt == []) { // if the file is empty or inexistant, we generate it
      _salt = await _generateSalt();
      await _saveSaltToFile(salt_path, _salt);
    }

    // Now, we can use the salt + the password to load the key
    _key = await _loadKey(password, _salt);
  }

  bool isInit() {
    return initialized;
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

    // pdkf2 creation
    final pbkdf2 = pc.KeyDerivator('SHA-256/HMAC/PBKDF2')
      ..init(pc.Pbkdf2Parameters(Uint8List.fromList(salt), 38000, 32));
    // WARNING: we should increase number of iteration

    // prepare key with password
    final keyBytes = pbkdf2.process(utf8.encode(password));

    // Key object based on password
    return Key(keyBytes);
  }

  String encrypt(String toEncrypt) {
    print("encrypting: $toEncrypt");
    // random IV (init vector)
    final iv = IV.fromSecureRandom(16);
    
    // encrypted bases on Key
    final encrypter = Encrypter(AES(_key!));

    // IV + AES on text to encrypt using encrypted
    final encrypted = encrypter.encrypt(toEncrypt, iv: iv);
    
    // crypted - iv
    return '${encrypted.base64}:${base64.encode(iv.bytes)}';
  }

  String decrypt(String toDecrypt) {
    // crypted - iv
    final parts = toDecrypt.split(':');
    
    // encrypted = text
    final encrypted = Encrypted(base64.decode(parts[0]));
    
    // iv from parts[1]
    final iv = IV(Uint8List.fromList(base64.decode(parts[1])));
    
    // AES using Key
    final encrypter = Encrypter(AES(_key!));
    
    // decrypted text with IV and Key from encrypter
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    
    return decrypted;
  }

  String generateSHA256Hash(String input) {
    // Create a SHA-256 digest instance
    final pc.Digest sha256 = pc.Digest('SHA-256');

    // Convert the input string to bytes
    final Uint8List data = Uint8List.fromList(utf8.encode(input));

    // Calculate the hash
    final Uint8List hash = sha256.process(data);

    // Convert the hash bytes to a hexadecimal string
    final hexString = hash.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');

    return hexString;
  }

  String secureHash(String input) {
    // double hash
    return generateSHA256Hash(generateSHA256Hash(input));
  }


}

void main() async {
  Crypter cr = await Crypter.create();
  await cr.init("test", "temp.key");
  print("init done");

  String toEncrypt = "coucou";

  String encrypted = cr.encrypt(toEncrypt);
  print("crypt done on $toEncrypt: $encrypted");

  String decrypted = cr.decrypt(encrypted);
  print("decrypt done: $decrypted");

  String hashed = cr.secureHash(toEncrypt);

  print("hash done on $toEncrypt: $hashed");

}
