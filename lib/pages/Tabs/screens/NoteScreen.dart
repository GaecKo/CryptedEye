import 'package:cryptedeye/controller.dart';
import 'package:flutter/material.dart';

import '../../widgets/NoteCardWidget.dart';

class NoteScreen extends StatefulWidget {
  final Controller ctr;
  final List<Widget> contents;
  final VoidCallback rebuildParent;
  final VoidCallback? rebuildNote;
  final NoteCard? note;
  final String? folderName;
  bool initialized = false;

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
    if (widget.note != null && !widget.initialized) {
      widget.initialized = true;
      _titleController.text = widget.ctr.crypter.decrypt(widget.note!.cryptedTitle);
      _contentController.text = widget.ctr.crypter.decrypt(widget.note!.cryptedContent);
      setState(() {

      });
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
                textAlignVertical: TextAlignVertical(y: -1),
                decoration: const InputDecoration(
                  fillColor: Colors.transparent,
                  hintText: "Note",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none
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

          if (_titleController.text.isNotEmpty) {
            String title = _titleController.text;
            String content = _contentController.text;
            String crTitle = widget.ctr.crypter.encrypt(title);
            String crContent = widget.ctr.crypter.encrypt(content);

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
              Navigator.of(context).pop();
            } else {
              if (widget.folderName != null) {
                widget.ctr.saveNewNote(crTitle, crContent,
                    cr_dir_name: widget.folderName as String);
              } else {
                widget.ctr.saveNewNote(crTitle, crContent);
              }

              widget.contents.add(NoteCard(
                cryptedTitle: crTitle,
                cryptedContent: crContent,
                ctr: widget.ctr,
                contents: widget.contents,
                rebuildParent: widget.rebuildParent,
                folderName: widget.folderName,
              ));

            }
          }
          else {
            setState(() {
              showError = true;
            });
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