import 'dart:async';
import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';
import 'package:ows/controller/login_controller.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';
import '../constants/constants.dart';
import '../controller/request_form_controller.dart';
import '../controller/state_management/state_manager.dart';
import '../constants/dropdown_search.dart';
import '../model/funding_record_model.dart';
import '../model/member_model.dart';
import '../model/request_form_model.dart';

class RequestFormM extends StatefulWidget {
  const RequestFormM({super.key});

  @override
  RequestFormMState createState() => RequestFormMState();
}

class RequestFormMState extends State<RequestFormM> {
  final RequestFormController controller = Get.find<RequestFormController>();
  final GlobalStateController statecontroller = Get.find<GlobalStateController>();
  late final UserProfile member;
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    initializeMember();
    fetchRecords();
  }

  Future<void> initializeMember() async {
    setState(() {
      controller.isLoading.value = true;
    });
    member = statecontroller.user.value;
    //checkEducationStatus(widget.member);
    // controller.appliedbyIts = await Constants().getFromPrefs('appliedByIts');
    // controller.appliedByName = await Constants().getFromPrefs('appliedByName');
    setState(() {
      controller.isLoading.value = false;
    });
    controller.reqId.value = await Api.fetchNextReqMasId();
  }

  List<FundingRecords> records = [];

  Future<void> fetchRecords() async {
    try {
      List<FundingRecords> fetchedRecords = await Api.fetchRecords(statecontroller.user.value.itsId.toString());
     // List<FundingRecords> fetchedRecords = await Api.fetchRecords('50493600');
      setState(() {
        records = fetchedRecords;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildAiutRecord(BuildContext context) {
    return records.isEmpty
        ? SizedBox.shrink()
        : Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xfffff7ec),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : records.isEmpty
            ? SizedBox.shrink()
            : SizedBox(
          width: double.infinity,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Previously Taking Imdaad Talimi",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
              // Table Header
              Divider(),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xffdbbb99),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tableHeaderCell("School"),
                    tableHeaderCell("Organization"),
                    tableHeaderCell("Percentage"),
                    tableHeaderCell("Amount"),
                    tableHeaderCell("Status"),
                  ],
                ),
              ),
              SizedBox(height: 5),
              // Table Data
              Column(
                children: records
                    .map((record) => tableRow(record))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to Determine Date Status
  String getDateStatus(String date, List<FundingRecords> allRecords) {
    bool has2024 = allRecords.any((r) => r.date.contains("2024"));
    bool has2025 = allRecords.any((r) => r.date.contains("2025"));

    if (date.contains("2025")) {
      return has2024 ? "Current" : "Current"; // 2025 is always Current
    } else if (date.contains("2024")) {
      return has2025 ? "Last Years" : "Current"; // 2024 is Current only if 2025 is not present
    } else {
      return "Last Years"; // Any year before 2024 is Last Years
    }
  }

// Table Header Cell
  Widget tableHeaderCell(String title) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        //width: width,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

// Table Row Widget
  Widget tableRow(FundingRecords record) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: getDateStatus(record.date.toString(),records) != 'Current' ? Colors.transparent : Colors.white,
        boxShadow: getDateStatus(record.date.toString(),records) != 'Current' ? [] : [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(5),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          tableDataCell(record.school),
          tableDataCell(record.org),
          tableDataCell(record.orgP.toString()),
          tableDataCell(record.amount.toString()),
          tableDataCell(getDateStatus(record.date,records)),
        ],
      ),
    );
  }

// Table Data Cell
  Widget tableDataCell(String text) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.brown,fontWeight: FontWeight.bold,),
        ),
      ),
    );
  }

  // List<String> checkEducationStatus(UserProfile userProfile) {
  //   List<String> statusList = [];
  //
  //   bool hasOngoingEducation = userProfile.marhalaOngoing == 1;
  //   bool hasFutureEducation = userProfile.future?.isNotEmpty ?? false;
  //
  //   if (hasOngoingEducation) {
  //     statusList.add("Apply For Ongoing");
  //     statusList.add(
  //         "Apply For Future Education"); // Always add future when ongoing is 1
  //   } else if (!hasOngoingEducation && hasFutureEducation) {
  //     statusList.add("Apply For Future Education");
  //   } else {
  //     statusList.add(
  //         "Apply For Future Education"); // When no ongoing and no future, still allow future application
  //   }
  //
  //   return statusList;
  // }

  // List<String> checkEducationStatus(UserProfile userProfile) {
  //   List<String> statusList = [];
  //
  //   Education? lastEducation = userProfile.education?.isNotEmpty == true
  //       ? userProfile.education!.first
  //       : null;
  //
  //   bool hasFutureEducation = userProfile.future?.isNotEmpty ?? false;
  //
  //   if (lastEducation != null) {
  //     if (userProfile.marhalaOngoing == 1) {
  //       statusList.add("Apply For Ongoing");
  //     }
  //     if (hasFutureEducation) {
  //       statusList.add("Apply For Future Education");
  //     }
  //     if (userProfile.marhalaOngoing == 0 && hasFutureEducation == false) {
  //       statusList.add("Please update your profile at PakTalim");
  //     }
  //   } else {
  //     statusList.add("No education records found. Please update your profile.");
  //   }
  //   return statusList;
  // }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xfffffcf6),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          title: Text(
            'Request Form',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.05), // White title text
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context); // Default back navigation
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonHideUnderline(
                child: SizedBox(
                  child: DropdownButton2(
                    isExpanded: true,
                    customButton:
                        const Icon(Icons.more_vert, color: Colors.black),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'add_guardian',
                        child: Row(
                          children: const [
                            Icon(Icons.person_rounded,
                                size: 20, color: Colors.black),
                            SizedBox(width: 10),
                            Text("Add Guardian"),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'paktalim',
                        child: Row(
                          children: const [
                            Icon(Icons.update_rounded,
                                size: 20, color: Colors.black),
                            SizedBox(width: 10),
                            Text("Update Profile"),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'talabulilm',
                        child: Row(
                          children: const [
                            Icon(Icons.open_in_browser_rounded,
                                size: 20, color: Colors.black),
                            SizedBox(width: 10),
                            Text("Visit Talabulilm"),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: const [
                            Icon(Icons.logout_rounded,
                                size: 20, color: Colors.black),
                            SizedBox(width: 10),
                            Text("Logout"),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == 'logout') {
                        //_logout(context);
                        Get.to(() => LoginController());
                      } else if (value == 'paktalim') {
                        //_openLink();
                        final url =
                            'https://www.paktalim.com/admin/login'; // Replace with your URL
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          throw 'Could not launch $url';
                        }
                      } else if (value == 'talabulilm') {
                        //_showAlert(context);
                        final url =
                            'https://www.mhbtalabulilm.com/home'; // Replace with your URL
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode
                                .externalApplication, // Ensures it opens in a new tab or external browser
                          );
                        } else {
                          throw 'Could not launch $url';
                        }
                      } else if (value == 'add_guardian') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return
                                //GuardianFormDialog();
                                SizedBox.shrink();
                          },
                        );
                      }
                    },
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors
                            .transparent, // Transparent to blend in AppBar
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xffffead1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
            ),
          ]),
      backgroundColor: Color(0xfffffcf6),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              child: buildContent(context),
            ),
          ),
          Obx(() {
            if (statecontroller.isLoading.value) {
              return Container(
                color: Colors.black
                    .withValues(alpha: 0.5), // Semi-transparent background
                child: Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    size: 50,
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

  Widget buildContent(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        //headerSection(context),
        headerProfile(context),
        buildAiutRecord(context),
        requestForm(context),
        SizedBox(
          height: 25,
        ),
      ],
    );
  }

  Widget headerProfile(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.035;

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xfffff7ec),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants().subHeading("Personal Information"),
          Divider(),
          Row(
            spacing: 15,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  Api.fetchImage(member.imageUrl!),
                  width: 100,
                  fit: BoxFit.contain,
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
                  // errorBuilder: (context, error, stackTrace) {
                  //   return Image.asset(
                  //     "assets/demo.jpg", // Path to default image
                  //     width: 100,
                  //     fit: BoxFit.contain,
                  //   );
                  // },
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName ?? '',
                      softWrap: true,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSize),
                    ),
                    Text(
                      'Student ITS: ${member.itsId.toString()}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSize),
                    )
                  ],
                ),
              ),
            ],
          ),
          Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 15,
                children: [
                  FaIcon(
                    FontAwesomeIcons.locationDot,
                    size: 18,
                  ),
                  Flexible(
                      child: Text(
                    member.address ?? '',
                    softWrap: true,
                    style: TextStyle(fontSize: fontSize),
                  )),
                ],
              ),
              Row(
                spacing: controller.defSpacing,
                children: [
                  FaIcon(
                    FontAwesomeIcons.house,
                    size: 18,
                  ),
                  Text(member.jamiaat ?? '',
                      style: TextStyle(fontSize: fontSize)),
                ],
              ),
              Column(
                children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 15,
                    children: [
                      Flexible(
                        child: Row(
                          spacing: controller.defSpacing,
                          children: [
                            Icon(Icons.calendar_month_rounded),
                            Text(member.dob ?? '',
                                style: TextStyle(fontSize: fontSize)),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          spacing: controller.defSpacing,
                          children: [
                            Icon(Icons.calendar_month_rounded),
                            Text(
                                "${controller.calculateAge(member.dob ?? '')} years old",
                                style: TextStyle(fontSize: fontSize)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 15,
                    children: [
                      Flexible(
                        child: Row(
                          spacing: controller.defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(member.mobileNo!,
                                style: TextStyle(fontSize: fontSize)),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          spacing: controller.defSpacing,
                          children: [
                            FaIcon(FontAwesomeIcons.whatsapp),
                            Text(member.whatsappNo!,
                                style: TextStyle(fontSize: fontSize)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Column(
                spacing: controller.defSpacing,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: controller.defSpacing,
                    children: [
                      Icon(Icons.email),
                      Text(member.email!, style: TextStyle(fontSize: fontSize)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15,
            children: [
              profileBox('Applied By', 'ITS', context),
              profileBox('Name', 'Name', context),
            ],
          ),
          lastEducation()
        ],
      ),
    );
  }

  Widget profileBox(String title, String value, BuildContext context) {
    if (value == 'ITS') {
      value = statecontroller.appliedByITS.value;
    } else {
      value = statecontroller.appliedByName.value;
    }

    return Expanded(
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(10),
        width: Constants().responsiveWidth(context, 0.12),
        decoration: BoxDecoration(
            color: Color(0xffffead1),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            Text(value,
                style: TextStyle(
                    color: Constants().green, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget lastEducation() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.035;

    if (member.education == null || member.education!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Constants().subHeading("Last Education"),
            Divider(),
            Text(
              "No education data available",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants().subHeading("Last Education"),
          Divider(),
          Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: fontSize), // Common font size
                  children: [
                    TextSpan(
                      text: "Class/ Degree Program: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for label
                      ),
                    ),
                    TextSpan(
                      text: member.education?.isNotEmpty == true
                          ? member.education![0].className ?? "Not available"
                          : "Not available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants().green, // Green color for value
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: fontSize), // Common font size
                  children: [
                    TextSpan(
                      text: "Institution: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for label
                      ),
                    ),
                    TextSpan(
                      text: member.education?.isNotEmpty == true
                          ? member.education![0].institute ?? "Not available"
                          : "Not available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants().green, // Green color for value
                      ),
                    ),
                  ],
                ),
                softWrap: true,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: fontSize), // Common font size
                  children: [
                    TextSpan(
                      text: "Field of Study: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for label
                      ),
                    ),
                    TextSpan(
                      text: member.education?.isNotEmpty == true
                          ? member.education![0].subject ?? "Not available"
                          : "Not available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants().green, // Green color for value
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: fontSize), // Common font size
                  children: [
                    TextSpan(
                      text: "City: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for label
                      ),
                    ),
                    TextSpan(
                      text: member.education?.isNotEmpty == true
                          ? member.education![0].city ?? "Not available"
                          : "Not available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants().green, // Green color for value
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget requestForm(BuildContext context) {
    //final double screenWidth = MediaQuery.of(context).size.width;
    //double fontSize = screenWidth * 0.035;
    //RxString selectedStatus = "".obs;
    //List<String> statusOptions = checkEducationStatus(widget.member);

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xfffff7ec),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Constants().subHeading('Request for Education Assistance'),
          Divider(),
          // Row(
          //   spacing: 10,
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Text(
          //       "${controller.reqNum}${controller.reqId}",
          //       style:
          //           TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          //     ),
          //     Text("|", style: TextStyle(fontSize: fontSize)),
          //     Text(
          //       "Date: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
          //       style:
          //           TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          //     )
          //   ],
          // ),
          //SizedBox(),
          // Column(
          //   spacing: 5,
          //   children: statusOptions.first ==
          //           'Please update your profile at PakTalim'
          //       ? [
          //           Center(
          //               child: Padding(
          //             padding: const EdgeInsets.symmetric(vertical: 15.0),
          //             child: Text(
          //               "Please update your profile at PakTalim",
          //               style: TextStyle(
          //                   fontWeight: FontWeight.bold, fontSize: 16),
          //             ),
          //           ))
          //         ]
          //       : statusOptions.map((status) {
          //           return Container(
          //             decoration: BoxDecoration(
          //                 color: const Color(0xfffffcf6),
          //                 borderRadius: BorderRadius.circular(8),
          //                 border: Border.all(color: Colors.brown, width: 1)),
          //             child: Obx(() => RadioListTile<String>(
          //                   title: Text(status,
          //                       style: TextStyle(
          //                           fontSize: fontSize,
          //                           fontWeight: FontWeight.bold)),
          //                   value: status,
          //                   groupValue: selectedStatus.value,
          //                   activeColor: Colors.brown,
          //                   onChanged: (value) {
          //                     selectedStatus.value = value!;
          //                     controller.isButtonEnabled.value = true;
          //                   },
          //                 )),
          //           );
          //         }).toList(),
          // ),
          // ElevatedButton(onPressed: (){                        Get.to(() => FormScreen());
          // }, child: Text("NEXT")),
          // Obx(() => ElevatedButton(
          //       onPressed: controller.isButtonEnabled.value
          //           ? () {
          //               Get.to(() => FormScreen());
          //             }
          //           : null, // Disabled if form is invalid
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: controller.isButtonEnabled.value
          //             ? Constants().green
          //             : Colors.grey,
          //         padding: EdgeInsets.symmetric(vertical: 14),
          //         shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(8)),
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             "Apply",
          //             style: TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.white),
          //           ),
          //           Icon(
          //             Icons.navigate_next_rounded,
          //             color: Colors.white,
          //             size: 24,
          //           )
          //         ],
          //       ),
          //     )),
          //_form(),
          educationRequestForm2(context),
          _formFunds(),
          SizedBox(),
        ],
      ),
    );
  }


  // Determine Organization based on Request Type and Conditions
  String determineOrganization() {
    if (controller.selectedCategory.value == "Deeni") {
      return statecontroller.user.value.tanzeem?.toString() ?? "";
    }

    List<String> fiveMohalla = [
      "KHI (AL-MAHALAT-TUL-BURHANIYAH)",
      "KHI (AL-MAHALAT-TUL-MOHAMMEDIYAH)",
      "KHI (AL-MAHALLATUL-FAKHRIYAH)",
      "KHI (BURHANI BAUGH)",
      "KHI (JAMALI MOHALLA - MAHALAT BURHANIYAH)",
      "KHI (EZZY MOHALLA)",
    ];

    // Marhala 1 to 4 -> AIUT
    if (controller.selectedMarhala.value! >= 1 &&
        controller.selectedMarhala.value! <= 4) {
      return "AIUT";
    }

    // Marhala 5 (class 11th & 12th) - AMBT for specific Mohallas
    if (controller.selectedMarhala.value == 5 &&
        fiveMohalla.contains(statecontroller.user.value.tanzeem?.toString())) {
      return "AMBT";
    }

    // Marhala 5 (class 11th & 12th) - STSMF for other Mohallas
    if (controller.selectedMarhala.value == 5 &&
        !fiveMohalla.contains(statecontroller.user.value.tanzeem?.toString())) {
      return "STSMF";
    }

    // Marhala 6-7 -> STSMF
    if (controller.selectedMarhala.value == 6 ||
        controller.selectedMarhala.value == 7) {
      return "STSMF";
    }

    return "";
  }

  Widget _formFunds() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xffffead1),
      ),
      child: Column(
        spacing: 10,
        children: [
          _buildField2("Funds", controller.funds),
          _buildField2("Description", controller.description,
              height: 100),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 35,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008759),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {

                if (!controller.isSubmitEnabled.value) {
                  Get.snackbar("Error", "Missing Fields",
                      backgroundColor: Colors.red);
                  return;
                }
                statecontroller.toggleLoading(true);

                String? classDegree;
                if (controller.marhala4Index.value != null) {
                  classDegree = controller.marhala4Class.firstWhere((e) =>
                  e["id"] == controller.marhala4Index.value)["name"];
                } else if (controller.marhala5Index.value != null) {
                  classDegree = controller.marhala5Class.firstWhere((e) =>
                  e["id"] == controller.marhala5Index.value)["name"];
                } else if (controller.degreeProgramIndex.value != null) {
                  classDegree = controller.degreePrograms.firstWhere((e) =>
                  e["id"] == controller.degreeProgramIndex.value)["name"];
                }

                // 🔹 **Dynamically determine fieldOfStudy**
                String? fieldOfStudy;
                if (controller.fieldOfStudyIndex.value != null) {
                  fieldOfStudy = controller.studyOptions.firstWhere((e) =>
                  e["id"] == controller.fieldOfStudyIndex.value)["name"];
                }

                // 🔹 **Dynamically determine subjectCourse**
                String? subjectCourse;
                if (controller.courseIndexPoint.value != null) {
                  subjectCourse = controller.courseOptions.firstWhere((e) =>
                  e["id"] == controller.courseIndexPoint.value)["name"];
                }

                String org = determineOrganization();
                controller.organization.value = org;

                if (org.isEmpty) {
                  print("FAILE");
                  Get.snackbar("Error", "Failed to determine organziation",
                      colorText: Colors.white, backgroundColor: Colors.red);
                }

                RequestFormModel requestData;

                if (controller.selectedCategory.value == "Dunyawi") {
                  print("HERE");
                  requestData = RequestFormModel(
                    ITS: statecontroller.user.value.itsId.toString(),
                    studentFirstName: statecontroller.user.value.firstName.toString(),
                    studentFullName: statecontroller.user.value.fullName.toString(),
                    reqByITS: statecontroller.appliedByITS.value,
                    reqByName: statecontroller.appliedByName.value,
                    mohalla:
                    statecontroller.user.value.tanzeem?.toString() ?? "",
                    address:
                    statecontroller.user.value.address?.toString() ?? "",
                    dob: statecontroller.user.value.dob?.toString() ?? "",
                    city: controller.selectedCity.value,
                    institution: controller.selectedInstituteName.value!,
                    classDegree: classDegree ?? "",
                    fieldOfStudy: fieldOfStudy ?? "",
                    subjectCourse: subjectCourse ?? "",
                    yearOfStart: controller.year.value,
                    email: controller.email.value,
                    contactNo: controller.phone.value,
                    whatsappNo: controller.whatsapp.value,
                    fundAsking: controller.funds.value,
                    description: controller.description.value,
                    applyDate: DateTime.now().toString(),
                    grade: controller.grade.value,
                    purpose: controller.purpose.value,
                    classification: "",
                    organization: org,
                    currentStatus: "",
                    createdBy: "",
                    updatedBy: "",
                  );
                } else {
                  if (org.isEmpty) {
                    Get.snackbar("Error", "Failed to determine organziation",
                        colorText: Colors.white, backgroundColor: Colors.red);
                  }

                  requestData = RequestFormModel(
                    ITS: statecontroller.user.value.itsId.toString(),
                    studentFirstName: statecontroller.user.value.firstName.toString(),
                    studentFullName: statecontroller.user.value.fullName.toString(),
                    reqByITS: statecontroller.appliedByITS.value,
                    reqByName: statecontroller.appliedByName.value,
                    mohalla:
                    statecontroller.user.value.tanzeem?.toString() ?? "",
                    address:
                    statecontroller.user.value.address?.toString() ?? "",
                    dob: statecontroller.user.value.dob?.toString() ?? "",
                    city: "",
                    institution: controller.madrasaName.value,
                    classDegree: controller.darajaName.value,
                    fieldOfStudy: controller.hifzProgramName.value,
                    subjectCourse: "",
                    yearOfStart: controller.year.value,
                    email: controller.email.value,
                    contactNo: controller.phone.value,
                    whatsappNo: controller.whatsapp.value,
                    fundAsking: controller.funds.value,
                    description: controller.description.value,
                    applyDate: DateTime.now().toString(),
                    grade: "",
                    purpose: controller.purpose.value,
                    classification: "",
                    organization: org,
                    currentStatus: "",
                    createdBy: "",
                    updatedBy: "",
                  );
                }
                int returnCode = await Api.addRequestForm(requestData);
                await Future.delayed(Duration(seconds: 1));
                statecontroller.toggleLoading(false);
                if (returnCode == 201) {
                  controller.selectedMarhala.value = null;
                  controller.resetFields();
                  controller.resetSelections();
                  controller.studyOptions.clear();
                  controller.filteredStudies.clear();
                  controller.courseOptions.clear();
                  controller.selectedInstitute.value = null;
                  controller.selectedCity.value = 'Select City';
                  controller.selectedInstituteName.value = '';
                  controller.year.value = '';
                  controller.selectedCityId.value = null;
                  controller.resetSelections();
                  controller.funds.value = '';
                  controller.description.value = '';
                  controller.selectedMarhala.value == null;
                  Get.snackbar(
                      "Success!", "Your request was successfully submitted!",
                      colorText: Colors.white, backgroundColor: Colors.green);
                } else {
                  Get.snackbar(
                      "Error", "Failed to submit request. Please try again!",
                      colorText: Colors.white, backgroundColor: Colors.red);
                }
              },
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField2(String label, RxString rxValue,
      {double? height, bool? isEnabled}) {
    bool isDescription = height != null;
    SuperTooltipController tooltipController = SuperTooltipController();
    Timer? hoverTimer;

    return Obx(() {
      String? error = controller.validateField(label, rxValue.value);
      bool isEmpty = rxValue.value
          .trim()
          .isEmpty;
      bool isValid = error == null && !isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height ?? 50,
            child: TextFormField(
              style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
              enabled: isEnabled ?? true,
              textInputAction: TextInputAction.done,
              cursorColor: Colors.brown,
              controller: TextEditingController(text: rxValue.value)
                ..selection =
                TextSelection.collapsed(offset: rxValue.value.length),
              onChanged: (value) {
                rxValue.value = value;
                controller.validateForm();
              },
              textCapitalization: TextCapitalization.sentences,
              maxLines: isDescription ? 3 : 1,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: isValid
                    ? Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                )
                    : SuperTooltip(
                  elevation: 1,
                  showBarrier: false,
                  barrierColor: Colors.transparent,
                  controller: tooltipController,
                  arrowTipDistance: 10,
                  arrowTipRadius: 2,
                  arrowLength: 10,
                  borderColor: isEmpty
                      ? Colors.amber // ⚠️ Yellow for info
                      : Colors.red,
                  // ❌ Red for error
                  borderWidth: 2,
                  backgroundColor: isEmpty
                      ? Colors.amber.withValues(alpha: 0.9) // ⚠️ Yellow
                      : Colors.red.withValues(alpha: 0.9),
                  // ❌ Red
                  boxShadows: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.2), // Light shadow
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                  content: Text(
                    isEmpty ? "This field is required" : error ?? "",
                    style: const TextStyle(
                        color: Colors.black, fontSize: 12),
                  ),
                  child: Container(
                    padding:
                    const EdgeInsets.all(10), // ✅ Expands hover area
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent, // No background
                    ),
                    child: MouseRegion(
                      onEnter: (_) {
                        hoverTimer =
                            Timer(const Duration(milliseconds: 300), () {
                              if (!tooltipController.isVisible) {
                                tooltipController.showTooltip();
                              }
                            });
                      },
                      onExit: (_) {
                        hoverTimer
                            ?.cancel(); // ✅ Prevent tooltip from showing if mouse leaves quickly
                        tooltipController.hideTooltip();
                      },
                      child: Icon(
                        isEmpty
                            ? Icons.info_rounded
                            : Icons.error_rounded,
                        color: isEmpty ? Colors.amber : Colors.red,
                        size: 24, // ✅ Keep icon size normal
                      ),
                    ),
                  ),
                ),
                labelText: label,
                labelStyle:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey), // Grey border when disabled
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                filled: true,
                fillColor: (isEnabled ?? true)
                    ? const Color(0xfffffcf6)
                    : Colors.grey[
                300],
                // Lighter color for disabled                //contentPadding: EdgeInsets.zero
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),
        ],
      );
    });
  }

  // Widget _buildDropdown2({
  //   required String label,
  //   required Rxn<int> selectedValue,
  //   required List<Map<String, dynamic>> items,
  //   required ValueChanged<int?> onChanged,
  //   required bool isEnabled,
  // }) {
  //   SuperTooltipController tooltipController = SuperTooltipController();
  //   String? error = controller.validateDropdown(label, selectedValue);
  //   Timer? hoverTimer;
  //
  //   return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //     Obx(() => Container(
  //           height: 40,
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: DropdownButtonFormField2<int>(
  //                   style: TextStyle(
  //                       letterSpacing: 0,
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 14),
  //                   value: selectedValue.value,
  //                   isExpanded: true,
  //                   decoration: InputDecoration(
  //                     suffixIcon: error == null
  //                         ? Icon(
  //                             Icons.check_circle_rounded,
  //                             color: Colors.green,
  //                           )
  //                         : SuperTooltip(
  //                             elevation: 1,
  //                             barrierColor: Colors
  //                                 .transparent, // Keep it visible without dark overlay
  //                             controller: tooltipController,
  //                             arrowTipDistance: 10,
  //                             showBarrier: false,
  //                             arrowTipRadius: 2,
  //                             arrowLength: 10,
  //                             borderColor: Color(0xffE9D502),
  //                             borderWidth: 2,
  //                             backgroundColor:
  //                                 Color(0xffE9D502).withValues(alpha: 0.9),
  //                             boxShadows: [
  //                               BoxShadow(
  //                                 color: Colors.black.withValues(
  //                                     alpha: 0.2), // Light shadow color
  //                                 blurRadius: 6, // Soft blur effect
  //                                 spreadRadius: 2,
  //                                 offset: Offset(0, 4),
  //                               ),
  //                             ],
  //                             content: Text(error,
  //                                 style: const TextStyle(
  //                                     color: Colors.black, fontSize: 12)),
  //                             child: MouseRegion(
  //                               onEnter: (_) {
  //                                 hoverTimer = Timer(
  //                                     const Duration(milliseconds: 300), () {
  //                                   if (!tooltipController.isVisible) {
  //                                     tooltipController.showTooltip();
  //                                   }
  //                                 });
  //                               },
  //                               onExit: (_) {
  //                                 hoverTimer
  //                                     ?.cancel(); // ✅ Prevent tooltip from showing if mouse leaves quickly
  //                                 tooltipController.hideTooltip();
  //                               },
  //                               child: Icon(
  //                                 Icons.error,
  //                                 color: Colors.amber,
  //                               ),
  //                             ),
  //                           ),
  //                     floatingLabelBehavior: FloatingLabelBehavior.always,
  //                     label: Text(label),
  //                     labelStyle: TextStyle(
  //                         fontWeight: FontWeight.bold, color: Colors.brown),
  //                     filled: true,
  //                     enabled: isEnabled,
  //                     enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: BorderSide(
  //                           width: 1,
  //                           color: Colors.brown), // Removes the border
  //                     ),
  //                     disabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: BorderSide(
  //                           width: 1, color: Colors.grey), // Removes the border
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(8)),
  //                       borderSide: BorderSide(width: 1, color: Colors.brown),
  //                     ),
  //                     fillColor: const Color(0xfffffcf6), // Background color
  //                     //contentPadding: EdgeInsets.zero
  //                     //contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //                   ),
  //                   dropdownStyleData: DropdownStyleData(
  //                       maxHeight: 200,
  //                       decoration: BoxDecoration(
  //                           color: Color(0xfffffcf6),
  //                           borderRadius: BorderRadius.circular(8))),
  //                   items: items.map((Map<String, dynamic> item) {
  //                     return DropdownMenuItem<int>(
  //                       value: item['id'],
  //                       child: Text(item['name']),
  //                     );
  //                   }).toList(),
  //                   onChanged: isEnabled
  //                       ? (value) {
  //                           selectedValue.value = value;
  //                           onChanged(value);
  //                           controller.validateForm();
  //                         }
  //                       : null, // Disable when needed
  //                   //disabledHint: Text("Select ${_getDisabledHint(label)}"),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )),
  //   ]);
  // }

  // Widget _buildDropdown({
  //   required String label,
  //   required Rxn<int> selectedValue,
  //   required List<Map<String, dynamic>> items,
  //   required ValueChanged<int?> onChanged,
  //   required bool isEnabled,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
  //       Obx(() => SizedBox(
  //             height: 40,
  //             child: DropdownButtonFormField<int>(
  //               isExpanded: true,
  //               value: selectedValue.value,
  //               icon: const Icon(Icons.arrow_drop_down),
  //               decoration: InputDecoration(
  //                 filled: true,
  //                 enabledBorder: OutlineInputBorder(
  //                   borderSide: BorderSide.none,
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderSide: BorderSide.none,
  //                 ),
  //                 fillColor: const Color(0xfffffcf6),
  //                 border: OutlineInputBorder(),
  //                 contentPadding:
  //                     EdgeInsets.symmetric(horizontal: 10, vertical: 0),
  //               ),
  //               items: items.map((Map<String, dynamic> item) {
  //                 return DropdownMenuItem<int>(
  //                   value: item['id'],
  //                   child: Text(item['name']),
  //                 );
  //               }).toList(),
  //               onChanged: isEnabled
  //                   ? (value) {
  //                       selectedValue.value = value;
  //                       onChanged(value);
  //                       controller.validateForm();
  //                     }
  //                   : null, // Disable when needed
  //               disabledHint: Text("Select ${_getDisabledHint(label)}"),
  //             ),
  //           )),
  //       // Show validation message dynamically
  //       Obx(() {
  //         String? error = controller.validateDropdown(label, selectedValue);
  //         return error != null
  //             ? Text(
  //                 error,
  //                 style: const TextStyle(color: Colors.red, fontSize: 12),
  //               )
  //             : const SizedBox(
  //                 height: 17); // Reserve space for validation message
  //       }),
  //     ],
  //   );
  // }

  // String _getDisabledHint(String label) {
  //   switch (label) {
  //     case "Study":
  //       return "Marhala First";
  //     case "Field":
  //       return "Study First";
  //     default:
  //       return label;
  //   }
  // }

  Future<List<Map<String, dynamic>>> loadStudyData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonData = json.decode(response);
    return jsonData.cast<Map<String, dynamic>>();
  }

  Widget educationRequestForm2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(() =>
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Education Type:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown)),
                Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xfffffcf6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown, width: 1),
                      ),
                      child: _radioOption("Apply for Ongoing",
                          controller.selectedEducationType),
                    ),
                    Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xfffffcf6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.brown, width: 1),
                        ),
                        child: _radioOption("Apply for Future",
                            controller.selectedEducationType)),
                  ],
                ),
                SizedBox(height: 10),
                if (controller.selectedEducationType.value.isNotEmpty) ...[
                  SizedBox(height: 10),
                  _buildDropdown2(
                    label: "Select Marhala",
                    selectedValue: controller.selectedMarhala,
                    // Using Rxn<int>
                    items: List.generate(7, (index) => index + 1)
                        .map((marhala) =>
                    {"id": marhala, "name": "Marhala $marhala"})
                        .toList(),
                    onChanged: (value) {
                      controller.selectedMarhala.value = value;
                      controller.resetFields();
                      controller.resetSelections();
                      controller.studyOptions.clear();
                      controller.filteredStudies.clear();
                      controller.courseOptions.clear();
                      filterStudyOptions(value!);
                    },
                    isEnabled:
                    controller.selectedEducationType.value.isNotEmpty,
                  ),
                ],
                SizedBox(height: 10),
                if (controller.selectedMarhala.value != null) ...[
                  SizedBox(height: 10),
                  Text("Select Study Type:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.brown)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    spacing: 10,
                    children: [
                      Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xfffffcf6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.brown, width: 1),
                          ),
                          child: _radioOption(
                              "Dunyawi", controller.selectedCategory)),
                      Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xfffffcf6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.brown, width: 1),
                          ),
                          child: _radioOption(
                              "Deeni", controller.selectedCategory)),
                    ],
                  ),
                ],
                SizedBox(height: 10),
                if (controller.selectedCategory.value.isNotEmpty)
                  _displayRelevantForm(),
                // ElevatedButton(
                //   onPressed: () {},
                //   child: Text("Submit"),
                // ),
              ],
            )),
      ],
    );
  }

  void filterStudyOptions(int marhala) async {
    List<Map<String, dynamic>> data = await loadStudyData();
    Map<int, String> uniqueStudies = {};

    for (var item in data) {
      if (item['marhala_id'] == marhala) {
        uniqueStudies[item['study_id']] = item['study'];
      }
    }

    List<Map<String, dynamic>> newStudyOptions = uniqueStudies.entries
        .map((e) => {"id": e.key, "name": e.value})
        .toList();

    controller.studyOptions.value = newStudyOptions;
  }

  Widget _displayRelevantForm() {
    if (controller.selectedCategory.value == "Dunyawi") {
      return _dunyawiForm();
    } else if (controller.selectedCategory.value == "Deeni") {
      controller.isDeeniSelected.value = true;
      return _deeniForm();
    }
    return SizedBox.shrink();
  }

  Widget _dunyawiForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xffffead1),
      ),
      child: Column(
        spacing: 10,
        children: [
          if (controller.selectedMarhala.value == 1)
            Column(
              spacing: 10,
              children: [
                _buildDropdown2(
                  label: "Standard",
                  selectedValue: controller.standardIndex,
                  items: [
                    {"id": 0, "name": "Play Group"},
                    {"id": 1, "name": "Nursery"},
                    {"id": 2, "name": "Junior Kindergarten"},
                    {"id": 3, "name": "Senior Kindergarten"},
                  ],
                  onChanged: (value) {
                    controller.standardIndex.value = value;

                    // ✅ Assigns the correct grade value dynamically
                    if (value != null) {
                      Map<int, String> gradeMapping = {
                        0: "Play Group",
                        1: "Nursery",
                        2: "Junior Kindergarten",
                        3: "Senior Kindergarten",
                      };
                      controller.grade.value = gradeMapping[value] ?? "";
                    } else {
                      controller.grade.value = ""; // Reset on null selection
                    }
                  },
                  isEnabled: true,
                ),
                CustomDropdownSearch<String>(
                  label: "City",
                  height: 50,
                  itemsLoader: (filter, _) async {
                    return controller.cities
                        .map((e) => e['name'] as String) // Extract city names
                        .toList();
                  },
                  selectedItem:
                  controller.selectedCity.value, // Bind selected city
                  isEnabled: controller.cities
                      .isNotEmpty, // Enable only if cities are available
                  onChanged: (String? cityName) {
                    if (cityName != null) {
                      //controller.selectedCity.value = cityName;
                      // Find city ID based on name and update selectedCityId
                      final selectedCityData = controller.cities.firstWhere(
                            (city) => city['name'] == cityName,
                        orElse: () =>
                        {"id": null}, // Ensure it returns a valid default
                      );
                      controller.selectCity(selectedCityData["id"]);
                    }
                  },
                ),
                CustomDropdownSearch<String>(
                  label: "Institute",
                  height: 50,
                  itemsLoader: (filter, _) async {
                    return controller.filteredInstitutes
                        .map((e) => e['name'] as String)
                        .toList();
                  },
                  selectedItem: controller.selectedInstituteName.value,
                  isEnabled: controller.selectedCity.value.isNotEmpty &&
                      controller.selectedCity.value != "Select City",
                  onChanged: (String? institute) {
                    controller.selectedInstituteName.value =
                        institute ?? "";
                  },
                ),
                _buildField2("Year", controller.year),
              ],
            ),
          if (controller.selectedMarhala.value == 2)
            Column(
              spacing: 10,
              children: [
                _buildDropdown2(
                  label: "Standard",
                  selectedValue: controller.standardIndex,
                  items: [
                    {"id": 2, "name": "Grade 1st"},
                    {"id": 3, "name": "Grade 2nd"},
                    {"id": 4, "name": "Grade 3rd"},
                    {"id": 5, "name": "Grade 4th"},
                  ],
                  onChanged: (value) {
                    controller.standardIndex.value = value;
                    controller.grade.value = value != null
                        ? controller.standardIndex.value != null
                        ? [
                      "Grade 1st",
                      "Grade 2nd",
                      "Grade 3rd",
                      "Grade 4th"
                    ][value - 2]
                        : ""
                        : "";
                  },
                  isEnabled: true,
                ),
                CustomDropdownSearch<String>(
                  label: "City",
                  height: 50,
                  itemsLoader: (filter, _) async {
                    return controller.cities
                        .map((e) => e['name'] as String) // Extract city names
                        .toList();
                  },
                  selectedItem:
                  controller.selectedCity.value, // Bind selected city
                  isEnabled: controller.cities
                      .isNotEmpty, // Enable only if cities are available
                  onChanged: (String? cityName) {
                    if (cityName != null) {
                      //controller.selectedCity.value = cityName;
                      // Find city ID based on name and update selectedCityId
                      final selectedCityData = controller.cities.firstWhere(
                            (city) => city['name'] == cityName,
                        orElse: () =>
                        {"id": null}, // Ensure it returns a valid default
                      );
                      controller.selectCity(selectedCityData["id"]);
                    }
                  },
                ),
                CustomDropdownSearch<String>(
                  label: "Institute",
                  height: 50,
                  itemsLoader: (filter, _) async {
                    return controller.filteredInstitutes
                        .map((e) => e['name'] as String)
                        .toList();
                  },
                  selectedItem: controller.selectedInstituteName.value,
                  isEnabled: controller.selectedCity.value.isNotEmpty &&
                      controller.selectedCity.value != "Select City",
                  onChanged: (String? institute) {
                    controller.selectedInstituteName.value =
                        institute ?? "";
                  },
                ),
                _buildField2("Year", controller.year),
              ],
            ),
          if (controller.selectedMarhala.value == 3)
            Column(
              spacing: 10,
              children: [
                _buildDropdown2(
                  label: "Standard",
                  selectedValue: controller.standardIndex,
                  items: [
                    {"id": 6, "name": "Grade 5th"},
                    {"id": 7, "name": "Grade 6th"},
                    {"id": 8, "name": "Grade 7th"},
                    {"id": 9, "name": "Grade 8th"},
                  ],
                  onChanged: (value) {
                    controller.standardIndex.value = value;
                    controller.grade.value = value != null
                        ? [
                      "Grade 5th",
                      "Grade 6th",
                      "Grade 7th",
                      "Grade 8th"
                    ]
                    [value - 6]
                        : "";
                  },
                  isEnabled: true,
                ),
                CustomDropdownSearch<String>(
                  label: "City",
                  height: 50,
                  itemsLoader: (filter, _) async {
                    return controller.cities
                        .map((e) => e['name'] as String) // Extract city names
                        .toList();
                  },
                  selectedItem:
                  controller.selectedCity.value, // Bind selected city
                  isEnabled: controller.cities
                      .isNotEmpty, // Enable only if cities are available
                  onChanged: (String? cityName) {
                    if (cityName != null) {
                      //controller.selectedCity.value = cityName;
                      // Find city ID based on name and update selectedCityId
                      final selectedCityData = controller.cities.firstWhere(
                            (city) => city['name'] == cityName,
                        orElse: () =>
                        {"id": null}, // Ensure it returns a valid default
                      );
                      controller.selectCity(selectedCityData["id"]);
                    }
                  },
                ),
                Obx(() =>
                    CustomDropdownSearch<String>(
                      label: "Institute",
                      height: 50,
                      itemsLoader: (filter, _) async {
                        return controller.filteredInstitutes
                            .map((e) => e['name'] as String)
                            .toList();
                      },
                      selectedItem: controller.selectedInstituteName.value,
                      isEnabled: controller.selectedCity.value.isNotEmpty &&
                          controller.selectedCity.value != "Select City",
                      onChanged: (String? institute) {
                        controller.selectedInstituteName.value =
                            institute ?? "";
                      },
                    )),
                _buildField2("Year", controller.year),
              ],
            ),
          if (controller.selectedMarhala.value == 4)
            Column(
              spacing: 10,
              children: [
                Column(
                  spacing: 10,
                  children: [
                    _buildDropdown2(
                      label: "Field of Study",
                      selectedValue: controller.fieldOfStudyIndex,
                      items: [
                        ...controller.studyOptions.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.fieldOfStudyIndex.value = value;
                        controller.courseIndexPoint.value = null;
                        filterByMarhalaAndStudy(4, controller.fieldOfStudyIndex.value);
                        // controller.marhala5Index.value = null;
                        controller.filterFields(value!);
                      },
                      isEnabled: true,
                    ),
                    _buildDropdown2(
                      label: "Class",
                      selectedValue: controller.marhala4Index,
                      items: [
                        ...controller.marhala4Class.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.marhala4Index.value = value;
                      },
                      isEnabled: true,
                    ),
                    _buildDropdown2(
                      label: "Subject",
                      selectedValue: controller.courseIndexPoint,
                      items: [
                        ...controller.courseOptions.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.courseIndexPoint.value = value;
                      },
                      isEnabled: true,
                    ),
                  ],
                ),
                _buildLocationSelection(),
              ],
            ),

          if (controller.selectedMarhala.value == 5)
            Column(
              spacing: 10,
              children: [
                Column(
                  spacing: 10,
                  children: [
                    _buildDropdown2(
                      label: "Field of Study",
                      selectedValue: controller.fieldOfStudyIndex,
                      items: [
                        ...controller.studyOptions.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.fieldOfStudyIndex.value = value;
                        controller.courseIndexPoint.value = null;
                        filterByMarhalaAndStudy(5, controller.fieldOfStudyIndex.value);
                        // controller.marhala5Index.value = null;
                        controller.filterFields(value!);
                      },
                      isEnabled: true,
                    ),
                    _buildDropdown2(
                      label: "Class",
                      selectedValue: controller.marhala5Index,
                      items: [
                        ...controller.marhala5Class.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.marhala5Index.value = value;
                      },
                      isEnabled: true,
                    ),
                    _buildDropdown2(
                      label: "Subject",
                      selectedValue: controller.courseIndexPoint,
                      items: [
                        ...controller.courseOptions.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.courseIndexPoint.value = value;
                      },
                      isEnabled: true,
                    ),
                  ],
                ),
                _buildLocationSelection(),
              ],
            ),

          if (controller.selectedMarhala.value == 6)
            Column(
              spacing: 10,
              children: [
                Column(
                  spacing: 10,
                  children: [
                    _buildDropdown2(
                      label: "Degree Program",
                      selectedValue: controller.degreeProgramIndex,
                      items: [
                        ...controller.degreePrograms.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.degreeProgramIndex.value = value;
                      },
                      isEnabled: true,
                    ),
                    _buildDropdown2(
                      label: "Field of Study",
                      selectedValue: controller.fieldOfStudyIndex,
                      items: [
                        ...controller.studyOptions.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.fieldOfStudyIndex.value = value;
                        controller.courseIndexPoint.value = null;
                        filterByMarhalaAndStudy(6, controller.fieldOfStudyIndex.value);
                        controller.filterFields(value!);
                      },
                      isEnabled: true,
                    ),
                    _buildDropdown2(
                      label: "Course",
                      selectedValue: controller.courseIndexPoint,
                      items: [
                        ...controller.courseOptions.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.courseIndexPoint.value = value;
                      },
                      isEnabled: true,
                    ),
                  ],
                ),
                _buildLocationSelection(),
              ],
            ),

          if (controller.selectedMarhala.value == 7)
            Column(
              spacing: 10,
              children: [
                Column(
                  spacing: 10,
                  children: [
                    _buildDropdown2(
                      label: "Degree Program",
                      selectedValue: controller.degreeProgramIndex,
                      items: [
                        ...controller.degreePrograms.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.degreeProgramIndex.value = value;
                      },
                      isEnabled: true,
                    ),
                    _buildDropdown2(
                      label: "Field of Study",
                      selectedValue: controller.fieldOfStudyIndex,
                      items: [
                        ...controller.studyOptions.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.fieldOfStudyIndex.value = value;
                        controller.courseIndexPoint.value = null;
                        filterByMarhalaAndStudy(7, controller.fieldOfStudyIndex.value);
                        // controller.filterFields(value!);
                      },
                      isEnabled: true,
                    ),
                    _buildDropdown2(
                      label: "Course",
                      selectedValue: controller.courseIndexPoint,
                      items: [
                        ...controller.courseOptions.map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.courseIndexPoint.value = value;
                      },
                      isEnabled: true,
                    ),
                  ],
                ),
                _buildLocationSelection(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSelection() {
    return Column(
      spacing: 10,
      children: [
        CustomDropdownSearch<String>(
          label: "City",
          height: 50,
          itemsLoader: (filter, _) async {
            return controller.cities
                .map((e) => e['name'] as String) // Extract city names
                .toList();
          },
          selectedItem:
          controller.selectedCity.value, // Bind selected city
          isEnabled: controller.cities
              .isNotEmpty, // Enable only if cities are available
          onChanged: (String? cityName) {
            if (cityName != null) {
              //controller.selectedCity.value = cityName;
              // Find city ID based on name and update selectedCityId
              final selectedCityData = controller.cities.firstWhere(
                    (city) => city['name'] == cityName,
                orElse: () =>
                {"id": null}, // Ensure it returns a valid default
              );
              controller.selectCity(selectedCityData["id"]);
            }
          },
        ),
        CustomDropdownSearch<String>(
          label: "Institute",
          height: 50,
          itemsLoader: (filter, _) async {
            return controller.filteredInstitutes
                .map((e) => e['name'] as String)
                .toList();
          },
          selectedItem: controller.selectedInstituteName.value,
          isEnabled: controller.selectedCity.value.isNotEmpty &&
              controller.selectedCity.value != "Select City",
          onChanged: (String? institute) {
            controller.selectedInstituteName.value = institute ?? "";
          },
        ),
        _buildField2("Year", controller.year),
      ],
    );
  }


  Future<void> filterByMarhalaAndStudy(int? marhalaId, int? studyId) async {
    // **Check if inputs are null**
    if (marhalaId == null || studyId == null) {
      controller.courseOptions.value = [];
    }

    try {
      // Load JSON data
      final String response = await rootBundle.loadString('assets/data.json');
      final List<dynamic> jsonData = json.decode(response);

      // Convert to List<Map<String, dynamic>>
      List<Map<String, dynamic>> data = jsonData.cast<Map<String, dynamic>>();

      // Filter items based on marhala_id and study_id, ensuring non-null values
      List<Map<String, dynamic>> filteredList = data
          .where((item) =>
      (item['marhala_id'] ?? -1) == marhalaId &&
          (item['study_id'] ?? -1) == studyId)
          .toList();

      // Extract only 'id' and 'name'
      List<Map<String, dynamic>> result =
      filteredList.map((e) => {"id": e["id"], "name": e["name"]}).toList();

      // Debugging output

      controller.courseOptions.value = result;
    } catch (e) {
      controller.courseOptions.value = [];
    }
  }

  Widget _deeniForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xffffead1),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            if (controller.selectedMarhala.value! < 5) ...[
              Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xfffffcf6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown, width: 1),
                      ),
                      child: _radioOption(
                          "Madrasa", controller.selectedDeeniType)),
                  Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xfffffcf6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown, width: 1),
                      ),
                      child:
                      _radioOption("Hifz", controller.selectedDeeniType)),
                ],
              ),
            ],
            if (controller.selectedMarhala.value! > 4) ...[
              _radioOption("Hifz", controller.selectedDeeniType),
            ],
            if (controller.selectedDeeniType.value == "Madrasa") ...[
              _buildDropdown2(
                label: "Madrasa",
                selectedValue: controller.madrasaIndex,
                // Use Rxn<int>
                items: [
                  // {"id": -1, "name": "Select an option"}, // Ensuring a null option
                  ...controller.madrasas
                      .map((e) => {"id": e["id"], "name": e["name"]})
                ],
                onChanged: (value) {
                  controller.madrasaIndex.value = value;
                  if (controller.madrasaIndex.value != null) {
                    controller.madrasaName.value = controller.madrasas
                        .firstWhere((e) => e["id"] == value)["name"];
                  }
                },
                isEnabled: true,
              ),
              _buildDropdown2(
                label: "Daraja",
                selectedValue: controller.darajaIndex,
                // Use Rxn<int>
                items: [
                  // {"id": -1, "name": "Select an option"}, // Ensuring a null option
                  ...controller.filteredDarajat
                      .map((e) => {"id": e["id"], "name": e["name"]})
                ],
                onChanged: (value) {
                  controller.darajaIndex.value = value;
                  if (controller.darajaIndex.value != null) {
                    controller.darajaName.value = controller.filteredDarajat
                        .firstWhere((e) => e["id"] == value)["name"];
                  }
                  // courseOptions.value = value != null
                  //     ? courseOptions.firstWhere((element) => element["study_id"] == value)["name"]
                  //     : "";
                },
                isEnabled: true,
              ),
              _buildField2("Year", controller.year),
            ],
            if (controller.selectedDeeniType.value == "Hifz") ...[
              _buildDropdown2(
                label: "Hifz Program",
                selectedValue: controller.hifzProgramIndex,
                // Use Rxn<int>
                items: [
                  // {"id": -1, "name": "Select an option"}, // Ensuring a null option
                  ...controller.hifzPrograms
                      .map((e) => {"id": e["id"], "name": e["name"]})
                ],
                onChanged: (value) {
                  controller.hifzProgramIndex.value = value;
                  if (controller.hifzProgramIndex.value != null) {
                    controller.hifzProgramName.value = controller.hifzPrograms
                        .firstWhere((e) => e["id"] == value)["name"];
                  }
                  // courseOptions.value = value != null
                  //     ? courseOptions.firstWhere((element) => element["study_id"] == value)["name"]
                  //     : "";
                },
                isEnabled: true,
              ),
              _buildField2("Year", controller.year),
            ],
          ]),
    );
  }

  Widget _radioOption(String label, RxString controllerVariable) {
    return Obx(() =>
        Row(
          spacing: 5,
          children: [
            SizedBox(
              width: 15,
            ),
            Radio<String>(
                value: label,
                groupValue: controllerVariable.value,
                onChanged: (value) {
                  controller.resetFields();
                  if (label == 'Apply For Ongoing') {
                    controller.purpose.value = "Ongoing Education";
                  } else {
                    controller.purpose.value = "Future Education";
                  }
                  if (label == 'Dunyawi') {
                    controller.isDeeniSelected.value = false;
                  } else {
                    controller.isDeeniSelected.value = true;
                  }
                  controllerVariable.value = value!;
                  controller
                      .filterDarajaByMarhala(
                      controller.selectedMarhala.value!);
                  filterStudyOptions(controller.selectedMarhala.value!);
                }),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }

  Widget _buildDropdown2({
    required String label,
    required Rxn<int> selectedValue,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
    required bool isEnabled,
  }) {
    SuperTooltipController tooltipController = SuperTooltipController();
    String? error = '';
    //    controller.validateDropdown(label, selectedValue);
    Timer? hoverTimer;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Obx(() =>
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField2<int>(
                    style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    value: selectedValue.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      suffixIcon: selectedValue.value != null
                          ? Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                      )
                          : SuperTooltip(
                        elevation: 1,
                        barrierColor: Colors
                            .transparent,
                        // Keep it visible without dark overlay
                        controller: tooltipController,
                        arrowTipDistance: 10,
                        showBarrier: false,
                        arrowTipRadius: 2,
                        arrowLength: 10,
                        borderColor: Color(0xffE9D502),
                        borderWidth: 2,
                        backgroundColor:
                        Color(0xffE9D502).withValues(alpha: 0.9),
                        boxShadows: [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: 0.2), // Light shadow color
                            blurRadius: 6, // Soft blur effect
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                        content: Text(error,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12)),
                        child: MouseRegion(
                          onEnter: (_) {
                            hoverTimer = Timer(
                                const Duration(milliseconds: 300), () {
                              if (!tooltipController.isVisible) {
                                tooltipController.showTooltip();
                              }
                            });
                          },
                          onExit: (_) {
                            hoverTimer
                                ?.cancel(); // ✅ Prevent tooltip from showing if mouse leaves quickly
                            tooltipController.hideTooltip();
                          },
                          child: Icon(
                            Icons.error,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: Text(label),
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.brown),
                      filled: true,
                      enabled: isEnabled,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            width: 1,
                            color: Colors.brown), // Removes the border
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            width: 1,
                            color: Colors.grey), // Removes the border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(width: 1, color: Colors.brown),
                      ),
                      fillColor: const Color(0xfffffcf6), // Background color
                      //contentPadding: EdgeInsets.zero
                      //contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                            color: Color(0xfffffcf6),
                            borderRadius: BorderRadius.circular(8))),
                    items: items
                        .map((item) =>
                        DropdownMenuItem<int>(
                          value: item['id'],
                          child: Text(item['name']),
                        ))
                        .toList(),
                    //
                    onChanged: isEnabled
                        ? (value) {
                      selectedValue.value = value;
                      onChanged(value);
                      //controller.validateForm();
                    }
                        : null, // Disable when needed
                    //disabledHint: Text("Select ${_getDisabledHint(label)}"),
                  ),
                ),
              ],
            ),
          )),
    ]);
  }

// Widget _form() {
//     return Form(
//       key: controller.mainFormKey,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: const Color(0xffffead1),
//         ),
//         child: Column(
//           spacing: 10,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Obx(
//               () => _buildDropdown2(
//                 label: "Marhala",
//                 selectedValue: controller.selectedMarhala,
//                 items: controller.predefinedMarhalas,
//                 onChanged: (value) {
//                   controller.selectedMarhala.value = value!;
//                   controller.selectedMarhalaName.value = controller
//                       .predefinedMarhalas
//                       .firstWhere((element) => element['id'] == value)['name'];
//                   controller.filterStudies(value);
//                 },
//                 isEnabled: true,
//               ),
//             ),
//             Obx(
//               () => _buildDropdown2(
//                 label: "Study",
//                 selectedValue: controller.selectedStudy,
//                 items: controller.filteredStudies,
//                 onChanged: (value) {
//                   controller.selectedStudy.value = value!;
//                   controller.selectedStudyName.value =
//                       controller.filteredStudies.firstWhere(
//                     (element) => element['id'] == value,
//                     orElse: () => {
//                       'id': -1,
//                       'name': 'Unknown Study'
//                     }, // Handle missing cases
//                   )['name'];
//                   controller.filterFields(value);
//                   controller.updateDropdownState();
//                 },
//                 isEnabled: controller.isStudyEnabled.value,
//               ),
//             ),
//             Obx(() => _buildDropdown2(
//                   label: "Field",
//                   selectedValue: controller.selectedField,
//                   items: controller.filteredFields,
//                   onChanged: (value) {
//                     controller.selectedField.value = value!;
//                     controller.selectedSubject2.value =
//                         controller.filteredFields.firstWhere(
//                       (element) => element['id'] == value,
//                       orElse: () => {
//                         'id': -1,
//                         'name': 'Unknown Study'
//                       }, // Handle missing cases
//                     )['name'];
//                     print(controller.selectedSubject2);
//                     controller.updateDropdownState();
//                   },
//                   isEnabled: true,
//                 )),
//             Obx(() {
//               return _buildDropdown2(
//                 label: "City",
//                 selectedValue: Rxn<int>(controller.selectedCityId.value),
//                 items: controller.cities,
//                 isEnabled: true,
//                 onChanged: (int? cityId) => controller.selectCity(cityId),
//               );
//             }),
//             Obx(() => CustomDropdownSearch<String>(
//                   label: "Institute",
//                   itemsLoader: (filter, _) async {
//                     return controller.filteredInstitutes
//                         .map((e) => e['name'] as String)
//                         .toList();
//                   },
//                   selectedItem: controller.selectedInstituteName.value,
//                   isEnabled: controller.selectedCity.value.isNotEmpty &&
//                       controller.selectedCity.value != "Select City",
//                   onChanged: (String? institute) {
//                     if (institute != null) {
//                       controller.selectedInstituteName.value = institute;
//                     }
//                   },
//                 )),
//             _buildField2("Year", controller.year),
//             _buildField2("Email", controller.email),
//             _buildField2("Phone Number", controller.phone),
//             _buildField2("WhatsApp Number", controller.whatsapp),
//           ],
//         ),
//       ),
//     );
//   }

  // Widget _formFunds() {
  //   return Form(
  //     key: controller.fundsFormKey,
  //     child: Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         color: const Color(0xffffead1),
  //       ),
  //       child: Column(
  //         spacing: 10,
  //         children: [
  //           _buildField2("Funds", controller.funds),
  //           _buildField2("Description", controller.description, height: 100),
  //           const SizedBox(height: 16),
  //           Obx(
  //             () => SizedBox(
  //               width: 120,
  //               height: 35,
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: controller.isButtonEnabled.value
  //                       ? const Color(0xFF008759)
  //                       : Colors.grey, // Change color based on validation
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(5),
  //                   ),
  //                 ),
  //                 onPressed: controller.isButtonEnabled.value
  //                     ? () async {
  //                         statecontroller.toggleLoading(true);
  //                         if (controller.mainFormKey.currentState!.validate() &&
  //                             controller.fundsFormKey.currentState!
  //                                 .validate()) {
  //                           print(controller.selectedMarhalaName);
  //                           print(controller.selectedStudyName);
  //                           var newData = RequestFormModel(
  //                             ITS: widget.member.itsId.toString(),
  //                             reqByITS: appliedbyIts.toString(),
  //                             reqByName: appliedByName.toString(),
  //                             mohalla: widget.member.tanzeem.toString(),
  //                             address: widget.member.address.toString(),
  //                             dob: widget.member.dob.toString(),
  //                             city: controller.selectedCity.value,
  //                             institution:
  //                                 controller.selectedInstituteName.value!,
  //                             classDegree: controller.selectedMarhalaName.value,
  //                             fieldOfStudy: controller.selectedStudyName
  //                                 .value, // 🔹 Renamed study → fieldOfStudy
  //                             subjectCourse: controller.selectedSubject2
  //                                 .value, // 🔹 Renamed subject → subjectCourse
  //                             yearOfStart: controller
  //                                 .year.value, // 🔹 Renamed year → yearOfStart
  //                             grade: "", // 🔹 Add if applicable
  //                             email: controller.email.value,
  //                             contactNo: controller.phone
  //                                 .value, // 🔹 Renamed phoneNumber → contactNo
  //                             whatsappNo: controller.whatsapp
  //                                 .value, // 🔹 Renamed whatsappNumber → whatsappNo
  //                             purpose: "", // 🔹 Add if applicable
  //                             fundAsking: controller.funds
  //                                 .value, // 🔹 Renamed fundAmount → fundAsking
  //                             classification: "", // 🔹 Add if applicable
  //                             organization: "", // 🔹 Add if applicable
  //                             description: controller.description
  //                                 .value, // 🔹 Renamed fundDescription → description
  //                             currentStatus:
  //                                 "", // 🔹 Default value, change if needed
  //                             createdBy:
  //                                 "", // 🔹 Renamed created_by → createdBy
  //                             updatedBy:
  //                                 "", // 🔹 Renamed updated_by → updatedBy
  //                             applyDate: DateTime.now().toString(),
  //                           );
  //
  //                           // Call the API to add request
  //                           int returnCode = await Api.addRequestForm(newData);
  //                           await Future.delayed(const Duration(seconds: 2));
  //                           statecontroller.toggleLoading(false);
  //
  //                           if (returnCode == 201) {
  //                             Get.snackbar("Success!",
  //                                 "Data successfully inserted in Database!");
  //                             Api.sendEmail(
  //                                 to: 'abialigadi@gmail.com',
  //                                 subject: 'Request Received - OWS',
  //                                 text:
  //                                     "Afzal us Salam,\n\nYour request is received! Your request number is ${controller.reqId}.\n\nWassalam.",
  //                                 html: """
  //                                       <p>Afzal us Salam,</p>
  //                                       <p>Your request is received! Your request number is <strong>${controller.reqId}</strong>.</p>
  //                                       <p>Wassalam.</p>
  //                                       """);
  //                           } else {
  //                             Get.snackbar("Error",
  //                                 "Failed to insert Data in Database!");
  //                           }
  //                         }
  //                       }
  //                     : null, // Disable the button when validation fails
  //                 child: const Text(
  //                   "Request",
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildField2(String label, RxString rxValue,
  //     {double? height, bool? isEnabled}) {
  //   bool isDescription = height != null;
  //   SuperTooltipController tooltipController = SuperTooltipController();
  //   Timer? hoverTimer;
  //
  //   return Obx(() {
  //     String? error = controller.validateField(label, rxValue.value);
  //     bool isEmpty = rxValue.value.trim().isEmpty;
  //     bool isValid = error == null && !isEmpty;
  //
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           height: height ?? 50,
  //           child: TextFormField(
  //             style: TextStyle(
  //                 letterSpacing: 0, fontWeight: FontWeight.w600, fontSize: 14),
  //             enabled: isEnabled ?? true,
  //             textInputAction: TextInputAction.done,
  //             cursorColor: Colors.brown,
  //             controller: TextEditingController(text: rxValue.value)
  //               ..selection =
  //                   TextSelection.collapsed(offset: rxValue.value.length),
  //             onChanged: (value) {
  //               rxValue.value = value;
  //               controller.validateForm();
  //             },
  //             textCapitalization: TextCapitalization.sentences,
  //             maxLines: isDescription ? 3 : 1,
  //             decoration: InputDecoration(
  //               floatingLabelBehavior: FloatingLabelBehavior.always,
  //               suffixIcon: isValid
  //                   ? Icon(
  //                       Icons.check_circle_rounded,
  //                       color: Colors.green,
  //                     )
  //                   : GestureDetector(
  //                       onTap: () async {
  //                         if (!isValid && !isEmpty) {
  //                           await tooltipController.showTooltip();
  //                         }
  //                       },
  //                       child: SuperTooltip(
  //                         elevation: 1,
  //                         showBarrier: true,
  //                         barrierColor: Colors.transparent,
  //                         controller: tooltipController,
  //                         arrowTipDistance: 10,
  //                         arrowTipRadius: 2,
  //                         arrowLength: 10,
  //                         toggleOnTap: true,
  //                         borderColor: isEmpty
  //                             ? Colors.amber // ⚠️ Yellow for info
  //                             : Colors.red, // ❌ Red for error
  //                         borderWidth: 2,
  //                         backgroundColor: isEmpty
  //                             ? Colors.amber.withValues(alpha: 0.9) // ⚠️ Yellow
  //                             : Colors.red.withValues(alpha: 0.9), // ❌ Red
  //                         boxShadows: [
  //                           BoxShadow(
  //                             color: Colors.black
  //                                 .withValues(alpha: 0.2), // Light shadow
  //                             blurRadius: 6,
  //                             spreadRadius: 2,
  //                             offset: Offset(0, 4),
  //                           ),
  //                         ],
  //                         content: Text(
  //                           isEmpty ? "This field is required" : error ?? "",
  //                           style: const TextStyle(
  //                               color: Colors.black, fontSize: 12),
  //                         ),
  //                         child: Container(
  //                           padding: const EdgeInsets.all(
  //                               10), // ✅ Expands hover area
  //                           decoration: BoxDecoration(
  //                             shape: BoxShape.circle,
  //                             color: Colors.transparent, // No background
  //                           ),
  //                           child: Icon(
  //                             isEmpty
  //                                 ? Icons.info_rounded
  //                                 : Icons.error_rounded,
  //                             color: isEmpty ? Colors.amber : Colors.red,
  //                             size: 24, // ✅ Keep icon size normal
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //               labelText: label,
  //               labelStyle:
  //                   TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
  //               enabledBorder: const OutlineInputBorder(
  //                 borderRadius: BorderRadius.all(Radius.circular(8)),
  //                 borderSide: BorderSide(width: 1, color: Colors.brown),
  //               ),
  //               disabledBorder: const OutlineInputBorder(
  //                 borderRadius: BorderRadius.all(Radius.circular(8)),
  //                 borderSide: BorderSide(
  //                     width: 1,
  //                     color: Colors.grey), // Grey border when disabled
  //               ),
  //               focusedBorder: const OutlineInputBorder(
  //                 borderRadius: BorderRadius.all(Radius.circular(8)),
  //                 borderSide: BorderSide(width: 1, color: Colors.brown),
  //               ),
  //               filled: true,
  //               fillColor: (isEnabled ?? true)
  //                   ? const Color(0xfffffcf6)
  //                   : Colors.grey[
  //                       300], // Lighter color for disabled                //contentPadding: EdgeInsets.zero
  //               contentPadding:
  //                   const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }
  //
  // Widget _buildDropdown2({
  //   required String label,
  //   required Rxn<int> selectedValue,
  //   required List<Map<String, dynamic>> items,
  //   required ValueChanged<int?> onChanged,
  //   required bool isEnabled,
  // }) {
  //   SuperTooltipController tooltipController = SuperTooltipController();
  //   String? error = controller.validateDropdown(label, selectedValue);
  //   Timer? hoverTimer;
  //
  //   return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //     Obx(() => SizedBox(
  //           height: 50,
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: DropdownButtonFormField2<int>(
  //                   style: TextStyle(
  //                       letterSpacing: 0,
  //                       color: Colors.black,
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 14),
  //                   value: selectedValue.value,
  //                   isExpanded: true,
  //                   decoration: InputDecoration(
  //                     suffixIcon: error == null
  //                         ? Icon(
  //                             Icons.check_circle_rounded,
  //                             color: Colors.green,
  //                           )
  //                         : GestureDetector(
  //                       onTap: () async {
  //                         await tooltipController.showTooltip();
  //                       },
  //                           child: SuperTooltip(
  //                           elevation: 1,
  //                           showBarrier: true,
  //                           barrierColor: Colors.transparent,
  //                           controller: tooltipController,
  //                           arrowTipDistance: 10,
  //                           arrowTipRadius: 2,
  //                           arrowLength: 10,
  //                           toggleOnTap: true,
  //                               borderColor: Color(0xffE9D502),
  //                               borderWidth: 2,
  //                               backgroundColor:
  //                                   Color(0xffE9D502).withValues(alpha: 0.9),
  //                               boxShadows: [
  //                                 BoxShadow(
  //                                   color: Colors.black.withValues(
  //                                       alpha: 0.2), // Light shadow color
  //                                   blurRadius: 6, // Soft blur effect
  //                                   spreadRadius: 2,
  //                                   offset: Offset(0, 4),
  //                                 ),
  //                               ],
  //                               content: Text(error,
  //                                   style: const TextStyle(
  //                                       color: Colors.black, fontSize: 12)),
  //                               child: Icon(
  //                                 Icons.error,
  //                                 color: Colors.amber,
  //                               ),
  //                             ),
  //                         ),
  //                     floatingLabelBehavior: FloatingLabelBehavior.always,
  //                     label: Text(label),
  //                     labelStyle: TextStyle(
  //                         fontWeight: FontWeight.bold, color: Colors.brown),
  //                     filled: true,
  //                     enabled: isEnabled,
  //                     enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: BorderSide(
  //                           width: 1,
  //                           color: Colors.brown), // Removes the border
  //                     ),
  //                     disabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: BorderSide(
  //                           width: 1, color: Colors.grey), // Removes the border
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(8)),
  //                       borderSide: BorderSide(width: 1, color: Colors.brown),
  //                     ),
  //                     fillColor: const Color(0xfffffcf6), // Background color
  //                     //contentPadding: EdgeInsets.zero
  //                     //contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //                   ),
  //                   dropdownStyleData: DropdownStyleData(
  //                       maxHeight: 200,
  //                       decoration: BoxDecoration(
  //                           color: Color(0xfffffcf6),
  //                           borderRadius: BorderRadius.circular(8))),
  //                   items: items.map((Map<String, dynamic> item) {
  //                     return DropdownMenuItem<int>(
  //                       value: item['id'],
  //                       child: Text(item['name']),
  //                     );
  //                   }).toList(),
  //                   onChanged: isEnabled
  //                       ? (value) {
  //                           selectedValue.value = value;
  //                           onChanged(value);
  //                           controller.validateForm();
  //                         }
  //                       : null, // Disable when needed
  //                   //disabledHint: Text("Select ${_getDisabledHint(label)}"),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )),
  //   ]);
  // }

// Wrap the form sections inside a `Form` widget
//   Widget _form() {
//     return Form(
//       key: controller.mainFormKey,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: const Color(0xffffead1),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Column(
//               spacing: 12,
//               children: [
//                 _buildDropdown(
//                   label: "Marhala",
//                   selectedValue: controller.selectedMarhala,
//                   items: controller.predefinedMarhalas,
//                   onChanged: (value) {
//                     controller.selectedMarhala.value = value!;
//                     controller.filterStudies(value);
//                   },
//                   isEnabled: true,
//                 ),
//                 Obx(
//                   () => _buildDropdown(
//                     label: "Study",
//                     selectedValue: controller.selectedStudy,
//                     items: controller.filteredStudies,
//                     onChanged: (value) {
//                       controller.selectedStudy.value = value!;
//                       controller.filterFields(value);
//                       controller
//                           .updateDropdownState(); // ✅ Update dropdown state
//                     },
//                     isEnabled: controller.isStudyEnabled.value,
//                   ),
//                 ),
//                 Obx(() => _buildDropdown(
//                       label: "Field",
//                       selectedValue: controller.selectedField,
//                       items: controller.filteredFields,
//                       onChanged: (value) {
//                         controller.selectedField.value = value!;
//                         controller.updateDropdownState();
//                       },
//                       isEnabled: controller.isFieldEnabled.value,
//                     )),
//                 Obx(() {
//                   return _buildDropdown(
//                     label: "City",
//                     selectedValue: Rxn<int>(controller
//                         .selectedCityId.value), // ✅ Pass the matched city ID
//                     items: controller.cities,
//                     isEnabled: true,
//                     onChanged: (int? cityId) => controller.selectCity(cityId),
//                   );
//                 }),
//                 Obx(() => CustomDropdownSearch<String>(
//                       label: "Institute",
//                       itemsLoader: (filter, _) async {
//                         return controller.filteredInstitutes
//                             .map((e) => e['name'] as String)
//                             .toList();
//                       },
//                       selectedItem: controller.selectedInstituteName.value,
//                       isEnabled: controller.selectedCity.value.isNotEmpty &&
//                           controller.selectedCity.value != "Select City",
//                       onChanged: (String? institute) {
//                         if (institute != null) {
//                           controller.selectedInstituteName.value = institute;
//                         }
//                       },
//                     )),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Column(
//               spacing: 10,
//               children: [
//                 _buildField1("Year", controller.year),
//                 _buildField1("Email", controller.email),
//                 _buildField1("Phone Number", controller.phone),
//                 _buildField1("WhatsApp Number", controller.whatsapp),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  // Widget _formFunds() {
  //   return Form(
  //     key: controller.fundsFormKey,
  //     child: Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         color: const Color(0xffffead1),
  //       ),
  //       child: Column(
  //         children: [
  //           Column(
  //             spacing: 12,
  //             children: [
  //               _buildField1("Funds", controller.funds),
  //               _buildField1("Description", controller.description,
  //                   height: 100),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           Obx(
  //             () => SizedBox(
  //               width: 120,
  //               height: 35,
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: controller.isButtonEnabled.value
  //                       ? const Color(0xFF008759)
  //                       : Colors.grey, // Change color based on validation
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(5),
  //                   ),
  //                 ),
  //                 onPressed: controller.isButtonEnabled.value
  //                     ? () async {
  //                         statecontroller.toggleLoading(true);
  //                         if (controller.mainFormKey.currentState!.validate() &&
  //                             controller.fundsFormKey.currentState!
  //                                 .validate()) {
  //                           var newData = RequestFormModel(
  //                             ITS: widget.member.itsId.toString(),
  //                             reqByITS: appliedbyIts.toString(),
  //                             reqByName: appliedByName.toString(),
  //                             city: controller.selectedCity.value,
  //                             mohalla: "${widget.member.jamaatId}",
  //                             address: widget.member.address.toString(),
  //                             dob: widget.member.dob.toString(),
  //                             institution: controller.selectedInstituteName.value!,
  //                             classDegree: controller.classDegree.value,
  //                             fieldOfStudy: controller.study.value, // 🔹 Renamed study → fieldOfStudy
  //                             subjectCourse: controller.selectedSubject.value, // 🔹 Renamed subject → subjectCourse
  //                             yearOfStart: controller.year.value, // 🔹 Renamed year → yearOfStart
  //                             grade: "", // 🔹 Add if applicable
  //                             email: controller.email.value,
  //                             contactNo: controller.phone.value, // 🔹 Renamed phoneNumber → contactNo
  //                             whatsappNo: controller.whatsapp.value, // 🔹 Renamed whatsappNumber → whatsappNo
  //                             purpose: "", // 🔹 Add if applicable
  //                             fundAsking: controller.funds.value, // 🔹 Renamed fundAmount → fundAsking
  //                             classification: "", // 🔹 Add if applicable
  //                             organization: "", // 🔹 Add if applicable
  //                             description: controller.description.value, // 🔹 Renamed fundDescription → description
  //                             currentStatus: "", // 🔹 Default value, change if needed
  //                             createdBy: "", // 🔹 Renamed created_by → createdBy
  //                             updatedBy: "", // 🔹 Renamed updated_by → updatedBy
  //                             applyDate: DateTime.now().toString(),
  //                           );
  //
  //                           // Call the API to add request
  //                           int returnCode = await Api.addRequestForm(newData);
  //                           await Future.delayed(const Duration(seconds: 2));
  //                           statecontroller.toggleLoading(false);
  //
  //                           if (returnCode == 200) {
  //                             Get.snackbar("Success!",
  //                                 "Data successfully inserted in Database!");
  //                           } else {
  //                             Get.snackbar("Error",
  //                                 "Failed to insert Data in Database!");
  //                           }
  //                         }
  //                       }
  //                     : null, // Disable the button when validation fails
  //                 child: const Text(
  //                   "Request",
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildField1(String label, RxString rxValue, {double? height}) {
  //   bool isDescription = height != null;
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  //       Obx(
  //         () => SizedBox(
  //           height: height ?? 40,
  //           child: TextFormField(
  //             controller: TextEditingController(text: rxValue.value)
  //               ..selection =
  //                   TextSelection.collapsed(offset: rxValue.value.length),
  //             onChanged: (value) {
  //               rxValue.value = value;
  //               controller.validateForm();
  //             },
  //             maxLines: isDescription ? 3 : 1,
  //             decoration: InputDecoration(
  //               enabledBorder: const OutlineInputBorder(
  //                 borderSide: BorderSide.none, // Removes the border
  //               ),
  //               focusedBorder: const OutlineInputBorder(
  //                 borderSide: BorderSide.none, // No border when focused
  //               ),
  //               filled: true,
  //               fillColor: const Color(0xfffffcf6),
  //               contentPadding:
  //                   const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //             ),
  //           ),
  //         ),
  //       ),
  //       // Display real-time validation error messages
  //       Obx(() {
  //         String? error = controller.validateField(label, rxValue.value);
  //         return error != null
  //             ? Text(error,
  //                 style: const TextStyle(color: Colors.red, fontSize: 12))
  //             : const SizedBox(height: 17);
  //       }),
  //     ],
  //   );
  // }
  //
  // Widget _buildDropdown({
  //   required String label,
  //   required Rxn<int> selectedValue,
  //   required List<Map<String, dynamic>> items,
  //   required ValueChanged<int?> onChanged,
  //   required bool isEnabled,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
  //       Obx(() => SizedBox(
  //             height: 40,
  //             child: DropdownButtonFormField<int>(
  //               isExpanded: true,
  //               value: selectedValue.value,
  //               icon: const Icon(Icons.arrow_drop_down),
  //               decoration: InputDecoration(
  //                 filled: true,
  //                 enabledBorder: OutlineInputBorder(
  //                   borderSide: BorderSide.none, // Removes the border
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderSide: BorderSide.none, // No border when focused
  //                 ),
  //                 fillColor: const Color(0xfffffcf6), // Background color
  //                 border: OutlineInputBorder(),
  //                 contentPadding:
  //                     EdgeInsets.symmetric(horizontal: 10, vertical: 0),
  //               ),
  //               items: items.map((Map<String, dynamic> item) {
  //                 return DropdownMenuItem<int>(
  //                   value: item['id'],
  //                   child: Text(item['name']),
  //                 );
  //               }).toList(),
  //               onChanged: isEnabled
  //                   ? (value) {
  //                       selectedValue.value = value;
  //                       onChanged(value);
  //                       controller.validateForm();
  //                     }
  //                   : null, // Disable when needed
  //               disabledHint: Text("Select ${_getDisabledHint(label)}"),
  //             ),
  //           )),
  //       // Show validation message dynamically
  //       Obx(() {
  //         String? error = controller.validateDropdown(label, selectedValue);
  //         return error != null
  //             ? Text(
  //                 error,
  //                 style: const TextStyle(color: Colors.red, fontSize: 12),
  //               )
  //             : const SizedBox(
  //                 height: 17); // Reserve space for validation message
  //       }),
  //     ],
  //   );
  // }
  //
  // String _getDisabledHint(String label) {
  //   switch (label) {
  //     case "Study":
  //       return "Marhala First";
  //     case "Field":
  //       return "Study First";
  //     default:
  //       return label;
  //   }
  // }
}
