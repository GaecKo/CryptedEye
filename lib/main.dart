// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/Tabs/notes.dart';
import 'pages/Tabs/albumPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CryptedEye Demo',

      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ); // Material App
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(64, 64, 64, 1),
          title: Text("CryptedEye",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),),
        
      
        bottom: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.panorama_outlined),),
            Tab(icon: Icon(Icons.lock),),
            Tab(icon: Icon(Icons.note_outlined),),
          ]),
      
        ), 
      
        //tabbar view
        body: TabBarView(
          children: <Widget>[
            AlbumsPage(),
            Icon(Icons.lock),
            NotesPage(),
          ],)
      
      
      ),
    );
  }
}
