import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/constants/constants.dart';

import '../../api/api.dart';
import '../../controller/state_management/state_manager.dart';

class ReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> formSections;
  final RxMap<String, RxString> textFields;
  final RxMap<String, Rxn<int>> dropdownFields;
  final Map<String, RxList<Map<String, dynamic>>> repeatableEntries;
  final Map<String, List<Map<String, dynamic>>> dropdownOptions;
  final void Function(String sectionKey)? onBackToEdit;

  ReviewScreen({
    super.key,
    required this.formSections,
    required this.textFields,
    required this.dropdownFields,
    required this.repeatableEntries,
    required this.dropdownOptions,
    this.onBackToEdit,
  });

  final RxBool isSubmitting = false.obs;
  final RxnInt submittedApplicationId = RxnInt();

  String getDropdownLabel(String key, int? id) {
    final options = dropdownOptions[key] ?? [];
    final match = options.firstWhereOrNull((opt) => opt['id'] == id);
    return match != null ? match['name'] : '';
  }

  Widget buildFieldBlock(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xfffffcf6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade100),
      ),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.brown,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildSection(Map<String, dynamic> section) {
    final title = section['title'] ?? 'Untitled';
    final List<dynamic> subSections = section['subSections'] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffffead1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
              if (onBackToEdit != null && submittedApplicationId.value == null)
                Padding(
                  padding: EdgeInsets.only(bottom: 10, right: 8),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // full red
                      foregroundColor:
                      Colors.white, // text and icon will be white
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      elevation: 0,
                    ),
                    onPressed: ()=> onBackToEdit!(section['key']),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: () => onBackToEdit!(section['key']),
                //   child: const Text(
                //     "Edit",
                //     style: TextStyle(
                //         fontWeight: FontWeight.bold, color: Colors.brown),
                //   ),
                // )
            ],
          ),
          const Divider(thickness: 1.5, color: Colors.white),
          ...subSections.map<Widget>((sub) {
            final subTitle = sub['title'] ?? '';
            final subKey = sub['key'];
            final fields = sub['fields'] ?? [];

            if (sub['type'] == 'repeatable') {
              final entries = repeatableEntries[subKey] ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subTitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        subTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ...entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.brown.shade100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: fields.map<Widget>((f) {
                          final key = f['key'];
                          final label = f['label'];
                          final type = f['type'];

                          if (type == 'dropdown') {
                            return buildFieldBlock(
                              label,
                              getDropdownLabel(
                                  f['itemsKey'], entry[key]?.value),
                            );
                          }

                          return buildFieldBlock(
                              label, entry[key]?.value ?? '');
                        }).toList(),
                      ),
                    );
                  }),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subTitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                    child: Text(
                      subTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                ...fields.map<Widget>((field) {
                  final key = field['key'];
                  final label = field['label'] ?? '';
                  final type = field['type'];

                  if (type == 'multiselect') {
                    final selectedItems = textFields[key]?.value ?? '';
                    final List<String> items =
                        selectedItems.split(',').map((e) => e.trim()).toList();

                    return buildFieldBlock(
                      label,
                      items.isNotEmpty ? items.join(', ') : 'None Selected',
                    );
                  }

                  if (type == 'repeatable') {
                    // 🛠 MINI REPEATABLE FIELD (NEW)
                    final miniEntries = repeatableEntries[key] ?? [];

                    if (miniEntries.isEmpty) {
                      return buildFieldBlock(label, "No entries added.");
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...miniEntries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.brown.shade100),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (field['fields'] ?? [])
                                  .map<Widget>((miniField) {
                                final miniKey = miniField['key'];
                                final miniLabel = miniField['label'];
                                final miniType = miniField['type'];

                                if (miniType == 'dropdown') {
                                  return buildFieldBlock(
                                    miniLabel,
                                    getDropdownLabel(miniField['itemsKey'],
                                        entry[miniKey]?.value),
                                  );
                                }
                                return buildFieldBlock(
                                  miniLabel,
                                  entry[miniKey]?.value ?? '',
                                );
                              }).toList(),
                            ),
                          );
                        }),
                      ],
                    );
                  }

                  if (type == 'dropdown') {
                    final selectedVal = dropdownFields[key]?.value;
                    final baseLabel =
                        getDropdownLabel(field['itemsKey'], selectedVal);

                    List<Widget> widgets = [
                      buildFieldBlock(label, baseLabel),
                    ];

                    if (field.containsKey('showTextFieldIf') &&
                        selectedVal == field['showTextFieldIf']) {
                      final textKey = field['textFieldKey'];
                      final linkedLabel = field['textFieldLabel'];
                      final linkedVal = textFields[textKey]?.value ?? '';
                      widgets.add(buildFieldBlock(linkedLabel, linkedVal));
                    }

                    if (field.containsKey('showDropdownIf') &&
                        selectedVal == field['showDropdownIf']) {
                      final dropdownKey = field['dropdownKey'];
                      final linkedLabel = field['dropdownLabel'];
                      final linkedVal = dropdownFields[dropdownKey]?.value;
                      final itemsKey = field['itemsKey2'];
                      widgets.add(buildFieldBlock(
                          linkedLabel, getDropdownLabel(itemsKey, linkedVal)));
                    }

                    return Column(children: widgets);
                  }

                  if (type == 'radio') {
                    final val = textFields[key]?.value ?? '';
                    List<Widget> widgets = [buildFieldBlock(label, val)];

                    if (field.containsKey('showTextFieldIf') &&
                        val == field['showTextFieldIf']) {
                      final textKey = field['textFieldKey'];
                      final linkedLabel = field['textFieldLabel'];
                      final linkedVal = textFields[textKey]?.value ?? '';
                      widgets.add(buildFieldBlock(linkedLabel, linkedVal));
                    }

                    if (field.containsKey('showDropdownIf') &&
                        val == field['showDropdownIf']) {
                      final dropdownKey = field['dropdownKey'];
                      final linkedLabel = field['dropdownLabel'];
                      final linkedVal = dropdownFields[dropdownKey]?.value;
                      final itemsKey = field['itemsKey'];
                      widgets.add(buildFieldBlock(
                          linkedLabel, getDropdownLabel(itemsKey, linkedVal)));
                    }

                    if (field.containsKey('conditional_value') &&
                        field.containsKey('condition_options') &&
                        field.containsKey('on_condition') &&
                        val == field['on_condition']) {
                      final nestedRadioKey = "${key}_conditional";
                      final nestedVal = textFields[nestedRadioKey]?.value ?? '';
                      widgets.add(buildFieldBlock(
                          field['conditional_value'], nestedVal));
                    }

                    return Column(children: widgets);
                  }

                  if (type == 'text') {
                    return buildFieldBlock(label, textFields[key]?.value ?? '');
                  }

                  return const SizedBox.shrink();
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Future<void> handleSubmit(BuildContext context) async {
    isSubmitting.value = true;

    try {
      // Simulate API
      await Future.delayed(const Duration(seconds: 2));
      final mockApplicationId = 123;

      submittedApplicationId.value = mockApplicationId;

      // ✅ Show success dialog
      showSubmissionSuccessDialog(context, mockApplicationId, () {
        Get.back(); // close dialog
        Get.offAllNamed('/home'); // 👈 navigate to your target route
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to submit application");
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffcf6),
      // appBar: AppBar(
      //   title: const Text("Review Your Application"),
      //   backgroundColor: Colors.brown.shade100,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () {
      //       Get.offAllNamed("/profile_preview_pdf");
      //     },
      //   ),
      //   centerTitle: true,
      // ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                  margin:
                  const EdgeInsets.only(top: 20.0, left: 15, bottom: 10),
                  child: Text(
                    "Imdaad Talimi Application Form",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black87),
                  )),
                  //headerProfile(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 10),

                    child: Column(
                      children: [
                        ...formSections
                            .where((section) => section['key'] != 'intendInfo')
                            .map(buildSection),
                        const SizedBox(height: 24),
                        if (submittedApplicationId.value == null)
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: isSubmitting.value
                                  ? null
                                  : () => handleSubmit(context),
                              icon: const Icon(Icons.send, color: Colors.white),
                              label: const Text("Submit Application",style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants().green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Set your desired radius
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 20),
                                textStyle:
                                const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        if (submittedApplicationId.value != null)
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  "Application Submitted!",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800),
                                ),
                                const SizedBox(height: 4),
                                Text("Application ID: ${submittedApplicationId.value}"),
                              ],
                            ),
                          ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isSubmitting.value)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.brown),
                ),
              )
          ],
        ),
      ),
    );
  }

  void showSubmissionSuccessDialog(
      BuildContext context, int applicationId, VoidCallback onClose) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: const Color(0xffffead1),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 50, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                "Application Submitted!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Your Application ID is: $applicationId",
                style: TextStyle(fontSize: 14, color: Colors.brown.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.check),
                label: const Text("OK"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  final GlobalStateController statecontroller =
  Get.find<GlobalStateController>();
  final double defSpacing = 8;


  Widget headerProfile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xfffff7ec),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
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
                  Api.fetchImage(statecontroller.user.value.imageUrl!),
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
                          statecontroller.user.value.fullName ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' | '),
                        Text(
                          statecontroller.user.value.itsId.toString(),
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
                                width: 600,
                                child: Text(
                                    statecontroller.user.value.address ?? '')),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.location_on_rounded),
                            Text(
                              statecontroller.user.value.jamiaat ?? '',
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
                            Text(statecontroller.user.value.dob ?? ''),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.calendar_month_rounded),
                            Text(
                                "${calculateAge(statecontroller.user.value.dob ?? '')} years old"),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.email),
                            Text(statecontroller.user.value.email!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(statecontroller.user.value.mobileNo!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(statecontroller.user.value.whatsappNo!),
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
    if (statecontroller.user.value.education == null ||
        statecontroller.user.value.education!.isEmpty) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Constants().subHeading("Last Education"),
          Divider(),
          Wrap(
            spacing: 20, // Space between items
            runSpacing: 10, // Space between lines when wrapped
            children: [
              buildEducationRow("Class/ Degree Program: ",
                  statecontroller.user.value.education![0].className),
              buildEducationRow("Institution: ",
                  statecontroller.user.value.education![0].institute),
              buildEducationRow("Field of Study: ",
                  statecontroller.user.value.education![0].subject),
              buildEducationRow(
                  "City: ", statecontroller.user.value.education![0].city),
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
      value = statecontroller.appliedByITS.value;
    } else {
      value = statecontroller.appliedByName.value;
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

}
