import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:ows/controller/request_form_controller.dart';
import 'package:ows/model/member_model.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
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
  //final bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PDFScreenController controller = Get.find<PDFScreenController>();

  @override
  Widget build(BuildContext context) {
    //final double screenHeight = MediaQuery.of(context).size.height;
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
                        value: 'request',
                        child: Row(
                          children: const [
                            Icon(Icons.person_rounded, size: 20, color: Colors.black),
                            SizedBox(width: 10),
                            Text("Request"),
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
                        Get.back();
                      } else if (value == 'request') {
                        Get.to(() => RequestForm(member: widget.member));
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
          ]
      ),
      backgroundColor: const Color(0xfffff7ec),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Main content
            Obx(() {
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
            })
          ],
        ),
      ),
    );
  }
}
