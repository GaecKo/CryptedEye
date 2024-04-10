import 'package:flutter/material.dart';
import '../../controller.dart';

class OpenDir extends StatefulWidget {
  final Controller ctr;
  final String dirName;

  OpenDir({Key? key, required this.ctr, required this.dirName}) : super(key: key);

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
    
    print("poulet");
    print("dirName: $dirName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dirName),
      ),
      body: ListView(
        children: contents,
      ),
    );
  }
}
