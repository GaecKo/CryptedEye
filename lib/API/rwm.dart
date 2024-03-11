// TODO: basic write function for general purpose
// Boolean write_content(String content, String path) -> true if done, false if error/...
// String read_content(String path) -> List<String> 
import 'dart:io';
import 'dart:convert';
import 'crypter.dart';

class RWM {
  Future<void> modify_content(String filePath, String newData) async {
    File file = File(filePath);
    if (!file.existsSync()) {
      throw Exception("Erreur fichier");
    }

    String currentContent = await file.readAsString();

    String modifiedContent = currentContent + newData;

    await file.writeAsString(modifiedContent);
  }

  Future<String> get_content(String filePath) async {
    File file = File(filePath);
    if (!file.existsSync()) {
      throw Exception("Erreur fichier");
    }
    return file.readAsStringSync();
  }

  Future<void> write_content(String filePath, String data) async{
    File file = File(filePath);
    if (!file.existsSync()) {
      throw Exception("Erreur fichier");
    }
    file.writeAsStringSync(data);
  }
}