import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/model/request_form_model.dart';
import '../api/api.dart';
import 'package:get/get.dart';
import '../model/funding_record_model.dart';

class MoreStudentInfo extends StatefulWidget {
  final RequestFormModel req;
  final bool allowEdit;
  const MoreStudentInfo({super.key, required this.req, required this.allowEdit});

  @override
  MoreStudentInfoState createState() => MoreStudentInfoState();
}

class MoreStudentInfoState extends State<MoreStudentInfo> {
  final double defSpacing = 8;
  bool _isLoading = true; // Track loading state
  UserProfile? user;

  @override
  void initState() {
    super.initState();
    fetchUserProfile(widget.req.ITS);
  }

  Future<void> fetchUserProfile(String itsId) async {
    try {
      setState(() {
        _isLoading = true; // ✅ Show loading animation
      });

      final userProfile = await Api.fetchUserProfile(itsId);
      if (userProfile != null) {
        setState(() {
          user = userProfile; // ✅ Store user data
        });
        await fetchRecords(); // ✅ Fetch additional records
      } else {
        setState(() {
          errorMessage = "Profile not found for ITS ID: $itsId";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch user profile: $e";
      });
    } finally {
      setState(() {
        _isLoading = false; // ✅ Hide loading animation after fetching
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double minWidth = 1280;
    final bool isScreenNarrow = screenWidth < minWidth;

    // ✅ Show loading screen
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xfffffcf6),
        body: Center(
          child: LoadingAnimationWidget.discreteCircle(
            color: Colors.white,
            size: 50,
          ),
        ),
      );
    }

    // ✅ Show error message if API failed
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xfffffcf6),
        body: Center(
          child: Text(errorMessage,
              style: const TextStyle(fontSize: 18, color: Colors.red)),
        ),
      );
    }

    // ✅ Show UI only if `user` is available
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xfffffcf6),
        body: const Center(
          child: Text("User data is not available.",
              style: TextStyle(fontSize: 18, color: Colors.red)),
        ),
      );
    }

    Widget content = isScreenNarrow
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: minWidth, child: buildContent(context)),
          )
        : buildContent(context);

    return Scaffold(
      backgroundColor: const Color(0xfffffcf6),
      body: Stack(
        children: [
          SingleChildScrollView(child: content),
          if (_isLoading)
            Container(
              color:
                  Colors.black.withValues(alpha: 0.5), // ✅ Fixed opacity method
              child: Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        headerProfile(context),
        buildAiutRecord(context),
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            spacing: 10,
            children: [
              Flexible(
                child: Column(
                  children: [
                    _sectionTitle(
                        "Requestor Information", Icons.account_circle),
                    _requestorDetails(),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  children: [
                    _sectionTitle(
                        "Funding & Organization Details", Icons.school),
                    _fundingDetails(),
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            spacing: 10,
            children: [
              Flexible(
                flex: 5,
                child: Column(
                  children: [
                    _sectionTitle("Request Details", Icons.description),
                    _requestDetails(),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  children: [
                    _sectionTitle("Description", Icons.notes),
                    _descriptionBox(widget.req.description),
                  ],
                ),
              )
            ],
          ),
        ), //buildReq(context)
      ],
    );
  }

  Widget _requestorDetails() {
    return _sectionCard(
      children: [
        _infoRow("Requested By (ITS)", widget.req.reqByITS),
        _infoRow("Requested By (Name)", widget.req.reqByName),
        _infoRow("Email", widget.req.email),
        _infoRow("Contact No", widget.req.contactNo),
        _infoRow("WhatsApp No", widget.req.whatsappNo),
        _infoRow("Purpose of Request", widget.req.purpose),
      ],
    );
  }

  Widget _fundingDetails() {
    return _sectionCard(
      children: [
        _infoRow("Fund Asking", widget.req.fundAsking),
        _infoRow("Classification", widget.req.classification),
        _infoRow("Organization", widget.req.organization),
        _infoRow("Mohalla", widget.req.mohalla),
      ],
    );
  }

  /// **🔹 Request Details**
  Widget _requestDetails() {
    return _sectionCard(
      height: 380,
      children: [
        _infoRow("Request ID", widget.req.reqId?.toString() ?? "N/A"),
        _infoRow("Apply Date", widget.req.applyDate),

        _infoRow("Class / Degree", widget.req.classDegree),
        _infoRow("Field of Study", widget.req.fieldOfStudy),
        _infoRow("Study Institution", widget.req.institution),
        _infoRow("Subject / Course", widget.req.subjectCourse),
        _infoRow("Grade", widget.req.grade),
        _infoRow("Year of Start", widget.req.yearOfStart),


        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
            child: _statusDropdown(widget.req.currentStatus)),
      ],
    );
  }

  final List<String> statusOptions = [
    "Request Generated",
    "Request Received",
    "Request Denied",
    "Request Pending",
    "Request Approved",
    "Application Applied",
    "Application Denied",
    "Application Pending",
    "Application Approved",
    "Payment in Process",
    "First Payment Done"
  ];

  Widget _statusDropdown(String currentStatus) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 180,
            child: Text(
              "Current Status",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentStatus=='' ? null : currentStatus,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                  isExpanded: true,
                  onChanged: widget.allowEdit==true ? (String? newValue) {
                    if (newValue != null && newValue != currentStatus) {
                      _showStatusConfirmationDialog(newValue);
                    }
                  }: null,
                  items: statusOptions.map<DropdownMenuItem<String>>((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusConfirmationDialog(String selectedStatus) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirm Status Update", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
            const SizedBox(height: 10),
            Text(
              "Are you sure you want to update the status to:\n\n"
                  "**$selectedStatus**?",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              _updateStatus(widget.req.reqId!,selectedStatus);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(int reqId, String newStatus) async {

    final response = await Api.updateRequestStatus(reqId,newStatus);

    if(response) {
      setState(() {
        widget.req.currentStatus = newStatus;
      });
      Get.snackbar(
        "Success",
        "Request status updated to: $newStatus",
        backgroundColor: Colors.teal,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }else{
      Get.snackbar(
        "Error",
        "Failed to update status",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// **✅ Section Title Widget**
  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown, size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children,double? height}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xfffff7ec),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: height ?? 250,
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  /// **✅ Key-Value Row for Data Display**
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// **✅ Request Status Badge**
  Widget _statusBadge(String status) {
    Color badgeColor;
    Color textColor;
    IconData statusIcon;

    switch (status) {
      case "Approved":
        badgeColor = Colors.green.shade50;
        textColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "Denied":
        badgeColor = Colors.red.shade50;
        textColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case "Pending":
        badgeColor = Colors.orange.shade50;
        textColor = Colors.orange;
        statusIcon = Icons.hourglass_bottom;
        break;
      case "Payment Released":
        badgeColor = Colors.blue.shade50;
        textColor = Colors.blue;
        statusIcon = Icons.payments;
        break;
      default:
        badgeColor = Colors.grey.shade200;
        textColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: textColor, size: 18),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// **✅ Divider**
  Widget _divider() {
    return const Divider(
      color: Colors.grey,
      thickness: 0.8,
      height: 25,
    );
  }

  /// **✅ Description Box**
  Widget _descriptionBox(String description) {
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Color(0xfffff7ec),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        description.isNotEmpty ? description : "No description provided",
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  String errorMessage = "";
  List<FundingRecords> records = [];

  Future<void> fetchRecords() async {
    if (user == null) return; // ✅ Prevent null access

    try {
      List<FundingRecords> fetchedRecords =
          await Api.fetchRecords(user!.itsId.toString());
      setState(() {
        records = fetchedRecords;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load records";
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
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : records.isEmpty
                      ? SizedBox.shrink()
                      : SizedBox(
                          width: double.infinity,
                          child: Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Previously Taking Imdaad Talimi",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              // Table Header
                              Divider(),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xffdbbb99),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
      return has2025
          ? "Last Years"
          : "Current"; // 2024 is Current only if 2025 is not present
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
        color: getDateStatus(record.date.toString(), records) != 'Current'
            ? Colors.transparent
            : Colors.white,
        boxShadow: getDateStatus(record.date.toString(), records) != 'Current'
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
        borderRadius: BorderRadius.circular(8),
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          tableDataCell(record.school),
          tableDataCell(record.org),
          tableDataCell(record.orgP.toString()),
          tableDataCell(record.amount.toString()),
          tableDataCell(getDateStatus(record.date, records)),
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget headerProfile(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink(); // ✅ Prevents crashes if user is null
    }

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xfffff7ec),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants().subHeading("Personal Information"),
          Divider(),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  Api.fetchImage(user!.imageUrl!),
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user!.fullName ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' | '),
                        Text(
                          user!.itsId.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Row(
                      spacing: defSpacing,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.location_on_rounded),
                            SizedBox(
                                width: 600, child: Text(user!.address ?? '')),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.location_on_rounded),
                            Text(
                              user!.jamiaat ?? '',
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      spacing: defSpacing,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.calendar_month_rounded),
                            Text(user!.dob ?? ''),
                          ],
                        ),
                        // Row(
                        //   spacing: defSpacing,
                        //   children: [
                        //     Icon(Icons.calendar_month_rounded),
                        //     Text(
                        //         "${controller.calculateAge(user.dob ?? '')} years old"),
                        //   ],
                        // ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.email),
                            Text(user!.email!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(user!.mobileNo!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(user!.whatsappNo!),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 15,
                  children: [
                    profileBox('Applied By', 'ITS', context),
                    profileBox('Name', 'Name', context),
                  ],
                ),
              )
            ],
          ),
          lastEducation()
        ],
      ),
    );
  }

  Widget lastEducation() {
    if (user!.education == null || user!.education!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Constants().subHeading("Last Education"),
          Divider(),
          Wrap(
            spacing: 20, // Space between items
            runSpacing: 10, // Space between lines when wrapped
            children: [
              buildEducationRow(
                  "Class/ Degree Program: ", user!.education![0].className),
              buildEducationRow("Institution: ", user!.education![0].institute),
              buildEducationRow(
                  "Field of Study: ", user!.education![0].subject),
              buildEducationRow("City: ", user!.education![0].city ?? ""),
            ],
          ),
          SizedBox()
        ],
      ),
    );
  }

  // ✅ Helper Widget to Ensure Consistent Text Styling
  Widget buildEducationRow(String label, String? value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, color: Colors.black), // Default style
        children: [
          TextSpan(text: label, style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: value ?? "Not available",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Constants().green),
          ),
        ],
      ),
    );
  }

  Widget profileBox(String title, String value, BuildContext context) {
    if (value == 'ITS') {
      value = widget.req.reqByITS;
    } else {
      value = widget.req.reqByName;
    }
    return Container(
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
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(value,
              style: TextStyle(
                  color: Constants().green, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
