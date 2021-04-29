import 'package:flutter/material.dart';
import 'package:mobil_proje/constants.dart';

// ignore: non_constant_identifier_names
Widget Head(context) {
  return Flexible(
    flex: 10,
    child: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: accentC,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Müzik Çalar",
            style: TextStyle(
              fontSize: 40.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
