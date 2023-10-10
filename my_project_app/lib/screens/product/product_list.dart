import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../entity/product.dart';
import '../../app_config.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_application_3/screens/product/product_detail.dart';
import 'report.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  int categoryValue = 0;
  List<Product> productList = [];
  List<Map<String, dynamic>> reportData = [];
  int productId = 0;

  @override
  void initState() {
    fetchProduct();
    super.initState();
  }

  void fetchProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.SERVICE_URL}/api/products/type/$categoryValue"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset:UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}'
      },
    );

    final json = jsonDecode(response.body);

    print(json["data"]);

    List<Product> store = List<Product>.from(json["data"].map((item) {
      return Product.fromJSON(item);
    }));

    setState(() {
      print(store);
      productList = store;
    });
  }

  void deleteProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("${AppConfig.SERVICE_URL}/api/products/delete"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}'
      },
      body: jsonEncode(<String, String>{'product_id': productId.toString()}),
    );

    final json = jsonDecode(response.body);

    print(json["data"]);

    fetchProduct();
  }

  Widget getProductListView() {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: productList.length,
      itemBuilder: (context, index) {
        Product item = productList[index];
        return Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2, color: Colors.amberAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: GFListTile(
            avatar: ClipOval(
              child: Image.asset(
                "assets/images/${item.imgesUrl}",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              item.productName,
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            description: Text(
              "${item.price}",
              style: TextStyle(color: Colors.red),
            ),
            subTitleText: ("${item.categoryName}"),
            icon: Icon(Icons.edit),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) =>
                          ProductDetail(productId: item.productId)))
                  .then((value) => {fetchProduct()});
            },
            onLongPress: () {
              setState(() {
                productId = item.productId;
              });

              showModalBottomSheet<void>(
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15.0)),
                ),
                context: context,
                builder: (BuildContext context) {
                  return getConfirmPanel(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget getScreen() {
    return SafeArea(child: getProductListView());
  }

  Widget getConfirmPanel(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            SizedBox(height: 15),
            const Text(
              "คุณแน่ใจหรือไม่ว่าต้องการลบข้อมูลนี้",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                deleteProduct();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                fixedSize: Size(150, 50),
              ),
              child: const Text(
                "ตกลง",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 15), // เพิ่มระยะห่างระหว่างปุ่ม
            ElevatedButton(
              onPressed: () {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการสินค้า"),
        backgroundColor: Colors.red,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    ReportPage(), // ใช้งาน ReportPage ที่นำเข้ามา
              ));
            },
            child: Text(
              "รายงาน",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFDCDF),
        child: getScreen(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const ProductDetail(productId: 0)))
              .then((value) => {fetchProduct()});
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}
