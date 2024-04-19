import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

import '../controller.dart';

class SettingsPage extends StatefulWidget {
  Controller ctr;

  SettingsPage({required this.ctr});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SettingsList(ctr: widget.ctr),
    );
  }
}

class SettingsList extends StatefulWidget {
  Controller ctr;

  SettingsList({required this.ctr});

  @override
  _SettingsList createState() => _SettingsList();
}

class _SettingsList extends State<SettingsList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Account Settings'),
          leading: Icon(Icons.account_circle),
          onTap: () {
            // Navigate to account settings screen
            // Example: Navigator.pushNamed(context, '/account_settings');
          },
        ),
        Divider(),
        ListTile(
          title: Text('Delete Data'),
          leading: Icon(Icons.delete),
          onTap: () {
            _showDeleteDataConfirmationDialog(context);
          },
        ),
        Divider(),
        ListTile(
          title: Text('Rename Account'),
          leading: Icon(Icons.edit),
          onTap: () {
            _showRenameAccountDialog(context);
          },
        ),
        Divider(),
        ListTile(
          title: Text('Logout'),
          leading: Icon(Icons.exit_to_app),
          onTap: () {
            _showLogoutConfirmationDialog(context);
          },
        ),
      ],
    );
  }

  void _showDeleteDataConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Data'),
          content: Text('Are you sure you want to delete all data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Perform delete data operation
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename Account'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Enter new name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Perform rename account operation
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                widget.ctr.closeApp();
                Restart.restartApp();
                Navigator.of(context).pop(); // Close dialog
                // Example: Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: Text('Logout'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
