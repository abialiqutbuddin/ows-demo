import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/web_ui/application_forms/application_form_web.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../constants/constants.dart';
import '../../constants/dropdown_search.dart';
import '../../controller/futureEducationController.dart';
import '../../controller/state_management/state_manager.dart';
import '../../model/pakTalimFuture.dart';

class FutureEducationDialog extends StatefulWidget {
  final void Function(FutureFormData data) onSubmit;
  const FutureEducationDialog({required this.onSubmit, super.key});

  @override
  State<FutureEducationDialog> createState() => _StateFutureEducationDialog();
}

class _StateFutureEducationDialog extends State<FutureEducationDialog> {
  final FutureEducationController controller =
      Get.put(FutureEducationController());

  final GlobalStateController globalStateController =
  Get.find<GlobalStateController>();

  List<String> khidmatOptions = [
    "Select Khidmat",
    "Umoor Deeniyah (Religious Affairs)",
    "Umoor Talimiyah (Education)",
    "Umoor Marafiq Burhaniyah (Welfare)",
    "Umoor Mawarid Bashariyah (Human Resource)",
    "Umooor Maliyah (Budgeting and Accounts)",
    "Umoor Dakheliyah (Internal Affairs)",
    "Umoor Kharejiyah (Public Relations)",
    "Umoor al-Qaza (Legal Affairs)",
    "Umoor Faizul Mawaidil Burhaniyah",
    "Umoor Iqtesadiyah (Finance and Business Development)",
    "Umoor al-Amlaak (Waqf & Trust)",
    "Umoor al-Sehhat (Health)"
  ];

  List<String> hifzEnrolledOptions = [
    "None",
    "Mahad al Zahra",
    "Mukhayyam",
    "Online",
    "School/Madrassa",
    "Private",
    "Other"
  ];

  List<String> studyLocationOptions = [
    "Pakistan",
    "Abroad",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.loadCityAndCountryJson();
    controller.loadInstitutesJson();
    controller.loadCoursesJson(); // <-- Add this line
  }

  @override
  void dispose() {
    if (Get.isRegistered<FutureEducationController>()) {
      Get.delete<FutureEducationController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                spacing: 10,
                children: [
                  const Text("Future Education Form",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Obx(()=>
                     Visibility(
                      visible: globalStateController.user.value.hifzSanad == 'Hafiz' ? false : true,
                      child: Row(
                        spacing: 5,
                        children: [
                          Flexible(
                              child: _buildRadioGroup(
                                  "Hifz Niyat", controller.isHifzNiyat)),
                          Flexible(
                            child: _buildDropdown2(
                              label: "Niyat Hifz Enrolled",
                              selectedValue: Rxn<Map<String, dynamic>>(),
                              items: hifzEnrolledOptions
                                  .map((e) => {"id": e, "name": e})
                                  .toList(),
                              onChanged: (val) => controller.niyatHifzEnrolled.value =
                                  val?['name'] ?? '',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(()=>
                    Visibility(
                      visible: globalStateController.user.value.hifzSanad == 'Hafiz' ? false : true,
                      child: Row(
                        spacing: 5,
                        children: [
                          Flexible(
                              child: _buildRadioGroup(
                                  "Tilawat Niyat", controller.isTilawatNiyat)),
                          Obx(()
                           => Visibility(
                              visible: controller.isTilawatNiyat.value == 'Yes' ? true : false,
                              child: Flexible(
                                child: _buildDropdown2(
                                  label: "Tilawat Preferred Days",
                                  selectedValue: Rxn<Map<String, dynamic>>(),
                                  items: ['Everyday','Weekends','Weekdays','Sunday,''Monday','Tuesday','Wednesday','Thursday', 'Friday', 'Saturday']
                                      .map((e) => {"id": e, "name": e})
                                      .toList(),
                                  onChanged: (val) => controller
                                      .tilawatPreferredDays.value = val?['name'] ?? '',
                                ),
                              ),
                            ),
                          ),
                          Obx(()
                            => Visibility(
                              visible: controller.isTilawatNiyat.value == 'Yes' ? true : false,
                              child: Flexible(
                                child: _buildDropdown2(
                                  label: "Tilawat Preferred Timings",
                                  selectedValue: Rxn<Map<String, dynamic>>(),
                                  items: ['Morning','Afternoon', 'Evening', 'Night']
                                      .map((e) => {"id": e, "name": e})
                                      .toList(),
                                  onChanged: (val) => controller
                                      .tilawatPreferredTimings.value = val?['name'] ?? '',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Flexible(
                          child: _buildRadioGroup(
                              "Will Asbaaq", controller.willAsbaaq)),
                      Flexible(
                          child: _buildRadioGroup(
                              "Will Khidmat", controller.willKhidmat)),
                      Obx(
                        ()=> Visibility(
                          visible: controller.willKhidmat.value == 'Yes' ? true : false,
                          child: Flexible(
                            child: _buildDropdown2(
                              label: "Khidmat",
                              selectedValue: Rxn<Map<String, dynamic>>(),
                              items: khidmatOptions
                                  .map((e) => {"id": e, "name": e})
                                  .toList(),
                              onChanged: (val) =>
                                  controller.khidmat.value = val?['name'] ?? '',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildField2("Comments", controller.comments,
                      context: context, controller: controller),
                  const Divider(height: 10),
                  const Text("Study Details",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    spacing: 5,
                    children: [
                      Flexible(
                        child: _buildDropdown2(
                          label: "Study Location",
                          selectedValue: Rxn<Map<String, dynamic>>(),
                          items: studyLocationOptions
                              .map((e) => {"id": e, "name": e})
                              .toList(),
                          onChanged: (val) =>
                              controller.studyLocation.value = val?['name'] ?? '',
                        ),
                      ),
                      Flexible(
                        child: Obx(
                              () => CustomDropdownSearch<String>(
                            height: 50,
                            label: "City",
                            itemsLoader: (filter, _) async {
                              return controller.cities
                                  .map((e) =>
                              e['city_name'] as String)
                                  .toList();
                            },
                            selectedItem: controller.selectedCity.value?['city_name'], // Bind selected city
                            isEnabled: controller.cities
                                .isNotEmpty,
                            onChanged: (String? cityName) {
                              if (cityName != null) {
                                final selectedCityData = controller.cities.firstWhere(
                                      (city) => city['city_name'] == cityName,
                                  orElse: () => {
                                    "id": null
                                  },
                                );
                                print(selectedCityData);
                                controller.cityId.value = selectedCityData['city_id'].toString() ?? '';
                                controller.countryId.value = selectedCityData['country_id'].toString() ?? '';
                                controller.filterInstitutesByCity(int.tryParse(controller.cityId.value) ?? 0);
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
                            selectedItem: controller.selectedInstitute.value?['name'],
                            onChanged: (String? institute) {
                              if (institute != null) {
                                final selectedInstData = controller.filteredInstitutes.firstWhere(
                                      (city) => city['name'] == institute,
                                  orElse: () => {
                                    "id": null
                                  },
                                );
                                print(selectedInstData);
                                controller.institute.value =
                                    selectedInstData['id'].toString();
                              }
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        child: Obx(
                              () => CustomDropdownSearch<String>(
                            height: 50,
                            label: "Course",
                            itemsLoader: (filter, _) async {
                              return controller.courseList
                                  .map((e) => e['name'] as String)
                                  .toList();
                            },
                            selectedItem: controller.selectedCourse.value?['name'],
                            onChanged: (String? course) {
                              if (course != null) {
                                final selectedCourseData = controller.courseList.firstWhere(
                                      (city) => city['name'] == course,
                                  orElse: () => {
                                    "id": null
                                  },
                                );
                                print(selectedCourseData);
                                controller.selectedCourse.value = selectedCourseData;
                                controller.course.value = selectedCourseData['id'].toString();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Visibility(
                      visible: controller.studyLocation.value == 'Abroad'
                          ? true
                          : false,
                      child: Row(
                        spacing: 5,
                        children: [
                          Flexible(
                              child: _buildRadioGroup(
                                  "Relative Abroad", controller.relativeAbroad)),
                          Flexible(
                              child: _buildField2(
                                  "Relationship", controller.relationship,
                                  context: context, controller: controller)),
                          Flexible(
                              child: _buildField2(
                                  "Relationship ITS", controller.relationshipIts,
                                  context: context, controller: controller)),
                          Flexible(
                              child: _buildRadioGroup(
                                  "Stay Together", controller.stayTogether)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Constants().green, // ✅ Your custom green color
                      foregroundColor: Colors.white, // ✅ White text
                      padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8), // ✅ Rounded rectangle
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      final details = StudyDetail(
                        studyLocation: controller.studyLocation.value,
                        cityId: controller.cityId.value,
                        institute: controller.institute.value,
                        course: controller.course.value,
                        countryId: controller.countryId.value,
                        relativeAbroad: controller.relativeAbroad.value.isEmpty ? "0" : controller.relativeAbroad.value == "Yes" ? "1" : "0",
                        relationship: controller.relationship.value.isEmpty ? "None" : controller.relationship.value,
                        relationshipIts: controller.relationshipIts.value.isEmpty ? "00000000" : controller.relationshipIts.value,
                        stayTogether: controller.stayTogether.value.isEmpty ? "0" : controller.stayTogether.value == "Yes" ? "1" : "0",
                      );

                      final form = FutureFormData(
                        itsId: stateController.user.value.itsId.toString(),
                        isHafiz: "0",
                        isHifzNiyat: controller.isHifzNiyat.value == "Yes" ? "1" : "0",
                        currentHifzEnrolled: controller.niyatHifzEnrolled.value.isEmpty ? 'None' : controller.niyatHifzEnrolled.value,
                        niyatHifzEnrolled: controller.niyatHifzEnrolled.value.isEmpty ? 'None' : controller.niyatHifzEnrolled.value,
                        nextSanad: "1",
                        isQuranTilawat: controller.isTilawatNiyat.value == "Yes" ? "1" : "0",
                        sehatEraab: "0",
                        sehatHuroof: "0",
                        isTilawatNiyat:
                            controller.isTilawatNiyat.value == "Yes" ? "1" : "0",
                        tilawatPreferredDays: controller.tilawatPreferredDays.value.isEmpty ? 'None' : controller.tilawatPreferredDays.value,
                        tilawatPreferredTimings:
                            controller.tilawatPreferredTimings.value.isEmpty ? 'None' : controller.tilawatPreferredTimings.value,
                        attendedCounselling: "0",
                        comments: controller.comments.value,
                        willAsbaaq:
                            controller.willAsbaaq.value == "Yes" ? "1" : "0",
                        willKhidmat:
                            controller.willKhidmat.value == "Yes" ? "1" : "0",
                        khidmat: controller.khidmat.value.isEmpty ? "None" : controller.khidmat.value,
                        details: [details],
                      );

                      widget.onSubmit(form);
                      Navigator.pop(context);
                    },
                    child: const Text("Add Future Education"),
                  ),
                ],
              ),
            ),
            InstructionsWidget(instructionsKey: 'futureEducation',)
          ],
        ),
      ),
    );
  }

  Widget _buildRadioGroup(String label, RxString selectedValue) {
    return Obx(() => Row(
          children: [
            Text("$label: "),
            ...["Yes", "No"].map((option) => Row(
                  children: [
                    Radio<String>(
                      value: option,
                      groupValue: selectedValue.value,
                      onChanged: (val) => selectedValue.value = val!,
                    ),
                    Text(option),
                  ],
                )),
          ],
        ));
  }

  Widget _buildField2(String label, RxString rxValue,
      {double? height,
      bool? isEnabled,
      required BuildContext context,
      required dynamic controller}) {
    bool isDescription = height != null;
    SuperTooltipController tooltipController = SuperTooltipController();
    Timer? hoverTimer;

    return Obx(() {
      String? error = controller.validateField(label, rxValue.value);
      bool isEmpty = rxValue.value.trim().isEmpty;
      bool isValid = error == null && !isEmpty;
      bool isDateField = label.toLowerCase() == 'end year';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height ?? 50,
            child: TextFormField(
              readOnly: isDateField,
              style: const TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              enabled: isEnabled ?? true,
              textInputAction: TextInputAction.done,
              cursorColor: Colors.brown,
              controller: TextEditingController(text: rxValue.value)
                ..selection =
                    TextSelection.collapsed(offset: rxValue.value.length),
              // onTap: isDateField
              //     ? () async {
              //   final pickedDate = await showDatePicker(
              //     context: context,
              //     initialDate:
              //     DateTime.tryParse(rxValue.value) ?? DateTime.now(),
              //     firstDate: DateTime(1900),
              //     lastDate: DateTime(2100),
              //   );
              //   if (pickedDate != null) {
              //     final formattedDate =
              //     DateFormat('yyyy-MM-dd').format(pickedDate);
              //     rxValue.value = formattedDate;
              //     controller.validateForm();
              //   }
              // }
              //     : null,
              onChanged: (value) {
                rxValue.value = value;
                //controller.validateForm();
              },
              textCapitalization: TextCapitalization.sentences,
              maxLines: isDescription ? 3 : 1,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: isDateField
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.brown),
                        onPressed: () async {
                          // final pickedDate = await showDatePicker(
                          //   context: context,
                          //   initialDate: DateTime.tryParse(rxValue.value) ??
                          //       DateTime.now(),
                          //   firstDate: DateTime(1900),
                          //   lastDate: DateTime(2100),
                          // );
                          // if (pickedDate != null) {
                          //   final formattedDate =
                          //   DateFormat('yyyy-MM-dd').format(pickedDate);
                          //   rxValue.value = formattedDate;
                          //   controller.validateForm();
                          // }
                        },
                      )
                    : isValid
                        ? const Icon(
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
                            borderColor: isEmpty ? Colors.amber : Colors.red,
                            borderWidth: 2,
                            backgroundColor: isEmpty
                                ? Colors.amber.withValues(alpha: 0.9)
                                : Colors.red.withValues(alpha: 0.9),
                            boxShadows: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            content: Text(
                              isEmpty ? "This field is required" : error ?? "",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
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
                                  hoverTimer?.cancel();
                                  tooltipController.hideTooltip();
                                },
                                child: Icon(
                                  isEmpty
                                      ? Icons.info_rounded
                                      : Icons.error_rounded,
                                  color: isEmpty ? Colors.amber : Colors.red,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                labelText: label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                filled: true,
                fillColor: (isEnabled ?? true)
                    ? const Color(0xfffffcf6)
                    : Colors.grey[300],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDropdown2({
    required String label,
    required Rxn<Map<String, dynamic>> selectedValue,
    required List<Map<String, dynamic>> items,
    bool isEnabled = true,
    ValueChanged<Map<String, dynamic>?>? onChanged,
  }) {
    final tooltipController = SuperTooltipController();
    Timer? hoverTimer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final current = selectedValue.value;
          return DropdownButtonFormField<Map<String, dynamic>>(
            value: current,
            isExpanded: true,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.brown),
              filled: true,
              fillColor: isEnabled ? const Color(0xFFFFFCF6) : Colors.grey[300],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(width: 1, color: Colors.brown),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(width: 1, color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(width: 1, color: Colors.brown),
              ),
              suffixIcon: current != null
                  ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                  : SuperTooltip(
                      controller: tooltipController,
                      showBarrier: false,
                      barrierColor: Colors.transparent,
                      arrowTipDistance: 10,
                      arrowTipRadius: 2,
                      arrowLength: 10,
                      borderColor: Colors.amber,
                      borderWidth: 2,
                      backgroundColor: Colors.amber.withValues(alpha: 0.9),
                      boxShadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        )
                      ],
                      content: Text(
                        "$label is required",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
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
                          hoverTimer?.cancel();
                          tooltipController.hideTooltip();
                        },
                        child: const Icon(Icons.error, color: Colors.amber),
                      ),
                    ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: item,
                child: Text(item['name']),
              );
            }).toList(),
            onChanged: isEnabled
                ? (value) {
                    selectedValue.value = value;
                    if (onChanged != null) onChanged(value);
                  }
                : null,
          );
        }),
      ],
    );
  }
}
