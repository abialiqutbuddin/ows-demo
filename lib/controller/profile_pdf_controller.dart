import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/api/api.dart';
import '../mobile_ui/profile_pdf_screen.dart';
import '../model/family_model.dart';
import '../model/member_model.dart';
import '../web_ui/profile_pdf_screen.dart';

class ProfilePDFScreen extends StatefulWidget {
  final UserProfile member;
  final Family family;

  const ProfilePDFScreen({
    super.key,
    required this.member,
    required this.family,
  });

  @override
  ProfilePDFScreenState createState() => ProfilePDFScreenState();
}

class ProfilePDFScreenState extends State<ProfilePDFScreen> {
  bool _isLoading = true; // Loading state
  late final Uint8List pdfData; // Pass the PDF data as Uint8List

  @override
  void initState() {
    super.initState();
    fetchAndLoadPDF(widget.member.itsId.toString());
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define the breakpoint for mobile
    const double mobileBreakpoint = 600;

    if (_isLoading) {
      // Show loading indicator while PDF is loading
      return Scaffold(
        backgroundColor: Color(0xffdbbb99),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return
      screenWidth <= mobileBreakpoint
        ? ProfilePDFScreenM(
            family: widget.family,
            member: widget.member,
        pdfData: pdfData,
          )
        :
    ProfilePDFScreenW(
            family: widget.family,
            member: widget.member,
            //pdfController: pdfController!,
      pdfData: pdfData,
          );
  }

  void fetchAndLoadPDF(String its) async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Load the PDF document from memory
      pdfData = await Api.fetchAndLoadPDF(its);

       setState(() {
        _isLoading = false; // Stop loading once initialized
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      Get.snackbar(
        "Failure",
        "Failed to Load PDF"
      );
    }
  }
}
