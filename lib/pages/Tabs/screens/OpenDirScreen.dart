import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import '../../../controller.dart';
import '../../widgets/FolderCardWidget.dart';
import '../../widgets/NoteCardWidget.dart';

import 'NoteScreen.dart';

class OpenDirScreen extends StatefulWidget {
  final Controller ctr;
  final String dirName;
  final List<dynamic> childs;
  final Function(Widget widget) deleteFolderBehavior;
  final VoidCallback rebuildParent;
  final FolderCard folderCard;

  const OpenDirScreen({
    super.key,
    required this.ctr,
    required this.dirName,
    required this.childs,
    required this.deleteFolderBehavior,
    required this.rebuildParent,
    required this.folderCard
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
        for (int i = 0; i < childNodes.length+1; i++) {
          if (i==0) {
            contents.add(const SizedBox(height: 15,));
            continue;
          }
          String title = childNodes[i-1];
          DateTime date = DateTime.parse(notesContent[title]["date"]);
          String content = notesContent[title]["content"];
          contents.add(NoteCard(
            cryptedTitle: title,
            date: date,
            cryptedContent: content,
            contents: contents,
            rebuildParent: rebuildDirPage,
            ctr: ctr,
            folderName: dirName,
            deleteNoteBehavior: deleteWidget,
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
        actions: [
          IconButton(
              onPressed: () {
                // XXX: should delete logic be in parent widget? Whereare button is here?
                widget.deleteFolderBehavior(widget.folderCard as Widget);
                widget.rebuildParent();
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.delete_forever,
                color: Colors.red,
              )
          )
        ],
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
                    deleteNoteBehavior: deleteWidget,
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
          return contents[index];
        },
      ),
    );
  }

  void deleteWidget(Widget widget) {
    if (widget is NoteCard) {
      contents.removeWhere((elem) {
        if (elem is NoteCard) {
          return elem.cryptedTitle == widget.cryptedTitle;
        }
        return false;
      });
      if (widget.folderName != null) {
        widget.ctr
            .deleteNote(
            widget.cryptedTitle, folderName: widget.folderName as String);
      } else {
        widget.ctr.deleteNote(widget.cryptedTitle);
      }
    }
  }

  // XXX: this could be directly done in deleteWidget,
  // and thus not need to pass the rebuild parent as param to note screen
  void rebuildDirPage() {
    setState(() {});
  }
}