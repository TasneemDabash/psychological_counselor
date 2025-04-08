import 'package:flutter/material.dart';
import 'package:phychological_counselor/frontend/SignUpPage.dart'; // היבוא של SignUpPage
import 'package:phychological_counselor/frontend/home_page.dart';
import 'package:phychological_counselor/main/navigation/routes/name.dart';


class TherapyBotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   'assets/images/favicon.png',
            //   width: 100,
            //   height: 100,
            //   fit: BoxFit.cover,
            //   errorBuilder: (context, error, stackTrace) {
            //     return Text(
            //       "Error loading image",
            //       style: TextStyle(color: Colors.red),
            //     );
            //   },
            // ),
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
                  // ניווט לעמוד SignUpPage
                  
                  Navigator.pushNamed(
                    context,AppRoutes.login
                
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 