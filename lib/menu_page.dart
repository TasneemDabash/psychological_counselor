<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'language_page.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isDarkMode = true; // מצב כהה כברירת מחדל

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Center(
                child: Text(
                  'Menu Options',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                _shareApp();
              },
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LanguagePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode), // סימן מצב
              title: Text('Mode: ${isDarkMode ? "Black" : "White"}'),
              onTap: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to the Menu!'),
      ),
    );
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality will be implemented here.')),
    );
  }
}
=======
// // import 'package:flutter/material.dart';
// // import 'profile_page.dart';
// // import 'settings_page.dart';
// // import 'language_page.dart';
// // import 'random_avatar.dart';
// // import 'dart:developer';

// // class MenuPage extends StatefulWidget {
// //   @override
// //   _MenuPageState createState() => _MenuPageState();
// // }

// // class _MenuPageState extends State<MenuPage> {
// //   bool isDarkMode = true; // מצב כהה כברירת מחדל
// //   List<Widget> _painters = []; // Define _painters to store generated avatars
// //   TextEditingController _controller = TextEditingController(); // Define _controller to manage SVG text

// //   @override
// //   void dispose() {
// //     _controller.dispose(); // Dispose of the controller to prevent memory leaks
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Menu'),
// //       ),
// //       drawer: Drawer(
// //         child: ListView(
// //           children: [
// //             DrawerHeader(
// //               decoration: BoxDecoration(color: Colors.indigo.shade400),
// //               child: Center(
// //                 child: Text(
// //                   'Menu Options',
// //                   style: TextStyle(fontSize: 24, color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //             ListTile(
// //               leading: Icon(Icons.person),
// //               title: Text('My Profile'),
// //               onTap: () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(builder: (context) => ProfilePage()),
// //                 );
// //               },
// //             ),
// //             ListTile(
// //               leading: Icon(Icons.settings),
// //               title: Text('Settings'),
// //               onTap: () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(builder: (context) => SettingsPage()),
// //                 );
// //               },
// //             ),
// //             ListTile(
// //               leading: Icon(Icons.share),
// //               title: Text('Share'),
// //               onTap: () {
// //                 _shareApp();
// //               },
// //             ),
// //             ListTile(
// //               leading: Icon(Icons.language),
// //               title: Text('Language'),
// //               onTap: () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(builder: (context) => LanguagePage()),
// //                 );
// //               },
// //             ),
// //             ListTile(
// //               leading: Icon(
// //                   isDarkMode ? Icons.dark_mode : Icons.light_mode), // סימן מצב
// //               title: Text('Mode: ${isDarkMode ? "Black" : "White"}'),
// //               onTap: () {
// //                 setState(() {
// //                   isDarkMode = !isDarkMode;
// //                 });
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //       body: Center(
// //         child: Wrap(
// //           alignment: WrapAlignment.center,
// //           spacing: 20,
// //           runSpacing: 20,
// //           children: [
// //             FloatingActionButton(
// //               onPressed: () {
// //                 String svg = RandomAvatarString(
// //                   DateTime.now().toIso8601String(),
// //                   trBackground: false,
// //                 );
// //                 log(svg);

// //                 _painters.add(
// //                   RandomAvatar(
// //                     DateTime.now().toIso8601String(),
// //                     height: 50,
// //                     width: 52,
// //                   ),
// //                 );
// //                 _controller.text = svg;
// //                 setState(() {});
// //               },
// //               tooltip: 'Generate',
// //               child: const Icon(Icons.gesture),
// //             ),
// //             ..._painters,
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   void _shareApp() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Share functionality will be implemented here.')),
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'profile_page.dart';
// import 'settings_page.dart';
// import 'language_page.dart';
// import 'dart:developer';

// class MenuPage extends StatefulWidget {
//   @override
//   _MenuPageState createState() => _MenuPageState();
// }

// class _MenuPageState extends State<MenuPage> {
//   bool isDarkMode = true; // Default to dark mode
//   List<Widget> _painters = []; // Store generated avatars
//   TextEditingController _controller = TextEditingController(); // Manage SVG text

//   @override
//   void dispose() {
//     _controller.dispose(); // Dispose controller to prevent memory leaks
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Menu'),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.indigo.shade400),
//               child: Center(
//                 child: Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundColor: Colors.white,
//                       child: Icon(
//                         Icons.person,
//                         size: 40,
//                         color: Colors.indigo.shade400,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'Menu Options',
//                       style: TextStyle(fontSize: 24, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.person),
//               title: Text('My Profile'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ProfilePage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.settings),
//               title: Text('Settings'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SettingsPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.share),
//               title: Text('Share'),
//               onTap: () {
//                 _shareApp();
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.language),
//               title: Text('Language'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => LanguagePage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(
//                   isDarkMode ? Icons.dark_mode : Icons.light_mode), // Mode icon
//               title: Text('Mode: ${isDarkMode ? "Black" : "White"}'),
//               onTap: () {
//                 setState(() {
//                   isDarkMode = !isDarkMode;
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Center(
//         child: Wrap(
//           alignment: WrapAlignment.center,
//           spacing: 20,
//           runSpacing: 20,
//           children: [
//             FloatingActionButton(
//               onPressed: () {
//                 // String svg = RandomAvatarString(
//                 //   DateTime.now().toIso8601String(),
//                 //   trBackground: false,
//                 // );
//                 // log(svg);

//                 // _painters.add(
//                 //   RandomAvatar(
//                 //     DateTime.now().toIso8601String(),
//                 //     height: 50,
//                 //     width: 52,
//                 //   ),
//                 // );
//                 // _controller.text = svg;
//                 // setState(() {});
//               },
//               tooltip: 'Generate',
//               child: const Icon(Icons.gesture),
//             ),
//             ..._painters,
//           ],
//         ),
//       ),
//     );
//   }

//   void _shareApp() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Share functionality will be implemented here.')),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        backgroundColor: Colors.indigo.shade400,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 400,
              child: ModelViewer(
                src: 'https://psychological-counselor.readyplayer.me/avatar.glb',
                alt: "3D Avatar",
                ar: true,
                autoRotate: true,
                cameraControls: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/menu',
    routes: {
      '/menu': (context) => MenuPage(),
      '/some_other_page': (context) => SomeOtherPage(), 
    },
  ));
}

class SomeOtherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Some Other Page'),
        backgroundColor: Colors.indigo.shade400,
      ),
      body: Center(
        child: Text('This is another page!'),
      ),
    );
  }
}
>>>>>>> 45892dbe463b398cc8270c315b487359cd152f8a
