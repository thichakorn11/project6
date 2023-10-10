import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/entity/product.dart';
import 'package:flutter_application_3/entity/variants.dart';
import 'package:flutter_application_3/screens/product/color_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_3/app_config.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product; // สินค้าที่จะแสดงรายละเอียด

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool showLargeImage = false;
  ProductVariants? selectedColor; // สีที่เลือก
  ProductVariants? selectedSize; // ไซส์ที่เลือก
  int quantity = 1;
  int totalPrice = 0;

  // Callback เมื่อผู้ใช้เลือกสี
  void onColorSelected(ProductVariants sc) {
    selectedColor = sc;
    print(sc.colorName);
    print(sc.colorId);
    print(sc.sizeId);
  }

  // Callback เมื่อผู้ใช้เลือกขนาด
  void onSizeSelected(ProductVariants sc) {
    selectedSize = sc;
    print(sc.colorName);
    print(sc.colorId);
    print(sc.sizeId);
  }

  @override
  void initState() {
    fetchProductVariants();
    fetchProductSize();
    fetchProductColor();
    super.initState();
  }

  List<ProductVariants> variantsList = [];
  Future<void> fetchProductVariants() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse(
          "${AppConfig.SERVICE_URL}/api/product_variants/${widget.product.productId}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
    );
    final json = jsonDecode(response.body);

    print(json["data"]);

    List<ProductVariants> store =
        List<ProductVariants>.from(json["data"].map((item) {
      return ProductVariants.fromJSON(item);
    }));

    setState(() {
      variantsList = store;
    });
  }

  List<ProductVariants> variantsSizeList = [];
  Future<void> fetchProductSize() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse(
          "${AppConfig.SERVICE_URL}/api/product_variants/size/${widget.product.productId}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
    );
    final json = jsonDecode(response.body);

    print(json["data"]);

    List<ProductVariants> store =
        List<ProductVariants>.from(json["data"].map((item) {
      return ProductVariants.fromJSON(item);
    }));

    setState(() {
      variantsSizeList = store;
    });
  }

  List<ProductVariants> variantsColorList = [];
  Future<void> fetchProductColor() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse(
          "${AppConfig.SERVICE_URL}/api/product_variants/color/${widget.product.productId}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
    );
    final json = jsonDecode(response.body);

    print(json["data"]);

    List<ProductVariants> store =
        List<ProductVariants>.from(json["data"].map((item) {
      return ProductVariants.fromJSON(item);
    }));

    setState(() {
      variantsColorList = store;
    });
  }

  //cart
  Future<bool> createCart() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("${AppConfig.SERVICE_URL}/api/cart/add"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
      body: jsonEncode(<String, String>{
        'user_id': "${prefs.getInt("user_id")}",
        'product_id': widget.product.productId
            .toString(), // เรียก ไอดีของสินค้าออกมากำหนดค่าเป็น String
        'color_id': selectedColor!.colorId.toString(),
        'size_id': selectedColor!.sizeId.toString(),
        'amount': quantity.toString()
      }),
    );

    final json = jsonDecode(response.body);

    if (json["result"]) {
      return true;
    } else {
      return false;
    }
  }

  //order
  Future<bool> createOrder() async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("${AppConfig.SERVICE_URL}/api/order/add"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}',
      },
      body: jsonEncode(<String, String>{
        'user_id': "${prefs.getInt("user_id")}",
        'product_id': widget.product.productId
            .toString(), // เรียก ไอดีของสินค้าออกมากำหนดค่าเป็น String
        'color_id': selectedColor!.colorId.toString(),
        'size_id': selectedColor!.sizeId.toString(),
        'amount': quantity.toString()
      }),
    );

    final json = jsonDecode(response.body);

    if (json["result"]) {
      return true;
    } else {
      return false;
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    return Color(int.parse("0xFF$hexColor"));
  }

  Widget getProductListView(
      {required Null Function(dynamic color) onColorSelected}) {
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(40),
      children: <Widget>[
        for (ProductVariants item in variantsColorList)
          buildProductVariantsGridItem(item),
      ],
    );
  }

  Widget getProductSizeListView(
      {required Null Function(dynamic size) onSizeSelected}) {
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(40),
      children: <Widget>[
        for (ProductVariants item in variantsSizeList)
          buildProductSizeGridItem(item),
      ],
    );
  }

  Color x = Colors.white;

  Widget buildProductVariantsGridItem(ProductVariants item) {
    Color color = _getColorFromHex(item.colorCode);
    double circleSize = 30.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = item;
          //print(selectedColor);
          print(
              "สี${item.colorId}"); //$ เป็นการกำหนดเทมเพลส String คือการที่เราสามารถพิมพ์ตัวแปรลงไปในข้อความได้
          //x = selectedColor == item ? Colors.blue : Colors.white;
          // print(x);
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                // color: selectedColor == item ? Colors.blue : Colors.white,
                color: x,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductSizeGridItem(ProductVariants item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = item;
          // print(item.sizeId);
          // print(selectedSize);
          x = selectedSize == item ? Colors.blue : Colors.white;
          // print(x);
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: selectedSize == item ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.0,
                    height: 30.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            selectedSize == item ? Colors.blue : Colors.black,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      item.sizeName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            selectedSize == item ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleOrderButtonPress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Colorselector(
          variantsColorList: variantsColorList,
          variantsSizeList: variantsSizeList,
          valueChanged: onColorSelected,
          onSelect: () {
            // ดำเนินการเมื่อเลือกสีและกดปุ่ม "สั่งซื้อ"
          },
          child: OrderButton(
            text: 'สั่งซื้อ',
            onPressed: () {
              // ดำเนินการเมื่อปุ่ม "สั่งซื้อ" ถูกคลิก
              createOrder();
            },
          ),
        );
      },
    );
  }

  void addToCart(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Colorselector(
          variantsColorList: variantsColorList,
          variantsSizeList: variantsSizeList,
          valueChanged: onColorSelected,
          onSelect: () {
            // ดำเนินการเมื่อเลือกสีและกดปุ่ม "เพิ่มลงตะกร้า"
          },
          child: AddToCartButton(
            text: 'เพิ่มลงตะกร้า',
            onPressed: () {
              // ดำเนินการเมื่อปุ่ม "เพิ่มลงตะกร้า" ถูกคลิก
              createCart();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดสินค้า'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  showLargeImage = !showLargeImage;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: double.infinity,
                height: showLargeImage ? 450 : 400,
                child: Image.asset(
                  "assets/images/${widget.product.imgesUrl}",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "ราคา: ${widget.product.price}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          handleOrderButtonPress(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          minimumSize: Size(150, 50),
                        ),
                        child: Text(
                          'สั่งซื้อสินค้า',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          addToCart(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          minimumSize: Size(150, 50),
                        ),
                        child: Text(
                          'เพิ่มลงตะกร้า',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
