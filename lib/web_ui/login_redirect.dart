import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/api/api.dart';
import 'package:ows/constants/app_routes.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/model/family_data2.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController2 extends StatefulWidget {
  const LoginController2({super.key});

  @override
  LoginController2State createState() => LoginController2State();
}

class LoginController2State extends State<LoginController2> {
  GlobalStateController stateController = Get.find<GlobalStateController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => extractAndLogin());
  }

  Future<void> extractAndLogin() async {
    stateController.version.value = await Api.fetchVersion();
    stateController.toggleLoading(true);
    Uri uri = Uri.base;
    String? itsEncoded;

    if (uri.fragment.contains("its=")) {
      Uri fragmentUri =
          Uri.parse("https://dummy.com/?${uri.fragment.split("?")[1]}");
      itsEncoded = fragmentUri.queryParameters['its'];
    }

    if (itsEncoded != null && itsEncoded.isNotEmpty) {
      try {
        String decodedString = utf8.decode(base64.decode(itsEncoded));
        String extractedIts = decodedString.substring(0, 8);
        performLogin(extractedIts);
      } catch (e) {
        stateController.toggleLoading(false);
        Get.snackbar("Error", e.toString());
      }
    } else {
      stateController.toggleLoading(false);
      Get.snackbar("Error", "ITS Not Found");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7EC), // Background color
        ),
        child: Stack(
          children: [
            Positioned(
              right: screenWidth * 0.03,
              top: screenHeight * 0.05,
              child: Text("Web: V1.1+2", style: TextStyle(fontSize: 16)),
            ),
            Positioned(
              right: screenWidth * 0.03,
              top: screenHeight * 0.07,
              child: Text('Backend: ${stateController.version.value}',
                  style: TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Column: Image
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.02),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            height: screenHeight * 0.9,
                            'assets/anwar.jpg',
                            fit: BoxFit.cover,
                            color: Colors.black.withValues(alpha: 0.1),
                            colorBlendMode: BlendMode
                                .darken, // Blend mode to apply the color
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0), // Spacing between columns

                  // Right Column: Text and Button
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.07, right: screenWidth * 0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 15,
                        children: [
                          // Title Text
                          const Text(
                            'IDARA AL-TA\'REEF AL-SHAKSHI (EJAMAAT) AUTHENTICATION',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          // Paragraph Text with Special Color Text
                          RichText(
                            text: TextSpan(
                              text: 'Kindly verify your Data on',
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              children: [
                                TextSpan(
                                  text: ' www.its52.com ',
                                  style: const TextStyle(
                                    color: Color(0xFF299E7C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final url =
                                          Uri.parse('https://www.its52.com');
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(
                                          url,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                ),
                                const TextSpan(
                                    text:
                                        'and then you will be able to login to OWS Website.'),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008759),
                                // Button color
                                shadowColor: Colors.greenAccent,
                                // Button shadow
                                elevation: 8.0,
                                // Elevation for shadow effect
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Rounded corners
                                ),
                              ),
                              onPressed: () async {
                                final url = Uri.parse('https://www.its52.com');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/its.png',
                                    width: screenHeight * 0.035,
                                    fit: BoxFit.cover,
                                    color: Colors.white, // Set icon color
                                  ),
                                  const SizedBox(width: 10),
                                  // Add spacing between icon and text
                                  const Text(
                                    'ITS Authentication',
                                    style: TextStyle(
                                      color: Colors.white,
                                      // Button text color
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Loading overlay
            Obx(() {
              if (stateController.isLoading.value) {
                return Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  // Semi-transparent background
                  child: Center(
                    child: LoadingAnimationWidget.discreteCircle(
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink(); // Empty widget when not loading
            }),
          ],
        ),
      ),
    );
  }

  Future<void> performLogin(String itsId) async {
    stateController.toggleLoading(true);
    try {
      var response = await Api.getToken(itsId);
      if (response.containsKey('token')) {
        String token = response['token'];
        GetStorage().write("token", token);
      }
      List<FamilyMember>? familyMembers = await Api.fetchFamilyData2(itsId);
      if (familyMembers != null && familyMembers.isNotEmpty) {
        stateController.setUser(itsId, familyMembers);
        Get.toNamed(AppRoutes.family_screen);
      } else {
        Get.snackbar("Error", "No family members found.");
      }
    } catch (e) {
      Get.snackbar("Login Failed", "Error: $e");
    } finally {
      stateController.toggleLoading(false);
    }
  }
}
