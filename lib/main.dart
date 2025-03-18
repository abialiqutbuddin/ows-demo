import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ows/constants/dummy_data.dart';
import 'package:ows/constants/table_controller.dart';
import 'package:ows/controller/family_screen_controller.dart';
import 'package:ows/controller/login_controller.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/update_paktalim_controller.dart';
import 'package:ows/mobile_ui/forms/personal_info_screen.dart';
import 'package:ows/mobile_ui/forms/student_education.dart';
import 'package:ows/web_ui/forms/main_form.dart';
import 'package:ows/web_ui/forms/personal_info_screen.dart';
import 'package:ows/web_ui/login_screen.dart';
import 'package:ows/web_ui/profile_preview_screen.dart';
import 'package:ows/web_ui/update_paktalim.dart';
import 'api/api.dart';
import 'controller/admin/view_req_forms.dart';
import 'controller/forms/form_screen_controller.dart';
import 'controller/profile_pdf_controller.dart';
import 'controller/request_form_controller.dart';
import 'controller/state_management/state_manager.dart';
import 'demo.dart';
import 'login2.dart';
import 'mobile_ui/forms/documents_upload.dart';
import 'mobile_ui/forms/financials.dart';

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
      //initialRoute: '/login',
      home:LoginController(),
       // home: LoginController2(),
     // home:ProfilePDFScreen(member: userProfile1),
    // home: ProfilePreview(member: userProfile1, family: dummyFamily),
     //home: IndexStackScreen(),
      //home: updatePakTalimForm(),
      //home:RequestForm(),

      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginController2(),
        ),

        GetPage(
          name: '/family-selection',
          page: () => FamilyScreenController(),
        ),

        GetPage(name: '/request-form-demo', page: () => RequestForm()),

        GetPage(name: '/request-form', page: () => RequestForm()),

        //GetPage(name: '/table', page: () => RequestForm())
      ],
      theme: ThemeData(
        primaryColor: const Color(0xFF008759),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}
