import 'dart:ui';
import 'package:flutter/material.dart';

class Constants {
  Color green = Color(0xFF008759);
  Color blue = Color(0xff005387);

  Widget heading(String value)
  {
    return Text(value,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24));
  }
  Widget subHeading(String value)
  {
    return Text(value,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16));
  }

  double responsiveWidth(BuildContext context, double fraction) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1280) {
      return screenWidth * fraction; // Use the fraction of the screen width
    } else {
      return 1280 * fraction; // Cap the maximum width based on 1280 pixels
    }
  }

}