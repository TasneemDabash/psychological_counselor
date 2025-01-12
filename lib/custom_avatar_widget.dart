import 'package:flutter/material.dart';

class CustomAvatarWidget extends StatelessWidget {
  final Map<String, String> attributes;

  CustomAvatarWidget({required this.attributes});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Color(int.parse(attributes['env']!.replaceFirst('#', '0xff'))),
      child: Icon(
        Icons.account_circle,
        size: 80,
        color: Color(int.parse(attributes['head']!.replaceFirst('#', '0xff'))),
      ),
    );
  }
}

Widget buildTherapyBotPage(BuildContext context) {
  final Map<String, String> avatarAttributes = {
    'env': '#40E83B',
    'head': '#85492C',
    'clo': '#f06'
  };

  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomAvatarWidget(attributes: avatarAttributes),
          SizedBox(height: 20),
          Text(
            "Hey! I'm TherapyBot",
            style: TextStyle(
              color: Colors.indigo.shade400,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "I'm here to help you love and nurture yourself",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          MouseRegion(
            onEnter: (event) => {},
            onExit: (event) => {},
            child: IconButton(
              icon: Icon(
                Icons.arrow_downward,
                color: Colors.indigo.shade400,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Placeholder()), // Replace with actual page
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
