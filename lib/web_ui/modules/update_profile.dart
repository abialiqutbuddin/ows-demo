import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/constants/expandable_container.dart';
import 'package:ows/web_ui/widgets/update_paktalim.dart';
import 'package:ows/web_ui/widgets/view_requests_web.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:get/get.dart';
import '../../api/api.dart';
import '../../controller/state_management/state_manager.dart';
import '../../model/family_model.dart';
import '../../model/pakTalimFuture.dart';
import '../widgets/show_instructions_dialog.dart';
import '../widgets/update_future_education.dart';

class ProfilePreview extends StatefulWidget {
  const ProfilePreview({
    super.key,
  });

  @override
  State<ProfilePreview> createState() => _ProfilePreviewState();
}

class _ProfilePreviewState extends State<ProfilePreview> {
  late final List<Widget> futureSubEducation = [
    subEducation("Dunyawi", "Future Education Plan,", "No Data Available"),
  ];

  //late UserProfile member;

  final GlobalStateController gController = Get.find<GlobalStateController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
    ever<UserProfile>(gController.user, (newUser) {
      setState(() {
      });
    });
   // _loadMemberFromController();
  }

  void _showInstructions() {
    final List<String> instructions = [
      "Marhala 1: Pre Primary - Class ( Play Group - Senior Kindergarten )",
      "Marhala 2: Primary - Class ( 1st - 4th )",
      "Marhala 3: Secondary - Class ( 5th - 8th )",
      "Marhala 4: O-Levels / Matric",
      "Marhala 5: A-Levels / HSSC",
      "Marhala 6: Graduation",
      "Marhala 7: Post Graduation / Master's",
      "Future Education: Planning for further studies",
      "Should be filled in defined sequance.",
      "Take special care in selecting Class & Year",
      "For Applying student profile:",
      "S/he must update future education for which S/he are applying for imdad talimi."
    ];
    showInstructionsDialog(
        () {}, instructions, "Instructions: How to update Profile.");
  }

  // Future<void> _loadMemberFromController() async {
  //   // If controller already has an itsId, just use it
  //   if (gController.user.value.itsId != null) {
  //     member = gController.user.value;
  //   } else {
  //     // Otherwise read from storage
  //     final storedData = await GetStorage().read('user');
  //     if (storedData == null) {
  //       throw Exception("No user in storage");
  //     }
  //     final storedProfile = UserProfile.fromJson(storedData);
  //     gController.user.value = storedProfile;
  //     member = storedProfile;
  //   }
  //
  //   // Now that member is set, show the UI
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Define the minimum width for your content
    const double minWidth = 1280;

    // Determine whether the screen is narrower than your minimum width
    final bool isScreenNarrow = screenWidth < minWidth;

    // Wrap your content in a SingleChildScrollView if the screen is too narrow
    Widget content = isScreenNarrow
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: minWidth, child: buildContent(context)),
          )
        : buildContent(context);

    return SelectionArea(
      child: Scaffold(
        backgroundColor: Color(0xfffff7ec),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                child: content,
              ),
            ),
            Obx(() {
              if (gController.updateProfileLoading.value) {
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
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        spacing: 10,
        children: [
          headerSection(context),
          headerProfile(context),
          Divider(),
          otherItems(context),
        ],
      ),
    );
  }

  Widget headerSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Constants().heading('Profile Preview'),
        Row(
          spacing: 16,
          children: [
            SizedBox(
              width: 120,
              height: 35,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008759),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    "Go Back",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        )
      ],
    );
  }

  Widget headerProfile(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                Api.fetchImage(gController.user.value.imageUrl!),
                width: 120,
                height: 170,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gController.user.value.fullName!),
                  Text(" | "),
                  Text('${gController.user.value.itsId}')
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                spacing: 10,
                children: [
                  Row(
                    spacing: 5,
                    children: [Icon(Icons.email), Text(gController.user.value.email!)],
                  ),
                  Row(
                    spacing: 5,
                    children: [Icon(Icons.phone), Text(gController.user.value.mobileNo!)],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Icon(Icons.calendar_month_rounded),
                      Text(gController.user.value.dob!)
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                spacing: 12,
                children: [
                  profileBox('Jamaat:', gController.user.value.tanzeem!, context),
                  profileBox(
                      'Hifz Sanad:',
                      (gController.user.value.hifzSanad == null || gController.user.value.hifzSanad!.isEmpty)
                          ? '-'
                          : gController.user.value.hifzSanad.toString(),
                      context),
                  profileBox(
                      'Current:', gController.user.value.currentClass.toString(), context),
                  profileBox('Marhala Status:',
                      (gController.user.value.status == 1) ? 'Completed' : 'Ongoing', context),
                  profileBox('Ambition', gController.user.value.ambitionId.toString(), context),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  "Your profile is 100% Completed!",
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Text(
                  "HOF ITS: ${gController.user.value.hofId}",
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Idara: ${gController.user.value.idara}",
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Organization: ${gController.user.value.organization}",
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget otherItems(BuildContext context) {
    List<Map<String, dynamic>> allClasses = [
      {"id": 1, "name": "Play Group", "rank": 1, "marhala": 1},
      {"id": 2, "name": "Nursery", "rank": 2, "marhala": 1},
      {"id": 3, "name": "Junior Kindergarten", "rank": 3, "marhala": 1},
      {"id": 4, "name": "Senior Kindergarten", "rank": 4, "marhala": 1},
      {"id": 5, "name": "1st", "rank": 5, "marhala": 2},
      {"id": 6, "name": "2nd", "rank": 6, "marhala": 2},
      {"id": 7, "name": "3rd", "rank": 7, "marhala": 2},
      {"id": 8, "name": "4th", "rank": 8, "marhala": 2},
      {"id": 9, "name": "5th", "rank": 9, "marhala": 3},
      {"id": 10, "name": "6th", "rank": 10, "marhala": 3},
      {"id": 11, "name": "7th", "rank": 11, "marhala": 3},
      {"id": 12, "name": "8th", "rank": 12, "marhala": 3},
      {"id": 13, "name": "9th", "rank": 13, "marhala": 4},
      {"id": 14, "name": "O-Level(I)", "rank": 14, "marhala": 4},
      {"id": 15, "name": "10th", "rank": 15, "marhala": 4},
      {"id": 16, "name": "O-Level(II)", "rank": 15, "marhala": 4},
      {"id": 17, "name": "11th", "rank": 16, "marhala": 5},
      {"id": 18, "name": "AS-Level", "rank": 16, "marhala": 5},
      {
        "id": 19,
        "name": "Diploma/ Vocational Training",
        "rank": 17,
        "marhala": 5
      },
      {
        "id": 20,
        "name": "Diploma of Associate Engineer (DAE)",
        "rank": 17,
        "marhala": 5
      },
      {"id": 21, "name": "12th", "rank": 17, "marhala": 5},
      {"id": 22, "name": "A2-Level", "rank": 17, "marhala": 5},
      {
        "id": 23,
        "name": "Associated Degree Programs",
        "rank": 18,
        "marhala": 6
      },
      {"id": 24, "name": "Bachelors Degree Programs", "rank": 18, "marhala": 6},
      {"id": 25, "name": "Professional Programs", "rank": 18, "marhala": 6},
      {
        "id": 26,
        "name": "Diploma/ Vocational Training",
        "rank": 18,
        "marhala": 6
      },
      {"id": 27, "name": "Masters/ M. Phil.", "rank": 19, "marhala": 7},
      {"id": 28, "name": "Ph.D", "rank": 19, "marhala": 7},
      {"id": 29, "name": "Post Doctorate", "rank": 19, "marhala": 7},
    ];

    List<Map<String, dynamic>> matchedEducationList = [];

    for (var education in gController.user.value.education!) {
      //  for (var education in gController.user.value.education!) {
      var matchedClass = allClasses.firstWhere(
        (cls) => cls["name"] == education.className,
        orElse: () => {},
      );

      if (matchedClass.isNotEmpty) {
        matchedEducationList.add(matchedClass);
      }
    }

    final groupedEducation =
        groupEducationByMarhala(gController.user.value.education ?? []);

    final groupedFutureEducation =
        groupFutureEducationByMarhala(gController.user.value.future ?? []);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          spacing: 20,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              width: Constants().responsiveWidth(context, 0.3),
              decoration: BoxDecoration(
                  color: Color(0xffffead1),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constants().subHeading("Education Journey"),
                  Divider(),
                  Container(
                    padding: EdgeInsets.only(right: 40),
                    child: FixedTimeline.tileBuilder(
                      theme: TimelineThemeData(
                        indicatorTheme: IndicatorThemeData(
                            color: Constants().green, size: 20),
                        direction: Axis.vertical,
                        connectorTheme: ConnectorThemeData(
                          space: 30.0,
                          thickness: 1.0,
                          color: Colors.brown,
                        ),
                      ),
                      builder: TimelineTileBuilder.connectedFromStyle(
                        contentsAlign: ContentsAlign.reverse,
                        oppositeContentsBuilder: (context, index) {
                          // Returning custom content for each index
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(matchedEducationList[index]['name']),
                                Text(
                                  "Completed",
                                  style: TextStyle(
                                      color: Constants().green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ), // Custom content changes for each item
                          );
                        },
                        contentsBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Marhala ${matchedEducationList[index]['marhala']}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ), // Display marhala from bottom to top
                          );
                        },
                        connectorStyleBuilder: (context, index) =>
                            ConnectorStyle.solidLine,
                        indicatorStyleBuilder: (context, index) =>
                            IndicatorStyle.outlined,
                        itemCount: matchedEducationList.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              width: Constants().responsiveWidth(context, 0.3),
              decoration: BoxDecoration(
                  color: Color(0xffffead1),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constants().subHeading("Family"),
                  Divider(),
                  //familyContainer(context, family),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 20, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    SizedBox(
                      height: 35,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008759),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5.0), // Rounded corners
                          ),
                        ),
                        onPressed: () async {
                          updatePakTalimForm().showRequestDetailsPopup(context);
                        },
                        child: const Text(
                          'Add Education',
                          style: TextStyle(
                            color: Colors.white,
                            // Button text color
                            letterSpacing: -0.5,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(5.0), // Rounded corners
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => FutureEducationDialog(
                              onSubmit: (FutureFormData formData) async {
                                //print(formData);
                                bool success = await Api.submitFutureForm(formData);
                                if (success){
                                  gController.updateProfileLoading.value = true;
                                  final userProfile = await Api.fetchUserProfile(gController.user.value.itsId.toString());

                                  if (userProfile != null) {
                                    GetStorage().write('user', userProfile);
                                    gController.user.value = userProfile;
                                    gController.updateProfileLoading.value = false;
                                  } else {
                                    gController.updateProfileLoading.value = false;
                                    Get.snackbar("Error", "Profile not found for ITS ID: ${gController.user.value.itsId.toString()}");
                                  }
                                }
                                //print(formData.toFormData()); // Submit to API or show snackbar
                              },
                            ),
                          );
                        },
                        child: Text("Add Future Education",style: TextStyle(
                          color: Colors.black,
                          letterSpacing: -0.5,
                          // Button text color
                          fontSize: 18.0,
                        ),),
                      ),
                    )
                  ],
                ),
                // Future Education Section
                if (groupedFutureEducation.isEmpty)
                  ExpandableEducation(
                    title: "Future Education",
                    subEducation: futureSubEducation,
                  )
                else
                  ...groupedFutureEducation.entries.map((entry) {
                    return ExpandableEducation(
                      title: "Future Education",
                      subEducation: [futureEducationDetails(entry.value)],
                    );
                  }),
                // Grouped Education Section
                ...groupedEducation.entries.map((entry) {
                  return ExpandableEducation(
                    title: "Marhala ${entry.key}",
                    subEducation: entry.value
                        .map((edu) =>
                            educationDetails(edu, edu.imaniOtherSchool ?? 0))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget futureEducationDetails(List<FuturePlan> education) {
    if (education.isEmpty) {
      return subEducation("Dunyawi", "Future Education Plan", "No Data Available");
    }

    final FuturePlan edu = education.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Color(0xfffff7ec),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Institution: ${edu.institute ?? '-'}"),
              Text("Course: ${edu.subject ?? '-'}"),
              Text("Standard: ${edu.study ?? '-'}"),
              Text("City: ${edu.city ?? '-'}"),
              Text("Country: ${edu.country ?? '-'}"),
            ],
          ),
        )
      ],
    );
  }

  Widget educationDetails(Education education, int type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Color(0xfffff7ec),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: type == 1 ? Constants().blue : Constants().green,
                    ),
                    child: Text(
                      type == 1 ? 'Deeni' : 'Dunyawi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                      height: 25,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5.0), // Rounded corners
                          ),
                        ),
                        onPressed: () {
                          updatePakTalimForm().showRequestDetailsPopup(context,
                              isEdit: true,
                              institute: education.institute,
                              marhalaId: education.marhalaId,
                              className: education.className,
                              city: education.city,
                            duration: education.duration.toString(),
                            course: education.subject,
                            endYear: education.endDate,
                            standard: education.standard

                          );
                        },
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            // Button text color
                            fontSize: 14.0,
                          ),
                        ),
                      )),
                ],
              ),
              Text("Institution: ${education.institute ?? '-'}"),
              Text("City: ${education.city ?? '-'}"),
              Text("Course: ${education.subject ?? '-'}"),
              Text("Standard: ${education.standard ?? '-'}"),
              Text("Status: ${education.status ?? '-'}"),
              Text("Duration: ${education.duration ?? '-'} months"),
              Text("Scholarship: ${education.scholarship ?? '-'}"),
              Text("Qarzan: ${education.qardan ?? '-'}"),
            ],
          ),
        )
      ],
    );
  }

  Widget familyContainer(BuildContext context, Family family) {
    // Combine family members into a single list with type
    List<Map<String, dynamic>> familyMembers = [
      if (family.father != null)
        {
          'type': 'Father',
          'member': family.father,
        },
      if (family.mother != null)
        {
          'type': 'Mother',
          'member': family.mother,
        },
      {
        'type': 'Child',
        'member': family,
      },
    ];

    return Wrap(
      spacing: 20, // Space between items
      runSpacing: 20, // Space between rows
      children: familyMembers.map((item) {
        final String type = item['type']
            as String; // Type of member (e.g., Father, Mother, Child)
        final dynamic member =
            item['member']; // Member object (Parent or Child)

        // Safeguard for null or invalid member data
        final String imageUrl =
            (member is Parent ? member.imageUrl : (member as Family).image) ??
                ''; // Use imageUrl if available
        final String fullName = (member is Parent
                ? member.fullName
                : (member as Family).fullName) ??
            ''; // Fallback for fullName
        final String itsId =
            (member is Parent ? member.itsId : (member as Family).its)
                .toString(); // ITS ID fallback

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                Api.fetchImage((imageUrl)).toString(),
                width: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            // Member Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // ITS Number and Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ITS: $itsId'),
                        Row(
                          children: const [
                            Icon(Icons.refresh, size: 16),
                            Text("100%"),
                          ],
                        ),
                      ],
                    ),
                    // Relationship Type
                    Text(type),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget subEducation(String type, String title, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Color(0xfffff7ec),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Dunyawi"), Text("No Data Available")],
              ),
              Text(
                "Future Education Plan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget profileBox(String title, String value, BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(10),
      width: Constants().responsiveWidth(context, 0.12),
      height: 100,
      decoration: BoxDecoration(
          color: Color(0xffffead1),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: [
          Text(title,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(value,
              style: TextStyle(
                  color: Constants().green, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Map<int, List<FuturePlan>> groupFutureEducationByMarhala(
      List<FuturePlan> educationList) {
    return {0: educationList}; // Using key `0` or any arbitrary key
  }

  Map<int, List<dynamic>> groupEducationByMarhala(List<dynamic> educationList) {
    Map<int, List<Education>> groupedEducation = {};
    for (var education in educationList) {
      groupedEducation
          .putIfAbsent(education.marhalaId!, () => [])
          .add(education);
    }
    return groupedEducation;
  }
}
