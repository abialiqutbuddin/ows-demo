import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/controller/profile_pdf_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/model/family_model.dart';
import 'package:ows/web_ui/modules/module_screen.dart';
import 'package:ows/mobile_ui/module_screen.dart';
import 'package:ows/web_ui/modules/update_profile.dart';
import '../model/module_model.dart';

class ModuleController extends GetxController {
  final modules = <ModuleModel>[].obs;
  final GlobalStateController globalController =
      Get.find<GlobalStateController>();

  @override
  void onInit() {
    super.onInit();
    modules.addAll(_getModules());
  }

  List<ModuleModel> _getModules() {
    return [
      ModuleModel(
        id: 1,
        moduleName: "education_assistance",
        moduleTitle: "Education Assistance",
        icon: "📚",
        featureIds: [],
        onModuleOpen: _openEducationAssistance,
      ),
      ModuleModel(
        id: 2,
        moduleName: "dashboard",
        moduleTitle: "Update Profile",
        icon: "📊",
        featureIds: [],
        onModuleOpen: _openDashboard,
      ),
    ];
  }

  void _openEducationAssistance(
      List<int> featureIds, String its, String? mohalla) {
    if (globalController.user.value.itsId != null) {
      Get.to(() => ProfilePDFScreen());
    }
  }

  void _openDashboard(List<int> featureIds, String its, String? mohalla) {
    Get.to(() => ProfilePreview(
          family: Family(),
          member: globalController.user.value,
        ));
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
