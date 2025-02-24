import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ows/constants/dummy_data.dart';
import 'package:ows/controller/family_screen_controller.dart';
import 'package:ows/controller/module_controller.dart';
import 'controller/admin/view_req_forms.dart';
import 'controller/profile_pdf_controller.dart';
import 'controller/request_form_controller.dart';
import 'controller/state_management/state_manager.dart';
import 'login2.dart';
import 'mobile_ui/forms/financials.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  //Get.put(() => ReqFormController());


  // Lazy initialization
  Get.lazyPut(() => RequestFormController());
  Get.lazyPut(() => PDFScreenController());
  Get.lazyPut(() => ReqFormController());
  Get.lazyPut(() => GlobalStateController());
  Get.lazyPut(() => ModuleController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OWS',
      initialRoute: '/login',
      getPages: [

        GetPage(
          name: '/login',
          page: () => LoginController2(),
        ),

        GetPage(
          name: '/family-selection',
          page: () => FamilyScreenController(),
        ),

        GetPage(name: '/request-form-demo', page: () => RequestForm(member: userProfile1))

      ],
      theme: ThemeData(
        primaryColor: const Color(0xFF008759),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}