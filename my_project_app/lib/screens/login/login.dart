// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, override_on_non_overriding_member, prefer_const_constructors
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/product/productlistscreen.dart';
// import 'package:flutter_application_3/product_detail.dart';
// import 'package:flutter_application_3/product_list.dart';
import 'package:flutter_application_3/user_detail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_3/app_config.dart';
import 'package:flutter_application_3/screens/login/reusable_widget.dart';
import 'package:flutter_application_3/screens/login/color_utils.dart';
// import 'package:flutter_application_3/user_detail.dart';
import 'package:flutter_application_3/home_owner.dart';
import 'package:flutter_application_3/home_admin.dart';
// import 'package:flutter_application_4/screens/app_config.dart';
// import 'dart:html';
// import 'dart:js';

class Login extends StatefulWidget {
  final bool logout = false;
  const Login({Key? key, bool? logout}) : super(key: key);

  @override
  void initState() {
    //Logout();
  }
  LoginState createState() {
    return LoginState();
  }
}

Future<void> Logout() async {
  final response = await http.post(
    Uri.parse('''${AppConfig.SERVICE_URL}/api/logout'''),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json'
    },
  );

  final json = jsonDecode(response.body);

  print(json);
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final _usernameValueController = TextEditingController();
  final _passwordValueController = TextEditingController();

  String authenToken = "----";

  String getMD5(String baseString) {
    return md5.convert(utf8.encode(baseString)).toString();
  }

  Future<bool> authenRequest(String user_name) async {
    var post = http.post(
        Uri.parse("${AppConfig.SERVICE_URL}/api/authen_request"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json'
        },
        body: jsonEncode(<String, String>{'user_name': getMD5(user_name)}));
    var post2 = post;
    final http.Response response = await newMethod(post2);

    final json = jsonDecode(response.body);

    print(json);

    if (json["result"]) {
      authenToken = json["auth_token"];
      return true;
    }

    return false;
  }

  Future<http.Response> newMethod(Future<http.Response> post) => post;

  Future<bool> doLogin(String user_name, String password) async {
    final authenRequestResult = await authenRequest(user_name);

    print(authenToken);

    if (!authenRequestResult) {
      return false;
    }

    final accessRequesResult = await accesRequest(user_name, password);

    return accessRequesResult;
  }

  Future<bool> accesRequest(String user_name, String password) async {
    String baseString = "${user_name}&${getMD5(password)}";
    String authenSignature = getMD5(baseString);

    print(user_name);
    print(password);

    final response = await http.post(
        Uri.parse('''${AppConfig.SERVICE_URL}/api/access_request'''),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json'
        },
        body: jsonEncode(<String, String>{
          'auth_signature': authenSignature,
          'auth_token': authenToken
        }));

    final json = jsonDecode(response.body);

    print(json);

    if (json["result"]) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString("access_token", json["access_token"]);
      await prefs.setInt("user_id", json["data"]["user_id"]);
      await prefs.setString("user_name", user_name);
      await prefs.setString("name", json["data"]["name"]);
      await prefs.setString("email", json["data"]["email"]);
      await prefs.setInt("role_id", json["data"]["role_id"]);
      await prefs.setString("role_name", json["data"]["role_name"]);

      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // _usernameValueController.text = "grace";
    // _passwordValueController.text = "456789";

    return Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              hexStringToColor("FFDCDF"),
              hexStringToColor("FFDCDF"),
              hexStringToColor("FFDCDF")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).size.height * 0.1, 10, 0),
                    // appBar: AppBar(title: Text("Login")),
                    // body: Center(
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            logoWidget("assets/images/logo.png"),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _usernameValueController,
                              cursorColor: Colors.black,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person_outlined,
                                  color: const Color.fromARGB(179, 8, 8, 8),
                                ),
                                labelText: "ชื่อผู้ใช้",
                                labelStyle: TextStyle(
                                    color: const Color.fromARGB(255, 8, 8, 8)
                                        .withOpacity(0.9)),
                                filled: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                fillColor: Colors.white.withOpacity(0.8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: const BorderSide(
                                        width: 0, style: BorderStyle.solid)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาใส่ Username';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _passwordValueController,
                              cursorColor: Colors.black,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: const Color.fromARGB(179, 8, 8, 8),
                                ),
                                labelText: "รหัสผ่าน",
                                labelStyle: TextStyle(
                                    color: const Color.fromARGB(255, 8, 8, 8)
                                        .withOpacity(0.9)),
                                filled: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                fillColor: Colors.white.withOpacity(0.8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: const BorderSide(
                                        width: 0, style: BorderStyle.solid)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาใส่ Password';
                                }

                                return null;
                              },
                              obscureText: true,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  bool loginResult = await doLogin(
                                      _usernameValueController.text,
                                      _passwordValueController.text);

                                  if (!loginResult) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                              content: Text(
                                                  "Username หรือ Password ไม่ถูกต้อง"));
                                        });
                                  } else {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    int userRole = prefs.getInt("role_id") ?? 3;

                                    if (userRole == 1) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Home_admin()),
                                      );
                                    } else if (userRole == 2) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Home_owner()),
                                      );
                                    } else if (userRole == 3) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProductListScreen()),
                                      );
                                    } else {
                                      // // สำหรับบทบาทอื่น ๆ ที่คุณต้องการจัดการ
                                      // Navigator.pushReplacement(
                                      //   context,
                                      //   MaterialPageRoute(builder: (context) => OtherPage()),
                                      //
                                    }
                                  }
                                }
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateColor.resolveWith((states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Color.fromARGB(255, 252, 250, 250);
                                    }
                                    return const Color.fromARGB(
                                        255, 253, 84, 72);
                                  }),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)))),
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('หากไม่มีบัญชีผู้ใช้ '),
                                InkWell(
                                  child: Text(
                                    'สมัครสมาชิก',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  onTap: () {
                                    // Navigate to the UserDetail screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserDetail(
                                          userId:
                                              123, // Replace with the actual userId
                                          roleId:
                                              3, // Replace with the actual roleId
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ],
                        ))))));
  }
}

// ignore: dead_code
// throw UnimplementedError();
