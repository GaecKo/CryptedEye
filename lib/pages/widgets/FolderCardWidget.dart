import 'package:cryptedeye/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tabs/notes.dart';
import '../tabs/screens/OpenDirScreen.dart';

class FolderCard extends StatefulWidget {
  final String name;
  final List<dynamic> childNotes;
  final Controller ctr;

  const FolderCard({
    super.key,
    required this.name,
    required this.childNotes,
    required this.ctr,
  });

  @override
  State<FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends State<FolderCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OpenDirScreen(
                ctr: widget.ctr,
                dirName: widget.name,
                childs: widget.childNotes,
              ),
            ),
          );
        },
        child: ListTile(
          title: Text(
            widget.ctr.crypter.decrypt(widget.name),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Icon(
            Icons.folder_open,
            size: 36.0,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}