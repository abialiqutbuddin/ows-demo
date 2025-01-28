import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/model/request_form_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';
import 'package:get/get.dart';
import '../controller/request_form_controller.dart';
import '../controller/state_management/state_manager.dart';

class RequestFormW extends StatefulWidget {
  final UserProfile member;
  const RequestFormW({super.key, required this.member});

  @override
  RequestFormWState createState() => RequestFormWState();
}

class RequestFormWState extends State<RequestFormW> {
  final double defSpacing = 8;
  final RequestFormController controller = Get.put(RequestFormController());
  final StateController statecontroller = Get.put(StateController());
  UserProfile? member;
  bool isLoading = true; // Track loading state

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
    // If you fetch member! details, perform it here asynchronously

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Define the minimum width for your content
    const double minWidth = 1280;

    // Determine whether the screen is narrower than your minimum width
    final bool isScreenNarrow = screenWidth < minWidth;

    // Handle loading state
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xfffffcf6),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  Api.fetchImage(member!.imageUrl!),
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
                          member!.fullName ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' | '),
                        Text(
                          member!.itsId.toString(),
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
                            Text(member!.address ?? ''),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.location_on_rounded),
                            Text(
                              member!.jamiaat ?? '',
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
                            Text(member!.dob ?? ''),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.calendar_month_rounded),
                            Text(
                                "${controller.calculateAge(member!.dob ?? '')} years old"),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.email),
                            Text(member!.email!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(member!.mobileNo!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(member!.whatsappNo!),
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
            children: [
              Row(
                spacing: 50,
                children: [
                  Row(
                    children: [
                      Text("Class/ Degree Program: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        member!.education![0].className ?? "Not available",
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
                        member!.education![0].institute ?? "Not available",
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
                        member!.education![0].subject ?? "Not available",
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
                        member!.education![0].city ?? "Not available",
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
          _form(),
          _formFunds()
        ],
      ),
    );
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
            Row(
              spacing: 10,
              children: [
                Flexible(
                    child: _buildField("Class / Degree Program",
                        controller.classDegreeController)),
                Flexible(
                    child: _buildField(
                        "Institution", controller.institutionController)),
                Flexible(
                  child: _buildDropdown(
                      "City", controller.selectedCity, controller.cities,
                      (newValue) {
                    setState(() {
                      controller.selectedCity = newValue!;
                    });
                  }),
                ),
                Flexible(
                    child: _buildField("Study", controller.studyController)),
                Flexible(
                  child: _buildDropdown(
                      "Subject / Course",
                      controller.selectedSubject,
                      controller.subjects, (newValue) {
                    setState(() {
                      controller.selectedSubject = newValue!;
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 10,
              children: [
                Flexible(child: _buildField("Year", controller.yearController)),
                Flexible(
                    child: _buildField("Email", controller.emailController)),
                Flexible(
                    child: _buildField(
                        "Phone Number", controller.phoneController)),
                Flexible(
                    child: _buildField(
                        "WhatsApp Number", controller.whatsappController)),
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
            Row(
              spacing: 10,
              children: [
                Flexible(
                    flex: 2,
                    child: _buildField("Funds", controller.fundsController)),
                Flexible(
                  flex: 5,
                  child: _buildField(
                      "Description", controller.descriptionController,
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
                            appliedby: member!.itsId.toString(),
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
                      backgroundColor: Colors.red
                          .withValues(alpha: 0.1), // Light red background
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
