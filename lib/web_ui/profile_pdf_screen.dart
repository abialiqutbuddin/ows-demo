import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/controller/request_form_controller.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/constants/constants.dart';
import 'package:get/get.dart';
import 'package:ows/table.dart';
import 'package:ows/web_ui/profile_preview_screen.dart';
import '../controller/profile_pdf_controller.dart';
import '../dropdown.dart';
import '../model/family_model.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ProfilePDFScreenW extends StatefulWidget {
  final UserProfile member;
  final Family family;

  const ProfilePDFScreenW({
    super.key,
    required this.member,
    required this.family,
  });

  @override
  ProfilePDFScreenWState createState() => ProfilePDFScreenWState();
}

class ProfilePDFScreenWState extends State<ProfilePDFScreenW> {

  final PDFScreenController controller = Get.find<PDFScreenController>();


  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }

  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: headerSection(context),
        ),
        buildPdf(context),
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

  Widget headerSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Constants().heading('Profile Preview'),
        Row(
          spacing: 16,
          children: [
            SizedBox(
              height: 35,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008759),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => ProfilePreview(member: widget.member, family: widget.family));
                  },
                  child: Text(
                    "Profile Display",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
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
                    Get.to(() => TableScreen());
                  },
                  child: Text(
                    "Table",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
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
                    Get.to(() => RequestForm(member: widget.member));
                  },
                  child: Text(
                    "Request",
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
