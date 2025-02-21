import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ows/api/api.dart';
import 'package:ows/constants/dummy_data.dart';
import 'package:ows/controller/login_controller.dart';
import 'package:ows/demo.dart';
import 'package:ows/mobile_ui/forms/personal_info_screen.dart';
import 'package:ows/mobile_ui/forms/student_education.dart';
import 'package:ows/table.dart';
import 'package:ows/web_ui/modules/view_requests.dart';
import 'constants/table.dart';
import 'controller/admin/view_req_forms.dart';
import 'controller/profile_pdf_controller.dart';
import 'controller/request_form_controller.dart';
import 'constants/dropdown_search.dart';
import 'mobile_ui/forms/financials.dart';

Future<void> main() async {
  Get.put(RequestFormController());
  Get.put(PDFScreenController());
  Get.put(ReqFormController());
  await GetStorage.init();
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
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: SelectionArea(child: LoginController()),
      //home: StudentEducation(),
      //home: ApiScreen()
      //home: DropdownFilteringPage(),
      //home: RequestForm(member: userProfile1),
      //home: UsersByMohallaScreen(),
       //home: ReqFormTable(mohalla: 'KHI (AL-MAHALAT-TUL-BURHANIYAH)')
      //home:SelectionArea(child: RequestTable())
      //home: performActions(),
    );
  }

  Widget performActions(){
    //Api.getToken('30445124');
    //return FormScreen();
    return FinancialFormScreen();
  }
}