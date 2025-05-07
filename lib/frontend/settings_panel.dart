// 📄 קובץ: settings_panel.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
=======
import 'dart:convert';
import 'package:http/http.dart' as http;
>>>>>>> 486fe11 (Initial clean commit after removing all secrets)

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({Key? key}) : super(key: key);

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _docId;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadUserProfile();
  }
=======
      testEmailAPI(); // ← קריאה לפונקציה מיד כשהמסך עולה

    _loadUserProfile();
  }
  void testEmailAPI() async {
  final email = 'ranim.muali0212@gmail.com';
  final apiKey = '2a31e8bff61647fdbb9f65c3aacf628d';
  final url = Uri.parse(
      'https://emailvalidation.abstractapi.com/v1/?api_key=$apiKey&email=$email');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("📥 תגובה מהשרת:");
    print(data);
  } else {
    print("❌ שגיאה בחיבור לשרת: ${response.statusCode}");
  }
}

>>>>>>> 486fe11 (Initial clean commit after removing all secrets)

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        setState(() {
          _docId = doc.id;
          _nameController.text = data['firstName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _ageController.text = (data['age'] ?? '').toString();
        });
      }
    }
  }

  Future<void> _updateUserProfile() async {
    if (_docId == null) return;

    await FirebaseFirestore.instance.collection('users').doc(_docId).update({
      'firstName': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
    });

    if (context.mounted) Navigator.of(context).pop();
  }

  void _showProfileDialog() async {
    await _loadUserProfile();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('👤 My Profile', style: TextStyle(color: Colors.lightBlueAccent)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 22),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.lightBlueAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
              ),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 22),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.lightBlueAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.orange, fontSize: 22),
                decoration: const InputDecoration(
                  labelText: 'Age',
                  labelStyle: TextStyle(color: Colors.orange),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('❌ Cancel', style: TextStyle(color: Colors.orange, fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: _updateUserProfile,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('💾 Save', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: ListView(
=======
Widget build(BuildContext context) {
  return Expanded( // ✅ הוספנו את זה כדי שה־Container יקבל גובה מתאים
    child: Container(
      width: 300,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: Column(
>>>>>>> 486fe11 (Initial clean commit after removing all secrets)
        children: [
          const Text("⚙️ Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

<<<<<<< HEAD
          ListTile(
            leading: const Icon(Icons.person_outline, size: 22),
            title: const Text("My Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            onTap: _showProfileDialog,
          ),

          // const Divider(),
          // const SizedBox(height: 10),

        ],
      ),
    );
  }
}
=======
          Expanded( // ✅ כדי שה־ListView לא יזרוק שגיאה
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, size: 22),
                  title: const Text("My Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  onTap: _showProfileDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
>>>>>>> 486fe11 (Initial clean commit after removing all secrets)
