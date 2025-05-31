import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ows/api/api.dart';
import 'package:ows/constants/app_routes.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:get/get.dart';
import '../mobile_ui/login_screen.dart';
import '../model/family_data2.dart';
import '../web_ui/admin/admin_login.dart';

class LoginController extends StatelessWidget {
  LoginController({super.key});

  @override
  Widget build(BuildContext context) {

    final double screenWidth = MediaQuery.of(context).size.width;

    const double mobileBreakpoint = 600;

    return Scaffold(
      body: screenWidth <= mobileBreakpoint
          ? LoginPageM() // Render LoginPageM for mobile
          : LoginPageW(), // Render LoginPage for larger screens
    );
  }

  final GlobalStateController stateController =
      Get.find<GlobalStateController>();

  void printUserPermissions(String its) async {
    final userPermissions = await Api.fetchUserPermissions(its);

    if (userPermissions == null) {
      print('Failed to fetch permissions');
      return;
    }

    print('User: ${userPermissions.name} (${userPermissions.role.name})');
    if (userPermissions.trusts != null) {
      for (final trust in userPermissions.trusts!) {
        print('Trust: ${trust.trustName}');
        if (trust.permissions != null) {
          print('  Can View: ${trust.permissions!.canView}');
          print('  Can Update: ${trust.permissions!.canUpdate}');
        }
      }
    }
  }


  Future<void> performLogin(String itsId) async {
    stateController.toggleLoading(true);
    try {
      // var response = await Api.getToken(itsId);
      // //printUserPermissions(itsId);
      // if (response.containsKey('token')) {
      //   String token = response['token'];
      //   GetStorage().write("token", token);
      // }
      List<FamilyMember>? familyMembers = await Api.fetchFamilyData2(itsId);
      if (familyMembers != null && familyMembers.isNotEmpty) {
        stateController.loggedinBy.value = familyMembers
            .firstWhere((member) => member.itsNumber == int.parse(itsId))
            .fullName;
        stateController.setUser(itsId, familyMembers);
        Get.toNamed(AppRoutes.family_screen);
      } else {
        Get.snackbar("Error", "No family members found.");
      }
      //Get.toNamed(AppRoutes.select_module);
    } catch (e) {
      Get.snackbar("Login Failed", "Error: $e");
    } finally {
      stateController.toggleLoading(false);
    }
  }

  // 🔹 Login Function
  // Future<void> performLogin(String itsId) async {
  //   stateController.toggleLoading(true);
  //   try {
  //     var response = await Api.getToken(itsId);
  //
  //     if (response.containsKey('token')) {
  //       String token = response['token'];
  //
  //       String role =
  //           response["user"]["role"] ?? "user"; // Default to 'user' if null
  //
  //       String mohalla =
  //           response["user"]["mohalla"] ?? ""; // Ensure it's always a string
  //
  //       String umoor =
  //           response["user"]["umoor"] ?? ""; // Ensure it's always a string
  //
  //       stateController.userRole.value = role;
  //       stateController.userMohalla.value = mohalla;
  //       stateController.userIts.value = itsId;
  //       stateController.userUmoor.value = umoor;
  //
  //       try {
  //         final userProfile = await Api.fetchUserProfile(itsId);
  //         if (userProfile != null) {
  //           stateController.user.value = userProfile;
  //           //Get.to(() => ProfilePDFScreen(member: userProfile,));
  //         } else {
  //           Get.snackbar("Error", "Profile not found for ITS ID: $itsId");
  //         }
  //       } catch (e) {
  //         Get.snackbar("Error", "Failed to fetch user profile: $e");
  //       }
  //
  //       GetStorage().write("token", token);
  //
  //       await fetchAndNavigate(itsId, role);
  //     } else {
  //       throw Exception("Invalid ITS ID");
  //     }
  //   } catch (e) {
  //     Get.snackbar("Login Failed", "Error: $e");
  //   } finally {
  //     stateController.toggleLoading(false);
  //   }
  // }

  // 🔹 Fetch User Permissions & Navigate
  Future<void> fetchAndNavigate(String itsId, String role) async {
    stateController.toggleLoading(true);
    try {
      //Get.to(() => ModuleScreenController();
      Get.toNamed(AppRoutes.select_module);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch permissions: $e");
    } finally {
      stateController.toggleLoading(false);
    }
  }
}
