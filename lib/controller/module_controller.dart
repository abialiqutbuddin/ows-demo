import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/constants/app_routes.dart';
import 'package:ows/controller/profile_pdf_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/model/family_model.dart';
import 'package:ows/web_ui/modules/module_screen.dart';
import 'package:ows/mobile_ui/module_screen.dart';
import 'package:ows/web_ui/modules/update_profile.dart';
import '../model/module_model.dart';
import '../web_ui/application_forms/application_form_web.dart';

class ModuleController extends GetxController {
  final modules = <ModuleModel>[].obs;
  final GlobalStateController globalController =
      Get.find<GlobalStateController>();

  @override
  void onInit() {
    super.onInit();
    _refreshModules();
    ever(globalController.lastMarhala, (_) => _refreshModules());
    ever(globalController.profileComplete, (_) => _refreshModules());
    ever(globalController.familyProfileComplete, (_) => _refreshModules());
  }

  void _refreshModules() {
    modules.value = _getModules();
  }

  List<ModuleModel> _getModules() {
    return [
      ModuleModel(
        id: 1,
        moduleName: "education_assistance",
        moduleTitle: "Education Assistance",
        icon: "📚",
        onModuleOpen: _openEducationAssistance,
        isEnabled: globalController.profileComplete.value && globalController.familyProfileComplete.value
      ),
      ModuleModel(
        id: 2,
        moduleName: "dashboard",
        moduleTitle: "Update Profile",
        subtitle: "Last Marhala: ",
        note: globalController.lastMarhala.value!=0 ? "Marhala ${globalController.lastMarhala.value}" : "No Data",
        icon: "📊",
        onModuleOpen: _openDashboard,
        isEnabled: true,
        profileText: true,
        profileComplete: globalController.profileComplete.value.toString(),
        familyComplete: globalController.familyProfileComplete.value.toString()
      ),
    ];
  }

  void _openEducationAssistance() {
    if (globalController.user.value.itsId != null) {
      //Get.to(() => ProfilePDFScreen());
      //Get.to(()=> DynamicFormBuilder());
      Get.toNamed(AppRoutes.profile_preview_pdf);
    }
  }

  void _openDashboard() {
    Get.toNamed(AppRoutes.profile_preview);
    //   Get.to(() => ProfilePreview(
    //         family: Family(),
    //         member: globalController.user.value,
    //       ));
    // }
  }
}

class ModuleScreenController extends StatelessWidget {
  ModuleScreenController({super.key});

  final GlobalStateController globalController =
      Get.find<GlobalStateController>();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width <= 600;

    return isMobile ? ModuleSelectionScreenM() : const ModuleSelectionScreenW();
  }
}
