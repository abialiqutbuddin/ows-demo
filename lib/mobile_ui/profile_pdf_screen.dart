import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/controller/request_form_controller.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/web_ui/request_form.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../controller/login_controller.dart';
import '../controller/profile_pdf_controller.dart';
import '../model/family_model.dart';

class ProfilePDFScreenM extends StatefulWidget {
  final UserProfile member;
  final Family family;
  //final Uint8List pdfData; // Pass the PDF data as Uint8List

  const ProfilePDFScreenM({
    super.key,
    required this.member,
    required this.family,
    // required this.pdfData,
  });

  @override
  ProfilePDFScreenMState createState() => ProfilePDFScreenMState();
}

class ProfilePDFScreenMState extends State<ProfilePDFScreenM> {
  final bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PDFScreenController controller = Get.find<PDFScreenController>();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          backgroundColor: Colors.brown,
          centerTitle: false,
          title: Text(
            'Profile Preview',
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
            Container(
              height: 35,
              padding: EdgeInsets.only(right: 15),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 11),
                  backgroundColor: const Color(0xFF008759),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  _scaffoldKey.currentState
                      ?.openDrawer(); // Open drawer when clicked
                },
                //icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                child: Row(
                  spacing: 5,
                  children: [
                    Text(
                      "More Options",
                      style: TextStyle(color: Colors.black),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            )
          ]),
      backgroundColor: const Color(0xfffff7ec),
      drawer: Drawer(
        backgroundColor: Color(0xffffead1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008759),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Color(0xFF008759), width: 2),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 15), // Removes extra padding
                      ),
                      onPressed: () {
                        Get.to(() => RequestForm(member: widget.member));
                      },
                      //icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      child: Text(
                        "Request",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Color(0xFF008759), width: 2),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 15), // Removes extra padding
                      ),
                      onPressed: () {
                        Constants().Logout();
                      },
                      //icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      child: Text(
                        "Logout",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Main content
            Expanded(
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
            )
          ],
        ),
      ),
    );
  }
}
