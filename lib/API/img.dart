import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;

class IMG {
  String? unTarFile(String sourceFile)  {
    // Vérifier si le fichier source existe
    File source = File(sourceFile);
    if (!source.existsSync()) {
      print("Le fichier source n'existe pas.");
      return null;
    }

    String? untarredFilePath = sourceFile;

    // Lire les données de l'archive tar
    List<int> bytes = source.readAsBytesSync();
    Archive archive = TarDecoder().decodeBytes(bytes);

    // Extraire les fichiers de l'archive
    for (var file in archive) {
      if (file.isFile) {
        List<int> data = file.content as List<int>;
        String filePath = file.name;
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        print('Fichier extrait: $filePath');
      }
    }

    print('Extraction terminée.');
    return untarredFilePath;
  }

  void createTarFile(Directory sourceDir, String targetFile) {
    // Créer une liste de tous les fichiers et sous-répertoires dans le dossier source
    List<FileSystemEntity> fileList =
        sourceDir.listSync(recursive: true);

    // Créer un objet Archive
    Archive archive = Archive();

    // Ajouter tous les fichiers et sous-répertoires à l'archive
    for (var file in fileList) {
      String filePath = file.path;
      if (FileSystemEntity.isFileSync(filePath)) {
        List<int> bytes = (file as File).readAsBytesSync();
        ArchiveFile af = ArchiveFile(filePath, bytes.length, bytes);
        archive.addFile(af);
      }
    }

    // Créer un fichier .tar à partir de l'archive
    File target = File(targetFile);
    if (!target.existsSync()) {
      target.createSync(recursive: true);
    }
    target.writeAsBytesSync(TarEncoder().encode(archive));
    print('Tar créer: $targetFile');
  }
}

void copyDirectoryContents(String sourceDirPath, String targetDirPath) {
  Directory sourceDir = Directory(sourceDirPath);
  Directory targetDir = Directory(targetDirPath);

  if (!sourceDir.existsSync()) {
    print('Le répertoire source n\'existe pas.');
    return;
  }

  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  List<FileSystemEntity> contents = sourceDir.listSync(recursive: true);
  for (FileSystemEntity entity in contents) {
    String relativePath = path.relative(entity.path, from: sourceDirPath);
    String destinationPath = path.join(targetDirPath, relativePath);

    if (entity is Directory) {
      Directory(destinationPath).createSync(recursive: true);
    } else if (entity is File) {
      File(entity.path).copySync(destinationPath);
    }
  }
}

void main(List<String> args) {
  IMG img = IMG();

  String data_path = "test";
  Directory d = Directory(data_path);
  String destinationFilePath = 'data.CryptedEye.tar';

  // img.createTarFile(d, destinationFilePath);
  //print(img.unTarFile(destinationFilePath));

  String sourceDirPath = 'test/test_tar';
  String targetDirPath = 'test2';

  copyDirectoryContents(sourceDirPath, targetDirPath);
}
