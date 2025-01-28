import 'package:flutter/material.dart';
import 'package:ows/controller/request_form_controller.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/web_ui/request_form.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../controller/login_controller.dart';
import '../model/family_model.dart';

class ProfilePDFScreenM extends StatefulWidget {
  final UserProfile member;
  final Family family;
  final PdfControllerPinch pdfController;

  const ProfilePDFScreenM({
    super.key,
    required this.member,
    required this.family,
    required this.pdfController,
  });

  @override
  ProfilePDFScreenMState createState() => ProfilePDFScreenMState();
}

class ProfilePDFScreenMState extends State<ProfilePDFScreenM> {
  late PdfControllerPinch _pdfController;
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

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading delay
    _pdfController = widget.pdfController;

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff7ec),
      appBar: AppBar(
        backgroundColor: const Color(0xFF008759),
        title: const Text(
          'Profile Preview',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Request Button
          TextButton(
            onPressed: () {
              Get.to(() => RequestForm(member: widget.member));
            },
            child: const Text(
              "Request",
              style: TextStyle(color: Colors.white),
            ),
          ),
          // Logout Button
          TextButton(
            onPressed: () {
              Get.to(() => LoginController());
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Main content
            if (!_isLoading)
              Column(
                children: [
                  Expanded(
                    child: PdfViewPinch(
                      controller: _pdfController,
                      padding: 0,
                      scrollDirection: Axis.vertical,
                    ),
                  ),
                ],
              ),
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}