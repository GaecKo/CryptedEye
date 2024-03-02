import 'package:flutter/material.dart';


class PasswordManagerPage extends StatelessWidget {
  const PasswordManagerPage({Key? key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Manager'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Password...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle add new password action
              print('Add new password');
            },
            child: Text('Add New Password'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Replace 5 with the actual number of passwords
              itemBuilder: (BuildContext context, int index) {
                return PasswordItem(
                  website: 'Website $index',
                  onEyePressed: () {
                    // Handle view password action
                    print('View password for website $index');
                  },
                  onPenPressed: () {
                    // Handle edit password action
                    print('Edit password for website $index');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordItem extends StatelessWidget {
  final String website;
  final VoidCallback onEyePressed;
  final VoidCallback onPenPressed;

  const PasswordItem({
    Key? key,
    required this.website,
    required this.onEyePressed,
    required this.onPenPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(website),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: onEyePressed,
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onPenPressed,
          ),
        ],
      ),
    );
  }
}