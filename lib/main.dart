// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/Tabs/notes.dart';
import 'pages/Tabs/albumPage.dart';
import 'pages/Tabs/passwords.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryptedEye Demo',
      routes: {
      '/login': (context) => LoginPage(),
      '/HomePage': (context) => HomePage(),
      },
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
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

    // TODO: retrieve real security var that could be needed.
    // retrieve password from LoginPage:
    Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var password = args['AP'];

    print("Retrieved password from HomePage: $password");

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

          actions : <Widget>[
            IconButton(
              icon : Icon(Icons.settings, size: 30, color: Colors.white,),
              onPressed: (){},
              )
          ],
        
      
        bottom: TabBar(
          tabs: const [
            Tab(icon: Icon(Icons.lock),),
            Tab(icon: Icon(Icons.panorama_outlined),),
            Tab(icon: Icon(Icons.note_outlined),),
            ],
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.white,
          overlayColor: MaterialStateColor.resolveWith((states) => Color.fromRGBO(20, 20, 40, 0.2)),
          splashBorderRadius: BorderRadius.circular(10),
          ),
      
        ), 
      
        // tabbar view
        body: SafeArea(
          child: TabBarView(
            children: const <Widget>[
              PasswordManagerPage(),
              AlbumsPage(),
              NotesPage(),
            ],),
        )
      
      
      ),
    );
  }
}
