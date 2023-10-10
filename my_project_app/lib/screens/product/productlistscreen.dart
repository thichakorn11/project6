import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../entity/product.dart';
import '../../app_config.dart';
import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:flutter_application_3/screens/product/productdetailscreen.dart';
import '../../category.dart';
import 'cartproduct.dart';
import 'package:flutter_application_3/screens/product/payment.dart';
import 'package:flutter_application_3/profile.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  int categoryValue = 0;
  List<Product> productList = [];
  int productId = 0;
  int currentPageIndex = 0;
  List<Category> categoryList = [];
  int categoryId = 0;

  @override
  void initState() {
    fetchCategory();
    fetchProduct();
    super.initState();
  }

  void fetchCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.SERVICE_URL}/api/category"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset:UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}'
      },
    );

    final json = jsonDecode(response.body);

    List<Category> store = List<Category>.from(json["data"].map((item) {
      return Category.fromJSON(item);
    }));

    setState(() {
      categoryList = store;
    });
  }

  void fetchProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.SERVICE_URL}/api/products/type/$categoryValue"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}'
      },
    );

    final json = jsonDecode(response.body);

    List<Product> store = List<Product>.from(json["data"].map((item) {
      return Product.fromJSON(item);
    }));

    setState(() {
      productList = store;
    });
  }

  void fetchProductsByCategory(int categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.SERVICE_URL}/api/products/category/$categoryId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}'
      },
    );

    final json = jsonDecode(response.body);

    List<Product> store = List<Product>.from(json["data"].map((item) {
      return Product.fromJSON(item);
    }));

    setState(() {
      productList = store;
    });
  }

  void fetchSearchProduct(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.SERVICE_URL}/api/products/search/$search"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${prefs.getString("access_token")}'
      },
    );

    final json = jsonDecode(response.body);

    List<Product> store = List<Product>.from(json["data"].map((item) {
      return Product.fromJSON(item);
    }));

    setState(() {
      productList = store;
    });
  }

  Widget getCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          for (Category category in categoryList)
            buildCategoryChipWithImageAndText(category),
        ],
      ),
    );
  }

  Widget buildCategoryChipWithImageAndText(Category category) {
    return ChoiceChip(
      backgroundColor: Color(0xFFFCC0C5),
      selectedColor: Colors.redAccent,
      label: Container(
        width: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/${category.imageUrl}",
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
      selected: category.categoryId == categoryId,
      onSelected: (isSelected) {
        setState(() {
          categoryId = isSelected ? category.categoryId : 0;
          fetchProductsByCategory(categoryId);
        });
      },
    );
  }

  Widget getProductListView() {
    return GridView.builder(
      primary: false,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: productList.length,
      itemBuilder: (BuildContext context, int index) {
        Product item = productList[index];
        return buildProductGridItem(item);
      },
    );
  }

  bool isFavorite = false; // เพิ่มตัวแปรเพื่อตรวจสอบสถานะการชื่นชอบ

  Widget buildProductGridItem(Product item) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: item),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  image: DecorationImage(
                    image: AssetImage("assets/images/${item.imgesUrl}"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  "\$${item.price}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getScreen() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          getCategoryList(),
          Expanded(
            child: getProductListView(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDCDF),
        title: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.black,
            ),
            SizedBox(width: 8), // เพิ่มระยะห่างระหว่างไอคอนและช่องค้นหา
            Expanded(
              child: TextField(
                onSubmitted: (value) {
                  fetchSearchProduct(value);
                },
                decoration: InputDecoration(
                  hintText: 'ค้นหา',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Cart()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFDCDF),
        child: getScreen(),
      ),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.home, title: "หน้าหลัก"),
          TabData(iconData: Icons.favorite, title: "สำหรับคุณ"),
          TabData(iconData: Icons.shopping_bag, title: "คำสั่งซื้อ"),
          TabData(iconData: Icons.person, title: "โปรไฟล์"),
        ],
        onTabChangedListener: (position) {
          setState(() {
            currentPageIndex = position;
            if (position == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListScreen(),
                ),
              );
            } else if (position == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Payment(),
                ),
              );
            } else if (position == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(),
                ),
              );
            }
          });
        },
        initialSelection: currentPageIndex,
      ),
    );
  }
}
