import 'package:flutter/material.dart';

class LanguagePage extends StatelessWidget {
  final List<String> languages = [
    'Arabic',
    'Hebrew',
    'English',
    'Chinese',
    'Spanish'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language', style: TextStyle(color: Colors.indigo.shade400)),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          return MouseRegion(
            onEnter: (event) => {},
            onExit: (event) => {},
            child: ListTile(
              title: Text(languages[index], style: TextStyle(color: Colors.indigo.shade400)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Language Change'),
                    content: Text('Language changed to ${languages[index]}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}