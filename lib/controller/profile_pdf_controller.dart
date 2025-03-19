import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ows/api/api.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../mobile_ui/profile_pdf_screen.dart';
import '../model/family_model.dart';
import '../model/member_model.dart';
import '../web_ui/profile_pdf_screen.dart';

class PDFScreenController extends GetxController {
  Rxn<Uint8List> pdfData = Rxn<Uint8List>(); // Pass the PDF data as Uint8List

  /// **Fetch and Load PDF Data**
  Future<void> fetchAndLoadPDF(String its) async {
    try {
      pdfData.value = null; // Reset before loading

      Uint8List fetchedData = await Api.fetchAndLoadPDF(its);

      if (fetchedData.isEmpty) {
        throw Exception("PDF data is null or empty");
      }

      pdfData.value = fetchedData;

    } catch (e) {
      if (Get.overlayContext != null) {
        Get.snackbar("Notice", "Failed to Load PDF.");
      }
    }
  }

}

class ProfilePDFScreen extends StatefulWidget {

  const ProfilePDFScreen({
    super.key,
  });

  @override
  ProfilePDFScreenState createState() => ProfilePDFScreenState();
}

class ProfilePDFScreenState extends State<ProfilePDFScreen> {
  bool _isLoading = true; // Loading state
  late final Uint8List pdfData; // Pass the PDF data as Uint8List
  final PDFScreenController controller = Get.find<PDFScreenController>();
  final GlobalStateController gController = Get.find<GlobalStateController>();


  @override
  void initState() {
    super.initState();
    controller.fetchAndLoadPDF(gController.user.value.itsId.toString());
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define the breakpoint for mobile
    const double mobileBreakpoint = 600;
      // Show loading indicator while PDF is loading
      return Scaffold(
        backgroundColor: Color(0xffdbbb99),
        body: screenWidth <= mobileBreakpoint
              ? ProfilePDFScreenM(
            member: gController.user.value,
            //pdfData: pdfData,
          )
              :
          ProfilePDFScreenW(
            member: gController.user.value,
          ),
      );
  }

  void fetchAndLoadPDF(String its) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Try fetching the PDF from API
      //controller.pdfData = await Api.fetchAndLoadPDF(its);

      // If there's an error, load the default PDF from assets
      // ByteData byteData = await rootBundle.load("assets/profile.pdf");
      // pdfData = byteData.buffer.asUint8List(); // Convert ByteData to Uint8List

      // Check if the fetched PDF is null or empty
      if (pdfData.isEmpty) {
        throw Exception("PDF data is null or empty");
      }
    } catch (e) {

      // If there's an error, load the default PDF from assets
      // ByteData byteData = await rootBundle.load("profile.pdf");
      // pdfData = byteData.buffer.asUint8List(); // Convert ByteData to Uint8List

      Get.snackbar(
          "Notice",
          "Failed to Load PDF."
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading in all cases
      });
    }
  }
}
