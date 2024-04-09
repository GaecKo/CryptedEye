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


    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold();

  }
}

class Note extends StatefulWidget {

  String title;
  String crypted_content;

  Note({super.key, required this.title, required this.crypted_content});

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
  final List<String> childNotes;


  Folder({Key? key, required this.title, required this.childNotes}) : super(key: key);

  @override
  _FolderState createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
      child: Container(
        child: Text(widget.title),
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
            const Icon(
              Icons.folder,
              size: 36.0, // Size of the folder icon
              color: Colors.blue,
            ),
            const SizedBox(width: 16.0), // Spacer between icon and text
            Expanded(
              child: Text(
                widget.name,
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

