import 'package:get/get.dart';

import '../../model/permission_model.dart';

class GlobalStateController extends GetxController {
  // Observable variable to track the loading state
  var isLoading = false.obs;
  var userProfile = ''.obs;
  var userRole = ''.obs;
  var userIts = ''.obs;

  // Store unique module IDs
  var moduleIds = <int>[].obs;

  // Store feature IDs for each module ID
  var moduleFeaturesMap = <int, List<int>>{}.obs;

  // Store module names by module ID
  var moduleNames = <int, String>{}.obs;

  // Store feature names by feature ID
  var featureNames = <int, String>{}.obs;

  // Function to process permissions list
  void setPermissions(List<Permission> permissions) {
    for (var permission in permissions) {
      // Add module ID if not present
      if (!moduleIds.contains(permission.moduleId)) {
        moduleIds.add(permission.moduleId);
        moduleNames[permission.moduleId] = permission.moduleName;
        moduleFeaturesMap[permission.moduleId] = [];
      }

      // Add feature ID to the module's feature list
      if (!moduleFeaturesMap[permission.moduleId]!.contains(permission.featureId)) {
        moduleFeaturesMap[permission.moduleId]!.add(permission.featureId);
        featureNames[permission.featureId] = permission.featureName;
      }
    }
  }

  // Method to toggle loading state
  void toggleLoading(bool value) {
    isLoading.value = value;
  }

}