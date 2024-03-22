// TODO: basic write function for general purpose
// Boolean write_content(String content, String path) -> true if done, false if error/...
// String read_content(String path) -> List<String>

// TODO: create function to create file

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class RWM {

  late String localPath;

  Future<void> modify_content(String filePath, String newData) async {
    File file = File("$localPath/$filePath");
    if (!file.existsSync()) {
      throw Exception("Erreur fichier");
    }

    String currentContent = await file.readAsString();

    String modifiedContent = currentContent + newData;

    await file.writeAsString(modifiedContent);
  }

  Future<String> get_content(String filePath) async {
    File file = File("$localPath/$filePath");
    if (!file.existsSync()) {
      throw Exception("Erreur fichier");
    }
    return file.readAsStringSync();
  }

  Future<void> write_content(String filePath, String data) async{
    File file = File("$localPath/$filePath");
    if (!file.existsSync()) {
      throw Exception("Erreur fichier");
    }
    file.writeAsStringSync(data);
  }

  void create_folder(String folderPath) {
    Directory("$localPath/$folderPath").createSync(recursive: true);
  }

  RWM._create();

  static Future<RWM> create() async {
    RWM rwm = RWM._create();

    rwm.localPath = await rwm.getLocalPath();

    return rwm;
  }

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  File create_file(String filePath) {
    return File("$localPath/$filePath");
  }

  Future<List<FileSystemEntity>> getListofVault() async {
    final dir = Directory(localPath);

    return await dir.list().toList();

  }

}


void main() {
  RWM r = RWM();
  r.create_folder("hello/les/loulou");
}