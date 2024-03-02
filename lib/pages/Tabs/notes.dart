import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({Key? key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(64, 64, 64, 1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NoteRow(),
              NoteRow(),
              NoteRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteRow extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTwoNotes = screenWidth > 600; // If screen width is more than 600, display two notes per row

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isTwoNotes ? NoteBox() : Expanded(child: NoteBox()),
          isTwoNotes ? NoteBox() : Container(), // If only one note per row, add an empty container
        ],
      ),
    );
  }
}

class NoteBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle tap event here
        print('Note tapped!');
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // Adjust width of the note box
        height: 100, // Fixed height for the note box
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(20.0), // Round the corners
        ),
        child: Center(
          child: Text(
            'Your Note',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}


