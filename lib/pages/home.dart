import 'package:flutter/material.dart';

import 'Tabs/albumPage.dart';
import 'Tabs/notes.dart';
import 'Tabs/passwords.dart';

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
          backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
          title: const Text("CryptedEye",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),),

          actions : <Widget>[
            IconButton(
              icon : const Icon(Icons.settings, size: 30, color: Colors.white,),
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
          overlayColor: MaterialStateColor.resolveWith((states) => const Color.fromRGBO(20, 20, 40, 0.2)),
          splashBorderRadius: BorderRadius.circular(10),
          ),
      
        ), 
      
        // tabbar view
        body: const SafeArea(
          child: TabBarView(
            children: <Widget>[
              PasswordManagerPage(),
              AlbumsPage(),
              NotesPage(),
            ],),
        )
      
      
      ),
    );
  }
}
