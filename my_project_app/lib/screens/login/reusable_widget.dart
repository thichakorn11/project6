import 'package:flutter/material.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 300,
    height: 300,
    //color: Colors.white,
  );
}

Image logoWidget1(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 150,
    height: 150,
    //color: Colors.white,
  );
}
