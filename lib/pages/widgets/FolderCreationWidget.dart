import 'package:cryptedeye/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'FolderCardWidget.dart';

class FolderCreation extends StatefulWidget {
  final Controller ctr;
  final List<Widget> contents;
  final VoidCallback rebuildParent;

  const FolderCreation({
    super.key,
    required this.ctr,
    required this.contents,
    required this.rebuildParent,
  });

  @override
  State<FolderCreation> createState() => _FolderCreationState();
}

class _FolderCreationState extends State<FolderCreation> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController folderNameController = TextEditingController();
    bool showError = false;

    void addFolder(String name) {
      String crName = widget.ctr.crypter.encrypt(name);
      widget.contents.insert(
        0,
        FolderCard(
          name: crName,
          childNotes: const [],
          ctr: widget.ctr,
        ),
      );
      widget.rebuildParent();
      widget.ctr.createNewFolder(crName);
    }

    return AlertDialog(
      title: const Text("Create Folder"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: folderNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Folder Name',
                errorText: showError && folderNameController.text.isEmpty
                    ? 'Please enter a folder name'
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            setState(() {
              showError = true;
            });
            if (folderNameController.text.isNotEmpty) {
              addFolder(folderNameController.text);
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

