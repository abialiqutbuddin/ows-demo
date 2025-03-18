import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/constants/constants.dart';
import 'package:get/get.dart';
import 'package:ows/web_ui/profile_preview_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';
import '../constants/custom_dialog.dart';
import '../controller/profile_pdf_controller.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../model/family_model.dart';
import 'forms/main_form.dart';

class ProfilePDFScreenW extends StatefulWidget {
  final UserProfile member;

  const ProfilePDFScreenW({
    super.key,
    required this.member,
  });

  @override
  ProfilePDFScreenWState createState() => ProfilePDFScreenWState();
}

class ProfilePDFScreenWState extends State<ProfilePDFScreenW> {
  final PDFScreenController controller = Get.find<PDFScreenController>();
  final GlobalStateController gController = Get.find<GlobalStateController>();

  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoadingDialog(context);
    });
  }

  Widget buildContent(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: headerSection(context),
            ),
            buildPdf(context),
          ],
        ),
      ],
    );
  }

  Widget buildPdf(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (controller.pdfData.value == null) {
          return Center(
            child: LoadingAnimationWidget.discreteCircle(
              color: Colors.white,
              size: 50,
            ),
          );
        }
        return SfPdfViewer.memory(
          enableTextSelection: false,
          enableDocumentLinkAnnotation: false,
          controller.pdfData.value!,
          pageSpacing: 0,
        );
      }),
    );
  }

  void showLoadingDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Color(0xffffead1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Modern Circular Loading Animation
              SizedBox(height: 20),

              // ✅ Loading Text with Modern Style
              Text(
                "Fetching your document...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              // ✅ Subtext for better clarity
              Text(
                "This may take 20-30 seconds. Please wait.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // ✅ Optional Cancel Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants().green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: Icon(Icons.close, color: Colors.white),
                label: Text(
                  "Close",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true, // Prevent closing until PDF loads
    );
    ever(controller.pdfData, (value) {
      if (value != null && Get.isDialogOpen == true) {
        Get.back();
      }
    });
  }

  Widget headerSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Constants().heading('Profile Preview'),
        Row(
          spacing: 16,
          children: [
            // SizedBox(
            //   height: 35,
            //   child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: const Color(0xFF008759),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(5),
            //         ),
            //       ),
            //       onPressed: () {
            //         Get.to(() => ProfilePreview(member: widget.member, family: widget.family));
            //       },
            //       child: Text(
            //         "Profile Display",
            //         style: TextStyle(color: Colors.white),
            //       )),
            // ),
            // SizedBox(
            //   width: 120,
            //   height: 35,
            //   child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: const Color(0xFF008759),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(5),
            //         ),
            //       ),
            //       onPressed: () {
            //         Get.to(() => TableScreen());
            //       },
            //       child: Text(
            //         "Table",
            //         style: TextStyle(color: Colors.white),
            //       )),
            // ),
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
                  overlayColor: WidgetStateProperty.all(
                      Colors.transparent), // No ripple effect
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
                  Get.to(()=>IndexStackScreen());
                },
                child: Text(
                  "Application Form",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 35,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008759),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () async {
                    var data = await Api.fetchProxiedData(
                        "https://paktalim.com/admin/ws_app/GetFamilyCompletionStatus/${gController.user.value.itsId}?access_key=622ae1838756026b9500e50e778f131ac180bf70&username=40459629");
                    //data['profile_complete'] = "false";
                    //data['family_complete'] = "false";
                    if (data["profile_complete"] == "true" &&
                        data["family_complete"] == "true") {
                      Get.toNamed('/request-form');
                    } else {
                      String message = "";
                      if (data["profile_complete"] != "true") {
                        message = "Kindly complete your Pak Talim profile.";
                        showCustomDialog(
                          title: "Incomplete Data",
                          message: message,
                          confirmText: "Update Profile",
                          cancelText: "Cancel",
                          onCancel: () {
                            Get.back();
                          },
                          onConfirm: () {
                            Family family = Family();
                            Get.to(() => ProfilePreview(
                                member: gController.user.value,
                                family: family));
                          },
                        );
                      } else {
                        message =
                            "Kindly complete your family’s Paktalim profile. Contact your mohallah UT committee for further guidance.";
                        showCustomDialog(
                          title: "Incomplete Data",
                          message: message,
                          confirmText: "Go to Paktalim",
                          cancelText: "Cancel",
                          onCancel: () {
                            Get.back();
                          },
                          onConfirm: () async {
                            final url =
                                'https://paktalim.com/admin/profile/create';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                        );
                      }
                    }
                  },
                  child: Text(
                    "Request Form",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
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
                  overlayColor: WidgetStateProperty.all(
                      Colors.transparent), // No ripple effect
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
                  Constants().Logout();
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
}
