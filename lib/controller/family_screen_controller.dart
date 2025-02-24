import 'package:flutter/material.dart';
import 'package:ows/mobile_ui/family_screen.dart';
import 'package:ows/model/family_data2.dart';
import 'package:ows/web_ui/family_screen.dart';
import '../model/family_model.dart';

class FamilyScreenController extends StatelessWidget {
  const FamilyScreenController({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define the breakpoint for mobile
    const double mobileBreakpoint = 600;

    return Scaffold(
       body: screenWidth <= mobileBreakpoint
           ? FamilyScreenM()
         : FamilyScreenW(),
    );
  }
}