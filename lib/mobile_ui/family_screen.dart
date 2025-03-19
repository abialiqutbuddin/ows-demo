import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/constants/dummy_data.dart';
import '../api/api.dart';
import '../constants/constants.dart';
import '../controller/profile_pdf_controller.dart';
import '../model/family_data2.dart';
import '../model/family_model.dart';
import 'dart:typed_data';
import '../controller/state_management/state_manager.dart';

class FamilyScreenM extends StatefulWidget {

  const FamilyScreenM({super.key});

  @override
  FamilyScreenMState createState() => FamilyScreenMState();
}

class FamilyScreenMState extends State<FamilyScreenM> {
  int? _selectedIndex;
  bool _isLoading = false;
  final GlobalStateController stateController = Get.find<GlobalStateController>();

  /// **🔹 Fetch User Profile Data**
  Future<void> fetchUserProfile(String itsId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userProfile = await Api.fetchUserProfile(itsId);
      if (userProfile != null) {
        Get.to(() => ProfilePDFScreen());
      } else {
        Get.snackbar("Error", "Profile not found for ITS ID: $itsId");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
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
          child: const Text(
            "Logout",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                    color: Colors.grey.withOpacity(0.2),
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
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // **Family Members List**
                  Expanded(
                    child: ListView.builder(
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
                                        member.fullName ?? '',
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

                  // **Continue Button**
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedIndex != null && !_isLoading
                          ? () {
                        final selectedMember =
                        stateController.familyMembers[_selectedIndex!];
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
                          ? const CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : const Text(
                        'Continue',
                        style:
                        TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}