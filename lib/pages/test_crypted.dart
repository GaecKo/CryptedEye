import 'package:flutter/material.dart';
import '/API/crypter.dart';

class HashPage extends StatefulWidget {
  const HashPage({Key? key}) : super(key: key);

  @override
  _HashPageState createState() => _HashPageState();
}

class _HashPageState extends State<HashPage> {
  TextEditingController _textController = TextEditingController();
  String _hashedString = '';
  late Crypter cr;

  @override
  void initState() {
    super.initState();
    initializeCrypter();
  }

  Future<void> initializeCrypter() async {
    cr = await Crypter.create("test", "temp.key");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypted text Generator'),
      ),
      body: Padding(
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
              onPressed: () {
                setState(() {
                  _hashedString = cr.encrypt(_textController.text);
                });
              },
              child: Text('Generate Hash'),
            ),
            SizedBox(height: 20),
            Text(
              'Hashed String: $_hashedString',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
