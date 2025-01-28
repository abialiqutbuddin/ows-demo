import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../mobile_ui/profile_pdf_screen.dart';
import '../model/family_model.dart';
import '../model/member_model.dart';
import '../web_ui/profile_pdf_screen.dart';
import 'package:http/http.dart' as http;

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
  PdfControllerPinch? pdfController; // Nullable to handle initialization
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchAndLoadPDF();
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
        backgroundColor: const Color(0xfffff7ec),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return screenWidth <= mobileBreakpoint
        ? ProfilePDFScreenM(
      family: widget.family,
      member: widget.member,
      pdfController: pdfController!,
    )
        : ProfilePDFScreenW(
      family: widget.family,
      member: widget.member,
      pdfController: pdfController!,
    );
  }

  Future<void> fetchAndLoadPDF() async {
    try {
      // Fetch the PDF from the backend
      final response =
      await http.get(Uri.parse('http://localhost:3002/fetch-pdf1'));

      if (response.statusCode == 200) {
        final pdfData = response.bodyBytes;

        // Load the PDF document from memory
        final document = PdfDocument.openData(pdfData);

        setState(() {
          pdfController = PdfControllerPinch(
            document: document,
            viewportFraction: 1.0,
          );
          _isLoading = false; // Stop loading once initialized
        });
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF: $e')),
      );
    }
  }
}