import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api.dart';
import '../constants/constants.dart';
import '../constants/dummy_data.dart';
import '../controller/profile_pdf_controller.dart';
import '../model/family_model.dart';

class FamilyScreenM extends StatefulWidget {
  final Family family;

  const FamilyScreenM({super.key, required this.family});

  @override
  FamilyScreenMState createState() => FamilyScreenMState();
}

class FamilyScreenMState extends State<FamilyScreenM> {
  int? _selectedIndex; // Track the currently selected index
  late List<Map<String, dynamic>> familyMembers; // Unified list for all members
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Combine family details into a unified list
    familyMembers = [
      if (widget.family.father != null)
        {
          'type': 'Father',
          'member': widget.family.father,
        },
      if (widget.family.mother != null)
        {
          'type': 'Mother',
          'member': widget.family.mother,
        },
      {
        'type': 'Child',
        'member': widget.family,
      },
    ];
  }

  Widget headerSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide(color: const Color(0xFF008759), width: 2),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: () async {
              Constants().Logout();
            },
            child: const Text(
              "Logout",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> fetchUserProfile(int itsId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Call the API to fetch user profile
      final userProfile1 = userProfile;
      if (userProfile1 != null) {
        Get.to(() => ProfilePDFScreen(
          member: userProfile,
          family: widget.family,
        ));
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(top: screenHeight*0.1),
      height: screenHeight,
      decoration: const BoxDecoration(
          color: Color(0xffffead1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 15,
            children: [
              // Header Section
              headerSection(context),
              Container(
                height: screenHeight*0.7,
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
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      'Education Assistance Form For:',
                      style: TextStyle(
                        fontSize: screenWidth*0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // List of family members
                    Expanded(
                      child: ListView.builder(
                        itemCount: familyMembers.length,
                        itemBuilder: (context, index) {
                          final item = familyMembers[index];
                          final member = item['member'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index == _selectedIndex ? null : index;
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
                                  // Image Section
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      // Replace with your backend API
                                      Api.fetchImage((member is Parent ? member.image : (member as Family).image) ?? '').toString(),
                                      height: 100,
                                      width: 70,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 70,
                                          width: 70,
                                          color: Colors.grey,
                                          child: const Icon(
                                            Icons.error,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Member Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (member is Parent
                                              ? member.fullName
                                              : (member as Family).fullName) ??
                                              '',
                                          style: TextStyle(
                                            fontSize: screenWidth*0.035,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (member is Parent
                                              ? member.its
                                              : (member as Family).its)
                                              .toString(),
                                          style: TextStyle(fontSize: screenWidth*0.035),
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
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _selectedIndex != null && !_isLoading
                            ? () {
                          final selectedMember =
                          familyMembers[_selectedIndex!]['member'];
                          final itsId = (selectedMember is Parent
                              ? selectedMember.its
                              : (selectedMember as Family).its) ??
                              0;
                          fetchUserProfile(itsId);
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
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
              //SizedBox(height: screenHeight*0.1)
            ],
          ),
        ),
    );
  }
}