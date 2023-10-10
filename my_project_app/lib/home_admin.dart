// import 'dart:ui';

import 'package:flutter/material.dart';
import 'screens/product/product_list.dart';
// import 'package:flutter_application_3/stock_list.dart';
import 'package:flutter_application_3/screens/login/login.dart';
import 'package:flutter_application_3/customer.dart';
import 'package:flutter_application_3/category_list.dart';
import './stock_list.dart';

// ignore: camel_case_types
class Home_admin extends StatelessWidget {
  const Home_admin({Key? key}) : super(key: key);

  static const String _title = 'จัดการข้อมูล';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(_title),
            backgroundColor: Colors.red,
          ),
          body: const MyStatefulWidget(),
          backgroundColor: const Color(0xFFFFDCDF),
        ));
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      primary: false,
      crossAxisCount: 2,
      mainAxisSpacing: 20, // ปรับระยะห่างระหว่างรูปภาพตามต้องการ
      crossAxisSpacing: 25, // ปรับระยะห่างระหว่างรูปภาพตามต้องการ
      padding: const EdgeInsets.all(40),
      children: <Widget>[
        ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange[200],
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Image.asset(
                        'assets/images/or.png',
                        width: 80,
                        height: 80,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "คำสั่งซื้อ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ])))),
        ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.green[200],
                child: InkWell(
                    onTap: () {
                      // Navigate to the ProductList screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Customer()),
                      );
                    },
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Image.asset(
                            'assets/images/cus.png',
                            width: 80,
                            height: 80,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "ข้อมูลลูกค้า",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]))))),
        ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red[200],
                child: InkWell(
                    onTap: () {
                      // Navigate to the ProductList screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategoryList()),
                      );
                    },
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Image.asset(
                            'assets/images/cate.png',
                            width: 80,
                            height: 80,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "หมวดหมู่สินค้า",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]))))),
        ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.blueGrey[200],
                child: InkWell(
                    onTap: () {
                      // Navigate to the ProductList screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListPage(),
                        ),
                      );
                    },
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Image.asset(
                            'assets/images/in-stock1.png',
                            width: 80,
                            height: 80,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "ดูสต็อกสินค้า",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]))))),
        ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.pink[200],
                child: InkWell(
                    onTap: () {
                      // Navigate to the ProductList screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductList()),
                      );
                    },
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Image.asset(
                            'assets/images/checklist.png',
                            width: 75,
                            height: 75,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "\t\t\t\t\t\t\tจัดการรายการสินค้า",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]))))),
        ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red,
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Image.asset(
                        'assets/images/order-fulfillment.png',
                        width: 80,
                        height: 80,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "สรุปยอดขาย",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ])))),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Color.fromARGB(255, 155, 168, 253),
            child: InkWell(
              onTap: () {
                // Navigate to the logout screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login(logout: true)),
                );
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/check-out.png',
                      width: 80,
                      height: 80,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "ออกจากระบบ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
