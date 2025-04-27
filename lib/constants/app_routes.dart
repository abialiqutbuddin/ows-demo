import 'package:get/get.dart';
import 'package:ows/constants/dummy_data.dart';
import 'package:ows/controller/family_screen_controller.dart';
import 'package:ows/controller/login_controller.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/profile_pdf_controller.dart';
import 'package:ows/controller/request_form_controller.dart';
import 'package:ows/web_ui/login_redirect.dart';
import 'package:ows/web_ui/application_forms/application_form_web.dart';
import 'package:ows/web_ui/modules/update_profile.dart';
import '../model/family_model.dart';

class AppRoutes {
  static const String login = '/login';
  static const String family_screen = '/family_screen';
  static const String select_module = '/select_module';
  static const String profile_preview_pdf = '/profile_preview_pdf';
  static const String profile_preview = '/profile_preview';
  static const String request_form = '/request_form';
  static const String app_form = '/application_form';
  static const String update_profile = '/update_profile';
  static const String application_form = '/application_form';

  static String getLoginRoute() => login;
  static String getFamilyRoute() => family_screen;
  static String getModuleRoute() => select_module;
  static String getProfilePdfRoute() => profile_preview_pdf;
  static String getRequestFormRoute() => request_form;
  static String getAppFormRoute() => app_form;
  static String getUpdateProfileRoute() => update_profile;
  static String getProfileRoute() => profile_preview;
  static String getApplicationForm() => application_form;

  static final List<GetPage> pages = [
    GetPage(name: login, page: () => LoginController()),
    GetPage(name: family_screen, page: () => FamilyScreenController()),
    GetPage(name: profile_preview_pdf, page: () => ProfilePDFScreen()),
    GetPage(name: request_form, page: () => RequestForm()),
    //GetPage(name: app_form, page: () => IndexStackScreen()),
    // GetPage(
    //     name: profile_preview,
    //     page: () => ProfilePreview(
    //           family: Family(),
    //           member: userProfile11,
    //         )),
    GetPage(name: select_module, page: () => ModuleScreenController()),
    GetPage(name: application_form, page: () => DynamicFormBuilder()),
    //GetPage(name: app_form, page: () => I()),
    //GetPage(name: family_screen, page: () => FamilyScreenController(family: family)),
    //GetPage(name: settings, page: () => SettingsPage()),
  ];
}
