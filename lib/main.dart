import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/controller/login_controller.dart';

void main() {
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
      home: SelectionArea(child: LoginController()),
     // home: ProfilePreview(member: dummyMembers.first,),
      //home: RequestForm(member: userProfile),
      //home:SelectionArea(child: RequestTable())
    );
  }
}