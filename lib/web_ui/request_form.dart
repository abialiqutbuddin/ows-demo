import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/model/request_form_model.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';
import 'package:get/get.dart';
import '../controller/request_form_controller.dart';
import '../controller/state_management/state_manager.dart';
import '../constants/dropdown_search.dart';

class RequestFormW extends StatefulWidget {
  final UserProfile member;
  const RequestFormW({super.key, required this.member});

  @override
  RequestFormWState createState() => RequestFormWState();
}

class RequestFormWState extends State<RequestFormW> {
  final double defSpacing = 8;
  final RequestFormController controller = Get.find<RequestFormController>();
  final GlobalStateController statecontroller =
      Get.put(GlobalStateController());
  late final UserProfile member;
  bool isLoading = true; // Track loading state
  late String? appliedByName;
  late String? appliedbyIts;

  List<dynamic> allData = [];
  List<dynamic> filteredStudies = [];
  List<dynamic> filteredNames = [];

  int? selectedMarhala;
  int? selectedStudy;
  int? selectedName;

  late List<String> statusOptions;

  List<String> checkEducationStatus(UserProfile userProfile) {
    List<String> statusList = [];

    bool hasOngoingEducation = userProfile.marhalaOngoing == 1;
    bool hasFutureEducation = userProfile.future?.isNotEmpty ?? false;

    if (hasOngoingEducation) {
      statusList.add("Apply For Ongoing");
      statusList.add("Apply For Future Education"); // Always add future when ongoing is 1
    } else if (!hasOngoingEducation && hasFutureEducation) {
      statusList.add("Apply For Future Education");
    } else {
      statusList.add("Apply For Future Education"); // When no ongoing and no future, still allow future application
    }

    return statusList;
  }

  @override
  void initState() {
    super.initState();
    initializeMember();
    statusOptions = checkEducationStatus(widget.member);

    Api.loadData().then((data) {
      setState(() {
        allData = data;
      });
    });
  }

  void filterStudies(int marhalaId) {
    setState(() {
      filteredStudies = allData
          .where((item) => item['marhala_id'] == marhalaId)
          .map((item) => {
                'id': item['study_id'],
                'name': item['study'],
              })
          .toSet()
          .toList(); // Remove duplicates
      selectedStudy = null;
      filteredNames = [];
      selectedName = null;
    });
  }

  void filterNames(int studyId) {
    setState(() {
      filteredNames = allData
          .where((item) => item['study_id'] == studyId)
          .map((item) => {
                'id': item['id'],
                'name': item['name'],
              })
          .toList();
      selectedName = null;
    });
  }

  Future<void> initializeMember() async {
    setState(() {
      isLoading = true;
    });

    member = widget.member;

    setState(() {
      isLoading = false;
    });

    // appliedbyIts = await Constants().getFromPrefs('appliedByIts');
    // appliedByName = await Constants().getFromPrefs('appliedByName');
    appliedByName = member.fullName;
    appliedbyIts = "${member.itsId}";
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

    return SelectionArea(
      child: Scaffold(
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
                        'https://www.talabulilm.com/profile/'; // Replace with your URL
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
                    elevation: WidgetStateProperty.all(0),
                  ),
                  onPressed: () async {
                    final url = 'https://paktalim.com/admin/profile/create';
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

  Widget checkStatus() {
    RxString selectedStatus = "".obs;
    List<String> statusOptions = checkEducationStatus(widget.member);

    return Column(
      spacing: 5,
      children: statusOptions
          .map((status) => Container(
        decoration: BoxDecoration(
          color: const Color(0xfffffcf6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown, width: 1),
        ),
        child: Obx(() => RadioListTile<String>(
          title: Text(
            status,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          value: status,
          groupValue: selectedStatus.value,
          activeColor: Colors.brown,
          onChanged: (value) {
            selectedStatus.value = value!;
            //controller.isButtonEnabled.value = true;
          },
        )),
      ))
          .toList(), // ✅ Convert map() result into a List<Widget>
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
                  Api.fetchImage(member.imageUrl!),
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
                            SizedBox(
                                width: 600, child: Text(member.address ?? '')),
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
                            Text(
                                "${controller.calculateAge(member.dob ?? '')} years old"),
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
                    profileBox('Applied By', 'ITS', context),
                    profileBox('Name', 'Name', context),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants().subHeading("Last Education"),
          Divider(),
          Wrap(
            spacing: 20, // Space between items
            runSpacing: 10, // Space between lines when wrapped
            children: [
              buildEducationRow(
                  "Class/ Degree Program: ", member.education![0].className),
              buildEducationRow(
                  "Institution: ", member.education![0].institute),
              buildEducationRow(
                  "Field of Study: ", member.education![0].subject),
              buildEducationRow("City: ", member.education![0].city),
            ],
          ),
          SizedBox()
        ],
      ),
    );
  }

// ✅ Helper Widget to Ensure Consistent Text Styling
  Widget buildEducationRow(String label, String? value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, color: Colors.black), // Default style
        children: [
          TextSpan(text: label, style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: value ?? "Not available",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Constants().green),
          ),
        ],
      ),
    );
  }

  Widget profileBox(String title, String value, BuildContext context) {
    if (value == 'ITS') {
      value = appliedbyIts ?? '';
    } else {
      value = appliedByName ?? '';
    }
    return Container(
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
          checkStatus(),
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${controller.reqNum}${controller.reqId}",
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

  Widget _buildField(String label, RxString rxValue, {double? height}) {
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
              spacing: 5,
              children: [
                Flexible(
                  child: Obx(
                    () => _buildDropdown2(
                      label: "Marhala",
                      selectedValue: controller.selectedMarhala,
                      items: controller.predefinedMarhalas,
                      onChanged: (value) {
                        controller.selectedMarhala.value = value!;
                        controller.selectedMarhalaName.value =
                            controller.predefinedMarhalas.firstWhere(
                                (element) => element['id'] == value)['name'];
                        controller.filterStudies(value);
                      },
                      isEnabled: true,
                    ),
                  ),
                ),
                Flexible(
                  child: Obx(
                    () => _buildDropdown2(
                      label: "Study",
                      selectedValue: controller.selectedStudy,
                      items: controller.filteredStudies,
                      onChanged: (value) {
                        controller.selectedStudy.value = value!;
                        controller.selectedStudyName.value =
                            controller.filteredStudies.firstWhere(
                          (element) => element['id'] == value,
                          orElse: () => {
                            'id': -1,
                            'name': 'Unknown Study'
                          }, // Handle missing cases
                        )['name'];
                        controller.filterFields(value);
                        controller.updateDropdownState();
                      },
                      isEnabled: controller.isStudyEnabled.value,
                    ),
                  ),
                ),
                Flexible(
                  child:
                      // Field Dropdown
                      Obx(() => _buildDropdown2(
                            label: "Field",
                            selectedValue: controller.selectedField,
                            items: controller.filteredFields,
                            onChanged: (value) {
                              controller.selectedField.value = value!;
                              controller.selectedSubject2.value =
                                  controller.filteredFields.firstWhere(
                                (element) => element['id'] == value,
                                orElse: () => {
                                  'id': -1,
                                  'name': 'Unknown Study'
                                }, // Handle missing cases
                              )['name'];
                              print(controller.selectedSubject2);
                              controller.updateDropdownState();
                            },
                            isEnabled: controller.isFieldEnabled.value,
                          )),
                ),
                Flexible(
                  child: Obx(() {
                    return _buildDropdown2(
                      label: "City",
                      selectedValue: Rxn<int>(controller.selectedCityId.value),
                      items: controller.cities,
                      isEnabled: true,
                      onChanged: (int? cityId) => controller.selectCity(cityId),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 5,
              children: [
                Flexible(
                  child: Obx(() => CustomDropdownSearch<String>(
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
                ),
                Flexible(child: _buildField2("Year", controller.year)),
                Flexible(child: _buildField2("Email", controller.email)),
                Flexible(child: _buildField2("Phone Number", controller.phone)),
                Flexible(
                    child:
                        _buildField2("WhatsApp Number", controller.whatsapp)),
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
                    flex: 2, child: _buildField2("Funds", controller.funds)),
                Flexible(
                  flex: 5,
                  child: _buildField2("Description", controller.description,
                      height: 100),
                ),
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
                            print(controller.selectedMarhalaName);
                            print(controller.selectedStudyName);
                            var newData = RequestFormModel(
                              ITS: widget.member.itsId.toString(),
                              reqByITS: appliedbyIts.toString(),
                              reqByName: appliedByName.toString(),
                              mohalla: widget.member.tanzeem.toString(),
                              address: widget.member.address.toString(),
                              dob: widget.member.dob.toString(),
                              city: controller.selectedCity.value,
                              institution:
                                  controller.selectedInstituteName.value!,
                              classDegree: controller.selectedMarhalaName.value,
                              fieldOfStudy: controller.selectedStudyName
                                  .value, // 🔹 Renamed study → fieldOfStudy
                              subjectCourse: controller.selectedSubject2
                                  .value, // 🔹 Renamed subject → subjectCourse
                              yearOfStart: controller
                                  .year.value, // 🔹 Renamed year → yearOfStart
                              grade: "", // 🔹 Add if applicable
                              email: controller.email.value,
                              contactNo: controller.phone
                                  .value, // 🔹 Renamed phoneNumber → contactNo
                              whatsappNo: controller.whatsapp
                                  .value, // 🔹 Renamed whatsappNumber → whatsappNo
                              purpose: "", // 🔹 Add if applicable
                              fundAsking: controller.funds
                                  .value, // 🔹 Renamed fundAmount → fundAsking
                              classification: "", // 🔹 Add if applicable
                              organization: "", // 🔹 Add if applicable
                              description: controller.description
                                  .value, // 🔹 Renamed fundDescription → description
                              currentStatus:
                                  "", // 🔹 Default value, change if needed
                              createdBy:
                                  "", // 🔹 Renamed created_by → createdBy
                              updatedBy:
                                  "", // 🔹 Renamed updated_by → updatedBy
                              applyDate: DateTime.now().toString(),
                            );

                            // Call the API to add request
                            int returnCode = await Api.addRequestForm(newData);
                            await Future.delayed(const Duration(seconds: 2));
                            statecontroller.toggleLoading(false);

                            if (returnCode == 200) {
                              Get.snackbar("Success!",
                                  "Data successfully inserted in Database!");
                              Api.sendEmail(
                                  to: 'abialigadi@gmail.com',
                                  subject: 'Request Received - OWS',
                                  text:
                                      "Afzal us Salam,\n\nYour request is received! Your request number is ${controller.reqId}.\n\nWassalam.",
                                  html: """
                                        <p>Afzal us Salam,</p>
                                        <p>Your request is received! Your request number is <strong>${controller.reqId}</strong>.</p>
                                        <p>Wassalam.</p>
                                        """);
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

  Widget _buildField2(String label, RxString rxValue,
      {double? height, bool? isEnabled}) {
    bool isDescription = height != null;
    SuperTooltipController tooltipController = SuperTooltipController();
    Timer? hoverTimer;

    return Obx(() {
      String? error = controller.validateField(label, rxValue.value);
      bool isEmpty = rxValue.value.trim().isEmpty;
      bool isValid = error == null && !isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height ?? 40,
            child: TextFormField(
              style: TextStyle(
                  letterSpacing: 0, fontWeight: FontWeight.w600, fontSize: 14),
              enabled: isEnabled ?? true,
              textInputAction: TextInputAction.done,
              cursorColor: Colors.brown,
              controller: TextEditingController(text: rxValue.value)
                ..selection =
                    TextSelection.collapsed(offset: rxValue.value.length),
              onChanged: (value) {
                rxValue.value = value;
                controller.validateForm();
              },
              textCapitalization: TextCapitalization.sentences,
              maxLines: isDescription ? 3 : 1,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: isValid
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                      )
                    : SuperTooltip(
                        elevation: 1,
                        showBarrier: false,
                        barrierColor: Colors.transparent,
                        controller: tooltipController,
                        arrowTipDistance: 10,
                        arrowTipRadius: 2,
                        arrowLength: 10,
                        borderColor: isEmpty
                            ? Colors.amber // ⚠️ Yellow for info
                            : Colors.red, // ❌ Red for error
                        borderWidth: 2,
                        backgroundColor: isEmpty
                            ? Colors.amber.withValues(alpha: 0.9) // ⚠️ Yellow
                            : Colors.red.withValues(alpha: 0.9), // ❌ Red
                        boxShadows: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.2), // Light shadow
                            blurRadius: 6,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                        content: Text(
                          isEmpty ? "This field is required" : error ?? "",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 12),
                        ),
                        child: Container(
                          padding:
                              const EdgeInsets.all(10), // ✅ Expands hover area
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent, // No background
                          ),
                          child: MouseRegion(
                            onEnter: (_) {
                              hoverTimer =
                                  Timer(const Duration(milliseconds: 300), () {
                                if (!tooltipController.isVisible) {
                                  tooltipController.showTooltip();
                                }
                              });
                            },
                            onExit: (_) {
                              hoverTimer
                                  ?.cancel(); // ✅ Prevent tooltip from showing if mouse leaves quickly
                              tooltipController.hideTooltip();
                            },
                            child: Icon(
                              isEmpty
                                  ? Icons.info_rounded
                                  : Icons.error_rounded,
                              color: isEmpty ? Colors.amber : Colors.red,
                              size: 24, // ✅ Keep icon size normal
                            ),
                          ),
                        ),
                      ),
                labelText: label,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey), // Grey border when disabled
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                filled: true,
                fillColor: (isEnabled ?? true)
                    ? const Color(0xfffffcf6)
                    : Colors.grey[
                        300], // Lighter color for disabled                //contentPadding: EdgeInsets.zero
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDropdown2({
    required String label,
    required Rxn<int> selectedValue,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
    required bool isEnabled,
  }) {
    SuperTooltipController tooltipController = SuperTooltipController();
    String? error = controller.validateDropdown(label, selectedValue);
    Timer? hoverTimer;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Obx(() => Container(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField2<int>(
                    style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    value: selectedValue.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      suffixIcon: error == null
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            )
                          : SuperTooltip(
                              elevation: 1,
                              barrierColor: Colors
                                  .transparent, // Keep it visible without dark overlay
                              controller: tooltipController,
                              arrowTipDistance: 10,
                              showBarrier: false,
                              arrowTipRadius: 2,
                              arrowLength: 10,
                              borderColor: Color(0xffE9D502),
                              borderWidth: 2,
                              backgroundColor:
                                  Color(0xffE9D502).withValues(alpha: 0.9),
                              boxShadows: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                      alpha: 0.2), // Light shadow color
                                  blurRadius: 6, // Soft blur effect
                                  spreadRadius: 2,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              content: Text(error,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12)),
                              child: MouseRegion(
                                onEnter: (_) {
                                  hoverTimer = Timer(
                                      const Duration(milliseconds: 300), () {
                                    if (!tooltipController.isVisible) {
                                      tooltipController.showTooltip();
                                    }
                                  });
                                },
                                onExit: (_) {
                                  hoverTimer
                                      ?.cancel(); // ✅ Prevent tooltip from showing if mouse leaves quickly
                                  tooltipController.hideTooltip();
                                },
                                child: Icon(
                                  Icons.error,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: Text(label),
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.brown),
                      filled: true,
                      enabled: isEnabled,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            width: 1,
                            color: Colors.brown), // Removes the border
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            width: 1, color: Colors.grey), // Removes the border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(width: 1, color: Colors.brown),
                      ),
                      fillColor: const Color(0xfffffcf6), // Background color
                      //contentPadding: EdgeInsets.zero
                      //contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                            color: Color(0xfffffcf6),
                            borderRadius: BorderRadius.circular(8))),
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
                    //disabledHint: Text("Select ${_getDisabledHint(label)}"),
                  ),
                ),
              ],
            ),
          )),
    ]);
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
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  fillColor: const Color(0xfffffcf6),
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
