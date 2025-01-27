import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/login_controller.dart';
import 'package:get/get.dart';

class LoginPageW extends StatelessWidget {
  LoginPageW({super.key});

  final StateController statecontroller = Get.put(StateController());

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final TextEditingController itsIdController = TextEditingController();
    final LoginController loginLogic = LoginController();

    return Container(
              decoration: const BoxDecoration(
              color: Color(0xFFFFF7EC), // Background color
            ),
              child: Stack(
                children: [
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.asset(
                                height: screenHeight * 0.9,
                                'assets/anwar.jpg',
                                fit: BoxFit.cover,
                                color: Colors.black.withValues(alpha: 0.1),
                                colorBlendMode:
                                BlendMode.darken, // Blend mode to apply the color
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
                                      ),
                                      const TextSpan(
                                          text:
                                          'and then you will be able to login to OWS Website.'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Button
                                SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Enter ITS ID",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 70,
                                        child: TextFormField(
                                          controller: itsIdController,
                                          maxLength: 8,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: "Enter 8-digit ITS ID",
                                            counterText: "",
                                            enabledBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Color(0xFF008759),width: 2), // Removes the border
                                            ),
                                            focusedBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Color(0xFF008759),width: 2), // No border when focused
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xfffffcf6),
                                            contentPadding:
                                            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          ),
                                        ),
                                      ),
                                      // TextField(
                                      //   controller: itsIdController,
                                      //   keyboardType: TextInputType.number,
                                      //   maxLength: 8,
                                      //   decoration: InputDecoration(
                                      //     border: OutlineInputBorder(),
                                      //     hintText: "Enter 8-digit ITS ID",
                                      //     counterText: "",
                                      //   ),
                                      // ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF008759), // Button color
                                            shadowColor: Colors.greenAccent, // Button shadow
                                            elevation: 8.0, // Elevation for shadow effect
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                            ),
                                          ),
                                          onPressed: () {
                                            final itsId = itsIdController.text.trim();
                                            // Validate input
                                            if (itsId.isEmpty || itsId.length != 8 || int.tryParse(itsId) == null) {
                                              Get.snackbar("Invalid Input", "Please enter a valid 8-digit ITS ID.");
                                              return;
                                            }

                                            // Call the fetchAndNavigate function
                                            loginLogic.performLogin();
                                            //loginLogic.fetchAndNavigate(itsId);
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
                                              const SizedBox(width: 10), // Add spacing between icon and text
                                              const Text(
                                                'ITS Authentication',
                                                style: TextStyle(
                                                  color: Colors.white, // Button text color
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Loading overlay
                  Obx(() {
                    if (statecontroller.isLoading.value) {
                      return Container(
                        color: Colors.black.withValues(alpha: 0.5), // Semi-transparent background
                        child: Center(
                          child: LoadingAnimationWidget.discreteCircle(
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink(); // Empty widget when not loading
                  }
                  ),
                ],
              ),
    );
  }
}
