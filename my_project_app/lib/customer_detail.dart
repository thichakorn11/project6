import 'package:flutter/material.dart';

class CustomerDetailScreen extends StatelessWidget {
  final dynamic customer;

  CustomerDetailScreen({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('โปรไฟล์ลูกค้า'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFDCDF), // เปลี่ยนสีพื้นหลัง
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xff6ae792),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'ชื่อ: ${customer["name"]}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // เปลี่ยนสีข้อความ
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // แสดงข้อมูลที่อยู่ในรูปแบบของ Card
                  CardInfo(title: 'ที่อยู่', content: customer['address']),
                  CardInfo(title: 'เบอร์โทร', content: customer['tel']),
                  CardInfo(title: 'อีเมล', content: customer['email']),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// สร้างวิดเจ็ตสำหรับแสดงข้อมูลในรูปแบบของ Card
class CardInfo extends StatelessWidget {
  final String title;
  final String content;

  CardInfo({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(width: 2, color: Colors.red),
      ),
      elevation: 5, // เพิ่ม Shadow ให้กับ Card
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
