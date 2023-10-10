import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'category.dart';
import 'package:flutter_application_3/app_config.dart';
import 'package:flutter_application_3/screens/login/reusable_widget.dart';
// import 'package:keyboard_actions/keyboard_actions.dart';
// import 'package:flutter_application_3/screens/login/color_utils.dart';

class CategoryDetail extends StatefulWidget {
  const CategoryDetail({Key? key, required this.categoryId}) : super(key: key);
  final int categoryId;

  @override
  CategoryDetailState createState() => CategoryDetailState();
}

class CategoryDetailState extends State<CategoryDetail> {
  // Fields
  List<Category> category = [];
  int? categoryId; // Make it nullable

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();

  //  Methods
  @override
  void initState() {
    fetchCategory();

    if (widget.categoryId != 0) {
      fetchCategory1();
    }
    super.initState();
  }

  // API Requests
  Future<void> fetchCategory() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.SERVICE_URL}/api/category"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
    );

    final json = jsonDecode(response.body);

    List<Category> store = List<Category>.from(json["data"].map((item) {
      return Category.fromJSON(item);
    }));

    setState(() {
      category = store;
      if (category.isNotEmpty) {
        categoryId = category[0].categoryId; // Set default value
      }
    });
  }

  Future<bool> createCategory() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("${AppConfig.SERVICE_URL}/api/category/add"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
      body: jsonEncode(<String, String>{
        'category_name': _nameController.text,
        'imageUrl': _imageController.text,
      }),
    );

    final json = jsonDecode(response.body);

    if (json["result"]) {
      return true;
    } else {
      return false;
    }
  }


  Future<bool> updateCategory() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
        Uri.parse("${AppConfig.SERVICE_URL}/api/category/update"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("access_token")}',
        },
        body: jsonEncode(<String, String>{
          'category_id': widget.categoryId.toString(),
          'category_name': _nameController.text,
          'imageUrl': _imageController.text,
        }));

    final json = jsonDecode(response.body);

    if (json["result"]) {
      return true;
    } else {
      return false;
    }
  }

  void fetchCategory1() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.SERVICE_URL}/api/category/${widget.categoryId}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
    );

    final json = jsonDecode(response.body);
    final category = Category.fromJSON(json["data"][0]);

    setState(() {
      _nameController.text = category.categoryName;
      _imageController.text = category.imageUrl;
    });
  }

  // Widgets
  Widget getProductTypeDropdown() {
    return DropdownButton<int>(
      value: categoryId,
      items: category.map((category) {
        return DropdownMenuItem<int>(
          value: category.categoryId,
          child: Text(category.categoryName),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          categoryId = newValue;
        });
      },
    );
  }

  Widget getForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          logoWidget1("assets/images/logo3.png"),
          // const Text("ชื่อสินค้า"),
          TextFormField(
            controller: _nameController,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black.withOpacity(0.9)),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.note_alt,
                color: const Color.fromARGB(179, 8, 8, 8),
              ),
              labelText: "ชื่อหมวดหมู่สินค้า",
              labelStyle: TextStyle(
                  color: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.9)),
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide:
                      const BorderSide(width: 0, style: BorderStyle.solid)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณากรอกหมวดหมู่สินค้า";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _imageController,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black.withOpacity(0.9)),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.note_alt,
                color: const Color.fromARGB(179, 8, 8, 8),
              ),
              labelText: "ชื่อรูปภาพหมวดหมู่)",
              labelStyle: TextStyle(
                  color: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.9)),
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide:
                      const BorderSide(width: 0, style: BorderStyle.solid)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณากรอกชื่อรูปภาพหมวดหมู่";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // Adjust alignment as needed
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool result = false;

                    if (widget.categoryId == 0) {
                      result = await createCategory();
                    } else {
                      result = await updateCategory();
                    }

                    if (!result) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text("ไม่สามารถบันทึกข้อมูล"),
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
                  "บันทึก",
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
                  "ยกเลิก",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("รายละเอียดหมวดหมู่สินค้า"),
        backgroundColor: Colors.red,
      ),
      body: Container(
        color: const Color(0xFFFFDCDF), // สีพื้นหลังสี
        child: Center(
          child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: getForm(),
          ),
        ),
      ),
    );
  }
}
