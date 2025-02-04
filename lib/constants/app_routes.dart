import 'package:get/get.dart';
import 'package:ows/controller/family_screen_controller.dart';
import 'package:ows/controller/login_controller.dart';

class AppRoutes {
  static const String login = '/login';
  static const String family_screen = '/family_screen';
  static const String profile_preview_pdf = '/profile_preview_pdf';
  static const String profile_preview = '/profile_preview';
  static const String request_form = '/request_form';

  static final List<GetPage> pages = [
    GetPage(name: login, page: () => LoginController()),
    //GetPage(name: family_screen, page: () => FamilyScreenController(family: family)),
    //GetPage(name: settings, page: () => SettingsPage()),
  ];
}