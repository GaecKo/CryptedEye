import 'package:flutter/material.dart';
import '../../controller.dart';

//TODO : remove que button to create a folder and all the code related to it

class OpenDir extends StatefulWidget {
  final Controller ctr;
  final String dirName;
  final List<dynamic> childs;

  OpenDir({Key? key, required this.ctr, required this.dirName, required this.childs}) : super(key: key);

  @override
  _OpenDirState createState() => _OpenDirState();
}

class _OpenDirState extends State<OpenDir> {
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
      //TODO: Decrypt key
        if (key == dirName) {
          print("ok");
          String dirTitle = key;
          List<dynamic> childNodes = value;

          for (int i = 0; i < childNodes.length; i++) {
            String title = childNodes[i];
            String content = notesContent[title];
            contents.add(Note(
              cryptedTitle: title,
              cryptedContent: content,
              ctr: ctr,
            ));
          }
        }
      });
    print("poulet");
    print("dirName: $dirName");
    print("childs: ${widget.childs}");
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ctr.crypter.decrypt(dirName)),
      ),
      backgroundColor: const Color.fromRGBO(100, 100, 100, 1),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteScreen(
                        ctr: ctr,
                        contents: contents,
                        rebuildParent: rebuildNotesPage,
                        dirName: dirName,
                      ),
                    ),
                  );
                },
                child: const Text("Add Note"),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => FolderCreation(
                      ctr: ctr,
                      contents: contents,
                      rebuildParent: rebuildNotesPage,
                    ),
                  );
                },
                icon: const Icon(Icons.create_new_folder, color: Colors.blue,),
                label: const Text("Create Folder"),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contents.length,
              itemBuilder: (BuildContext context, int index) {
                return contents[index];
              },
            ),
          ),
        ],
      ),
    );
  }

  void rebuildNotesPage() {
    setState(() {
      // Trigger a rebuild of NotesPageState
    });
  }
}


class Note extends StatefulWidget {
  final Controller ctr;
  final String cryptedTitle;
  final String cryptedContent;

  Note({
    required this.cryptedTitle,
    required this.cryptedContent,
    required this.ctr,
  });

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          widget.ctr.crypter.decrypt(widget.cryptedTitle),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          widget.ctr.crypter.decrypt(widget.cryptedContent),
        ),
      ),
    );
  }
}

class Folder extends StatefulWidget {
  final String name;
  final List<Note> content;
  final Controller ctr;

  Folder({
    required this.name,
    required this.content,
    required this.ctr,
  });

  @override
  State<Folder> createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        child: Container(

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              widget.ctr.crypter.decrypt(widget.name),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: const Icon(
              Icons.folder,
              size: 36.0,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

class NoteScreen extends StatefulWidget {
  final Controller ctr;
  final List<Widget> contents;
  final VoidCallback rebuildParent;
  final String dirName;


  NoteScreen({
    required this.ctr,
    required this.contents,
    required this.rebuildParent,
    required this.dirName,
  });

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Note"),
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
                maxLines: null,
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
          widget.contents.add(
            Note(
              cryptedTitle: widget.ctr.crypter.encrypt(title),
              cryptedContent: widget.ctr.crypter.encrypt(content),
              ctr: widget.ctr,
            ),
          );
          widget.rebuildParent();
          widget.ctr.saveNewNote(
            widget.ctr.crypter.encrypt(title),
            widget.ctr.crypter.encrypt(content),
            cr_dir_name:  widget.dirName,
          );
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note saved successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

class FolderCreation extends StatefulWidget {
  final Controller ctr;
  final List<Widget> contents;
  final VoidCallback rebuildParent;

  FolderCreation({
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
    final TextEditingController _folderNameController = TextEditingController();
    bool _showError = false;

    void _addFolder(String name) {
      widget.contents.insert(
        0,
        Folder(
          name: widget.ctr.crypter.encrypt(name),
          content: [],
          ctr: widget.ctr,
        ),
      );
      widget.rebuildParent();
      widget.ctr.createNewFolder(widget.ctr.crypter.encrypt(name));
    }

    return AlertDialog(
      title: const Text("Create Folder"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _folderNameController,
              decoration: InputDecoration(
                labelText: 'Folder Name',
                errorText: _showError && _folderNameController.text.isEmpty ? 'Please enter a folder name' : null,
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
          onPressed: () {
            setState(() {
              _showError = true;
            });
            if (_folderNameController.text.isNotEmpty) {
              _addFolder(_folderNameController.text);
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
