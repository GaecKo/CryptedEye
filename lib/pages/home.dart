import 'package:flutter/material.dart';

import '../controller.dart';
import 'Tabs/notes.dart';
import 'Tabs/passwords.dart';

class HomePage extends StatefulWidget {
  Controller ctr;
  late bool isStartup;

  HomePage({super.key, required this.ctr});

  @override
  State<HomePage> createState() => _HomePageState(ctr);
}

class _HomePageState extends State<HomePage> {
  Controller ctr;

  _HomePageState(this.ctr);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    widget.isStartup = args["isStartup"];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
            title: Row(
              children: [
                const Icon(
                  Icons.lock,
                  size: 26,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                const Text(
                  "CryptedEye",
                  style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  " > ${widget.ctr.VaultName}",
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/Settings');
                  setState(() {});
                },
              )
            ],
            bottom: TabBar(
              tabs: const [
                Tab(
                  icon: Icon(Icons.password),
                ),
                /*Tab(icon: Icon(Icons.panorama_outlined),),*/
                Tab(
                  icon: Icon(Icons.notes),
                ),
              ],
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.white,
              overlayColor: MaterialStateColor.resolveWith(
                  (states) => const Color.fromRGBO(20, 20, 40, 0.2)),
              splashBorderRadius: BorderRadius.circular(10),
            ),
          ),

          // tabbar view
          body: SafeArea(
            child: TabBarView(
              children: <Widget>[
                PasswordManagerPage(ctr: ctr, isStartup: widget.isStartup,),
                /*AlbumsPage(),*/
                NotesPage(ctr: ctr, isStartup: widget.isStartup,),
              ],
            ),
          )),
    );
  }
}
