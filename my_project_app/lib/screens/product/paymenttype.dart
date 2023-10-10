import 'package:flutter/material.dart';

class PaymentTypeSelection extends StatefulWidget {
  final void Function(String) onPaymentTypeSelected;

  PaymentTypeSelection({required this.onPaymentTypeSelected});

  @override
  _PaymentTypeSelectionState createState() => _PaymentTypeSelectionState();
}

class _PaymentTypeSelectionState extends State<PaymentTypeSelection> {
  String? selectedPaymentType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เลือกประเภทการชำระเงิน:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListTile(
          title: const Text('ชำระเงินผ่านเลขบัญชี'),
          leading: Radio<String>(
            value: 'bank_account',
            groupValue: selectedPaymentType,
            onChanged: (String? value) {
              setState(() {
                selectedPaymentType = value;
                widget.onPaymentTypeSelected(value!);
              });
            },
          ),
        ),
        if (selectedPaymentType == 'bank_account')
          ListTile(
            title: const Text(
                'เลขบัญชี: 123-456-7890'), // Replace with the desired account number
          ),
        ListTile(
          title: const Text('ชำระเงินผ่านพร้อมเพย์'),
          leading: Radio<String>(
            value: 'promptpay',
            groupValue: selectedPaymentType,
            onChanged: (String? value) {
              setState(() {
                selectedPaymentType = value;
                widget.onPaymentTypeSelected(value!);
              });
            },
          ),
        ),
      ],
    );
  }
}
