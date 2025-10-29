import 'package:cryptedeye/controller.dart';
import 'package:flutter/material.dart';

import '../tabs/screens/NoteScreen.dart';

class NoteCard extends StatefulWidget {
  final Controller ctr;
  late String cryptedTitle;
  late String cryptedContent;
  List<Widget> contents;
  final VoidCallback rebuildParent;
  String? folderName;

  NoteCard({
    super.key,
    required this.cryptedTitle,
    required this.cryptedContent,
    required this.ctr,
    required this.contents,
    required this.rebuildParent,
    this.folderName,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
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