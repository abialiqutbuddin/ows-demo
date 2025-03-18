import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ows/model/family_data2.dart';
import 'package:ows/model/member_model.dart';

import '../../mobile_ui/forms/documents_upload.dart';
import '../../model/document.dart';
import '../../model/family_model.dart';
import '../../model/permission_model.dart';

class GlobalStateController extends GetxController {
  // Observable variable to track the loading state
  var isLoading = false.obs;
  var userProfile = ''.obs;
  var userRole = ''.obs;
  var userIts = ''.obs;
  var userMohalla = ''.obs;
  var userUmoor = ''.obs;
  var appliedByITS = ''.obs;
  var appliedByName = ''.obs;
  var familyMembers = <FamilyMember>[].obs;
  final box = GetStorage();
  var token = ''.obs;
  var version = ''.obs;

  final RxMap<String, Document?> documents = <String, Document?>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadFromStorage();
  }


  void loadFromStorage() {
    userIts.value = box.read('userIts') ?? '';
    token.value = box.read('token') ?? '';

    var storedFamily = box.read<List<dynamic>>('familyMembers');
    if (storedFamily != null) {
      familyMembers.value = storedFamily.map((e) => FamilyMember.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      familyMembers.clear();
    }
  }

  void setUser(String its, List<FamilyMember> family) {
    userIts.value = its;
    familyMembers.value = family;

    box.write('userIts', its);
    box.write('familyMembers', family.map((e) => e.toJson()).toList());
  }

  //final Rx<FamilyMember> family = FamilyMember().obs;
  final Rx<UserProfile> user = UserProfile().obs;

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