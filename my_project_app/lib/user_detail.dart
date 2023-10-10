import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_3/app_config.dart';
import 'package:flutter_application_3/entity/user_model.dart';
import 'package:crypto/crypto.dart';

class UserDetail extends StatefulWidget {
  const UserDetail({Key? key, required this.userId, required int roleId})
      : super(key: key);

  final int userId;

  @override
  UserDetailState createState() => UserDetailState();
}

class UserDetailState extends State<UserDetail> {
  // Fields
  List<User> roles = [];
  int? roleId = 3;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _telController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    //fetchRole();
    super.initState();
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  // API Requests
  Future<void> fetchRole() async {
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

    print(">>$json");

    List<User> store = List<User>.from(json["data"].map((item) {
      return User.fromJSON(item);
    }));

    setState(() {
      roles = store;
    });
  }

  Future<bool> createUser() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("${AppConfig.SERVICE_URL}/api/users/add"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
      body: jsonEncode(<String, String>{
        'name': _nameController.text,
        'role_id': roleId.toString(),
        'email': _emailController.text,
        'tel': _telController.text,
        'address': _addressController.text,
        'user_name': _usernameController.text,
        'password': generateMd5(_passwordController.text),
      }),
    );

    final json = jsonDecode(response.body);

    if (json["result"]) {
      return true;
    } else {
      return false;
    }
  }

  // Widgets
  Widget getRoleDropdown() {
    return DropdownButton<int>(
      value: roleId,
      items: roles.map((roles) {
        return DropdownMenuItem<int>(
          value: roles.roleId,
          child: Text(roles.roleName),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          roleId = newValue!;
        });
      },
    );
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
          color: Colors.grey[600],
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
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
            label: "ชื่อ-นามสกุล",
            prefixIcon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณากรอกชื่อ-นามสกุล";
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          buildTextField(
            controller: _emailController,
            label: "อีเมล",
            prefixIcon: Icons.email,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณากรอกอีเมล";
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          buildTextField(
            controller: _telController,
            label: "เบอร์โทรศัพท์",
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.number,
            inputFormatter: FilteringTextInputFormatter.digitsOnly,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณากรอกเบอร์โทรศัพท์";
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          buildTextField(
            controller: _addressController,
            label: "ที่อยู่",
            prefixIcon: Icons.home,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณากรอกที่อยู่";
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          buildTextField(
            controller: _usernameController,
            label: "ชื่อผู้ใช้งาน",
            prefixIcon: Icons.person_2_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณากรอกชื่อผู้ใช้งาน";
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          buildTextField(
            controller: _passwordController,
            label: "รหัสผ่าน",
            prefixIcon: Icons.lock,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณากรอกรหัสผ่าน";
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool result = await createUser();

                    if (!result) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text("ไม่สามารถสมัครสมาชิกได้"),
                          );
                        },
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // สีพื้นหลังของปุ่มเมื่อปกติ
                  onPrimary: Colors.white, // สีของตัวอักษรบนปุ่ม
                  elevation: 3, // ความยกของปุ่ม (เงา)
                  minimumSize: Size(150, 40), // ขนาดของปุ่ม
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // ลักษณะรูปร่างของปุ่ม
                  ),
                ),
                child: Text(
                  "บันทึก",
                  style: TextStyle(fontSize: 18), // ขนาดตัวอักษรบนปุ่ม
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // สีพื้นหลังของปุ่มเมื่อปกติ
                  onPrimary: Colors.white, // สีของตัวอักษรบนปุ่ม
                  elevation: 3, // ความยกของปุ่ม (เงา)
                  minimumSize: Size(150, 40), // ขนาดของปุ่ม
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // ลักษณะรูปร่างของปุ่ม
                  ),
                ),
                child: Text(
                  "ยกเลิก",
                  style: TextStyle(fontSize: 18), // ขนาดตัวอักษรบนปุ่ม
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDCDF),
      appBar: AppBar(
        title: Text("สมัครสมาชิก"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
