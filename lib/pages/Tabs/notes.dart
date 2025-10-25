import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../controller.dart';

class NotesPage extends StatefulWidget {
  final Controller ctr;
  bool shown = false;

  NotesPage({super.key, required this.ctr});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Widget> contents = [];
  late Controller ctr;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

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
                "lib/assets/notes.png",
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

    // Calculate filtered items count
    final filteredItems = contents.where((widget) {
      if (_searchQuery.isEmpty) return true;

      String searchQueryLower = _searchQuery.toLowerCase();

      if (widget is Note) {
        return widget.ctr.crypter
            .decrypt(widget.cryptedTitle)
            .toLowerCase()
            .contains(searchQueryLower) ||
            widget.ctr.crypter
                .decrypt(widget.cryptedContent)
                .toLowerCase()
                .contains(searchQueryLower);
      } else if (widget is Folder) {
        return widget.ctr.crypter
            .decrypt(widget.name)
            .toLowerCase()
            .contains(searchQueryLower);
      }
      return true;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Main content with ListView
          Positioned.fill(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 60),
              itemCount: filteredItems.length + 1, // +1 for the spacer
              itemBuilder: (BuildContext context, int index) {
                // First item is the spacer
                if (index == 0) {
                  return const SizedBox(height: 70.0); // Space for search bar
                }

                // Adjust index for data access (subtract 1 for the spacer)
                final widget = filteredItems[index - 1];

                return Slidable(
                  key: UniqueKey(),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: DismissiblePane(onDismissed: () {
                      deleteWidgetFromContents(widget);
                      setState(() {});
                    }),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          deleteWidgetFromContents(widget);
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
                  child: widget,
                );
              },
            ),
          ),

          // Glassy search bar
          Positioned(
            top: 10.0,
            left: 20.0,
            right: 20.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    onChanged: _updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search Notes...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      filled: false,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 50.0,
            bottom: 10.0,
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
            bottom: 10.0,
            child: SpeedDial(
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
                          rebuildParent: rebuildNotesPage,
                        ),
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.create_new_folder,
                      color: Theme.of(context).colorScheme.primary),
                  backgroundColor: Theme.of(context).colorScheme.surface,
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
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Widget widget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                deleteWidgetFromContents(widget);
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

  void deleteWidgetFromContents(Widget widget) {
    if (widget is Note) {
      contents.removeWhere((elem) {
        if (elem is Note) {
          return elem.cryptedTitle == widget.cryptedTitle;
        }
        return false;
      });
      if (widget.folderName != null) {
        widget.ctr
            .deleteNote(widget.cryptedTitle, folderName: widget.folderName as String);
      } else {
        widget.ctr.deleteNote(widget.cryptedTitle);
      }
    } else if (widget is Folder) {
      contents.removeWhere((elem) {
        if (elem is Folder) {
          return elem.name == widget.name;
        }
        return false;
      });
      widget.ctr.deleteFolder(widget.name);
    }
  }

  void rebuildNotesPage() {
    setState(() {
      // Trigger a rebuild of NotesPageState
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class Note extends StatefulWidget {
  final Controller ctr;
  late String cryptedTitle;
  late String cryptedContent;
  List<Widget> contents;
  final VoidCallback rebuildParent;
  String? folderName;

  Note({
    super.key,
    required this.cryptedTitle,
    required this.cryptedContent,
    required this.ctr,
    required this.contents,
    required this.rebuildParent,
    this.folderName,
  });

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
            Icon(
              Icons.note,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 5),
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

  const Folder({
    super.key,
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

class NoteScreen extends StatefulWidget {
  final Controller ctr;
  final List<Widget> contents;
  final VoidCallback rebuildParent;
  final VoidCallback? rebuildNote;
  final Note? note;
  final String? folderName;

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
      _titleController.text = widget.ctr.crypter.decrypt(widget.note!.cryptedTitle);
      _contentController.text = widget.ctr.crypter.decrypt(widget.note!.cryptedContent);
    }

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              child: TextFormField(
                textInputAction: TextInputAction.next,
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
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
                  setState(() {
                    showError = _titleController.text.isEmpty;
                  });
                },
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.normal,
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
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.save),
        onPressed: () {
          setState(() {
            showError = true;
          });
          if (_titleController.text.isNotEmpty) {
            String title = _titleController.text;
            String content = _contentController.text;
            String crTitle = widget.ctr.crypter.encrypt(title);
            String crContent = widget.ctr.crypter.encrypt(content);
            Navigator.of(context).pop();
            widget.rebuildParent();
            if (widget.note != null) {
              if (widget.folderName == null) {
                widget.ctr.updateNewNote(
                    widget.note!.cryptedTitle, crTitle, crContent);
              } else {
                widget.ctr.updateNewNote(
                    widget.note!.cryptedTitle, crTitle, crContent,
                    cr_dir_name: widget.folderName!);
              }
              widget.note?.cryptedTitle = crTitle;
              widget.note?.cryptedContent = crContent;
              widget.rebuildNote!();
            } else {
              if (widget.folderName != null) {
                widget.ctr.saveNewNote(crTitle, crContent,
                    cr_dir_name: widget.folderName as String);
              } else {
                widget.ctr.saveNewNote(crTitle, crContent);
              }
              widget.contents.add(Note(
                cryptedTitle: crTitle,
                cryptedContent: crContent,
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
        Folder(
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

class OpenDir extends StatefulWidget {
  final Controller ctr;
  final String dirName;
  final List<dynamic> childs;

  const OpenDir({
    super.key,
    required this.ctr,
    required this.dirName,
    required this.childs,
  });

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
    Note tmp = contents[index] as Note;
    widget.ctr.deleteNote(tmp.cryptedTitle, folderName: dirName);
    contents.removeWhere((elem) {
      return (elem as Note).cryptedTitle == tmp.cryptedTitle;
    });
    setState(() {});
  }

  void rebuildDirPage() {
    setState(() {});
  }
}