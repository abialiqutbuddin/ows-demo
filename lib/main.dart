import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ows/constants/app_routes.dart';
import 'package:ows/controller/family_screen_controller.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/update_paktalim_controller.dart';
import 'package:ows/web_ui/application_forms/application_pdf.dart';
import 'package:ows/web_ui/application_forms/review_application.dart';
import 'package:ows/web_ui/login_redirect.dart';
import 'package:ows/model/family_model.dart';
import 'package:ows/web_ui/modules/module_screen.dart';
import 'package:ows/web_ui/modules/update_profile.dart';
import 'api/api.dart';
import 'constants/dummy_data.dart';
import 'controller/admin/view_req_forms.dart';
import 'controller/forms/form_screen_controller.dart';
import 'controller/profile_pdf_controller.dart';
import 'controller/request_form_controller.dart';
import 'controller/state_management/state_manager.dart';
import 'mobile_ui/application_form_mobile.dart';
import 'web_ui/application_forms/application_form_web.dart';

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
  Get.put(FamilyScreenController());

  await fetchProfile();

  runApp(MyApp());
}

fetchProfile() async {
  GlobalStateController stateController = Get.find<GlobalStateController>();
  stateController.user.value = (await Api.fetchUserProfile('30445124'))!;
  //stateController.user.value = userProfile1111;
  stateController.appliedByITS.value = '50486846';
  stateController.appliedByName.value = 'TEST';
  stateController.reqId.value = 129;
  stateController.draftId.value = 31;
  stateController.intentCompleted.value = true;
  stateController.appInstructions = await Api.loadInstructionsByShortDesc();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OWS',
     // initialRoute: AppRoutes.login,
      //home: ReviewScreen(),
      //initialRoute: AppRoutes.application_form,
      //initialRoute: AppRoutes.profile_preview,
      //home: ApplicationPdf(id: 15,),
      home: DynamicFormBuilderM(),
      getPages: AppRoutes.pages,
      theme: ThemeData(
        primaryColor: const Color(0xFF008759),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}
