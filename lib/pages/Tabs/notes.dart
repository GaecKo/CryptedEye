import 'dart:ui';

import 'package:cryptedeye/pages/tabs/screens/NoteScreen.dart';
import 'package:cryptedeye/pages/widgets/FrostedAlertDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../controller.dart';
import '../widgets/FolderCardWidget.dart';
import '../widgets/FolderCreationWidget.dart';
import '../widgets/NoteCardWidget.dart';

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
    Map<String, dynamic> notesContent = notesData["Notes"];
    Map<String, dynamic> mainContent = notesData["Directories"];

    mainContent.forEach((key, value) {
      if (key != "child") {
        String dirTitle = key;
        List<dynamic> childNotes = value;
        childNotes.sort((a, b) {
          final dateA = DateTime.parse(notesContent[a]["date"]);
          final dateB = DateTime.parse(notesContent[b]["date"]);
          return dateB.compareTo(dateA); // Newest firstx
        });
        List<NoteCard> childNotesWidget = [];

        for (int i = 0; i < childNotes.length; i++) {
          String title = childNotes[i];
          DateTime noteDate = DateTime.parse(notesContent[title]["date"]);
          String content = notesContent[title]["content"];
          childNotesWidget.add(NoteCard(
            cryptedTitle: title,
            date: noteDate,
            cryptedContent: content,
            ctr: ctr,
            rebuildParent: rebuildNotesPage,
            contents: contents,
          ));
        }
        contents.add(FolderCard(
          name: dirTitle,
          childNotes: childNotes,
          ctr: ctr,
        ));
      }
    });
    List<dynamic> mainChildNotes = mainContent["child"];
    mainChildNotes.sort((a, b) {
      final dateA = DateTime.parse(notesContent[a]["date"]);
      final dateB = DateTime.parse(notesContent[b]["date"]);
      return dateB.compareTo(dateA); // Newest first
    });

    for (int i = 0; i < mainChildNotes.length; i++) {
      String title = mainChildNotes[i];

      String content = notesContent[title]["content"];
      DateTime date = DateTime.parse(notesContent[title]["date"]);

      contents.add(NoteCard(
        cryptedTitle: title,
        date: date,
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

      if (widget is NoteCard) {
        return widget.ctr.crypter
            .decrypt(widget.cryptedTitle)
            .toLowerCase()
            .contains(searchQueryLower) ||
            widget.ctr.crypter
                .decrypt(widget.cryptedContent)
                .toLowerCase()
                .contains(searchQueryLower);
      } else if (widget is FolderCard) {
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
    if (widget is NoteCard) {
      contents.removeWhere((elem) {
        if (elem is NoteCard) {
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
    } else if (widget is FolderCard) {
      contents.removeWhere((elem) {
        if (elem is FolderCard) {
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









