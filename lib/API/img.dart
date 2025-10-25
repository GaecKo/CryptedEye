import 'dart:io';

import 'package:archive/archive_io.dart';

class IMG {
  String unTarFile(String sourceFile, String targetDirectory, String tarName) {
    // Vérifier si le fichier source existe
    File source = File(sourceFile);
    if (!source.existsSync()) {
      print("Le fichier source n'existe pas.");
      return "";
    }

    // Changer le nom si existe déja
    String tarFileName = '$targetDirectory/$tarName.CryptedEye';
    int cpt = 1;
    while (Directory(tarFileName).existsSync()) {
      tarFileName = '$targetDirectory/$tarName($cpt).CryptedEye';
      cpt++;
    }
    if (cpt != 1) {
      int nmbrTar = cpt - 1;
      tarName = "$tarName($nmbrTar)";
    }

    // Lire les données de l'archive tar
    List<int> bytes = source.readAsBytesSync();
    Archive archive = TarDecoder().decodeBytes(bytes);

    // Extraire les fichiers de l'archive
    for (var file in archive) {
      if (file.isFile) {
        List<int> data = file.content as List<int>;
        String filePath = file.name;
        String outputFile = '$targetDirectory/$tarName.CryptedEye/$filePath';
        File(outputFile)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        print('Fichier extrait: $outputFile');
      }
    }

    source.deleteSync();
    print('Extraction terminée.');
    return '$targetDirectory/$tarName.CryptedEye';
  }

  String createTarFile(
      Directory sourceDir, String outputDirectory, String tarName) {
    // Créer une liste de tous les fichiers et sous-répertoires dans le dossier source
    List<FileSystemEntity> fileList = sourceDir.listSync();

    // Créer un objet Archive
    Archive archive = Archive();

    // Ajouter tous les fichiers et sous-répertoires du dernier niveau à l'archive
    for (var entity in fileList) {
      if (entity is File) {
        List<int> bytes = (entity).readAsBytesSync();
        String filePath =
            entity.path.substring(sourceDir.path.length + 1); // Chemin relatif
        ArchiveFile af = ArchiveFile(filePath, bytes.length, bytes);
        archive.addFile(af);
      } else if (entity is Directory) {
        String dirName = entity.path
            .substring(sourceDir.path.length + 1); // Nom du répertoire
        addDirectoryContentToArchive(entity, archive, dirName);
      }
    }

    // Créer un fichier .tar à partir de l'archive
    String tarFileName = '$outputDirectory/$tarName.CryptedEye.tar';
    int cpt = 1;
    while (File(tarFileName).existsSync()) {
      tarFileName = '$outputDirectory/$tarName($cpt).CryptedEye.tar';
      cpt++;
    }

    print(tarFileName);
    File tarFile = File(tarFileName);
    tarFile.createSync(recursive: true);
    tarFile.writeAsBytesSync(TarEncoder().encode(archive));
    print('Tar créé: ${tarFile.path}');
    return tarFile.path;
  }

  void addDirectoryContentToArchive(
      Directory directory, Archive archive, String relativePath) {
    // Récupérer la liste de tous les fichiers et sous-répertoires dans le répertoire
    List<FileSystemEntity> content = directory.listSync();

    // Ajouter tous les fichiers et sous-répertoires à l'archive
    for (var entity in content) {
      if (entity is File) {
        List<int> bytes = (entity).readAsBytesSync();
        String filePath =
            entity.path.substring(directory.path.length + 1); // Chemin relatif
        String archivePath = '$relativePath/$filePath';
        ArchiveFile af = ArchiveFile(archivePath, bytes.length, bytes);
        archive.addFile(af);
      } else if (entity is Directory) {
        String dirName = entity.path
            .substring(directory.path.length + 1); // Nom du sous-répertoire
        addDirectoryContentToArchive(entity, archive, '$relativePath/$dirName');
      }
    }
  }
}

void main(List<String> args) {
  IMG img = IMG();

  String dataPath = "test_untar/test";
  Directory d = Directory(dataPath);
  String tarName = 'data';

  // img.createTarFile(d, 'test_untar', 'data');
  // print(img.unTarFile('test_untar/data.cryptedEye.tar', 'test_untar/test', tar_name));
}
