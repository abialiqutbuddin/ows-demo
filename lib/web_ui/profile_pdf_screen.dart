import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ows/controller/request_form_controller.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/constants/constants.dart';
import 'package:get/get.dart';
import 'package:ows/table.dart';
import '../model/family_model.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ProfilePDFScreenW extends StatefulWidget {
  final UserProfile member;
  final Family family;
  final Uint8List pdfData; // Pass the PDF data as Uint8List


  const ProfilePDFScreenW({
    super.key,
    required this.member,
    required this.family,
    required this.pdfData,
  });

  @override
  ProfilePDFScreenWState createState() => ProfilePDFScreenWState();
}

class ProfilePDFScreenWState extends State<ProfilePDFScreenW> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffff7ec),
      body: buildContent(context),
    );
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
      child: SfPdfViewer.memory(
          widget.pdfData,
        pageSpacing: 0,
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
