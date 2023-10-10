import 'package:flutter/material.dart';
import '../../entity/variants.dart';
import 'package:flutter_application_3/screens/product/payment.dart';

class Colorselector extends StatefulWidget {
  const Colorselector({
    Key? key,
    required this.variantsColorList,
    required this.variantsSizeList,
    required this.valueChanged,
    required this.onSelect,
    required this.child,
  });

  final List<ProductVariants> variantsColorList; 
  final List<ProductVariants> variantsSizeList;
  final ValueChanged<ProductVariants> valueChanged;
  final VoidCallback onSelect;
  final Widget child;

  @override
  State<Colorselector> createState() => _ColorselectorState();
}

class _ColorselectorState extends State<Colorselector> {
  ProductVariants? selectedColor;
  ProductVariants? selectedSize;
  int quantity = 1;

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    return Color(int.parse("0xFF$hexColor"));
  }

  Widget getProductColorListView() {
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(40),
      children: <Widget>[
        for (ProductVariants item in widget.variantsColorList)
          buildProductVariantsGridItem(item),
      ],
    );
  }

  Widget buildProductVariantsGridItem(ProductVariants item) {
    Color color = _getColorFromHex(item.colorCode);
    double circleSize = 30.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = item;
          widget.valueChanged(item);
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
                color: selectedColor == item ? Colors.blue : Colors.white,
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
        for (ProductVariants item in widget.variantsSizeList)
          buildProductSizeGridItem(item),
      ],
    );
  }

  Widget buildProductSizeGridItem(ProductVariants item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = item;
          widget.valueChanged(item);
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

  Widget getProductQuantitySelector() {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "จำนวน :                                             ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (quantity > 1) {
                  quantity--;
                }
              });
            },
          ),
          Text(
            '$quantity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '     สี :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: getProductColorListView(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '     ไซส์ :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: getProductSizeListView(
              onSizeSelected: (size) {
                // ทำอะไรกับไซส์ที่ถูกเลือกตรงนี้
              },
            ),
          ),
          getProductQuantitySelector(),
          widget.child,
        ],
      ),
    );
  }
}

class OrderButton extends StatelessWidget {
  const OrderButton({
    Key? key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // เพิ่มลิงค์ไปยังหน้า Payment ที่นี่
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Payment(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        minimumSize: Size(150, 50),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AddToCartButton extends StatelessWidget {
  const AddToCartButton({
    Key? key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.green,
        minimumSize: Size(150, 50),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
