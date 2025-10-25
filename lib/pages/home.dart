import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller.dart';
import 'tabs/notes.dart';
import 'tabs/passwords.dart';
import 'themeProvider.dart';

class HomePage extends StatefulWidget {
  final Controller ctr;
  late bool isStartup;

  HomePage({super.key, required this.ctr});

  @override
  _HomePageState createState() => _HomePageState(ctr);
}

class _HomePageState extends State<HomePage> {
  Controller ctr;
  bool isHighContrast = false; // Track the current theme state

  _HomePageState(this.ctr);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool defaultLightTheme = themeProvider.mode == "Light";

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 91, 91, 91),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  " > ${widget.ctr.VaultName}",
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              // Toggle button for switching themes
              icon: Icon(
                defaultLightTheme ? Icons.dark_mode : Icons.light_mode,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                if (themeProvider.mode == "Light") {
                  themeProvider.setDarkMode();
                  setState(() {
                    defaultLightTheme = false;
                  });
                } else {
                  themeProvider.setLightMode();
                  setState(() {
                    defaultLightTheme = true;
                  });
                }
              },
            ),
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
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.password),
              ),
              Tab(
                icon: Icon(Icons.notes),
              ),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.white,
            overlayColor: WidgetStateColor.resolveWith(
                (states) => const Color.fromRGBO(20, 20, 40, 0.2)),
            splashBorderRadius: BorderRadius.circular(10),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: <Widget>[
              PasswordManagerPage(
                ctr: ctr,
              ),
              NotesPage(
                ctr: ctr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
