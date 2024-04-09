import 'package:flutter/material.dart';
import '../controller.dart';

import 'Tabs/notes.dart';
import 'Tabs/passwords.dart';

class HomePage extends StatefulWidget {
  Controller ctr;

  HomePage({super.key, required this.ctr});

  @override
  State<HomePage> createState() => _HomePageState(ctr);
}

class _HomePageState extends State<HomePage> {

  Controller ctr;

  _HomePageState(this.ctr);

  @override
  Widget build(BuildContext context) {

    // TODO: retrieve real security var that could be needed.
    // retrieve password from LoginPage:
    // Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
          title: const Text("CryptedEye",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),),

          actions : const <Widget>[
            Text("Alpha Version"),
            SizedBox(width: 10,)
            /*IconButton(
              icon : const Icon(Icons.warning_amber_rounded, size: 30, color: Colors.white,),
              onPressed: (){
                ctr.resetPasswordJson();},
              )*/
          ],
        
      
        bottom: TabBar(
          tabs: const [
            Tab(icon: Icon(Icons.lock),),
            /*Tab(icon: Icon(Icons.panorama_outlined),),*/
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
        body: SafeArea(
          child: TabBarView(
            children: <Widget>[
              PasswordManagerPage(ctr : ctr),
              /*AlbumsPage(),*/
              NotesPage(ctr: ctr),
            ],),
        )
      
      
      ),
    );
  }
}
