import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/login_controller.dart';
import 'package:get/get.dart';

class LoginPageM extends StatefulWidget {
  LoginPageM({super.key});

  @override
  _LoginPageMState createState() => _LoginPageMState();
}

class _LoginPageMState extends State<LoginPageM> {

  final StateController statecontroller = Get.put(StateController());
  final TextEditingController itsIdController = TextEditingController();

  @override
  void dispose() {
    itsIdController.dispose(); // Dispose controller when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final LoginController loginLogic = LoginController();

    return Stack(
      children: [
        Container(
          height: screenHeight,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7EC), // Background color
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top Image
                ClipRRect(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50),bottomRight: Radius.circular(50)),
                  child: Image.asset(
                    'assets/anwar.jpg',
                    height: screenHeight * 0.35,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.1),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: screenHeight*0.07),
                    // Content Area
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Text(
                            'IDARA AL-TA\'REEF AL-SHAKSHI (EJAMAAT) AUTHENTICATION',
                            style: TextStyle(
                              fontSize: 24.0, // Reduced font size for mobile
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
            
                          // Description
                          RichText(
                            text: TextSpan(
                              text: 'Kindly verify your Data on',
                              style: const TextStyle(fontSize: 16.0, color: Colors.black),
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
                          const SizedBox(height: 20),
            
                          // ITS ID Input Field
                          const Text(
                            "Enter ITS ID",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: itsIdController,
                            maxLength: 8,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Enter 8-digit ITS ID",
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF008759), width: 2),
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF008759), width: 2),
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              filled: true,
                              fillColor: const Color(0xfffffcf6),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: screenWidth * 0.035,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008759),
                                shadowColor: Colors.greenAccent,
                                elevation: 8.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () {
                                final itsId = itsIdController.text.trim();
                                // Validate input
                                if (itsId.isEmpty || itsId.length != 8 || int.tryParse(itsId) == null) {
                                  Get.snackbar(
                                    "Invalid Input",
                                    "Please enter a valid 8-digit ITS ID.",
                                  );
                                  return;
                                }
                                loginLogic.performLogin();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Image.asset(
                                      'assets/its.png',
                                      width: screenWidth * 0.06,
                                      fit: BoxFit.cover,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'ITS Authentication',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Loading Overlay
        Obx(() {
          if (statecontroller.isLoading.value) {
            return Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: Colors.white,
                  size: 50,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}