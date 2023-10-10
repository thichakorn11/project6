import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart'; // เพิ่ม crypto package

import '../../entity/user_model.dart';
import '../../role.dart';
import '../../app_config.dart';

class AdminDetail extends StatefulWidget {
  const AdminDetail({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  AdminDetailState createState() => AdminDetailState();
}

class AdminDetailState extends State<AdminDetail> {
  List<Role> roles = [];
  int? roleValue; // Make it nullable

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _telController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    fetchRoles();
    if (widget.userId != 0) {
      fetchUser();
    }
    super.initState();
  }

  Future<void> fetchRoles() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.SERVICE_URL}/api/roles"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
    );

    final json = jsonDecode(response.body);

    List<Role> store = List<Role>.from(json["data"].map((item) {
      return Role.fromJSON(item);
    }));

    setState(() {
      roles = store;
      if (roles.isNotEmpty) {
        roleValue = roles[0].roleId; // Set default value
      }
    });
  }

  Future<void> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.SERVICE_URL}/api/user/${widget.userId}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json.containsKey("data") && json["data"].isNotEmpty) {
        final user = User.fromJSON(json["data"][0]);

        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _addressController.text = user.address;
          _telController.text = user.tel;
          _usernameController.text = user.userName;
          _passwordController.text = ''; // เราไม่ต้องแสดงรหัสผ่าน
          roleValue = user.roleId;
        });
      }
    }
  }

  String encodePassword(String password) {
    final bytes = utf8.encode(password); // Convert the password to bytes
    final digest = md5.convert(bytes); // Calculate the MD5 hash
    return digest
        .toString(); // Get the hexadecimal string representation of the hash
  }

  Future<bool> createAdmin() async {
    final prefs = await SharedPreferences.getInstance();

    String password =
        encodePassword(_passwordController.text); // เข้ารหัสรหัสผ่าน

    final response = await http.post(
      Uri.parse("${AppConfig.SERVICE_URL}/api/user/add"),
      headers: <String, String>{
        'Content-Type': 'application/json', // เพิ่ม Content-Type ให้ถูกต้อง
        'Accept': 'application/json', // เพิ่ม Accept ให้ถูกต้อง
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
      body: jsonEncode(<String, dynamic>{
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'tel': _telController.text,
        'user_name': _usernameController.text,
        'password': password, // ใช้รหัสผ่านที่ถูกเข้ารหัสแล้ว
        'role_id': roleValue.toString(),
      }),
    );

    final json = jsonDecode(response.body);

    if (json["result"]) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateAdmin() async {
    final prefs = await SharedPreferences.getInstance();

    String password =
        encodePassword(_passwordController.text); // เข้ารหัสรหัสผ่าน

    final response = await http.post(
      Uri.parse("${AppConfig.SERVICE_URL}/api/user/update"),
      headers: <String, String>{
        'Content-Type': 'application/json', // เพิ่ม Content-Type ให้ถูกต้อง
        'Accept': 'application/json', // เพิ่ม Accept ให้ถูกต้อง
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': widget.userId.toString(),
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'tel': _telController.text,
        'user_name': _usernameController.text,
        'password': password, // ใช้รหัสผ่านที่ถูกเข้ารหัสแล้ว
        'role_id': roleValue.toString(),
      }),
    );

    final json = jsonDecode(response.body);

    if (json["result"]) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
    TextInputFormatter? inputFormatter,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      keyboardType: keyboardType,
      inputFormatters: inputFormatter != null ? [inputFormatter] : null,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(
          prefixIcon,
          color: const Color.fromARGB(179, 8, 8, 8),
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.9),
        ),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.solid,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget getForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildTextField(
            controller: _nameController,
            label: 'ชื่อ-นามสกุล',
            prefixIcon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกชื่อ-นามสกุล';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _emailController,
            label: 'อีเมล',
            prefixIcon: Icons.email,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกอีเมล';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _telController,
            label: 'เบอร์โทรศัพท์',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.number,
            inputFormatter: FilteringTextInputFormatter.digitsOnly,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกเบอร์โทรศัพท์';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _addressController,
            label: 'ที่อยู่',
            prefixIcon: Icons.home,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกที่อยู่';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _usernameController,
            label: 'ชื่อผู้ใช้งาน',
            prefixIcon: Icons.person_2_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกชื่อผู้ใช้งาน';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _passwordController,
            label: 'รหัสผ่าน',
            prefixIcon: Icons.lock,
            isPassword: true,
          ),
          const SizedBox(height: 10),
          // const Text("Role"),
          // getRoleDropdown(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool result = false;

                    if (widget.userId == 0) {
                      result = await createAdmin();
                    } else {
                      result = await updateAdmin();
                    }

                    if (!result) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text('ไม่สามารถบันทึกข้อมูล'),
                          );
                        },
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  fixedSize: Size(150, 50),
                ),
                child: const Text(
                  'บันทึก',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  fixedSize: Size(150, 50),
                ),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget getRoleDropdown() {
  //   return DropdownButton<int>(
  //     value: roleValue,
  //     items: roles.map((role) {
  //       return DropdownMenuItem<int>(
  //         value: role.roleId,
  //         child: Text(role.roleName),
  //       );
  //     }).toList(),
  //     onChanged: (int? newValue) {
  //       setState(() {
  //         roleValue = newValue;
  //       });
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดแอดมิน'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        color: const Color(0xFFFFDCDF),
        child: Center(
          child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: SingleChildScrollView(
              child: getForm(),
            ),
          ),
        ),
      ),
    );
  }
}
