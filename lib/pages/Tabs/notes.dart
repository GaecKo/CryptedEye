import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controller.dart';

class NotesPage extends StatefulWidget {
  Controller ctr;

  NotesPage({super.key, required this.ctr});

  @override
  _NotesPageState createState() => _NotesPageState();

}

class _NotesPageState extends State<NotesPage> {

  late List<Widget> contents = [];
  late Controller ctr;
  @override
  void initState() {
    ctr = widget.ctr;
    Map<String, dynamic> notes_data = ctr.notes_data;
    Map<String, dynamic> notes_content = notes_data["Notes"];
    Map<String, dynamic> main_content = notes_data["Directories"];

    main_content.forEach((key, value) {
      if (key == "child") {
        List<dynamic> main_child_notes = value;
        for (int i = 0; i < main_child_notes.length; i++) {
          String title = main_child_notes[i];
          String content = notes_content[title];
          contents.add(Note(crypted_title: title, crypted_content: content, ctr: ctr,));
        }
      } else {
        String dir_title = key;
        List<dynamic> child_nodes = value;
        List<Note> child_notes_widget = [];

        for (int i = 0; i < child_nodes.length; i ++) {
          String title = child_nodes[i];
          String content = notes_content[title];
          child_notes_widget.add(Note(crypted_title: title, crypted_content: content, ctr: ctr,));
        }
        contents.add(Folder(name: dir_title, content: child_notes_widget, ctr: ctr,));
      }
    });

    super.initState();
  }

  void rebuildNotesPage() {
    setState(() {
      // Trigger a rebuild of NotesPageState
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(100, 100, 100, 1),
      body : Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>
                    NoteScreen(
                      ctr: ctr,
                      contents: contents,
                      rebuiltParent: rebuildNotesPage,)
                    ,)
                );
              },
              child: const Text("Add Note")
          ),
          Expanded(
            child: ListView.builder(
                itemCount: contents.length,
                itemBuilder: (BuildContext context, int index) {
                  return contents[index];
                },
            ),
          )
        ],
      )
    );

  }
}

class Note extends StatefulWidget {
  Controller ctr;
  String crypted_title;
  String crypted_content;

  Note({super.key, required this.crypted_title, required this.crypted_content, required this.ctr});

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
              widget.ctr.crypter.decrypt(widget.crypted_title),
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
  String name;
  List<Note> content;
  Controller ctr;


  Folder({Key? key, required this.name, required this.content, required this.ctr}) : super(key: key);

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
            Text(widget.ctr.crypter.decrypt(widget.name)),
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

class NoteScreen extends StatefulWidget {
  VoidCallback rebuiltParent;
  Controller ctr;
  List<Widget> contents;

  NoteScreen({Key? key, required this.ctr, required this.contents, required this.rebuiltParent}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Title",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Enter title...",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Content",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null, // Allow multiline input
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Enter content...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          String title = _titleController.text;
          String content = _contentController.text;

          // Call a method or function to handle saving the note with title and content
          _saveNote(title, content);
        },
      ),
    );
  }

  void _saveNote(String title, String content) {
    // Implement your logic here to save the note
    // You can use `widget.ctr` to access the controller if needed
    // For example:
    widget.contents.add(
      Note(
        crypted_title: widget.ctr.crypter.encrypt(title),
        crypted_content: widget.ctr.crypter.encrypt(content),
        ctr: widget.ctr,
      ),
    );
    widget.rebuiltParent();
    widget.ctr.saveNewNote(
        widget.ctr.crypter.encrypt(title),
        widget.ctr.crypter.encrypt(content)
    );

    // After saving, you might want to navigate back or show a confirmation message
    Navigator.of(context).pop(); // Example: Navigate back to previous screen
    // or show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note saved successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
