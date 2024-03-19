import 'package:flutter/material.dart';
import '/API/crypter.dart';
import 'package:flutter/services.dart'; // Needed for clipboard

class HashPage extends StatefulWidget {
  const HashPage({Key? key}) : super(key: key);

  @override
  _HashPageState createState() => _HashPageState();
}

class _HashPageState extends State<HashPage> {
  TextEditingController _textController = TextEditingController();
  TextEditingController _encryptedTextController = TextEditingController();
  TextEditingController _hashTextController = TextEditingController();
  String _cryptedString = '';
  String _decryptedString = '';
  String _hashedString = '';
  Crypter cr = Crypter.create();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var password = args['AP'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Crypted text Generator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter a string',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!cr.isInit()) {
                    await cr.init(password, "temp.key");
                  }
                  setState(() {
                    _cryptedString = cr.encrypt(_textController.text);
                  });
                },
                child: Text('Generate crypt'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Hashed String: $_cryptedString',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _cryptedString));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ));
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _encryptedTextController,
                decoration: InputDecoration(
                  labelText: 'Enter encrypted string',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _decryptedString = cr.decrypt(_encryptedTextController.text);
                  });
                },
                child: Text('Decrypt'),
              ),
              SizedBox(height: 20),
              Text(
                'Decrypted String: $_decryptedString',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _hashTextController,
                decoration: InputDecoration(
                  labelText: 'Enter string to hash',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hashedString = cr.secureHash(_hashTextController.text);
                  });
                },
                child: Text('Hash'),
              ),
              SizedBox(height: 20),
              Text(
                'Hashed String: $_hashedString',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
