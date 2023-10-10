// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// import 'entity/product.dart';
// import 'category.dart';
// import 'package:flutter_application_3/app_config.dart';
// import 'package:flutter_application_3/screens/login/reusable_widget.dart';
// // import 'package:keyboard_actions/keyboard_actions.dart';
// // import 'package:flutter_application_3/screens/login/color_utils.dart';

// class StockDetail extends StatefulWidget {
//   const StockDetail({Key? key, required this.productId}) : super(key: key);
//   final int productId;

//   @override
//   StockDetailState createState() => StockDetailState();
// }

// class StockDetailState extends State<StockDetail> {
//   // Fields
//   List<Category> category = [];
//   int? categoryId; // Make it nullable

//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _imgesUrlController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _stockController = TextEditingController();

//   //  Methods
//   @override
//   void initState() {
//     fetchCategory();

//     if (widget.productId != 0) {
//       fetchProduct1();
//     }
//     super.initState();
//   }

//   // API Requests
//   Future<void> fetchCategory() async {
//     final prefs = await SharedPreferences.getInstance();

//     final response = await http.get(
//       Uri.parse("${AppConfig.SERVICE_URL}/api/category"),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer ${prefs.getString("access_token")}',
//       },
//     );

//     final json = jsonDecode(response.body);

//     List<Category> store = List<Category>.from(json["data"].map((item) {
//       return Category.fromJSON(item);
//     }));

//     setState(() {
//       category = store;
//       if (category.isNotEmpty) {
//         categoryId = category[0].categoryId; // Set default value
//       }
//     });
//   }

//   void fetchProduct() async {
//     final prefs = await SharedPreferences.getInstance();

//     final response = await http.get(
//       Uri.parse("${AppConfig.SERVICE_URL}/api/products/${widget.productId}"),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer ${prefs.getString("access_token")}',
//       },
//     );

//     final json = jsonDecode(response.body);
//     final product = Product.fromJSON(json["data"][0]);

//     setState(() {
//       _nameController.text = product.productName;
//       _imgesUrlController.text = product.imgesUrl;
//       _priceController.text = product.price.toString();
//       _stockController.text = product.stock.toString();
//     });
//   }

//   Future<bool> createProduct() async {
//     final prefs = await SharedPreferences.getInstance();

//     final response = await http.post(
//       Uri.parse("${AppConfig.SERVICE_URL}/api/products/add"),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer ${prefs.getString("access_token")}',
//       },
//       body: jsonEncode(<String, String>{
//         'product_name': _nameController.text,
//         'imgesUrl': _imgesUrlController.text,
//         'category_id': categoryId.toString(),
//         'price': _priceController.text,
//         'stock': _stockController.text,
//       }),
//     );

//     final json = jsonDecode(response.body);

//     if (json["result"]) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   Future<bool> updateProduct() async {
//     final prefs = await SharedPreferences.getInstance();

//     final response = await http.post(
//         Uri.parse("${AppConfig.SERVICE_URL}/api/products/update"),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer ${prefs.getString("access_token")}',
//         },
//         body: jsonEncode(<String, String>{
//           'product_id': widget.productId.toString(),
//           'product_name': _nameController.text,
//           'imgesUrl': _imgesUrlController.text,
//           'category_id': categoryId.toString(),
//           'price': _priceController.text,
//           'stock': _stockController.text,
//         }));

//     final json = jsonDecode(response.body);

//     if (json["result"]) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   void fetchProduct1() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // ignore: unused_local_variable
//     final response = await http.get(
//         Uri.parse("${AppConfig.SERVICE_URL}/api/products/${widget.productId}"),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer ${prefs.getString("access_token")}'
//         });

//     final json = jsonDecode(response.body);

//     print(json["data"][0]);

//     Product product = Product.fromJSON(json["data"][0]);

//     setState(() {
//       _nameController.text = product.productName;
//       _imgesUrlController.text = product.imgesUrl;
//       _priceController.text = product.price.toString();
//       _stockController.text = product.stock.toString();
//     });
//   }

//   // Widgets
//   Widget getProductTypeDropdown() {
//     return DropdownButton<int>(
//       value: categoryId,
//       items: category.map((category) {
//         return DropdownMenuItem<int>(
//           value: category.categoryId,
//           child: Text(category.categoryName),
//         );
//       }).toList(),
//       onChanged: (int? newValue) {
//         setState(() {
//           categoryId = newValue;
//         });
//       },
//     );
//   }

//   Widget getForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           logoWidget1("assets/images/logo3.png"),
//           // const Text("ชื่อสินค้า"),
//           TextFormField(
//             controller: _nameController,
//             cursorColor: Colors.black,
//             style: TextStyle(color: Colors.black.withOpacity(0.9)),
//             decoration: InputDecoration(
//               prefixIcon: Icon(
//                 Icons.note_alt,
//                 color: const Color.fromARGB(179, 8, 8, 8),
//               ),
//               labelText: "ชื่อสินค้า",
//               labelStyle: TextStyle(
//                   color: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.9)),
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.never,
//               fillColor: Colors.white.withOpacity(0.8),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                   borderSide:
//                       const BorderSide(width: 0, style: BorderStyle.solid)),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "กรุณากรอกชื่อสินค้า";
//               }
//               return null;
//             },
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           TextFormField(
//             controller: _imgesUrlController,
//             cursorColor: Colors.black,
//             style: TextStyle(color: Colors.black.withOpacity(0.9)),
//             decoration: InputDecoration(
//               prefixIcon: Icon(
//                 Icons.image,
//                 color: const Color.fromARGB(179, 8, 8, 8),
//               ),
//               labelText: "ชื่อรูปภาพ",
//               labelStyle: TextStyle(
//                   color: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.9)),
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.never,
//               fillColor: Colors.white.withOpacity(0.8),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                   borderSide:
//                       const BorderSide(width: 0, style: BorderStyle.solid)),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "กรุณากรอกชื่อรูปภาพ";
//               }
//               return null;
//             },
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           const Text("หมวดหมู่สินค้า"),
//           getProductTypeDropdown(),
//           const SizedBox(
//             height: 10,
//           ),
//           // const Text("ราคา"),
//           TextFormField(
//             controller: _priceController,
//             cursorColor: Colors.black,
//             style: TextStyle(color: Colors.black.withOpacity(0.9)),
//             decoration: InputDecoration(
//               prefixIcon: Icon(
//                 Icons.price_change,
//                 color: const Color.fromARGB(179, 8, 8, 8),
//               ),
//               labelText: "ราคา",
//               labelStyle: TextStyle(
//                   color: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.9)),
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.never,
//               fillColor: Colors.white.withOpacity(0.8),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                   borderSide:
//                       const BorderSide(width: 0, style: BorderStyle.solid)),
//             ),
//             keyboardType: TextInputType.number,
//             inputFormatters: <TextInputFormatter>[
//               FilteringTextInputFormatter.digitsOnly,
//             ],
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "กรุณากรอกราคาสินค้า";
//               }
//               return null;
//             },
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           // const Text("จำนวน"),
//           TextFormField(
//             controller: _stockController,
//             cursorColor: Colors.black,
//             style: TextStyle(color: Colors.black.withOpacity(0.9)),
//             decoration: InputDecoration(
//               prefixIcon: Icon(
//                 Icons.inventory,
//                 color: const Color.fromARGB(179, 8, 8, 8),
//               ),
//               labelText: "จำนวน",
//               labelStyle: TextStyle(
//                   color: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.9)),
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.never,
//               fillColor: Colors.white.withOpacity(0.8),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                   borderSide:
//                       const BorderSide(width: 0, style: BorderStyle.solid)),
//             ),
//             keyboardType: TextInputType.number,
//             inputFormatters: <TextInputFormatter>[
//               FilteringTextInputFormatter.digitsOnly,
//             ],
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "กรุณากรอกจำนวนสินค้า";
//               }
//               return null;
//             },
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceEvenly, // Adjust alignment as needed
//             children: [
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     bool result = false;

//                     if (widget.productId == 0) {
//                       result = await createProduct();
//                     } else {
//                       result = await updateProduct();
//                     }

//                     if (!result) {
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return const AlertDialog(
//                             content: Text("ไม่สามารถบันทึกข้อมูล"),
//                           );
//                         },
//                       );
//                     } else {
//                       Navigator.pop(context);
//                     }
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.green,
//                   fixedSize: Size(150, 50),
//                 ),
//                 child: const Text(
//                   "บันทึก",
//                   style: TextStyle(
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.red,
//                   fixedSize: Size(150, 50),
//                 ),
//                 child: const Text(
//                   "ยกเลิก",
//                   style: TextStyle(
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("รายละเอียดสินค้า"),
//         backgroundColor: Colors.red,
//       ),
//       body: Container(
//         color: const Color(0xFFFFDCDF), // สีพื้นหลังสี
//         child: Center(
//           child: Container(
//             alignment: Alignment.topCenter,
//             padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//             child: getForm(),
//           ),
//         ),
//       ),
//     );
//   }
// }
