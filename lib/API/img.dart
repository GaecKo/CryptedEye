import 'dart:io';

import 'package:archive/archive_io.dart';
// import 'package:path/path.dart' as p;

class IMG {

  void unTarFile(String sourceDir, String targetFile) async {
    // ... TODO: @guillaume
  }

  void createTarFile(String sourceDir, String targetFile) async {
    // Créer une liste de tous les fichiers et sous-répertoires dans le dossier source
    List<FileSystemEntity> fileList = Directory(sourceDir).listSync(recursive: true);
    

    // Créer un objet Archive
    Archive archive = Archive();

    // Ajouter tous les fichiers et sous-répertoires à l'archive
    for (var file in fileList) {
      String filePath = file.path;
      if (FileSystemEntity.isFileSync(filePath)) {
        List<int> bytes = await (file as File).readAsBytes();
        ArchiveFile af =  ArchiveFile(filePath, bytes.length, bytes);
        archive.addFile(af);
      }
    }

    // Créer un fichier .tar à partir de l'archive
    File target = File(targetFile);
    if (!target.existsSync()) {
      target.createSync(recursive: true);
    }
    target.writeAsBytesSync(TarEncoder().encode(archive));
  }
}




void main(List<String> args) {
  IMG img = IMG();

  String sourceFolderPath = 'test';
  String destinationFilePath = 'data.CryptedEye.tar';
  
  img.createTarFile(sourceFolderPath, destinationFilePath);
}