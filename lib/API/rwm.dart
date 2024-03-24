// TODO: basic write function for general purpose
// Boolean write_content(String content, String path) -> true if done, false if error/...
// String read_content(String path) -> List<String>

// TODO: create function to create file

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class RWM {

  late String localPath;

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

  Future<void> modify_content(String filePath, String newData) async {
    File file = File("$localPath/$filePath");
    if (!file.existsSync()) {
      throw Exception("Erreur fichier: $localPath");
    }

    String currentContent = await file.readAsString();

    String modifiedContent = currentContent + newData;

    await file.writeAsString(modifiedContent);
  }

  Future<String> get_content(String filePath) async {
    File file = File("$localPath/$filePath");
    if (!file.existsSync()) {
      throw Exception("Erreur fichier: $filePath");
    }
    return file.readAsStringSync();
  }

  Future<void> write_content(String filePath, String data) async{
    File file = File("$localPath/$filePath");
    if (!file.existsSync()) {
      var t = file.path;
      throw Exception("Erreur fichier: $t");
    }
    file.writeAsStringSync(data);
  }

  void create_folder(String folderPath) {
    // create folder at localPath/filePath
    Directory("$localPath/$folderPath").createSync(recursive: true);
  }

  File create_file(String filePath) {
    // create file at localPath/filePath
    return File("$localPath/$filePath");
  }

  void deleteDirectory(String filePath) {
    final dir = Directory("$localPath/$filePath");
    dir.deleteSync(recursive: true);
  }

  List<File> getListofVault() {
    final dir = Directory(localPath);

    final List<FileSystemEntity> entities = dir.listSync().toList();

    final List<File> files = entities.whereType<File>().where((entity) {
      return entity.path.endsWith('.CrytpedEye.tar');
    }).toList();

    return files;

  }

}