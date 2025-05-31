import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/constants/app_routes.dart';
import '../api/api.dart';
import '../constants/constants.dart';
import 'dart:typed_data';
import '../constants/custom_dialog.dart';
import '../controller/admin/view_req_forms.dart';
import 'package:ows/controller/family_screen_controller.dart';
import '../controller/state_management/state_manager.dart';
import '../model/family_model.dart';
import '../model/member_model.dart';

class FamilyScreenW extends StatefulWidget {
  //final List<FamilyMember> familyMembers;

  const FamilyScreenW({
    super.key,
  });

  @override
  FamilyScreenWState createState() => FamilyScreenWState();
}

class FamilyScreenWState extends State<FamilyScreenW> {
  int? _selectedIndex;
  final RxBool _isLoading = false.obs;
  GlobalStateController stateController = Get.find<GlobalStateController>();
  FamilyScreenController controller = Get.find<FamilyScreenController>();
  final ReqFormController reqFormController = Get.find<ReqFormController>();

  @override
  void initState() {
    super.initState();

    if (stateController.familyMembers.isEmpty) {
      stateController.loadFromStorage();
    }

    if (stateController.familyMembers.isNotEmpty) {
    } else {
      print("No family members loaded yet.");
    }
  }

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

  /// **🔹 Function to Handle Base64 Image Conversion**
  Widget _buildProfileImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Container(
        height: 90,
        width: 70,
        color: Colors.grey,
        child: const Icon(Icons.person, color: Colors.white, size: 40),
      );
    }

    try {
      /// **🔄 Remove "data:image/jpeg;base64," prefix before decoding**
      String base64Data = base64String.split(',').last;
      Uint8List imageBytes = base64Decode(base64Data);

      return Image.memory(
        imageBytes,
        height: 90,
        width: 70,
        fit: BoxFit.cover,
      );
    } catch (e) {
      print("🚨 Error decoding Base64 image: $e");
      return Container(
        height: 90,
        width: 70,
        color: Colors.grey,
        child: const Icon(Icons.error, color: Colors.white, size: 40),
      );
    }
  }

  Widget headerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Login By: ${stateController.loggedinBy.value}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          Row(
            children: [
              Text(
                "Click family member or self-student for whom applying for Imdaad Talimi.  ",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side:
                          BorderSide(color: const Color(0xFF008759), width: 2),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(0),
                ),
                onPressed: () => Constants().Logout(),
                child: Text("Logout",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xffffead1)),
      child: Stack(
        children: [
          // _isLoading == true
          //     ? Center(
          //   child:LoadingAnimationWidget.discreteCircle(
          //     color: Colors.white,
          //     size: 80,
          //   ),
          // )
          //     :
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: headerSection(context),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF7EC), // Background color
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
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
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 500,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 120,
                                childAspectRatio: 8.5 / 2,
                              ),
                              itemCount: stateController.familyMembers.length,
                              itemBuilder: (context, index) {
                                final member =
                                    stateController.familyMembers[index];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index == _selectedIndex
                                          ? null
                                          : index;
                                    });
                                    final selectedMember = stateController
                                        .familyMembers[_selectedIndex!];
                                    fetchUserProfile(
                                        selectedMember.itsNumber.toString());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Color(0xffffead1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedIndex == index
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: _buildProfileImage(
                                              member.profileImage),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: _selectedIndex == index
                                                    ? Icon(Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 20)
                                                    : Icon(Icons.check_circle,
                                                        color:
                                                            Colors.transparent,
                                                        size: 20),
                                              ),
                                              Text(
                                                member.fullName,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                member.itsNumber.toString(),
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                'Age: ${member.age.toString()}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                "Note: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              Text(
                                  style: TextStyle(fontSize: 17),
                                  "Approval of your Imdad Talimi application is depends on your correct education profile filled on Paktalim.com.pk."),
                            ],
                          ),
                          Text(
                              style: TextStyle(fontSize: 17),
                              "It’s compulsory to complete education profile first for all family members on Paktalim.com.pk."),
                          Text(
                              style: TextStyle(fontSize: 17),
                              "For applicant’s convenient profile update icon also provided on next page. Check your education profile and update it correctly."),
                          SizedBox(height: 25),

                          // SizedBox(
                          //   width: 300,
                          //   height: 50,
                          //   child: ElevatedButton(
                          //     onPressed: _selectedIndex != null && !_isLoading
                          //         ? () {
                          //             final selectedMember = stateController
                          //                 .familyMembers[_selectedIndex!];
                          //             fetchUserProfile(
                          //                 selectedMember.itsNumber.toString());
                          //           }
                          //         : null,
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: const Color(0xFF008759),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //     ),
                          //     child: _isLoading
                          //         ? CircularProgressIndicator(
                          //             valueColor: AlwaysStoppedAnimation<Color>(
                          //                 Colors.white))
                          //         : Text('Continue',
                          //             style: TextStyle(
                          //                 fontSize: 18, color: Colors.white)),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            if (_isLoading.value) {
              return Container(
                color: Colors.black.withValues(alpha: 0.5),
                // Semi-transparent background
                child: Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              );
            }
            return const SizedBox.shrink(); // Empty widget when not loading
          }),
        ],
      ),
    );
  }
}
