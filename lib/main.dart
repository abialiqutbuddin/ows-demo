import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ows/constants/app_routes.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/update_paktalim_controller.dart';
import 'controller/admin/view_req_forms.dart';
import 'controller/forms/form_screen_controller.dart';
import 'controller/profile_pdf_controller.dart';
import 'controller/request_form_controller.dart';
import 'controller/state_management/state_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Lazy initialization
  Get.put(RequestFormController());
  Get.put(PDFScreenController());
  Get.put(ReqFormController());
  Get.put(GlobalStateController());
  Get.put(ModuleController());
  Get.put(FormController());
  Get.put(UpdatePaktalimController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OWS',
      initialRoute: AppRoutes.login,
     // initialRoute: AppRoutes.app_form,
      //initialRoute: AppRoutes.request_form,
     // home:LoginController(),
       // home: LoginController2(),
     // home:ProfilePDFScreen(member: userProfile1),
    // home: ProfilePreview(member: userProfile1, family: dummyFamily),
    // home: IndexStackScreen(),
      //home: updatePakTalimForm(),
      //home:RequestForm(),

      getPages: AppRoutes.pages,
      theme: ThemeData(
        primaryColor: const Color(0xFF008759),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}
