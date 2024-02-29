import 'package:flutter/material.dart';

// tutorial used: https://youtu.be/Dh-cTQJgM-Q
class NotesPage extends StatelessWidget {
  const NotesPage({Key? key}) : super(key: key); // Fix constructor syntax

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
      body: SafeArea(
        child: Center(
          child: Column( // Changed Center to Column
            mainAxisAlignment: MainAxisAlignment.center, // Added alignment for Column
            children: [
              // empty space
              const SizedBox(height: 50),

              // Title 
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  // Pictures Icon
                  Icon(
                    Icons.panorama_outlined, 
                    size:40,
                    color: Colors.white,
                  ),

                  SizedBox(width: 30),
              
                  // Lock Icon
                  Icon(
                    Icons.lock, 
                    size:40,
                    color: Colors.white,
                  ),

                  SizedBox(width: 30),

                  // File Icon
                  Icon(
                    Icons.note_outlined, 
                    size:40,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 100),
              const Text(
                "notes page",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
