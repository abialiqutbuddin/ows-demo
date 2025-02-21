import 'package:get/get.dart';
import 'package:ows/controller/family_screen_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/mobile_ui/module_screen.dart';
import 'package:ows/web_ui/modules/view_requests.dart';
import '../api/api.dart';
import '../constants/table.dart';
import '../model/family_model.dart';
import '../model/module_model.dart';
import 'package:flutter/material.dart';

import '../web_ui/module_screen.dart';

class ModuleController extends GetxController {
  var modules = <ModuleModel>[].obs;
  RxBool isLoading = false.obs;

  final GlobalStateController permissionsController =
      Get.find<GlobalStateController>();

  void toggleLoading(bool value) {
    isLoading.value = value;
  }

  Future<void> fetchModules(String itsId) async {
    try {
      var allModules = getAllModules();
      var moduleMap = <int, ModuleModel>{};
      if (permissionsController.userRole.value == "admin") {
        moduleMap = allModules;
      } else {
        var permissions = permissionsController.moduleFeaturesMap;

        for (var moduleId in permissions.keys) {
          if (!allModules.containsKey(moduleId)) {
            print("Ignoring unknown module ID: $moduleId");
            continue;
          }
          ModuleModel matchedModule = allModules[moduleId]!;
          List<int> allowedFeatureIds = permissions[moduleId] ?? [];

          moduleMap[moduleId] =
              matchedModule.copyWith(featureIds: allowedFeatureIds);
        }
      }

      modules.value = moduleMap.values.toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch modules: $e");
    }
  }

  Map<int, ModuleModel> getAllModules() {
    return {
      1: ModuleModel(
        id: 1,
        moduleName: "education_assistance",
        moduleTitle: "Education Assistance",
        icon: "📚",
        featureIds: [],
        onModuleOpen: (featureIds, its,mohalla) async {
          navigateToModule(1, featureIds, its: its);
        },
      ),
      2: ModuleModel(
        id: 2,
        moduleName: "dashboard",
        moduleTitle: "View Requests",
        icon: "📊",
        featureIds: [],
        onModuleOpen: (featureIds, its, mohalla) async {
          navigateToModule(2, featureIds, its: its,mohalla: mohalla);
        },
      ),
      // 3: ModuleModel(
      //   id: 3,
      //   moduleName: "admin_panel",
      //   moduleTitle: "Admin Panel",
      //   icon: "⚙️",
      //   featureIds: [],
      //   onModuleOpen: (featureIds, its) async {
      //     navigateToModule(3, featureIds, its: its);
      //   },
      // ),
    };
  }

  Future<void> navigateToModule(int moduleId, List<int> featureIds,
      {String? its, String? mohalla}) async {
    switch (moduleId) {
      case 1:
        if(its!=null){
          isLoading.value = true;
          //var family = await Api.fetchProxiedData('http://192.168.52.58:8080/crc_live/backend/dist/mumineen/getFamilyDetails.php?user_name=umoor_talimiyah&password=UTalim2025&token=0a1d240f3f39c454e22b2402303aa2959d00b770d9802ed359d75cf07d2e2b65&its_id=${its}');
          //print(family);
          Family? family = await Api.fetchFamilyProfileOld(its);
          isLoading.value = false;
          Get.to(() => FamilyScreenController(family: family!));
        }
        break;
      case 2:
        Get.to(() => ReqFormTable(mohalla: mohalla!));
        break;
      case 3:
        print("Opening Admin Panel Module with Features: $featureIds");
        break;
      default:
        Get.snackbar("Error", "Module not found");
    }
  }
}

class ModuleScreenController extends StatelessWidget {
  const ModuleScreenController({super.key, required this.its});
  final String its;

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define the breakpoint for mobile
    const double mobileBreakpoint = 600;

    return screenWidth <= mobileBreakpoint
          ? ModuleSelectionScreenM(its: its)
          : ModuleSelectionScreenW(its: its);
  }
}
