import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '/entity/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_3/app_config.dart';
import 'package:http/http.dart' as http;

class Delivery extends StatefulWidget {
  final List<dynamic> cartList;

  Delivery({Key? key, this.cartList= const []}) : super(key: key);
  @override
  _DeliveryState createState() => _DeliveryState();
 
}

class _DeliveryState extends State<Delivery> {

  String address = '';
  double amount = 0.0;
  String imagePath = '';
  File? selectedFile;
   User? user;
  String accessToken = '';
  int userId = 0;
  String userName = '';
  String name = '';
  String email = '';
  int roleId = 0;
  String roleName = '';
  String Total = '' ;

  void initState() {
    super.initState();
    fetchUser();
    print("===============");
    print(widget.cartList);
    Total = calculateTotalPrice();
  }

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  String calculateTotalPrice() {
    double total = 0;
    for (var cart in widget.cartList) {
      if (cart["isSelected"]) {
        total += (cart["amount"] * cart["price"]);
      }
    }

    return total.toStringAsFixed(2);
  }

  Future<bool> saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
  for (var cart in widget.cartList) {
      if (cart["isSelected"]) {
              final response = await http.post(
          Uri.parse("${AppConfig.SERVICE_URL}/api/order/add"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${prefs.getString("access_token")}',
          },
          body: jsonEncode(<String, String>{
            'user_id':"${prefs.getInt("user_id").toString()}", 
            'product_id':  cart['product_id'].toString(),
            'color_id': cart['color_id'].toString(), 
            'size_id': cart['size_id'].toString(), 
            'receipt_id': "1",
            'amount': cart['amount'].toString(), 
            'total':( cart['amount'] * cart["price"] ).toString()
            //order_status, 
            //transport_type
          }),
        );

        final json = jsonDecode(response.body);

        if (json["result"]) {
          return true;
        } else {
          return false;
        }
      }else{
        return false;
      }
    }

        return false;

  }


 



 Future<void> fetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(
      Uri.parse(
          "${AppConfig.SERVICE_URL}/api/users/${prefs.getInt("user_id")}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
    );
    final json = jsonDecode(response.body);
    print(json);

    // Read values from SharedPreferences
    setState(() {
     
      name = json["data"][0]["name"] ?? '';
      
   
      address = json["data"][0]["address"] ?? '';
     

    });
  }

  void _submitForm() {
    print('ชื่อ: $name');
    print('ที่อยู่: $address');
    print('จำนวนเงิน: $amount');
    if (selectedFile != null) {
      print('ไฟล์ที่เลือก: ${selectedFile!.path}');
    }
    saveOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แบบฟอร์มการจัดส่ง'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              // เพิ่มการทำงานเมื่อกดปุ่ม info ที่อยู่ข้างขวาบน
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ชื่อ',
              style: TextStyle(fontSize: 18),
            ),
            TextField( 
              controller: _nameController..text=name,
              decoration: InputDecoration(
                hintText: 'กรอกชื่อของคุณ',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'ที่อยู่จัดส่ง',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _addressController..text=address,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'กรอกที่อยู่จัดส่งของคุณ',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  address = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'จำนวนเงิน',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _amountController..text=Total,
              decoration: InputDecoration(
                hintText: 'กรอกจำนวนเงิน',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                );
                if (result != null) {
                  selectedFile = File(result.files.single.path!);
                  setState(() {
                    imagePath = result.files.single.name;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_upload,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'เลือกไฟล์',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'ไฟล์ที่เลือก: $imagePath',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                label: Text(
                  'ส่งข้อมูล',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
