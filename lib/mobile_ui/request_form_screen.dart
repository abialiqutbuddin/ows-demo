import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/model/member_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';
import '../constants/constants.dart';
import '../controller/request_form_controller.dart';
import '../controller/state_management/state_manager.dart';
import '../model/request_form_model.dart';

class RequestFormM extends StatefulWidget {
  final UserProfile member;
  const RequestFormM({super.key, required this.member});

  @override
  RequestFormMState createState() => RequestFormMState();
}

class RequestFormMState extends State<RequestFormM> {
  final double defSpacing = 15;
  final RequestFormController controller = Get.find<RequestFormController>();
  final StateController statecontroller = Get.put(StateController());
  UserProfile? member;
  bool isLoading = true; // Track loading state
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? appliedByName;
  String? appliedbyIts;

  @override
  void initState() {
    super.initState();
    initializeMember();
  }

  Future<void> initializeMember() async {
    setState(() {
      isLoading = true;
    });
    member = widget.member; // Assuming data comes from the widget's member!
    setState(() {
      isLoading = false;
    });
    appliedbyIts = await Constants().getFromPrefs('appliedByIts');
    appliedByName = await Constants().getFromPrefs('appliedByName');

  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          backgroundColor: Colors.brown,
          centerTitle: false,
          title: Text(
            'Request Form',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              fontSize: screenWidth*0.05
            ), // White title text
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
                  padding:EdgeInsets.symmetric(horizontal: 11),
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
                    Icon(Icons.arrow_drop_down,color: Colors.black,)
                  ],
                ),
              ),
            )
          ]),
      drawer: Drawer(
        backgroundColor: Color(0xffffead1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 100,),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                spacing: 25,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008759),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return
                                //GuardianFormDialog();
                              SizedBox.shrink();
                            },
                          );
                        },
                        child: Text(
                          "Add Guardian",
                          style: TextStyle(color: Colors.white),
                        )
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered)) {
                              return Colors.transparent; // No hover effect
                            }
                            return Colors.transparent; // Default color
                          },
                        ),
                        overlayColor: WidgetStateProperty.all(
                            Colors.transparent), // No ripple effect
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              color: const Color(0xFF008759),
                              width: 2, // Green border
                            ),
                          ),
                        ),
                        elevation: WidgetStateProperty.all(0), // Flat button
                      ),
                      onPressed: () async {
                        final url =
                            'https://www.mhbtalabulilm.com/home'; // Replace with your URL
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode
                                .externalApplication, // Ensures it opens in a new tab or external browser
                          );
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Text(
                        "Carry me to Talabulilm",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered)) {
                              return Colors.transparent; // No hover effect
                            }
                            return Colors.transparent; // Default color
                          },
                        ),
                        overlayColor: WidgetStateProperty.all(
                            Colors.transparent), // No ripple effect
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              color: const Color(0xFF008759),
                              width: 2, // Green border
                            ),
                          ),
                        ),
                        elevation: WidgetStateProperty.all(0), // Flat button
                      ),
                      onPressed: () async {
                        final url =
                            'https://www.paktalim.com/admin/login'; // Replace with your URL
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Text(
                        "Carry me to PakTalim",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008759),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "View my education profile",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  //   icon: Icon(Icons.close),
                  // )
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Color(0xfffffcf6),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              child: buildContent(context),
            ),
          ),
          Obx(() {
            if (statecontroller.isLoading.value) {
              return Container(
                color: Colors.black
                    .withValues(alpha: 0.5), // Semi-transparent background
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
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        //headerSection(context),
        headerProfile(context),
        requestForm(context),
      ],
    );
  }

  Widget headerProfile(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth*0.035;

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xfffff7ec),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants().subHeading("Personal Information"),
          Divider(),
          Row(
            spacing: 15,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  Api.fetchImage(member!.imageUrl!),
                  width: 100,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 70,
                      width: 70,
                      color: Colors.grey,
                      child: const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member!.fullName ?? '',
                      softWrap: true,
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: fontSize),
                    ),
                    Text(
                      'Student ITS: ${member!.itsId.toString()}',
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: fontSize),
                    )
                  ],
                ),
              ),
            ],
          ),
          Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                spacing: defSpacing,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: defSpacing,
                    children: [
                      Icon(Icons.location_on_rounded),
                      Flexible(
                          child: Text(member!.address ?? '', softWrap: true,style: TextStyle(fontSize: fontSize),)),
                    ],
                  ),
                  Row(
                    spacing: defSpacing,
                    children: [
                      Icon(Icons.location_on_rounded),
                      Text(
                        member!.jamiaat ?? '',style: TextStyle(fontSize: fontSize)
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    spacing: 15,
                    children: [
                      Row(
                        spacing: defSpacing,
                        children: [
                          Icon(Icons.calendar_month_rounded),
                          Text(member!.dob ?? '',style: TextStyle(fontSize: fontSize)),
                        ],
                      ),
                      Row(
                        spacing: defSpacing,
                        children: [
                          Icon(Icons.calendar_month_rounded),
                          Text(
                              "${controller.calculateAge(member!.dob ?? '')} years old",style: TextStyle(fontSize: fontSize)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              Column(
                spacing: defSpacing,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: defSpacing,
                    children: [
                      Icon(Icons.email),
                      Text(member!.email!,style: TextStyle(fontSize: fontSize)),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    spacing: 15,
                    children: [
                      Row(
                        spacing: defSpacing,
                        children: [
                          Icon(Icons.phone),
                          Text(member!.mobileNo!,style: TextStyle(fontSize: fontSize)),
                        ],
                      ),
                      Row(
                        spacing: defSpacing,
                        children: [
                          Icon(Icons.phone),
                          Text(member!.whatsappNo!,style: TextStyle(fontSize: fontSize)),
                        ],
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15,
            children: [
              profileBox('Applied By', 'ITS', context),
              profileBox('Name', 'Name', context),
            ],
          ),
          lastEducation()
        ],
      ),
    );
  }


  Widget profileBox(String title, String value, BuildContext context) {
    if(value == 'ITS'){
      value = appliedbyIts ?? '';
    }else{
    value = appliedByName ?? '';
    }


    return Expanded(
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(10),
        width: Constants().responsiveWidth(context, 0.12),
        decoration: BoxDecoration(
            color: Color(0xffffead1),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            Text(title,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            Text(value,
                style: TextStyle(
                    color: Constants().green, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget lastEducation() {

    final double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth*0.037;


    if (member!.education == null || member!.education!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Constants().subHeading("Last Education"),
            Divider(),
            Text(
              "No education data available",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants().subHeading("Last Education"),
          Divider(),
          Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: fontSize), // Common font size
                  children: [
                    TextSpan(
                      text: "Class/ Degree Program: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for label
                      ),
                    ),
                    TextSpan(
                      text: member?.education?.isNotEmpty == true
                          ? member!.education![0].className ?? "Not available"
                          : "Not available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants().green, // Green color for value
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: fontSize), // Common font size
                  children: [
                    TextSpan(
                      text: "Institution: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for label
                      ),
                    ),
                    TextSpan(
                      text: member?.education?.isNotEmpty == true
                          ? member!.education![0].institute ?? "Not available"
                          : "Not available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants().green, // Green color for value
                      ),
                    ),
                  ],
                ),
                softWrap: true,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: fontSize), // Common font size
                  children: [
                    TextSpan(
                      text: "Field of Study: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for label
                      ),
                    ),
                    TextSpan(
                      text: member?.education?.isNotEmpty == true
                          ? member!.education![0].subject ?? "Not available"
                          : "Not available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants().green, // Green color for value
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: fontSize), // Common font size
                  children: [
                    TextSpan(
                      text: "City: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for label
                      ),
                    ),
                    TextSpan(
                      text: member?.education?.isNotEmpty == true
                          ? member!.education![0].city ?? "Not available"
                          : "Not available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants().green, // Green color for value
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget requestForm(BuildContext context) {

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xfffff7ec),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Constants().subHeading('Request for Education Assistance'),
          Divider(),
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Request #: 000${controller.reqId}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("|"),
              Text(
                "Date: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          SizedBox(),
          _form(),
          SizedBox(),
          _formFunds(),
          SizedBox(),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {double? height}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth*0.037;
    bool isDescription = height != null;
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        //const SizedBox(height: 5),
        SizedBox(
          height: height ?? 40,
          child: TextFormField(
            style: TextStyle(fontSize: fontSize),
            controller: controller,
            maxLines: isDescription ? 3 : 1,
            validator: (value) {
              this.controller.validateField(label, value);
              return null;
            },
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none, // Removes the border
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none, // No border when focused
              ),
              filled: true,
              fillColor: const Color(0xfffffcf6),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
        // Fixed height container for error messages
        //const SizedBox(height: 1), // Adjust this height as needed
        Builder(
          builder: (context) {
            String? error =
                this.controller.validateField(label, controller.text);
            if (error != null) {
              return Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              );
            }
            return const SizedBox(height: 17);
          },
        ),
      ],
    );
  }

// Wrap the form sections inside a `Form` widget
  Widget _form() {
    return Form(
      key: controller.mainFormKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffffead1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: 12,
              children: [
                _buildField(
                    "Class / Degree Program", controller.classDegreeController),
                _buildField("Institution", controller.institutionController),
                _buildDropdown(
                    "City", controller.selectedCity, controller.cities,
                    (newValue) {
                  setState(() {
                    controller.selectedCity = newValue!;
                  });
                }),
                _buildField("Study", controller.studyController),
                _buildDropdown("Subject / Course", controller.selectedSubject,
                    controller.subjects, (newValue) {
                  setState(() {
                    controller.selectedSubject = newValue!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              spacing: 10,
              children: [
                _buildField("Year", controller.yearController),
                _buildField("Email", controller.emailController),
                _buildField("Phone Number", controller.phoneController),
                _buildField("WhatsApp Number", controller.whatsappController),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _formFunds() {
    return Form(
      key: controller.fundsFormKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffffead1),
        ),
        child: Column(
          children: [
            Column(
              spacing: 12,
              children: [
                _buildField("Funds", controller.fundsController),
                _buildField("Description", controller.descriptionController,
                    height: 100),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isButtonEnabled
                      ? const Color(0xFF008759)
                      : Colors.grey, // Change color based on validation
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: controller.isButtonEnabled
                    ? () async {
                        statecontroller.toggleLoading(true);
                        if (controller.mainFormKey.currentState!.validate() &&
                            controller.fundsFormKey.currentState!.validate()) {
                          var newData = RequestFormModel(
                            classDegree: controller.classDegreeController.text,
                            institution: controller.institutionController.text,
                            city: controller.selectedCity,
                            study: controller.studyController.text,
                            subject: controller.selectedSubject,
                            year: controller.yearController.text,
                            email: controller.emailController.text,
                            phoneNumber: controller.phoneController.text,
                            whatsappNumber: controller.whatsappController.text,
                            fundAmount: controller.fundsController.text,
                            memberITS: member!.itsId.toString(),
                            appliedbyIts: appliedbyIts.toString(),
                            appliedbyName: appliedByName.toString(),
                            fundDescription:
                                controller.descriptionController.text,
                            mohalla: member!.jamaatId.toString(),
                            address: member!.address ?? "",
                            dob: member!.dob ?? "",
                            fullName: member!.fullName ?? "",
                            firstName: member!.firstName ?? "",
                            applyDate: DateTime.now().toString(),
                          );

                          // Call the API to add request
                          int returnCode = await Api.addRequestForm(newData);
                          await Future.delayed(const Duration(seconds: 2));
                          statecontroller.toggleLoading(false);

                          if (returnCode == 200) {
                            Get.snackbar("Success!",
                                "Data successfully inserted in Database!");
                          } else {
                            Get.snackbar(
                                "Error", "Failed to insert Data in Database!");
                          }
                        }
                      }
                    : null, // Disable the button when validation fails
                child: const Text(
                  "Request",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for dropdowns
  Widget _buildDropdown(String label, String selectedValue, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            icon: const Icon(Icons.arrow_drop_down),
            decoration: InputDecoration(
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none, // Removes the border
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none, // No border when focused
              ),
              fillColor: const Color(0xfffffcf6), // Background color
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
        Builder(
          builder: (context) {
            String? error = controller.validateDropdown(label, selectedValue);
            if (error != null) {
              return Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              );
            }
            return const SizedBox(
                height: 17); // Reserve space for validation message
          },
        ),
      ],
    );
  }
}
