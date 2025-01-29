import 'package:flutter/material.dart';
import 'package:ows/api/api.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/controller/family_screen_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/dummy_data.dart';
import '../mobile_ui/login_screen.dart';
import '../model/family_model.dart';
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

  final StateController stateController = Get.put(StateController());
  // Perform login logic
  Future<void> performLogin() async {
    stateController.toggleLoading(true); // Start loading
    await Future.delayed(const Duration(seconds: 2)); // Simulate a delay
    stateController.toggleLoading(false); // Stop loading

    Constants().saveToPrefs('appliedByIts', '${dummyFamily.its}');
    Constants().saveToPrefs('appliedByName', '${dummyFamily.fullName}');

    Get.to(() => FamilyScreenController(family: dummyFamily));
  }

  // Fetch family data and navigate to FamilyScreen
  Future<void> fetchAndNavigate(String itsId,String? name) async {
    stateController.toggleLoading(true); // Start loading
    try {
      Family? family = await Api.fetchFamilyProfile(itsId);

      if (family != null) {
        Constants().saveToPrefs('appliedByIts', '${family.its}');
        Constants().saveToPrefs('appliedByName', '${family.fullName}');
        stateController.toggleLoading(false); // Stop loading
        Get.to(() => FamilyScreenController(family: family));
      } else {
        Get.snackbar("Error", "No family data found for ITS ID: $itsId");
        stateController.toggleLoading(false); // Stop loading
      }
    } catch (e) {
      stateController.toggleLoading(false); // Stop loading
      Get.snackbar("Error", "Failed to fetch family data: $e");
    }
  }

}