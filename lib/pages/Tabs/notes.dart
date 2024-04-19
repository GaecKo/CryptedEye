import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../controller.dart';

class NotesPage extends StatefulWidget {
  final Controller ctr;

  NotesPage({Key? key, required this.ctr}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Widget> contents = [];
  late Controller ctr;

  @override
  void initState() {
    super.initState();
    ctr = widget.ctr;
    Map<String, dynamic> notesData = ctr.notes_data;
    Map<String, dynamic> notesContent = notesData["Notes"];
    Map<String, dynamic> mainContent = notesData["Directories"];

    mainContent.forEach((key, value) {
      if (key != "child") {
        String dirTitle = key;
        List<dynamic> childNotes = value;
        List<Note> childNotesWidget = [];

        for (int i = 0; i < childNotes.length; i++) {
          String title = childNotes[i];
          String content = notesContent[title];
          childNotesWidget.add(Note(
            cryptedTitle: title,
            cryptedContent: content,
            ctr: ctr,
            rebuildParent: rebuildNotesPage,
            contents: contents,
          ));
        }
        contents.add(Folder(
          name: dirTitle,
          childNotes: childNotes,
          ctr: ctr,
        ));
      }
    });
    List<dynamic> mainChildNotes = mainContent["child"];
    for (int i = 0; i < mainChildNotes.length; i++) {
      String title = mainChildNotes[i];

      String content = notesContent[title];

      contents.add(Note(
        cryptedTitle: title,
        cryptedContent: content,
        ctr: ctr,
        rebuildParent: rebuildNotesPage,
        contents: contents,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(100, 100, 100, 1),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
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
                icon: const Icon(
                  Icons.create_new_folder,
                  color: Colors.blue,
                ),
                label: const Text("Create Folder"),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
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
                        backgroundColor: Color(0xFFFE4A49),
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
          ),
        ],
      ),
    );
  }

  void deleteWidget(int index) {
    Widget tmp = contents[index];
    if (tmp is Note) {
      tmp = tmp as Note;
      if (tmp.folderName != null) {
        widget.ctr
            .deleteNote(tmp.cryptedTitle, folderName: tmp.folderName as String);
      } else {
        widget.ctr.deleteNote(tmp.cryptedTitle);
      }
      contents.removeWhere((elem) {
        if (elem is Note) {
          return elem.cryptedTitle == (tmp as Note).cryptedTitle;
        }
        return false;
      });
    } else {
      // TODO: ERROR WHEN REMOVING FOLDER, TO CHECK
      tmp = tmp as Folder;
      // remove folder from backend, its child notes as well
      widget.ctr.deleteFolder(tmp.name);
      // remove folder from frontend
      contents.removeWhere((elem) {
        if (elem is Folder) {
          return elem.name == (tmp as Folder).name;
        }
        return false;
      });
    }
  }

  void rebuildNotesPage() {
    setState(() {
      // Trigger a rebuild of NotesPageState
    });
  }
}

class Note extends StatefulWidget {
  final Controller ctr;
  late String cryptedTitle;
  late String cryptedContent;
  List<Widget> contents;
  final VoidCallback rebuildParent;
  String? folderName;

  Note(
      {required this.cryptedTitle,
      required this.cryptedContent,
      required this.ctr,
      required this.contents,
      required this.rebuildParent,
      this.folderName});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  rebuild() {
    setState(() {});
  }

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
          maxLines: 3,
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                // build NoteScreen for note update: ctr, contents, rebuildParent, rebuildNote, note widget
                builder: (_) => NoteScreen(
                  ctr: widget.ctr,
                  contents: widget.contents,
                  rebuildParent: widget.rebuildParent,
                  rebuildNote: rebuild,
                  note: widget,
                  folderName: widget.folderName,
                ),
              ));
        },
      ),
    );
  }
}

class Folder extends StatefulWidget {
  final String name;
  final List<dynamic> childNotes;
  final Controller ctr;

  Folder({
    required this.name,
    required this.childNotes,
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OpenDir(
                ctr: widget.ctr,
                dirName: widget.name,
                childs: widget.childNotes,
              ),
            ),
          );
        },
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
  VoidCallback? rebuildNote;
  Note? note;
  String? folderName;

  NoteScreen({
    super.key,
    this.note,
    this.rebuildNote,
    this.folderName,
    required this.ctr,
    required this.contents,
    required this.rebuildParent,
  });

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.note != null) {
      _titleController.text = (widget.note == null
          ? null
          : widget.ctr.crypter.decrypt(widget.note!.cryptedTitle))!;
      _contentController.text = (widget.note == null
          ? null
          : widget.ctr.crypter.decrypt(widget.note!.cryptedContent))!;
    }
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
                    hintText: "Enter content...", border: OutlineInputBorder()),
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
          String cr_title = widget.ctr.crypter.encrypt(title);
          String cr_content = widget.ctr.crypter.encrypt(content);

          widget.rebuildParent();
          if (widget.note != null) {
            // NOTE UPDATE
            // update note in backend
            if (widget.folderName == null) {
              // if it has a defined folder name, then update
              widget.ctr.updateNewNote(
                  widget.note!.cryptedTitle, cr_title, cr_content);
            } else {
              widget.ctr.updateNewNote(
                  widget.note!.cryptedTitle, cr_title, cr_content,
                  cr_dir_name: widget.folderName!);
            }

            widget.note?.cryptedTitle = cr_title;
            widget.note?.cryptedContent = cr_content;
            widget.rebuildNote!();
          } else {
            widget.rebuildParent();
            if (widget.folderName != null) {
              widget.ctr.saveNewNote(cr_title, cr_content,
                  cr_dir_name: widget.folderName as String);
            } else {
              widget.ctr.saveNewNote(cr_title, cr_content);
            }

            widget.contents.add(Note(
              cryptedTitle: cr_title,
              cryptedContent: cr_content,
              ctr: widget.ctr,
              contents: widget.contents,
              rebuildParent: widget.rebuildParent,
              folderName: widget.folderName,
            ));
          }

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
      String cr_name = widget.ctr.crypter.encrypt(name);
      widget.contents.insert(
        0,
        Folder(
          name: cr_name,
          childNotes: [],
          ctr: widget.ctr,
        ),
      );
      widget.rebuildParent();
      widget.ctr.createNewFolder(cr_name);
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
                errorText: _showError && _folderNameController.text.isEmpty
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

class OpenDir extends StatefulWidget {
  final Controller ctr;
  final String dirName;
  final List<dynamic> childs;

  OpenDir(
      {Key? key,
      required this.ctr,
      required this.dirName,
      required this.childs})
      : super(key: key);

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
      if (key == dirName) {
        String dirTitle = key;
        List<dynamic> childNodes = value;

        for (int i = 0; i < childNodes.length; i++) {
          String title = childNodes[i];
          String content = notesContent[title];
          contents.add(Note(
            cryptedTitle: title,
            cryptedContent: content,
            contents: contents,
            rebuildParent: rebuildDirPage,
            ctr: ctr,
            folderName: dirTitle,
          ));
        }
      }
    });
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
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // build note screen for new note: ctr, contents, rebuildDirPage, dirName
                      builder: (_) => NoteScreen(
                        ctr: ctr,
                        contents: contents,
                        rebuildParent: rebuildDirPage,
                        folderName: dirName,
                      ),
                    ),
                  );
                },
                child: const Text("Add Note"),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
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
                        backgroundColor: Color(0xFFFE4A49),
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
          ),
        ],
      ),
    );
  }

  void deleteWidget(int index) {
    Note tmp = contents[index] as Note;

    widget.ctr.deleteNote(tmp.cryptedTitle, folderName: dirName);
    contents.removeWhere((elem) {
      return (elem as Note).cryptedTitle == tmp.cryptedTitle;
    });
  }

  void rebuildDirPage() {
    setState(() {
      // Trigger a rebuild of NotesPageState
    });
  }
}
