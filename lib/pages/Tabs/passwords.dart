import 'dart:ui';

import 'package:cryptedeye/pages/widgets/AddPasswordItemWidget.dart';
import 'package:cryptedeye/pages/widgets/FrostedAlertDialog.dart';
import 'package:cryptedeye/pages/widgets/EditPasswordItemWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../../theme/themeProvider.dart';

import '../../controller.dart';
import '../widgets/PasswordCardWidget.dart';

class PasswordManagerPage extends StatefulWidget {
  final Controller ctr;
  bool shown = false;

  PasswordManagerPage({super.key, required this.ctr});

  @override
  _PasswordManagerPageState createState() => _PasswordManagerPageState();
}

class _PasswordManagerPageState extends State<PasswordManagerPage> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void _editPassword(String website, String username, String password) {
    FrostedAlertDialog(
      title: Text("Edit '${widget.ctr.crypter.decrypt(website)}' Password"),
      content: EditPasswordItem(
        ctr: widget.ctr,
        initialWebsite: website,
        initialUsername: username,
        initialPassword: password,
        rebuildParent: _rebuildParent,
      ),
    ).show(context);
  }


  void _rebuildParent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Calculate filtered items count
    final filteredItems = widget.ctr.password_data.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;

      String website = entry.key;
      List<dynamic> userData = entry.value;
      String username = userData[0];
      String password = userData[1];

      String decryptedWebsite = widget.ctr.crypter.decrypt(website);
      String decryptedUsername = widget.ctr.crypter.decrypt(username);
      String decryptedPassword = widget.ctr.crypter.decrypt(password);

      String decryptedWebsiteLowercase = decryptedWebsite.toLowerCase();
      String decryptedUsernameLowercase = decryptedUsername.toLowerCase();
      String decryptedPasswordLowercase = decryptedPassword.toLowerCase();
      String searchQueryLowercase = _searchQuery.toLowerCase();

      return decryptedWebsiteLowercase.contains(searchQueryLowercase) ||
          decryptedUsernameLowercase.contains(searchQueryLowercase) ||
          decryptedPasswordLowercase.contains(searchQueryLowercase);
    }).toList();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          // Main content with ListView
          Positioned.fill(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 60),
              itemCount: filteredItems.length + 1, // +1 for the spacer
              itemBuilder: (BuildContext context, int index) {
                // First item is the spacer
                if (index == 0) {
                  return const SizedBox(height: 70.0); // Space for search bar
                }

                // Adjust index for data access (subtract 1 for the spacer)
                final entry = filteredItems[index - 1];
                String website = entry.key;
                List<dynamic> userData = entry.value;
                String username = userData[0];
                String password = userData[1];

                String decryptedWebsite = widget.ctr.crypter.decrypt(website);
                String decryptedUsername = widget.ctr.crypter.decrypt(username);
                String decryptedPassword = widget.ctr.crypter.decrypt(password);

                return PasswordItem(
                    website: decryptedWebsite,
                    cryptedWebsite: website,
                    username: decryptedUsername,
                    password: decryptedPassword,
                    ctr: widget.ctr,
                    onCardPressed: () {
                      _editPassword(website, username, password);
                    },
                    rebuiltParent: () {_rebuildParent();},
                  );

              },
            ),
          ),

          // Glassy search bar
          Positioned(
            top: 10.0,
            left: 20.0,
            right: 20.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    onChanged: _updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search Passwords...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      filled: false,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
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
                popup(themeProvider);
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
                    final dialog = FrostedAlertDialog(
                      title: const Text('Add New Password'),
                      content: AddPasswordItem(
                        ctr: widget.ctr,
                        rebuildParent: _rebuildParent,
                      ),
                    );
                    dialog.show(context);
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

  void popup(ThemeProvider themeProvider) {
    FrostedAlertDialog frostedAlertDialog = FrostedAlertDialog(
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
            "Use the '+' button to create Passwords. Tap to modify or delete a password.",
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

    frostedAlertDialog.show(context);

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}