import 'package:cryptedeye/pages/widgets/AddPasswordItemWidget.dart';
import 'package:cryptedeye/pages/widgets/EditPasswordItemWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../controller.dart';
import '../widgets/PasswordItemWidget.dart';

class PasswordManagerPage extends StatefulWidget {
  final Controller ctr;
  bool shown = false;

  PasswordManagerPage({super.key, required this.ctr});

  @override
  _PasswordManagerPageState createState() => _PasswordManagerPageState();
}

class _PasswordManagerPageState extends State<PasswordManagerPage> {
  String _searchQuery = '';

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void _editPassword(String website, String username, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPasswordItem(
          ctr: widget.ctr,
          initialWebsite: website,
          initialUsername: username,
          initialPassword: password,
          rebuildParent: _rebuildParent,
        );
      },
    );
  }

  void _rebuildParent() {
    setState(() {});
  }

  Widget popup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Adding Passwords",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "lib/assets/passwords.png",
                width: 350,
              ),
              const SizedBox(height: 20),
              const Text(
                "Use the '+' button to create Passwords. Swipe left to delete.",
                textAlign: TextAlign.center,
                style: TextStyle(),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search Password...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Coins arrondis
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary), // Couleur de la bordure
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Coins arrondis
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, // Couleur de la bordure lorsqu'elle est activée
                    width: 2.0, // Largeur de la bordure lorsqu'elle est activée
                  ),
                ),
              ),
              style: TextStyle(
                // Définir la couleur de la bordure lorsqu'elle n'est pas activée
                decorationColor:Theme.of(context).colorScheme.primary,
                // Définir l'épaisseur de la bordure lorsqu'elle n'est pas activée
                decorationThickness: 2.0,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 60),
              itemCount: widget.ctr.password_data.length,
              itemBuilder: (BuildContext context, int index) {
                String website = widget.ctr.password_data.keys.elementAt(index);
                List<dynamic> userData =
                    widget.ctr.password_data.values.elementAt(index);
                String username = userData[0];
                String password = userData[1];

                String decryptedWebsite = widget.ctr.crypter.decrypt(website);
                String decryptedUsername = widget.ctr.crypter.decrypt(username);
                String decryptedPassword = widget.ctr.crypter.decrypt(password);

                String decryptedWebsiteLowercase =
                    decryptedWebsite.toLowerCase();
                String decryptedUsernameLowercase =
                    decryptedUsername.toLowerCase();
                String decryptedPasswordLowercase =
                    decryptedPassword.toLowerCase();
                String searchQueryLowercase = _searchQuery.toLowerCase();

                // Apply search filter
                if (_searchQuery.isNotEmpty &&
                    !decryptedWebsiteLowercase.contains(searchQueryLowercase) &&
                    !decryptedUsernameLowercase
                        .contains(searchQueryLowercase) &&
                    !decryptedPasswordLowercase
                        .contains(searchQueryLowercase)) {
                  return const SizedBox
                      .shrink(); // Hide item if it doesn't match search query
                }

                return Slidable(
                  key: UniqueKey(),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: DismissiblePane(onDismissed: () {
                      widget.ctr.deletePassword(website);
                      _rebuildParent();
                    }),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          widget.ctr.deletePassword(website);
                          _rebuildParent();
                        },
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: PasswordItem(
                    website: decryptedWebsite,
                    username: decryptedUsername,
                    password: decryptedPassword,
                    ctr: widget.ctr,
                    onPenPressed: () {
                      _editPassword(website, username, password);
                    },
                    onEyePressed: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 50.0,
            bottom: 10.0,
            child: FloatingActionButton(
              onPressed: () {
                popup();
              },
              mini: true,
              backgroundColor: Colors.grey,
              shape: const CircleBorder(),
              tooltip: 'Show Popup',
              child: const Icon(Icons.question_mark),
            ),
          ),
          Positioned(
            right: 16.0,
            bottom: 10.0,
            child: SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              backgroundColor: Theme.of(context).colorScheme.primary,
              animatedIconTheme: const IconThemeData(size: 22.0),
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.password),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  label: 'Add Password',
                  labelStyle: const TextStyle(fontSize: 16.0),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddPasswordItem(
                        ctr: widget.ctr,
                        rebuildParent: _rebuildParent,
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.autorenew),
                  backgroundColor: Colors.deepPurpleAccent,
                  label: "Generate Password",
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String website) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: Text(
              'Are you sure you want to delete ${widget.ctr.crypter.decrypt(website)} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                widget.ctr.deletePassword(website);
                _rebuildParent();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}




