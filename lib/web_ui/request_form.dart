import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/model/request_form_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';
import 'package:get/get.dart';

import '../controller/state_management/state_manager.dart';

class RequestForm extends StatefulWidget {
  final UserProfile member;
  const RequestForm({super.key, required this.member});

  @override
  RequestFormState createState() => RequestFormState();
}

class RequestFormState extends State<RequestForm> {
  final double defSpacing = 8;
  late final UserProfile member;
  bool isButtonEnabled = false;
  final StateController statecontroller = Get.put(StateController());
  late int reqId = 0;

  final TextEditingController classDegreeController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController studyController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController fundsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

// Add separate keys for each form section
  final GlobalKey<FormState> _mainFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _fundsFormKey = GlobalKey<FormState>();

  // Dropdown values
  String selectedCity = "Select City";
  String selectedSubject = "Select Subject";

  // Dropdown options
  final List<String> cities = ["Select City", "Karachi", "Islamabad", "Lahore"];
  final List<String> subjects = [
    "Select Subject",
    "Math",
    "Science",
    "History",
    "Computer Science"
  ];

  @override
  void initState() {
    super.initState();
    member = widget.member;
    fetchReqId();
    classDegreeController.addListener(validateForm);
    institutionController.addListener(validateForm);
    studyController.addListener(validateForm);
    yearController.addListener(validateForm);
    emailController.addListener(validateForm);
    phoneController.addListener(validateForm);
    whatsappController.addListener(validateForm);
    fundsController.addListener(validateForm);
    descriptionController.addListener(validateForm);
  }

  Future<void> fetchReqId() async {
    reqId = await Api.fetchNextReqMasId();
    setState(() {
      reqId;
    });
  }

  int calculateAge(String dobString) {
    // Parse the string into a DateTime object
    final dob = DateTime.parse(dobString);
    final today = DateTime.now();
    int age = today.year - dob.year;
    // Adjust age if the current date is before the birthday this year
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  void validateForm() {
    setState(() {
      isButtonEnabled = classDegreeController.text.isNotEmpty &&
          institutionController.text.isNotEmpty &&
          selectedCity != "Select City" &&
          studyController.text.isNotEmpty &&
          selectedSubject != "Select Subject" &&
          yearController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          whatsappController.text.isNotEmpty &&
          fundsController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    classDegreeController.dispose();
    institutionController.dispose();
    studyController.dispose();
    yearController.dispose();
    emailController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    fundsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Define the minimum width for your content
    const double minWidth = 1280;

    // Determine whether the screen is narrower than your minimum width
    final bool isScreenNarrow = screenWidth < minWidth;

    // Wrap your content in a SingleChildScrollView if the screen is too narrow
    Widget content = isScreenNarrow
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: minWidth, child: buildContent(context)),
          )
        : buildContent(context);

    return Scaffold(
      backgroundColor: Color(0xfffffcf6),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              child: content,
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
        headerSection(context),
        headerProfile(context),
        requestForm(context),
      ],
    );
  }

  Widget headerSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Color(0xffdbbb99)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Constants().heading('Profile Preview'),
          Row(
            spacing: 16,
            children: [
              SizedBox(
                height: 35,
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
                          return GuardianFormDialog();
                        },
                      );
                    },
                    child: Text(
                      "Add Guardian",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(
                height: 35,
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
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget headerProfile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xfffff7ec),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants().subHeading("Personal Information"),
          Divider(),
          Row(
            children: [
              // Container(
              //   width: 120,
              //     height: 170,
              //     child: Image.asset('assets/img.png',fit: BoxFit.contain,)
              // ),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  'http://localhost:3001/fetch-image?url=${Uri.encodeComponent(member.imageUrl!)}',
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullName ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' | '),
                        Text(
                          member.itsId.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Row(
                      spacing: defSpacing,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.location_on_rounded),
                            Text(member.address ?? ''),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.location_on_rounded),
                            Text(
                              member.jamiaat ?? '',
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      spacing: defSpacing,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.calendar_month_rounded),
                            Text(member.dob ?? ''),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.calendar_month_rounded),
                            Text("${calculateAge(member.dob ?? '')} years old"),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.email),
                            Text(member.email!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(member.mobileNo!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(member.whatsappNo!),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 15,
                  children: [
                    profileBox('Applied By', '30445124', context),
                    profileBox('Name', 'Abi Ali Qutbuddin', context),
                  ],
                ),
              )
            ],
          ),
          lastEducation()
        ],
      ),
    );
  }

  Widget lastEducation() {
    if (member.education == null || member.education!.isEmpty) {
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
            children: [
              Row(
                spacing: 50,
                children: [
                  Row(
                    children: [
                      Text("Class/ Degree Program: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        member.education![0].className ?? "Not available",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Constants().green),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Institution: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        member.education![0].institute ?? "Not available",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Constants().green),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Field of Study: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        member.education![0].subject ?? "Not available",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Constants().green),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("City: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        member.education![0].city ?? "Not available",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Constants().green),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget profileBox(String title, String value, BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(10),
      width: Constants().responsiveWidth(context, 0.12),
      height: 80,
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
                "Request #: 000$reqId",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("|"),
              Text(
                "Date: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          _form(),
          _formFunds()
        ],
      ),
    );
  }

  // Define validation logic here
  String? _validateField(String label, String? value) {
    if (value == null || value.isEmpty) {
      return "* $label is required";
    }

    switch (label.toLowerCase()) {
      case "year":
        return _validateYear(value);
      case "class / degree program":
        return _validateDegree(value);
      case "institution":
        return _validateInstitution(value);
      case "email":
        return _validateEmail(value);
      case "phone number":
      case "whatsapp number":
        return _validatePhoneNumber(value);
      case "funds":
        return _validateFunds(value);
      default:
        return null;
    }
  }

  String? _validateDegree(String? value) {
    if (value == null || value.isEmpty) {
      return "Degree is required";
    }

    // Regular expression to allow only alphabets and spaces
    final regex = RegExp(r'^[a-zA-Z\s]+$');

    if (!regex.hasMatch(value)) {
      return "Degree can only contain alphabets and spaces";
    }

    // Check for minimum length
    if (value.length < 2) {
      return "Degree must be at least 2 characters long";
    }

    // Check for maximum length
    if (value.length > 100) {
      return "Degree cannot exceed 100 characters";
    }

    // Check for leading or trailing spaces
    if (value.trim() != value) {
      return "Degree cannot start or end with spaces";
    }

    return null;
  }

  String? _validateInstitution(String? value) {
    if (value == null || value.isEmpty) {
      return "Institution name is required";
    }

    // Regular expression to allow only alphabets and spaces
    final regex = RegExp(r'^[a-zA-Z\s]+$');

    if (!regex.hasMatch(value)) {
      return "Please enter valid Institution";
    }

    // Check for minimum length
    if (value.length < 2) {
      return "Institution name must be at least 2 characters long";
    }

    // Check for maximum length
    if (value.length > 150) {
      return "Institution name cannot exceed 150 characters";
    }

    // Check for leading or trailing spaces
    if (value.trim() != value) {
      return "Institution name cannot start or end with spaces";
    }

    return null;
  }

  String? _validateYear(String value) {
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return "Enter a valid year (e.g., 2023)";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email address is required";
    }

    // Regular expression for validating email addresses
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address";
    }

    // Check if email starts or ends with invalid characters
    if (value.startsWith('.') || value.startsWith('-') || value.startsWith('_')) {
      return "Email cannot start with a special character";
    }

    if (value.endsWith('.') || value.endsWith('-') || value.endsWith('_')) {
      return "Email cannot end with a special character";
    }

    // Check for consecutive dots
    if (value.contains('..')) {
      return "Email cannot contain consecutive dots";
    }

    return null;
  }

  String? _validatePhoneNumber(String value) {
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
      return "Enter a valid phone number (10-15 digits)";
    }
    return null;
  }

  String? _validateFunds(String? value) {
    if (value == null || value.isEmpty) {
      return "Funds amount is required";
    }

    // Regular expression to check for numeric input
    final numericRegex = RegExp(r'^\d+$');

    if (!numericRegex.hasMatch(value)) {
      return "Enter a valid numeric amount for funds";
    }

    // Convert to a number for further checks
    final amount = int.tryParse(value);

    if (amount == null) {
      return "Enter a valid numeric amount for funds";
    }

    // Check for non-negative values
    if (amount < 0) {
      return "Funds amount cannot be negative";
    }

    if (amount < 1000) {
      return "Funds amount must be greater than 1000";
    }

    // Check for excessively large amounts
    if (amount > 100000000) {
      return "Funds amount cannot exceed 1,000,000,00";
    }

    // Check for leading zeros
    if (value.length > 1 && value.startsWith('0')) {
      return "Funds amount cannot have leading zeros";
    }

    return null;
  }

  String? _validateDropdown(String label, String value) {
    if (value == "Select City" || value == "Select Subject") {
      return "* $label is required";
    }
    return null;
  }

  Widget _buildField(String label, TextEditingController controller,
      {double? height}) {
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
            controller: controller,
            maxLines: isDescription ? 3 : 1,
            validator: (value) {
              _validateField(label, value);
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
            String? error = _validateField(label, controller.text);
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
      key: _mainFormKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffffead1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                Flexible(
                    child: _buildField(
                        "Class / Degree Program", classDegreeController)),
                Flexible(
                    child: _buildField("Institution", institutionController)),
                Flexible(
                  child:
                      _buildDropdown("City", selectedCity, cities, (newValue) {
                    setState(() {
                      selectedCity = newValue!;
                    });
                  }),
                ),
                Flexible(child: _buildField("Study", studyController)),
                Flexible(
                  child: _buildDropdown(
                      "Subject / Course", selectedSubject, subjects,
                      (newValue) {
                    setState(() {
                      selectedSubject = newValue!;
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 10,
              children: [
                Flexible(child: _buildField("Year", yearController)),
                Flexible(child: _buildField("Email", emailController)),
                Flexible(child: _buildField("Phone Number", phoneController)),
                Flexible(
                    child: _buildField("WhatsApp Number", whatsappController)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _formFunds() {
    return Form(
      key: _fundsFormKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffffead1),
        ),
        child: Column(
          children: [
            Row(
              spacing: 10,
              children: [
                Flexible(flex: 2, child: _buildField("Funds", fundsController)),
                Flexible(
                  flex: 5,
                  child: _buildField("Description", descriptionController,
                      height: 100),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled
                      ? const Color(0xFF008759)
                      : Colors.grey, // Change color based on validation
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: isButtonEnabled
                    ? () async {
                  statecontroller.toggleLoading(true);
                  if (_mainFormKey.currentState!.validate() &&
                      _fundsFormKey.currentState!.validate()) {
                    var newData = RequestFormModel(
                      classDegree: classDegreeController.text,
                      institution: institutionController.text,
                      city: selectedCity,
                      study: studyController.text,
                      subject: selectedSubject,
                      year: yearController.text,
                      email: emailController.text,
                      phoneNumber: phoneController.text,
                      whatsappNumber: whatsappController.text,
                      fundAmount: fundsController.text,
                      memberITS: member.itsId.toString(),
                      appliedby: member.itsId.toString(),
                      fundDescription: descriptionController.text,
                      mohalla: member.jamaatId.toString(),
                      address: member.address ?? "",
                      dob: member.dob ?? "",
                      fullName: member.fullName ?? "",
                      firstName: member.firstName ?? "",
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
            String? error = _validateDropdown(label, selectedValue);
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

class RequestTable extends StatefulWidget {
  const RequestTable({super.key});

  @override
  RequestTableState createState() => RequestTableState();
}

class RequestTableState extends State<RequestTable> {
  List<Map<String, dynamic>> _data = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchData({String? id}) async {
    final url = Uri.parse(
        'http://localhost:3000/get-requests${id != null ? "?id=$id" : ""}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch all data initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Table'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final id = _searchController.text.trim();
                    if (id.isNotEmpty) {
                      fetchData(id: id);
                    } else {
                      fetchData(); // Fetch all if search is empty
                    }
                  },
                  child: Text('Search'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Class Degree')),
                    DataColumn(label: Text('Institution')),
                    DataColumn(label: Text('City')),
                    DataColumn(label: Text('Study')),
                    DataColumn(label: Text('Subject')),
                    DataColumn(label: Text('Year')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('WhatsApp')),
                    DataColumn(label: Text('Funds')),
                    DataColumn(label: Text('Description')),
                  ],
                  rows: _data.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(item['id'].toString())),
                      DataCell(Text(item['classDegree'] ?? '')),
                      DataCell(Text(item['institution'] ?? '')),
                      DataCell(Text(item['city'] ?? '')),
                      DataCell(Text(item['study'] ?? '')),
                      DataCell(Text(item['subject'] ?? '')),
                      DataCell(Text(item['year'] ?? '')),
                      DataCell(Text(item['email'] ?? '')),
                      DataCell(Text(item['phoneNumber'] ?? '')),
                      DataCell(Text(item['whatsappNumber'] ?? '')),
                      DataCell(Text(item['fundAmount'].toString())),
                      DataCell(Text(item['fundDescription'] ?? '')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuardianFormDialog extends StatefulWidget {
  const GuardianFormDialog({super.key});

  @override
  GuardianFormDialogState createState() => GuardianFormDialogState();
}

class GuardianFormDialogState extends State<GuardianFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController itsController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  @override
  void dispose() {
    itsController.dispose();
    nameController.dispose();
    contactController.dispose();
    super.dispose();
  }

  String? _validateITS(String? value) {
    if (value == null || value.isEmpty) {
      return "ITS is required";
    } else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      return "ITS must be 8 digits";
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required";
    }

    // Check for length
    if (value.length < 3) {
      return "Name must be at least 3 characters long";
    }

    // Check for special characters or numbers
    final regex = RegExp(r'^[a-zA-Z\s]+$');
    if (!regex.hasMatch(value)) {
      return "Name can only contain alphabets and spaces";
    }

    // Check for multiple spaces
    if (value.contains(RegExp(r'\s{2,}'))) {
      return "Name cannot contain consecutive spaces";
    }

    // Check if the name starts or ends with spaces
    if (value.startsWith(' ') || value.endsWith(' ')) {
      return "Name cannot start or end with spaces";
    }

    return null;
  }

  String? _validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return "Contact Info is required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xffffead1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        width: 450,
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 5,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Guardian",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: TextFormField(
                  controller: itsController,
                  maxLength: 8,
                  keyboardType: TextInputType.number,
                  validator: _validateITS,
                  decoration: InputDecoration(
                    hintText: "Enter Guardian ITS ID",
                    counterText: "",
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                          color: Color(0xFF008759),
                          width: 2), // Removes the border
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF008759),
                          width: 2), // No border when focused
                    ),
                    filled: true,
                    fillColor: const Color(0xfffffcf6),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              // TextFormField(
              //   controller: itsController,
              //   decoration: InputDecoration(
              //     labelText: "ITS (8 digits)",
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: _validateITS,
              // ),
              SizedBox(
                height: 50,
                child: TextFormField(
                  controller: nameController,
                  validator: _validateName,
                  decoration: InputDecoration(
                    hintText: "Enter Guardian Name",
                    counterText: "",
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                          color: Color(0xFF008759),
                          width: 2), // Removes the border
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF008759),
                          width: 2), // No border when focused
                    ),
                    filled: true,
                    fillColor: const Color(0xfffffcf6),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: TextFormField(
                  controller: contactController,
                  validator: _validateContact,
                  decoration: InputDecoration(
                    hintText: "Enter Guardian Contact",
                    counterText: "",
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                          color: Color(0xFF008759),
                          width: 2), // Removes the border
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF008759),
                          width: 2), // No border when focused
                    ),
                    filled: true,
                    fillColor: const Color(0xfffffcf6),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Smooth rounded edges
                        side: BorderSide(
                            color: Colors.redAccent), // Add a red border
                      ),
                      backgroundColor:
                          Colors.red.withValues(alpha: 0.1), // Light red background
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.redAccent, // Red text color
                        fontWeight:
                            FontWeight.bold, // Bold text for better visibility
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008759),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Smooth rounded edges
                        side: BorderSide.none, // Add a red border
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle form submission
                        Navigator.pop(context); // Close the dialog
                      }
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
