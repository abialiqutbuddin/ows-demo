import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ows/constants/app_routes.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/model/family_model.dart';
import 'package:ows/web_ui/modules/update_profile.dart';
import '../api/api.dart';
import '../constants/constants.dart';
import '../controller/profile_pdf_controller.dart';
import 'dart:typed_data';
import '../controller/state_management/state_manager.dart';

class FamilyScreenW extends StatefulWidget {
  //final List<FamilyMember> familyMembers;

  const FamilyScreenW({
    super.key,
  });

  @override
  FamilyScreenWState createState() => FamilyScreenWState();
}

class FamilyScreenWState extends State<FamilyScreenW> {
  int? _selectedIndex; // Track the selected family member
  bool _isLoading = false;
  GlobalStateController stateController = Get.find<GlobalStateController>();

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

  Future<void> fetchUserProfile(String itsId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userProfile = await Api.fetchUserProfile(itsId);
      if (userProfile != null) {
        stateController.user.value = userProfile;
        //   Get.to(() => AppRoutes.select_module);
        //   // if(stateController.updateProfile.value==true){
        //   //   stateController.user.value = userProfile;
        //   //   //Get.to(() => ProfilePreview(member: userProfile, family: Family()));
        //   // }else {
        //   //   stateController.user.value = userProfile;
        //   //   //Get.to(() => ProfilePDFScreen());
        //   // }
      } else {
        Get.snackbar("Error", "Profile not found for ITS ID: $itsId");
      }
      var response = await Api.getToken(itsId);
      if (response.containsKey('token')) {
        String token = response['token'];
        stateController.userRole.value = response["user"]["role"];
        stateController.userMohalla.value = response["user"]["mohalla"];
        stateController.userUmoor.value = response["user"]["umoor"] ?? "";
        stateController.userIts.value = itsId;
        GetStorage().write("token", token);
        Get.to(() => ModuleScreenController());
      }

      // if (userProfile != null) {
      //   Get.to(() => AppRoutes.select_module);
      //   // if(stateController.updateProfile.value==true){
      //   //   stateController.user.value = userProfile;
      //   //   //Get.to(() => ProfilePreview(member: userProfile, family: Family()));
      //   // }else {
      //   //   stateController.user.value = userProfile;
      //   //   //Get.to(() => ProfilePDFScreen());
      //   // }
      // } else {
      //   Get.snackbar("Error", "Profile not found for ITS ID: $itsId");
      // }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
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
          child: Text("Logout",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xffffead1)),
      child: Column(
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
                        color: Colors.grey.withOpacity(0.1),
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
                        'Education Assistance Form For:',
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
                            final member = stateController.familyMembers[index];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIndex =
                                      index == _selectedIndex ? null : index;
                                });
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
                                      borderRadius: BorderRadius.circular(8),
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
                                            alignment: Alignment.centerRight,
                                            child: _selectedIndex == index
                                                ? Icon(Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 20)
                                                : Icon(Icons.check_circle,
                                                    color: Colors.transparent,
                                                    size: 20),
                                          ),
                                          Text(
                                            member.fullName ?? '',
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            member.itsNumber.toString(),
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
                      SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedIndex != null && !_isLoading
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
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white))
                              : Text('Continue',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
