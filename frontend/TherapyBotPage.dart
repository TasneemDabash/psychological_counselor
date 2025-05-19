import 'package:flutter/material.dart';
import 'package:phychological_counselor/main/navigation/routes/name.dart';

class TherapyBotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment(0, 0.3), // X=0 (אמצע), Y=0.3 (קצת למטה)
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Hey! I'm Counseling chatbot",
              style: TextStyle(
                color: Colors.indigo.shade400,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "I'm here to help you love and nurture yourself",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            IconButton(
              icon: Icon(
                Icons.arrow_downward,
                color: Colors.indigo.shade400,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
