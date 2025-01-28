import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/controller/request_form_controller.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/web_ui/request_form.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../controller/login_controller.dart';
import '../model/family_model.dart';

class ProfilePDFScreenW extends StatefulWidget {
  final UserProfile member;
  final Family family;
  final PdfControllerPinch pdfController;

  const ProfilePDFScreenW({
    super.key,
    required this.member,
    required this.family,
    required this.pdfController,
  });

  @override
  ProfilePDFScreenWState createState() => ProfilePDFScreenWState();
}

class ProfilePDFScreenWState extends State<ProfilePDFScreenW> {
  PdfControllerPinch? _pdfController;

  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    loadPdfController();
  }

  Future<void> loadPdfController() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate loading delay
    _pdfController = widget.pdfController;

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

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
      child: _pdfController != null
          ? SizedBox.expand(
              child: PdfViewPinch(
                controller: _pdfController!,
                scrollDirection: Axis.vertical,
                padding: 0,
              ),
            )
          : Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.white,
                size: 50,
              ),
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
                  Get.to(() => LoginController());
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
