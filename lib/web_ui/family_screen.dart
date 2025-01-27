import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/dummy_data.dart';
import '../controller/profile_pdf_controller.dart';
import '../model/family_model.dart';

class FamilyScreenW extends StatefulWidget {
  final Family family;

  const FamilyScreenW({super.key, required this.family});

  @override
  FamilyScreenWState createState() => FamilyScreenWState();
}

class FamilyScreenWState extends State<FamilyScreenW> {
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
        Row(
          spacing: 16,
          children: [
            SizedBox(
              height: 35,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.transparent; // No hover effect
                      }
                      return Colors.transparent; // Default color
                    },
                  ),
                  overlayColor: WidgetStateProperty.all(Colors.transparent), // No ripple effect
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                        color: const Color(0xFF008759),
                        width: 2, // Green border
                      ),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(0), // Flat button
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text(
                  "Logout",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<void> fetchUserProfile(int itsId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Call the API to fetch user profile
      //final userProfile = await Api.fetchUserProfile(itsId.toString()); // Add API call
      final userProfile1 = userProfile;
      if (userProfile1 != null) {
        // Get.to(() => ProfilePreview(
        //   member: userProfile,
        //   family: widget.family,
        // ));
        // Get.to(() => ProfilePreview(
        //   member: userProfile1,
        //   family: widget.family,
        // ));
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
    return Container(
        decoration: BoxDecoration(
          color: Color(0xffffead1),
        ),
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
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 16,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Education Assistance Form For:',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Grid view for family members
                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 500, // Maximum width of each item
                              crossAxisSpacing: 16, // Spacing between columns
                              mainAxisSpacing: 16, // Spacing between rows
                              mainAxisExtent: 120,
                              childAspectRatio:
                                  8.5 / 2, // Aspect ratio for item (width:height)
                            ),
                            itemCount: familyMembers.length,
                            itemBuilder: (context, index) {
                              final item = familyMembers[index];
                              final member =
                                  item['member']; // Cast to the Family model
              
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Photo(member is Parent
                                      //                                         ? member.image
                                      //                                         : (member as Family).image) ??
                                      //                                         '',
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          // Use your backend API to fetch the image
                                          'http://localhost:3001/fetch-image?url=${Uri.encodeComponent(
                                            (member is Parent ? member.image : (member as Family).image) ?? '',
                                          )}',
                                          height: 150,
                                          width: 110,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 150,
                                              width: 110,
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
                                      // Member details
                                      Flexible(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: _selectedIndex == index
                                                  ? Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 20,
                                                    )
                                                  : const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.transparent,
                                                      size: 20,
                                                    ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (member is Parent
                                                            ? member.name
                                                            : (member as Family)
                                                                .fullName) ??
                                                        '',
                                                    softWrap: false,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    (member is Parent
                                                            ? member.itsId
                                                            : (member as Family).its)
                                                        .toString(),
                                                    style:
                                                        const TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            )
                                            // Tick icon
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Continue button
                      SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedIndex != null && !_isLoading
                              ? () {
                            final selectedMember =
                            familyMembers[_selectedIndex!]['member'];
                            final itsId = (selectedMember is Parent
                                ? selectedMember.itsId
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
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
