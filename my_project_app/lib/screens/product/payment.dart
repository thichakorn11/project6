import 'package:flutter/material.dart';
// import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_application_3/screens/product/paymenttype.dart';
import 'package:flutter_application_3/screens/product/delivery.dart';

class Payment extends StatefulWidget {
  final List<dynamic> cartList;

  Payment({Key? key, this.cartList = const []}) : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String? selectedPaymentType;
  String qrCodeData = "";
  String accountNumber = "123-456-7890";
  bool showQRCode = false;

  Future<void> _showQRCode() async {
    final ByteData assetByteData =
        await rootBundle.load('assets/images/imageBase64.jpg');
    final List<int> imageBytes = assetByteData.buffer.asUint8List();
    final String imageBase64 = base64Encode(imageBytes);

    setState(() {
      qrCodeData = imageBase64;
      showQRCode = true;
    });

    if (selectedPaymentType == 'promptpay') {
      try {
        // final barcodeScanResult = await BarcodeScanner.scan();
        setState(() {
          // qrCodeData = barcodeScanResult.rawContent ?? "ไม่พบข้อมูล";
        });
      } catch (e) {
        print("เกิดข้อผิดพลาดในการสแกนคิวบาร์โค้ด: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาดในการสแกนคิวบาร์โค้ด: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คำสั่งซื้อ'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          if (selectedPaymentType == 'promptpay' && showQRCode)
            Column(
              children: [
                Text(
                  'รูปภาพ QR Code:',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Image.memory(
                  base64Decode(qrCodeData),
                  width: 200.0,
                ),
                SizedBox(height: 8),
              ],
            ),
          if (selectedPaymentType == 'bank_account' && !showQRCode)
            Column(
              children: [
                Text(
                  'เลขบัญชี:',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  accountNumber,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          SizedBox(height: 16),
          PaymentTypeSelection(
            onPaymentTypeSelected: (type) {
              setState(() {
                selectedPaymentType = type;
                if (type == 'bank_account') {
                  showQRCode = false;
                } else if (type == 'promptpay') {
                  showQRCode = true;
                  _showQRCode();
                }
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (selectedPaymentType == 'promptpay') {
                // เรียกใช้ Navigator เพื่อนำทางไปยังหน้า Delivery
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Delivery(cartList: widget.cartList)),
                );
              }
            },
            child: Text("แนบหลักการชำระเงิน"),
          ),
          SizedBox(height: 16)
        ],
      ),
    );
  }
}
