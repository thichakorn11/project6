// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'app_config.dart';
// import 'package:fl_chart/fl_chart.dart'; // เพิ่ม import

// class ReportPage extends StatefulWidget {
//   @override
//   _ReportPageState createState() => _ReportPageState();
// }

// class _ReportPageState extends State<ReportPage> {
//   List<dynamic> reportData = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   void fetchData() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();

//       final response = await http.get(
//         Uri.parse("${AppConfig.SERVICE_URL}/api/report"),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer ${prefs.getString("access_token")}'
//         },
//       );

//       final json = jsonDecode(response.body);

//       print(json["data"]);

//       if (json["result"] == true) {
//         setState(() {
//           reportData = List.from(json["data"]);
//         });
//       } else {
//         // แสดงข้อความหรือกระทบอื่น ๆ เมื่อมีข้อผิดพลาด
//         print("มีข้อผิดพลาด: ${json['message']}");
//       }
//     } catch (e) {
//       // แสดงข้อความข้อผิดพลาดเมื่อเกิดข้อผิดพลาด
//       print("เกิดข้อผิดพลาด: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('รายงาน'),
//       ),
//       body: reportData.isEmpty
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : Column(
//               children: [
//                 SizedBox(height: 40),
//                 Text(
//                   'สินค้าที่แบ่งตามหมวดหมู่',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: BarChart(
//                       BarChartData(
//                         titlesData: FlTitlesData(
//                           show: false,
//                         ),
//                         borderData: FlBorderData(
//                           show: true,
//                         ),
//                         barGroups: reportData.asMap().entries.map((entry) {
//                           final index = entry.key.toDouble();
//                           final value = entry.value['product_count'] as int;

//                           return BarChartGroupData(
//                             x: index.toInt(),
//                             barRods: [
//                               BarChartRodData(
//                                 toY: value.toDouble(), // ให้แกน Y เป็น double
//                                 color: Colors.blue,
//                               ),
//                             ],
//                           );
//                         }).toList(),
//                         // barGroups: List.generate(
//                         //   reportData.length,
//                         //   (index) => BarChartGroupData(
//                         //     x: index,
//                         //     barRods: [
//                         //       BarChartRodData(
//                         //         toY: reportData[index],
//                         //         color: Colors.blue,
//                         //       ),
//                         //     ],
//                         //   ),
//                         // ).toList(),
//                         gridData: FlGridData(show: false),
//                         minY: 0,
//                         maxY: reportData
//                             .map((item) => item['product_count'] as int)
//                             .reduce((value, element) =>
//                                 value > element ? value : element)
//                             .toDouble(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_config.dart';
import 'package:pie_chart/pie_chart.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<dynamic> reportData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.get(
        Uri.parse("${AppConfig.SERVICE_URL}/api/report"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("access_token")}'
        },
      );

      final json = jsonDecode(response.body);

      print(json["data"]);

      if (json["result"] == true) {
        setState(() {
          reportData = List.from(json["data"]);
        });
      } else {
        print("มีข้อผิดพลาด: ${json['message']}");
        reportData = [];
      }
    } catch (e) {
      print("เกิดข้อผิดพลาด: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> sampleData = {};
    for (var data in reportData) {
      sampleData[data['category_name']] =
          int.parse(data['product_count'].toString());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('รายงาน'),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'แต่ละหมวดหมู่มีสินค้ากี่อย่าง',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            reportData.isNotEmpty
                ? Expanded(
                    child: PieChart(
                      dataMap: sampleData.map<String, double>(
                        (key, value) => MapEntry(key, value.toDouble()),
                      ),
                      animationDuration: Duration(milliseconds: 800),
                      chartLegendSpacing: 32.0,
                      chartRadius: MediaQuery.of(context).size.width / 2,
                      colorList: [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.red,
                        Colors.pink,
                        Colors.purple,
                      ],
                      chartType: ChartType.disc,
                      centerText: "รายงาน",
                      legendOptions: LegendOptions(
                        showLegendsInRow: false,
                        legendPosition: LegendPosition.bottom,
                        showLegends: true,
                        legendShape: BoxShape.circle,
                        legendTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      chartValuesOptions: ChartValuesOptions(
                        showChartValueBackground: true,
                        showChartValues: true,
                        showChartValuesInPercentage: false,
                        showChartValuesOutside: true,
                        decimalPlaces: 0,
                        chartValueStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                  ),
          ],
        ),
      ),
    );
  }
}
