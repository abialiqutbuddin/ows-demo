import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ows/api/api.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:get/get.dart';
import 'package:ows/mobile_ui/module_screen.dart';
import '../mobile_ui/login_screen.dart';
import '../web_ui/login_screen.dart';

class LoginController extends StatelessWidget {
  LoginController({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;

    // Define the breakpoint for mobile
    const double mobileBreakpoint = 600;

    return Scaffold(
      body: screenWidth <= mobileBreakpoint
          ? LoginPageM() // Render LoginPageM for mobile
          : LoginPageW(), // Render LoginPage for larger screens
    );
  }

  final GlobalStateController stateController = Get.put(GlobalStateController());

  // 🔹 Login Function
  Future<void> performLogin(String itsId) async {
    stateController.toggleLoading(true);
    try {

      var response = await Api.getToken(itsId);
          if (response.containsKey('token')) {
        String token = response['token'];
        stateController.userRole.value = response["user"]["role"];
        stateController.userIts.value = itsId;
        GetStorage().write("token", token);
        await fetchAndNavigate(itsId,stateController.userRole.value);
        Api.fetchProxiedData('http://192.168.52.58:8080/crc_live/backend/dist/mumineen/getFamilyDetails.php?user_name=umoor_talimiyah&password=UTalim2025&token=0a1d240f3f39c454e22b2402303aa2959d00b770d9802ed359d75cf07d2e2b65&its_id=30445124');
          } else {
        throw Exception("Invalid ITS ID");
      }
    } catch (e) {
      //await fetchAndNavigate(itsId);
      Get.snackbar("Login Failed", "Error: $e");
    } finally {
      stateController.toggleLoading(false);
    }
  }

  // 🔹 Fetch User Permissions & Navigate
  Future<void> fetchAndNavigate(String itsId,String role) async {
    stateController.toggleLoading(true);
    //await Future.delayed(const Duration(seconds: 2)); // Simulate a delay
    try {
        Get.to(() => ModuleScreenController(its: itsId));
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch permissions: $e");
    } finally {
      stateController.toggleLoading(false);
    }
  }

}