import 'package:cryptedeye/controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../tabs/screens/NoteScreen.dart';

class NoteCard extends StatefulWidget {
  final Controller ctr;
  late String cryptedTitle;
  late String cryptedContent;
  List<Widget> contents;
  final VoidCallback rebuildParent;
  DateTime date;
  String? folderName;

  NoteCard({
    super.key,
    required this.cryptedTitle,
    required this.date,
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
            const SizedBox(width: 6),
            // Title text
            Expanded(
              child: Text(
                widget.ctr.crypter.decrypt(widget.cryptedTitle),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
            // Date + time
            Text(
              DateFormat('d/MM/yy-HH:mm').format(widget.date),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.right,
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