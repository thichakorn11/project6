import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_3/app_config.dart';
import 'entity/user_model.dart';
import 'package:flutter_application_3/user_edit.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  String accessToken = '';
  int userId = 0;
  String userName = '';
  String name = '';
  String email = '';
  int roleId = 0;
  String roleName = '';

  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Read values from SharedPreferences
    setState(() {
      accessToken = prefs.getString("access_token") ?? '';
      userId = prefs.getInt("user_id") ?? 0;
      userName = prefs.getString("user_name") ?? '';
      name = prefs.getString("name") ?? '';
      email = prefs.getString("email") ?? '';
      roleId = prefs.getInt("role_id") ?? 0;
      roleName = prefs.getString("role_name") ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('โปรไฟล์ของฉัน'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue, // สีของพื้นหลังของไอคอน
              child: Icon(
                Icons.person, // ไอคอนที่คุณต้องการใช้
                size: 70, // ขนาดของไอคอน
                color: Colors.white, // สีของไอคอน
              ),
            ),
            SizedBox(height: 16),
            Text(
              "${userName}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // กดปุ่มแก้ไขโปรไฟล์
                // คุณสามารถเพิ่มโค้ดเปิดหน้าแก้ไขโปรไฟล์ที่นี่
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEdit(
                      userId: userId, // Replace with the actual userId
                      roleId: roleId, // Replace with the actual roleId
                    ),
                  ),
                );
              },
              child: Text('แก้ไขโปรไฟล์'),
            ),
          ],
        ),
      ),
    );
  }
}
