import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api.dart';
import '../constants/app_routes.dart';
import '../constants/constants.dart';
import '../controller/admin/view_req_forms.dart';
import '../controller/family_screen_controller.dart';
import 'dart:typed_data';
import '../controller/state_management/state_manager.dart';

class FamilyScreenM extends StatefulWidget {
  const FamilyScreenM({super.key});

  @override
  FamilyScreenMState createState() => FamilyScreenMState();
}

class FamilyScreenMState extends State<FamilyScreenM> {
  int? _selectedIndex;
  final RxBool _isLoading = false.obs;
  final GlobalStateController stateController =
      Get.find<GlobalStateController>();
  FamilyScreenController controller = Get.find<FamilyScreenController>();
  final ReqFormController reqFormController = Get.find<ReqFormController>();

  final box = GetStorage();


  Future<void> fetchUserProfile(String itsId) async {
    bool shouldProceed = true;
    setState(() {
      _isLoading.value = true;
    });
    try {
      var data = await Api.fetchProxiedData(
          "https://paktalim.com/admin/ws_app/GetFamilyCompletionStatus/$itsId?access_key=622ae1838756026b9500e50e778f131ac180bf70&username=40459629");

      stateController.profileComplete.value =
          data['profile_complete'].toString().toLowerCase() == 'true';
      stateController.familyProfileComplete.value =
          data['family_complete'].toString().toLowerCase() == 'true';


      if(stateController.devMode.value==true) {
        Get.snackbar("Completion Status",
            "Profile Complete: ${stateController.profileComplete.value},"
                "Family Complete: ${stateController.familyProfileComplete
                .value}",
            backgroundColor: Colors.green.withValues(alpha: 0.6));
      }

      shouldProceed = await controller.checkForActions();

      if (shouldProceed) {
        final userProfile = await Api.fetchUserProfile(itsId);
        stateController.paktalimFamily.value = await Api.fetchFamilyProfileOld(itsId);
        print(stateController.paktalimFamily.value.mother!.fullName);
        stateController.appInstructions = await Api.loadInstructionsByShortDesc();

        if (userProfile != null) {
          box.write('user', userProfile);
          stateController.user.value = userProfile;
          //       stateController.motherITS.value =  ;
          // stateController.fatherITS.value = (stateController.paktalimFamily.value.father!=null  ? stateController.paktalimFamily.value.father!.itsId.toString()  : '');
          stateController.lastMarhala.value = controller.fetchHighestMarhalaId(userProfile)!;
          await reqFormController.fetchRequests('', '', stateController.user.value.itsId.toString(), '');
        } else {
          Get.snackbar("Error", "Profile not found for ITS ID: $itsId");
        }
        //var response = await Api.getToken(itsId);
        //if (response.containsKey('token')) {
        //String token = response['token'];
        // stateController.userRole.value = response["user"]["role"];
        // stateController.userMohalla.value = response["user"]["mohalla"];
        // stateController.userUmoor.value = response["user"]["umoor"] ?? "";
        //stateController.userIts.value = itsId;
        //GetStorage().write("token", token);
        Get.toNamed(AppRoutes.select_module);
        //}
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user profile: $e");
    } finally {
      setState(() {
        _isLoading.value = false;
      });
    }
  }

  /// **🔹 Profile Image Loader (Base64 Support)**
  Widget _buildProfileImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Container(
        height: 80,
        width: 60,
        color: Colors.grey[300],
        child: const Icon(Icons.person, color: Colors.white, size: 40),
      );
    }

    try {
      String base64Data = base64String.split(',').last;
      Uint8List imageBytes = base64Decode(base64Data);

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          imageBytes,
          height: 80,
          width: 60,
          fit: BoxFit.cover,
        ),
      );
    } catch (e) {
      print("🚨 Error decoding Base64 image: $e");
      return Container(
        height: 80,
        width: 60,
        color: Colors.grey[300],
        child: const Icon(Icons.error, color: Colors.white, size: 40),
      );
    }
  }

  /// **🔹 Logout Button**
  Widget headerSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            "Login By: ${stateController.loggedinBy.value}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        Flexible(
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: const Color(0xFF008759), width: 2),
                ),
              ),
              elevation: WidgetStateProperty.all(0),
            ),
            onPressed: () => Constants().Logout(),
            child: const Text(
              "Logout",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(top: screenHeight * 0.05),
      height: screenHeight,
      decoration: const BoxDecoration(
        color: Color(0xffffead1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 15,
            children: [
              headerSection(context),
              Container(
                height: screenHeight * 0.75,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EC),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Family Members',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Click family member or self-student for whom applying for Imdaad Talimi.  ",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    // **Family Members List**
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero, // 👈 prevents default top padding
                        itemCount: stateController.familyMembers.length,
                        itemBuilder: (context, index) {
                          final member = stateController.familyMembers[index];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex =
                                    index == _selectedIndex ? null : index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xffffead1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _selectedIndex == index
                                      ? Colors.green
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProfileImage(member.profileImage),
                                  const SizedBox(width: 12),

                                  // **Member Details**
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.fullName,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          member.itsNumber.toString(),
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.035),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedIndex == index)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    // **Continue Button**
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _selectedIndex != null && !_isLoading.value
                            ? () {
                                final selectedMember = stateController
                                    .familyMembers[_selectedIndex!];
                                fetchUserProfile(
                                    selectedMember.itsNumber.toString());
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008759),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading.value
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Note: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                      style: TextStyle(fontSize: 12),
                      "Approval of your Imdad Talimi application is depends on your correct education profile filled on Paktalim.com.pk."),
                  Text(
                      style: TextStyle(fontSize: 12),
                      "It’s compulsory to complete education profile first for all family members on Paktalim.com.pk."),
                  Text(
                      style: TextStyle(fontSize: 12),
                      "For applicant’s convenient profile update icon also provided on next page. Check your education profile and update it correctly."),
                ],
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
