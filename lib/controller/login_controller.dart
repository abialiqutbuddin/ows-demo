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

  final GlobalStateController stateController = Get.find<GlobalStateController>();

  // 🔹 Login Function
  Future<void> performLogin(String itsId) async {
    stateController.toggleLoading(true);
    try {
      var response = await Api.getToken(itsId);

      print("here");

      if (response.containsKey('token')) {
        print("here");

        String token = response['token'];

        String role = response["user"]["role"] ?? "user"; // Default to 'user' if null

        String mohalla = response["user"]["mohalla"] ?? ""; // Ensure it's always a string

        String umoor = response["user"]["umoor"] ?? ""; // Ensure it's always a string

        stateController.userRole.value = role;
        stateController.userMohalla.value = mohalla;
        stateController.userIts.value = itsId;
        stateController.userUmoor.value = umoor;

        try {
          final userProfile = await Api.fetchUserProfile(itsId);
          if (userProfile != null) {
            stateController.user.value = userProfile;
            //Get.to(() => ProfilePDFScreen(member: userProfile,));
          } else {
            Get.snackbar("Error", "Profile not found for ITS ID: $itsId");
          }
        } catch (e) {
          Get.snackbar("Error", "Failed to fetch user profile: $e");
        }

        GetStorage().write("token", token);

        await fetchAndNavigate(itsId, role);
      } else {
        throw Exception("Invalid ITS ID");
      }
    } catch (e) {
      Get.snackbar("Login Failed", "Error: $e");
    } finally {
      stateController.toggleLoading(false);
    }
  }

  // 🔹 Fetch User Permissions & Navigate
  Future<void> fetchAndNavigate(String itsId,String role) async {
    stateController.toggleLoading(true);
    try { Get.to(() => ModuleScreenController(its: itsId));
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch permissions: $e");
    } finally {
      stateController.toggleLoading(false);
    }
  }

}