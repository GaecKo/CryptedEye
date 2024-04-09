import 'package:flutter/material.dart';
import '../../controller.dart';

class NotesPage extends StatefulWidget {
  Controller ctr;

  NotesPage({super.key, required this.ctr});

  @override
  _NotesPageState createState() => _NotesPageState();

}

class _NotesPageState extends State<NotesPage> {

  late List<Widget> contents;
  late Controller ctr;
  @override
  void initState() {
    ctr = widget.ctr;
    Map<String, dynamic> notes_data = ctr.notes_data;
    Map<String, dynamic> notes_content = notes_data["Notes"];
    Map<String, dynamic> main_content = notes_data["Directories"];

    main_content.forEach((key, value) {
      if (key == "child") {
        List<String> main_child_notes = value;
        for (int i = 0; i < main_child_notes.length; i++) {
          String title = main_child_notes[i];
          String content = notes_content[title];
          contents.add(Note(crypted_title: title, crypted_content: content,));
        }
      } else {
        String dir_title = key;
        List<String> child_nodes = value;
        List<Note> child_notes_widget = [];

        for (int i = 0; i < child_nodes.length; i ++) {
          String title = child_nodes[i];
          String content = notes_content[title];
          child_notes_widget.add(Note(crypted_title: title, crypted_content: content));
        }
        contents.add(Folder(title: dir_title, content: child_notes_widget,))
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      backgroundColor: const Color.fromRGBO(100, 100, 100, 1),
      body : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

        ],
      )
    );

  }
}

class Note extends StatefulWidget {

  String crypted_title;
  String crypted_content;

  Note({super.key, required this.crypted_title, required this.crypted_content});

  @override
  _NoteState createState() => _NoteState();

}

class _NoteState extends State<Note> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              ],
            )
        )
    );
  }
}

class Folder extends StatefulWidget {
  final String title;
  final List<Note> content;


  Folder({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  _FolderState createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
      child: Container(
        width: double.infinity, // Take the full available width
        padding: const EdgeInsets.all(16.0), // Padding inside the container
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 2), // Shadow position, adjust as needed
            ),
          ],
        ),
        child: Row(
          children: [
            Text(widget.title),
            const Icon(
              Icons.folder,
              size: 36.0, // Size of the folder icon
              color: Colors.blue,
            ),
            const SizedBox(width: 16.0), // Spacer between icon and text
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
