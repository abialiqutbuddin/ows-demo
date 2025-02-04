import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/constants/dummy_data.dart';
import 'package:ows/controller/login_controller.dart';
import 'package:ows/table.dart';
import 'controller/profile_pdf_controller.dart';
import 'controller/request_form_controller.dart';
import 'dropdown.dart';

void main() {
  Get.put(RequestFormController());
  Get.put(PDFScreenController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OWS',
      theme: ThemeData(
        primaryColor: const Color(0xFF008759),
      ),
      //home: SelectionArea(child: LoginController()),
      //home: DropdownFilteringPage(),
      home: RequestForm(member: userProfile1),
      //home:SelectionArea(child: RequestTable())
    );
  }
}