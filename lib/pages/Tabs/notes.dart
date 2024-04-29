import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../controller.dart';

class NotesPage extends StatefulWidget {
  final Controller ctr;
  bool shown = false;

  NotesPage({Key? key, required this.ctr}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Widget> contents = [];
  late Controller ctr;
  String _searchQuery = '';

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void popup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Adding Notes and Folders",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "lib/images/notes.png",
                width: 350,
              ),
              const SizedBox(height: 20),
              const Text(
                "Use the '+' button to create Folders and Notes. Swipe left to delete.",
                textAlign: TextAlign.center,
                style: TextStyle(),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.shown = true;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  void buildContent() {
    contents = [];
    ctr = widget.ctr;
    Map<String, dynamic> notesData = ctr.notes_data;
    print("Notes: $notesData");
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
    buildContent();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(100, 100, 100, 1),
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 50.0,
            bottom: 30.0,
            child: FloatingActionButton(
              onPressed: () {
                popup();
              },
              mini: true,
              backgroundColor: Colors.grey,
              shape: const CircleBorder(),
              tooltip: 'Show Popup',
              child: const Icon(Icons.question_mark),
            ),
          ),
          Positioned(
            right: 16.0,
            bottom: 30.0,
            child: SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              animatedIconTheme: const IconThemeData(size: 22.0),
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.note_add_outlined),
                  backgroundColor: Colors.blue,
                  label: 'Add Note',
                  labelStyle: const TextStyle(fontSize: 16.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteScreen(
                          ctr: widget.ctr,
                          contents: contents,
                          rebuildParent: rebuildNotesPage,
                        ),
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child:
                      const Icon(Icons.create_new_folder, color: Colors.blue),
                  backgroundColor: Colors.white,
                  label: 'Create Folder',
                  labelStyle: const TextStyle(fontSize: 16.0),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => FolderCreation(
                        ctr: widget.ctr,
                        contents: contents,
                        rebuildParent: rebuildNotesPage,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            height: 0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search Notes...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Coins arrondis
                  borderSide: const BorderSide(
                      color: Colors.blue), // Couleur de la bordure
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Coins arrondis
                  borderSide: const BorderSide(
                    color: Colors
                        .blue, // Couleur de la bordure lorsqu'elle est activée
                    width: 2.0, // Largeur de la bordure lorsqu'elle est activée
                  ),
                ),
              ),
              style: const TextStyle(
                // Définir la couleur de la bordure lorsqu'elle n'est pas activée
                decorationColor: Colors.blue,
                // Définir l'épaisseur de la bordure lorsqu'elle n'est pas activée
                decorationThickness: 2.0,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contents.length,
              itemBuilder: (BuildContext context, int index) {
                Widget tmp = contents[index];

                if (tmp is Note) {
                  if (_searchQuery.isNotEmpty &&
                      !widget.ctr.crypter
                          .decrypt(tmp.cryptedTitle)
                          .contains(_searchQuery) &&
                      !widget.ctr.crypter
                          .decrypt(tmp.cryptedContent)
                          .contains(_searchQuery)) {
                    return const SizedBox.shrink();
                  }
                } else if (tmp is Folder) {
                  if (_searchQuery.isNotEmpty &&
                      !widget.ctr.crypter
                          .decrypt(tmp.name)
                          .contains(_searchQuery)) {
                    return const SizedBox.shrink();
                  }
                }

                return Slidable(
                  key: UniqueKey(),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: DismissiblePane(onDismissed: () {
                      deleteWidget(index);
                      // _showDeleteConfirmationDialog(context, index);
                    }),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          //_showDeleteConfirmationDialog(context, index);
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
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text('Are you sure you want to delete this note ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                deleteWidget(index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: ListTile(
        title: Row(
          children: [
            const Icon(
              Icons.note,
              color: Colors.blue,
              size: 18,
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.ctr.crypter.decrypt(widget.cryptedTitle),
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.fade,
                maxLines: 2,
              ),
            ),
          ],
        ),
        subtitle: Text(
          widget.ctr.crypter.decrypt(widget.cryptedContent),
          maxLines: 3,
          overflow: TextOverflow.fade,
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
            ),
          );
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
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
        child: ListTile(
          title: Text(
            widget.ctr.crypter.decrypt(widget.name),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: const Icon(
            Icons.folder_open,
            size: 36.0,
            color: Colors.blue,
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

  bool showError = false;

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
        backgroundColor: Colors.white,
        title: const SizedBox.shrink(), // Enlève le texte du titre
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.zero,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  disabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  errorText: showError ? 'Please enter a title' : null,
                ),
                onChanged: (value) {
                  showError = _titleController.text.isEmpty;
                },
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextFormField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Note",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder
                      .none, // Supprime le contour rectangulaire autour de la note
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal, // Remet la police en normal
                  color: Colors.black, // Couleur normale du texte en noir
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.save),
        onPressed: () {
          setState(() {
            showError = true;
          });
          if (_titleController.text.isNotEmpty) {
            String title = _titleController.text;
            String content = _contentController.text;
            String cr_title = widget.ctr.crypter.encrypt(title);
            String cr_content = widget.ctr.crypter.encrypt(content);
            Navigator.of(context).pop();
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
          }
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
      floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          animatedIconTheme: const IconThemeData(size: 22.0),
          children: [
            SpeedDialChild(
              child: const Icon(Icons.note_add_outlined),
              backgroundColor: Colors.blue,
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
          ]),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(
            height: 10,
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
