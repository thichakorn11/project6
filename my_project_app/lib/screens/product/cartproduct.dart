import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/product/delivery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';

import '../../app_config.dart';
import 'package:flutter_application_3/screens/product/payment.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<dynamic> cartData = [];
  List<dynamic>cartSelectedData = [];
  bool isAllSelected = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<void> saveList(List<dynamic> list, String key) async {
  final prefs = await SharedPreferences.getInstance();

  // Convert the list of maps to a List of JSON strings
  final listOfJsonStrings = list.map((item) => jsonEncode(item)).toList();

  // Save the List of JSON strings in SharedPreferences
  prefs.setStringList(key, listOfJsonStrings);
}

  
  void fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.get(
        Uri.parse(
            "${AppConfig.SERVICE_URL}/api/cart/${prefs.getInt("user_id")}"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("access_token")}'
        },
      );

      final json = jsonDecode(response.body);

      if (json["result"] == true) {
        setState(() {
          cartData = List.from(json["data"]);
          for (var item in cartData) {
            item["isSelected"] = false;
          }
        });
      } else {
        print("Error: ${json['message']}");
        setState(() {
          cartData = [];
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  void deleteCart(cartItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("${AppConfig.SERVICE_URL}/api/cart/delete"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}'
      },
      body: jsonEncode(<String, String>{'cart_id': cartItem["cart_id"].toString()}),
    );

    final json = jsonDecode(response.body);

    print(json["data"]);

   
  }

  void updateCartAmount(cartItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("${AppConfig.SERVICE_URL}/api/cart/updateAmount"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}'
      },
      body: jsonEncode(<String, String>{
        'cart_id': cartItem["cart_id"].toString(),
        'amount': cartItem["amount"].toString()
        }),
    );

    final json = jsonDecode(response.body);

    print(json["data"]);

   
  }

  Widget buildCartList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartData.length,
            itemBuilder: (context, index) {
              var cart = cartData[index];
              bool isSelected = cart["isSelected"];

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            cart["isSelected"] = value;
                            checkAllSelectedStatus();
                          });
                        },
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          "assets/images/${cart["imgesUrl"]}",
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cart["product_name"],
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "ไซส์: ${cart["size_name"]}",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "สี: ${cart["color_name"]}",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          removeItemFromCart(cart);
                        },
                        color: Colors.black,
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (cart["amount"] > 1) {
                                    cart["amount"]--;
                                    updateCartAmount(cart);
                                  }
                                });
                              },
                            ),
                          ),
                          Text(
                            '${cart["amount"]}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  cart["amount"]++;
                                  updateCartAmount(cart);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'รวม: ฿ ${(cart["price"] * cart["amount"]).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Checkbox(
                value: isAllSelected,
                onChanged: (value) {
                  if (value == true) {
                    selectAllItems();
                  } else {
                    deselectAllItems();
                  }
                },
                activeColor: Colors.red,
              ),
              Text(
                "เลือกทั้งหมด",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void checkAllSelectedStatus() {
    bool allSelected = true;
    for (var item in cartData) {
      if (!item["isSelected"]) {
        allSelected = false;
        break;
      }
    }
    setState(() {
      isAllSelected = allSelected;
    });
  }

  void selectAllItems() {
    setState(() {
      for (var item in cartData) {
        item["isSelected"] = true;
      }
      isAllSelected = true;
    });
  }

  void deselectAllItems() {
    setState(() {
      for (var item in cartData) {
        item["isSelected"] = false;
      }
      isAllSelected = false;
    });
  }

  void removeItemFromCart(cartItem) {
    print(cartItem);
    setState(() {
      cartData.remove(cartItem);
      deleteCart(cartItem);
      // ส่งข้อมูลการลบรายการไปยังเซิร์ฟเวอร์เพื่ออัปเดตฐานข้อมูล
      // และดำเนินการตามความเหมาะสม
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ตะกร้าสินค้า"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ),
            onPressed: () {
              // นำทางไปยังหน้าตะกร้าสินค้า
              // คุณสามารถเพิ่มโค้ดการนำทางไปยังหน้าตะกร้าสินค้าที่นี่
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFDCDF),
        child: Column(
          children: [
            Expanded(
              child: buildCartList(),
            ),
            ElevatedButton(
              onPressed: () {
                // นำทางไปยังหน้าชำระเงินหรือหน้าจอการสั่งซื้อ
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Payment(cartList : cartSelectedData),
                ));
              },
              child: Text(
                "ชำระเงิน",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "ราคารวมทั้งหมด: ฿${calculateTotalPrice()}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String calculateTotalPrice ()   {
    double total = 0;
    for (var cart in cartData) {
      if (cart["isSelected"]) {
        total += (cart["amount"] * cart["price"]);
        cartSelectedData.add(cart);
      }
    }
    setCartList ();

    return total.toStringAsFixed(2);
  }

  Future setCartList ()  async {
    cartSelectedData.clear();
    for (var cart in cartData) {
      if (cart["isSelected"]) {
        cartSelectedData.add(cart);
      }
    }
    print("--------------");
    print(cartSelectedData);
    await saveList(cartSelectedData,"cartList");
   
  }
}

