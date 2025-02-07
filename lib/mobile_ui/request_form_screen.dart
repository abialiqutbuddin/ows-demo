import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';
import '../constants/constants.dart';
import '../controller/request_form_controller.dart';
import '../controller/state_management/state_manager.dart';
import '../constants/dropdown_search.dart';
import '../model/member_model.dart';
import '../model/request_form_model.dart';

class RequestFormM extends StatefulWidget {
  final UserProfile member;
  const RequestFormM({super.key, required this.member});

  @override
  RequestFormMState createState() => RequestFormMState();
}

class RequestFormMState extends State<RequestFormM> {
  final RequestFormController controller = Get.find<RequestFormController>();
  final StateController statecontroller = Get.put(StateController());
  late final UserProfile member;

  @override
  void initState() {
    super.initState();
    initializeMember();
  }

  Future<void> initializeMember() async {
    setState(() {
      controller.isLoading.value = true;
    });
    member = widget.member;
    controller.appliedbyIts = await Constants().getFromPrefs('appliedByIts');
    controller.appliedByName = await Constants().getFromPrefs('appliedByName');
    setState(() {
      controller.isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
          backgroundColor: Colors.brown,
          centerTitle: false,
          title: Text(
            'Request Form',
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
                        value: 'add_guardian',
                        child: Row(
                          children: const [
                            Icon(Icons.person_rounded, size: 20, color: Colors.black),
                            SizedBox(width: 10),
                            Text("Add Guardian"),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'paktalim',
                        child: Row(
                          children: const [
                            Icon(Icons.update_rounded,
                                size: 20, color: Colors.black),
                            SizedBox(width: 10),
                            Text("Update Profile"),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'talabulilm',
                        child: Row(
                          children: const [
                            Icon(Icons.open_in_browser_rounded, size: 20, color: Colors.black),
                            SizedBox(width: 10),
                            Text("Visit Talabulilm"),
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
                        //_logout(context);
                        Get.back();
                      } else if (value == 'paktalim') {
                        //_openLink();
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
                      } else if (value == 'talabulilm') {
                        //_showAlert(context);
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
                      } else if (value == 'add_guardian') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return
                                //GuardianFormDialog();
                                SizedBox.shrink();
                          },
                        );
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
          ]),
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
    double fontSize = screenWidth * 0.035;

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
                  Api.fetchImage(member.imageUrl!),
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
                  // errorBuilder: (context, error, stackTrace) {
                  //   return Image.asset(
                  //     "assets/demo.jpg", // Path to default image
                  //     width: 100,
                  //     fit: BoxFit.contain,
                  //   );
                  // },
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName ?? '',
                      softWrap: true,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSize),
                    ),
                    Text(
                      'Student ITS: ${member.itsId.toString()}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSize),
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
                spacing: controller.defSpacing,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: controller.defSpacing,
                    children: [
                      Icon(Icons.location_on_rounded),
                      Flexible(
                          child: Text(
                        member.address ?? '',
                        softWrap: true,
                        style: TextStyle(fontSize: fontSize),
                      )),
                    ],
                  ),
                  Row(
                    spacing: controller.defSpacing,
                    children: [
                      Icon(Icons.location_on_rounded),
                      Text(member.jamiaat ?? '',
                          style: TextStyle(fontSize: fontSize)),
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
                        spacing: controller.defSpacing,
                        children: [
                          Icon(Icons.calendar_month_rounded),
                          Text(member.dob ?? '',
                              style: TextStyle(fontSize: fontSize)),
                        ],
                      ),
                      Row(
                        spacing: controller.defSpacing,
                        children: [
                          Icon(Icons.calendar_month_rounded),
                          Text(
                              "${controller.calculateAge(member.dob ?? '')} years old",
                              style: TextStyle(fontSize: fontSize)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              Column(
                spacing: controller.defSpacing,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: controller.defSpacing,
                    children: [
                      Icon(Icons.email),
                      Text(member.email!, style: TextStyle(fontSize: fontSize)),
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
                        spacing: controller.defSpacing,
                        children: [
                          Icon(Icons.phone),
                          Text(member.mobileNo!,
                              style: TextStyle(fontSize: fontSize)),
                        ],
                      ),
                      Row(
                        spacing: controller.defSpacing,
                        children: [
                          Icon(Icons.phone),
                          Text(member.whatsappNo!,
                              style: TextStyle(fontSize: fontSize)),
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
    if (value == 'ITS') {
      value = controller.appliedbyIts ?? '';
    } else {
      value = controller.appliedByName ?? '';
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
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
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
    double fontSize = screenWidth * 0.035;

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
                      text: member.education?.isNotEmpty == true
                          ? member.education![0].className ?? "Not available"
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
                      text: member.education?.isNotEmpty == true
                          ? member.education![0].institute ?? "Not available"
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
                      text: member.education?.isNotEmpty == true
                          ? member.education![0].subject ?? "Not available"
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
                      text: member.education?.isNotEmpty == true
                          ? member.education![0].city ?? "Not available"
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
    final double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.035;

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
                "${controller.reqNum}${controller.reqId}",
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
              ),
              Text("|", style: TextStyle(fontSize: fontSize)),
              Text(
                "Date: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
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
                _buildDropdown(
                  label: "Marhala",
                  selectedValue: controller.selectedMarhala,
                  items: controller.predefinedMarhalas,
                  onChanged: (value) {
                    controller.selectedMarhala.value = value!;
                    controller.filterStudies(value);
                  },
                  isEnabled: true,
                ),
                Obx(
                  () => _buildDropdown(
                    label: "Study",
                    selectedValue: controller.selectedStudy,
                    items: controller.filteredStudies,
                    onChanged: (value) {
                      controller.selectedStudy.value = value!;
                      controller.filterFields(value);
                      controller
                          .updateDropdownState(); // ✅ Update dropdown state
                    },
                    isEnabled: controller.isStudyEnabled.value,
                  ),
                ),
                Obx(() => _buildDropdown(
                      label: "Field",
                      selectedValue: controller.selectedField,
                      items: controller.filteredFields,
                      onChanged: (value) {
                        controller.selectedField.value = value!;
                        controller.updateDropdownState();
                      },
                      isEnabled: controller.isFieldEnabled.value,
                    )),
                Obx(() {
                  return _buildDropdown(
                    label: "City",
                    selectedValue: Rxn<int>(controller
                        .selectedCityId.value), // ✅ Pass the matched city ID
                    items: controller.cities,
                    isEnabled: true,
                    onChanged: (int? cityId) => controller.selectCity(cityId),
                  );
                }),
                Obx(() => CustomDropdownSearch<String>(
                      label: "Institute",
                      itemsLoader: (filter, _) async {
                        return controller.filteredInstitutes
                            .map((e) => e['name'] as String)
                            .toList();
                      },
                      selectedItem: controller.selectedInstituteName.value,
                      isEnabled: controller.selectedCity.value.isNotEmpty &&
                          controller.selectedCity.value != "Select City",
                      onChanged: (String? institute) {
                        if (institute != null) {
                          controller.selectedInstituteName.value = institute;
                        }
                      },
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              spacing: 10,
              children: [
                _buildField1("Year", controller.year),
                _buildField1("Email", controller.email),
                _buildField1("Phone Number", controller.phone),
                _buildField1("WhatsApp Number", controller.whatsapp),
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
                _buildField1("Funds", controller.funds),
                _buildField1("Description", controller.description,
                    height: 100),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => SizedBox(
                width: 120,
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isButtonEnabled.value
                        ? const Color(0xFF008759)
                        : Colors.grey, // Change color based on validation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: controller.isButtonEnabled.value
                      ? () async {
                          statecontroller.toggleLoading(true);
                          if (controller.mainFormKey.currentState!.validate() &&
                              controller.fundsFormKey.currentState!
                                  .validate()) {
                            var newData = RequestFormModel(
                              classDegree: controller
                                  .classDegree.value, // ✅ Use RxString.value
                              institution: controller.institution.value,
                              city: controller.selectedCity.value,
                              study: controller.study.value,
                              subject: controller.selectedSubject.value,
                              year: controller.year.value,
                              email: controller.email.value,
                              phoneNumber: controller.phone.value,
                              whatsappNumber: controller.whatsapp.value,
                              fundAmount: controller.funds.value,
                              memberITS: controller.appliedbyIts.toString(),
                              appliedbyIts: controller.appliedbyIts.toString(),
                              appliedbyName:
                                  controller.appliedByName.toString(),
                              fundDescription: controller.description.value,
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
                              Get.snackbar("Error",
                                  "Failed to insert Data in Database!");
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField1(String label, RxString rxValue, {double? height}) {
    bool isDescription = height != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Obx(
          () => SizedBox(
            height: height ?? 40,
            child: TextFormField(
              controller: TextEditingController(text: rxValue.value)
                ..selection =
                    TextSelection.collapsed(offset: rxValue.value.length),
              onChanged: (value) {
                rxValue.value = value;
                controller.validateForm();
              },
              maxLines: isDescription ? 3 : 1,
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
        ),
        // Display real-time validation error messages
        Obx(() {
          String? error = controller.validateField(label, rxValue.value);
          return error != null
              ? Text(error,
                  style: const TextStyle(color: Colors.red, fontSize: 12))
              : const SizedBox(height: 17);
        }),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required Rxn<int> selectedValue,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
    required bool isEnabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Obx(() => SizedBox(
              height: 40,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                value: selectedValue.value,
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
                items: items.map((Map<String, dynamic> item) {
                  return DropdownMenuItem<int>(
                    value: item['id'],
                    child: Text(item['name']),
                  );
                }).toList(),
                onChanged: isEnabled
                    ? (value) {
                        selectedValue.value = value;
                        onChanged(value);
                        controller.validateForm();
                      }
                    : null, // Disable when needed
                disabledHint: Text("Select ${_getDisabledHint(label)}"),
              ),
            )),
        // Show validation message dynamically
        Obx(() {
          String? error = controller.validateDropdown(label, selectedValue);
          return error != null
              ? Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                )
              : const SizedBox(
                  height: 17); // Reserve space for validation message
        }),
      ],
    );
  }

  String _getDisabledHint(String label) {
    switch (label) {
      case "Study":
        return "Marhala First";
      case "Field":
        return "Study First";
      default:
        return label;
    }
  }
}
