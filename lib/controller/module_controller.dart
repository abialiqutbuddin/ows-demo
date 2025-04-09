import 'dart:convert';

import 'package:get/get.dart';
import 'package:ows/constants/app_routes.dart';
import 'package:ows/controller/family_screen_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/mobile_ui/module_screen.dart';
import 'package:ows/web_ui/modules/view_requests.dart';
import '../api/api.dart';
import '../constants/table_controller.dart';
import '../model/family_data2.dart';
import '../model/family_model.dart';
import '../model/module_model.dart';
import 'package:flutter/material.dart';

import '../web_ui/module_screen.dart';
import '../web_ui/profile_preview_screen.dart';

class ModuleController extends GetxController {
  var modules = <ModuleModel>[].obs;
  RxBool isLoading = false.obs;

  final GlobalStateController globalController =
      Get.find<GlobalStateController>();

  void toggleLoading(bool value) {
    isLoading.value = value;
  }

  Future<void> fetchModules(String itsId) async {
    try {
      var allModules = getAllModules();
      var moduleMap = <int, ModuleModel>{};
      if (globalController.userRole.value == "admin") {
        moduleMap = allModules;
      } else {
        var permissions = globalController.moduleFeaturesMap;

        for (var moduleId in permissions.keys) {
          if (!allModules.containsKey(moduleId)) {
            continue;
          }
          ModuleModel matchedModule = allModules[moduleId]!;
          List<int> allowedFeatureIds = permissions[moduleId] ?? [];

          moduleMap[moduleId] =
              matchedModule.copyWith(featureIds: allowedFeatureIds);
        }
        moduleMap[2] = allModules[2]!;
      }

      modules.value = moduleMap.values.toList();
    } catch (e) {
      if (Get.overlayContext != null) {
        Get.snackbar("Error", "Failed to fetch modules: $e");
      }
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
        onModuleOpen: (featureIds, its, mohalla) async {
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
          navigateToModule(2, featureIds,
              its: its,
              mohalla: mohalla,
              role: globalController.userRole.value);
        },
      ),
      3: ModuleModel(
        id: 2,
        moduleName: "update_profile",
        moduleTitle: "Update Profile",
        icon: "📊",
        featureIds: [],
        onModuleOpen: (featureIds, its, mohalla) async {
          navigateToModule(3, featureIds,
              its: its,
              mohalla: mohalla,
              role: globalController.userRole.value);
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
      {required String its, String? mohalla, String? role}) async {
    switch (moduleId) {
      case 1:
        isLoading.value = true;
        List<FamilyMember>? familyMembers = await Api.fetchFamilyData2(its);
        isLoading.value = false;

        if (familyMembers != null && familyMembers.isNotEmpty) {
          globalController.updateProfile.value = false;
          globalController.setUser(its, familyMembers);
          globalController.familyMembers.value = familyMembers;
          Get.toNamed(AppRoutes.family_screen);
        } else {
          Get.snackbar("Error", "No family members found.");
        }
        break;
      case 2:
        Get.to(() => ReqFormTable(
              mohalla: globalController.userMohalla.value,
              featureIds: featureIds,
              org: globalController.userUmoor.value,
              ITS: its.toString(),
              role: role.toString(),
            ));
        break;
      case 3:
        isLoading.value = true;
        List<FamilyMember>? familyMembers = await Api.fetchFamilyData2(its);
        isLoading.value = false;

        if (familyMembers != null && familyMembers.isNotEmpty) {
          globalController.updateProfile.value = true;
          globalController.setUser(its, familyMembers);
          globalController.familyMembers.value = familyMembers;
          Get.toNamed(AppRoutes.family_screen);
        } else {
          Get.snackbar("Error", "No family members found.");
        }
        break;
      default:
        Get.snackbar("Error", "Module not found");
    }
  }
}

class ModuleScreenController extends StatelessWidget {
  ModuleScreenController({super.key});

  final GlobalStateController globalController =
      Get.find<GlobalStateController>();

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define the breakpoint for mobile
    const double mobileBreakpoint = 600;

    return screenWidth <= mobileBreakpoint
        ? ModuleSelectionScreenM(its: globalController.userIts.value)
        : ModuleSelectionScreenW(its: globalController.userIts.value);
  }
}
