import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/login_controller.dart';

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

  Future<void> saveToPrefs(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> clearSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void Logout(){
    clearSharedPreferences();
    Get.to(() => LoginController());
  }

}