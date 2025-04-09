import 'dart:async';
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/controller/update_paktalim_controller.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../api/api.dart';
import '../constants/constants.dart';
import '../constants/dropdown_search.dart';
import '../model/update_paktalim_model.dart';

class updatePakTalimForm {
  final UpdatePaktalimController controller =
      Get.find<UpdatePaktalimController>();
  final GlobalStateController globalStateController =
      Get.find<GlobalStateController>();

  void showRequestDetailsPopup(BuildContext context) {
    //globalStateController.user.value = userProfile1;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Adds rounded corners
          ),
          insetPadding: const EdgeInsets.all(20),
          // Controls padding around the popup
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            // 95% of screen width
            height: MediaQuery.of(context).size.height * 0.65,
            // 95% of screen height
            padding: const EdgeInsets.all(16),
            // Inner padding inside the dialog
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: updateEducation(),
          ),
        );
      },
    );
  }

  Widget _radioOption(String label, RxString controllerVariable) {
    return Obx(() => Row(
          spacing: 5,
          children: [
            SizedBox(
              width: 15,
            ),
            Radio<String>(
                value: label,
                groupValue: controllerVariable.value,
                onChanged: (value) {
                  controllerVariable.value = value!;
                }),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }

  Widget updateEducation() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: 450,
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              Flexible(
                child: _buildDropdown2(
                  label: "Select Marhala",
                  selectedValue: controller.selectedMarhala,
                  // Using Rxn<int>
                  items: List.generate(7, (index) => index + 1)
                      .map((marhala) =>
                          {"id": marhala, "name": "Marhala $marhala"})
                      .toList(),
                  onChanged: (value) {
                    controller.selectedMarhala.value = value;
                    controller.resetFields();
                    controller.classId = Rxn<int>();
                    filterStudyOptions(value!);
                  },
                  isEnabled: true,
                ),
              ),
              // Dropdown for selecting Class (filtered by Marhala)
              Flexible(
                child: Obx(() {
                  List<Map<String, dynamic>> filteredClasses = controller
                      .getClassesByMarhala(controller.selectedMarhala.value);
                  return _buildDropdown2(
                    label: "Select Class",
                    selectedValue: controller.classId,
                    items: filteredClasses,
                    onChanged: (value) {
                      controller.classId.value = value;
                      if (controller.selectedMarhala.value! > 0 &&
                          controller.selectedMarhala.value! < 4) {
                        controller.sId.value = filteredClasses
                            .firstWhere(
                              (element) => element['id'] == value,
                              orElse: () => {},
                            )['standard_id']
                            .toString();
                      }
                    },
                    isEnabled: controller.selectedMarhala.value != null,
                  );
                }),
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Flexible(
                child: Obx(
                  () => CustomDropdownSearch<String>(
                    height: 50,
                    label: "City",
                    itemsLoader: (filter, _) async {
                      return controller.cities
                          .map((e) => e['name'] as String) // Extract city names
                          .toList();
                    },
                    selectedItem:
                        controller.selectedCity.value, // Bind selected city
                    isEnabled: controller.cities
                        .isNotEmpty, // Enable only if cities are available
                    onChanged: (String? cityName) {
                      if (cityName != null) {
                        //controller.selectedCity.value = cityName;
                        // Find city ID based on name and update selectedCityId
                        final selectedCityData = controller.cities.firstWhere(
                          (city) => city['name'] == cityName,
                          orElse: () =>
                              {"id": null}, // Ensure it returns a valid default
                        );
                        controller.selectCity(selectedCityData["id"]);
                        controller.updateCityAndCountryIds();
                      }
                    },
                  ),
                ),
              ),
              Flexible(
                child: Obx(
                  () => CustomDropdownSearch<String>(
                    height: 50,
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
                      controller.selectedInstituteName.value = institute ?? "";

                      var selectedInstitute =
                          controller.filteredInstitutes.firstWhere(
                        (element) => element['name'] == institute,
                        orElse: () => {},
                      );

                      controller.iId.value = selectedInstitute['id'].toString();
                      controller.imani.value =
                          selectedInstitute["is_imani"] == 0 ? "O" : "I";
                    },
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              //visible: true,
              visible: controller.selectedMarhala.value != null &&
                  controller.selectedMarhala.value! > 3,
              child: Row(
                spacing: 10,
                children: [
                  Flexible(
                      child: Obx(
                    () => _buildDropdown2(
                      label: "Field of Study",
                      selectedValue: controller.fieldOfStudyIndex,
                      items: [
                        ...controller.studyOptions
                            .map((e) => {"id": e["id"], "name": e["name"]})
                      ],
                      onChanged: (value) {
                        controller.sId.value = value.toString();
                        controller.fieldOfStudyIndex.value = value;
                        controller.courseIndexPoint.value = null;
                        filterByMarhalaAndStudy(
                            controller.selectedMarhala.value,
                            controller.fieldOfStudyIndex.value);
                        controller.filterFields(value!);
                      },
                      isEnabled: true,
                    ),
                  )),
                  Flexible(
                    child: Obx(
                      () => _buildDropdown2(
                        label: "Subject",
                        selectedValue: controller.courseIndexPoint,
                        items: [
                          ...controller.courseOptions
                              .map((e) => {"id": e["id"], "name": e["name"]})
                        ],
                        onChanged: (value) {
                          controller.subId.value = [value.toString()];
                          controller.courseIndexPoint.value = value;
                        },
                        isEnabled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            spacing: 8,
            children: [
              Text(
                "Scholarship Taken",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              _radioOption("Yes", controller.scholarshipTaken),
              _radioOption("No", controller.scholarshipTaken),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Flexible(child: Constants().buildField("Qardan:", controller.qardan, controller)),
              Flexible(child: _buildField2("Scholarship", controller.scholar)),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Flexible(child: _buildField2("Start Date:", controller.sdate)),
              Flexible(child: _buildField2("End Date:", controller.edate)),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              controller.submitForm();
              // UpdateProfileRequest profileData = await controller.getProfileData();
              //
              // printProfileData(profileData);
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  void printProfileData(UpdateProfileRequest data) {
    print("===== Profile Data =====");
    print("P ID: ${data.pId}");
    print("ITS ID: ${data.itsId}");
    print("M ID: ${data.mId}");
    print("J ID: ${data.jId}");
    print("C ID: ${data.cId}");
    print("City ID: ${data.cityId}");
    print("Imani: ${data.imani}");
    print("I ID: ${data.iId}");
    print("Sub ID: ${data.subId}");
    print("Scholarship Taken: ${data.scholarshipTaken}");
    print("Qardan: ${data.qardan}");
    print("Cert: ${data.cert}");
    print("Scholar: ${data.scholar}");
    print("Class ID: ${data.classId}");
    print("S ID: ${data.sId}");
    print("E-Date: ${data.edate}");
    print("S-Date: ${data.sdate}");
    print("Duration: ${data.duration}");
    print("========================");
  }

  Future<List<Map<String, dynamic>>> loadStudyData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonData = json.decode(response);
    return jsonData.cast<Map<String, dynamic>>();
  }

  void filterStudyOptions(int marhala) async {
    print(marhala);
    List<Map<String, dynamic>> data = await loadStudyData();
    Map<int, String> uniqueStudies = {};

    for (var item in data) {
      if (item['marhala_id'] == marhala) {
        uniqueStudies[item['study_id']] = item['study'];
      }
    }

    List<Map<String, dynamic>> newStudyOptions = uniqueStudies.entries
        .map((e) => {"id": e.key, "name": e.value})
        .toList();

    controller.studyOptions.value = newStudyOptions;
  }

  Future<void> filterByMarhalaAndStudy(int? marhalaId, int? studyId) async {
    // **Check if inputs are null**
    if (marhalaId == null || studyId == null) {
      controller.courseOptions.value = [];
    }

    try {
      // Load JSON data
      final String response = await rootBundle.loadString('assets/data.json');
      final List<dynamic> jsonData = json.decode(response);

      // Convert to List<Map<String, dynamic>>
      List<Map<String, dynamic>> data = jsonData.cast<Map<String, dynamic>>();

      // Filter items based on marhala_id and study_id, ensuring non-null values
      List<Map<String, dynamic>> filteredList = data
          .where((item) =>
              (item['marhala_id'] ?? -1) == marhalaId &&
              (item['study_id'] ?? -1) == studyId)
          .toList();

      // Extract only 'id' and 'name'
      List<Map<String, dynamic>> result =
          filteredList.map((e) => {"id": e["id"], "name": e["name"]}).toList();

      // Debugging output

      controller.courseOptions.value = result;
    } catch (e) {
      controller.courseOptions.value = [];
    }
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
            height: height ?? 50,
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
                            : Colors.red,
                        // ❌ Red for error
                        borderWidth: 2,
                        backgroundColor: isEmpty
                            ? Colors.amber.withValues(alpha: 0.9) // ⚠️ Yellow
                            : Colors.red.withValues(alpha: 0.9),
                        // ❌ Red
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
                    : Colors.grey[300],
                // Lighter color for disabled                //contentPadding: EdgeInsets.zero
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
    String? error = '';
    //    controller.validateDropdown(label, selectedValue);
    Timer? hoverTimer;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Obx(() => SizedBox(
            height: 50,
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
                      suffixIcon: selectedValue.value != null
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            )
                          : SuperTooltip(
                              elevation: 1,
                              barrierColor: Colors.transparent,
                              // Keep it visible without dark overlay
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
                    items: items
                        .map((item) => DropdownMenuItem<int>(
                              value: item['id'],
                              child: Text(item['name']),
                            ))
                        .toList(),
                    //
                    onChanged: isEnabled
                        ? (value) {
                            selectedValue.value = value;
                            onChanged(value);
                            //controller.validateForm();
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
}
