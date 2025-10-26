import 'dart:ui';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import '../../../controller.dart';
import '../../widgets/NoteCardWidget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'NoteScreen.dart';

class OpenDirScreen extends StatefulWidget {
  final Controller ctr;
  final String dirName;
  final List<dynamic> childs;

  const OpenDirScreen({
    super.key,
    required this.ctr,
    required this.dirName,
    required this.childs,
  });

  @override
  _OpenDirScreenState createState() => _OpenDirScreenState();
}

class _OpenDirScreenState extends State<OpenDirScreen> {
  late List<Widget> contents = [];
  late Controller ctr;
  late String dirName;

  @override
  void initState() {
    super.initState();
    ctr = widget.ctr;
    dirName = widget.dirName;
    Map<String, dynamic> notesData = ctr.notes_data;
    Map<String, dynamic> notesContent = notesData["Notes"];
    Map<String, dynamic> mainContent = notesData["Directories"];

    mainContent.forEach((key, value) {
      if (key == dirName) {
        List<dynamic> childNodes = value;
        for (int i = 0; i < childNodes.length; i++) {
          String title = childNodes[i];
          String content = notesContent[title];
          contents.add(NoteCard(
            cryptedTitle: title,
            cryptedContent: content,
            contents: contents,
            rebuildParent: rebuildDirPage,
            ctr: ctr,
            folderName: dirName,
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.ctr.crypter.decrypt(dirName)),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        animatedIconTheme: const IconThemeData(size: 22.0),
        children: [
          SpeedDialChild(
            child: Icon(Icons.note_add_outlined,
                color: Theme.of(context).colorScheme.onPrimary),
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: 'Add Note',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteScreen(
                    ctr: widget.ctr,
                    contents: contents,
                    rebuildParent: rebuildDirPage,
                    folderName: widget.dirName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 60),
        itemCount: contents.length,
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            key: UniqueKey(),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              dismissible: DismissiblePane(onDismissed: () {
                deleteWidget(index);
              }),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    deleteWidget(index);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(
                      vertical: 0, horizontal: 10),
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: contents[index],
          );
        },
      ),
    );
  }

  void deleteWidget(int index) {
    NoteCard tmp = contents[index] as NoteCard;
    widget.ctr.deleteNote(tmp.cryptedTitle, folderName: dirName);
    contents.removeWhere((elem) {
      return (elem as NoteCard).cryptedTitle == tmp.cryptedTitle;
    });
    setState(() {});
  }

  void rebuildDirPage() {
    setState(() {});
  }
}