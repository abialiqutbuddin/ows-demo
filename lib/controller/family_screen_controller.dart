import 'package:flutter/material.dart';
import 'package:ows/mobile_ui/family_screen.dart';
import 'package:ows/model/family_data2.dart';
import 'package:ows/web_ui/family_screen.dart';
import '../model/family_model.dart';
import 'package:get/get.dart';
import '../controller/state_management/state_manager.dart';
import '../constants/custom_dialog.dart';
import '../model/member_model.dart';


class FamilyScreenController extends StatelessWidget {
   FamilyScreenController({super.key});

  final GlobalStateController stateController =
  Get.find<GlobalStateController>();

   /// Safely fetches the marhalaId of the most recently completed education.
   /// Returns null if there are no valid end dates or any parsing error occurs.
   int? fetchHighestMarhalaId(UserProfile profile) {
     final edus = profile.education;
     if (edus == null || edus.isEmpty) return 0;

     int? maxId;
     for (final e in edus) {
       if (maxId == null || e.marhalaId! > maxId) {
         maxId = e.marhalaId;
       }
     }
     return maxId;
   }

  Future<bool> checkForActions() async {
    String title = "";
    String message = "";
    String confirmText = "";
    String? cancelText;
    Function? onConfirm;
    Function? onCancel;

    if(stateController.profileComplete.value!=false) {
      if (!stateController.familyProfileComplete.value) {
        title = "Family Data Incomplete";
        message = "Please update your family education data on Pak Talim";
        confirmText = "Ok";
        onConfirm = () {
          Get.back();
        };

        Get.dialog(CustomDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: () => onConfirm!(),
          onCancel: () => onCancel!(),
        ));
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define the breakpoint for mobile
    const double mobileBreakpoint = 600;

    return Scaffold(
       body: screenWidth <= mobileBreakpoint
           ? FamilyScreenM()
         : FamilyScreenW(),
    );
  }
}