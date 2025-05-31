import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/controller/update_paktalim_controller.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../constants/constants.dart';
import '../../constants/dropdown_search.dart';
import '../../model/member_model.dart';
import '../../model/update_paktalim_model.dart';
import '../application_forms/application_form_web.dart';
import 'class_selection.dart';
import 'education_caraousel.dart';
import 'package:intl/intl.dart'; // Needed for optional date formatting

class updatePakTalimForm {
  final UpdatePaktalimController controller =
      Get.find<UpdatePaktalimController>();
  final GlobalStateController globalStateController =
      Get.find<GlobalStateController>();

  RxString error = ''.obs;

  void showRequestDetailsPopup(BuildContext context,
      {String? institute,
      String? className,
      bool isEdit = false,
      int? marhalaId,
      String? city,
        String? endYear,
        String? duration,
        String? standard,
        String? course
      }) {
    //globalStateController.user.value = userProfile1;
    // if(isEdit == true){
    //
    // }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Adds rounded corners
          ),
          // Controls padding around the popup
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            // // 95% of screen width
            height: MediaQuery.of(context).size.height * 0.9,
            // 95% of screen height
            padding: const EdgeInsets.all(8),
            // Inner padding inside the dialog
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: isEdit
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FutureBuilder<Widget>(
                          future: updateEducation(
                            context,
                            isEdit: true,
                            className: className,
                            institute: institute,
                            marhalaId: marhalaId,
                            city: city,
                            duration: duration,
                            course: course,
                            standard: standard,
                            endYear: endYear
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else {
                              return snapshot.data!;
                            }
                          },
                        ),
                      ),
                      InstructionsWidget(instructionsKey: 'editEducation',)
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FutureBuilder<Widget>(
                          future: updateEducation(context),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text("Error: ${snapshot.error}"));
                            } else {
                              return snapshot.data!;
                            }
                          },
                        ),
                      ),
                      InstructionsWidget(instructionsKey: 'addEducation',)
                    ],
                  ),
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

  int? getIdByName(List<Map<String, dynamic>> list, String name) {
    final filtered = list.where(
      (element) =>
          element['name']?.toString().toLowerCase() == name.toLowerCase(),
    );
    if (filtered.isEmpty) return null;
    return filtered.first['id'] as int;
  }

  getLabel() {
    if (controller.selectedMarhala2.value?['id'] != null) {
      if (controller.selectedMarhala2.value?['id'] > 4) {
        return "Degree Program";
      }
    }
    return "Class";
  }

  getSubject() {
    if (controller.selectedMarhala2.value?['id'] != null) {
      if (controller.selectedMarhala2.value?['id'] > 4) {
        return "Course";
      }
    }
    return "Subject";
  }

  // Widget _buildClassGrid(){
  //   return
  // }

  Future<Widget> updateEducation(BuildContext context,
      {bool isEdit = false,
      int? marhalaId,
      String? institute,
      String? className,
      String? city,
      String? endYear,
      String? duration,
      String? standard,
      String? course}) async {
    controller.selectedClass.value = null;
    controller.selectedSubject1.value = null;
    controller.fieldOfStudy2.value = null;
    controller.selectedMarhala2.value = null;
    controller.selectedClass.value = null;
    controller.selectedInstituteName.value = null;
    controller.selectedCity.value = '';
    if (isEdit == true) {
      controller.selectedMarhala2.value =
          controller.getMarhalaById(controller.predefinedMarhalas, marhalaId!);
      controller.selectedMarhala.value = marhalaId;
      controller.selectedClass.value = null;
      controller.selectedSubject1.value = null;
      controller.fieldOfStudy2.value = null;
      controller.filteredClasses.value =
          controller.getClassesByMarhala(marhalaId);
      await filterStudyOptions(marhalaId);
      //print(controller.filteredClasses.value.f);
      Map<String, dynamic>? classx = controller.getClassByName(
          controller.filteredClasses.value, className!);
      controller.selectedClass.value = classx;
      final selectedCityData = controller.cities.firstWhere(
        (c) => c['name'] == city,
        orElse: () => {"id": null}, // Ensure it returns a valid default
      );
      controller.selectCity(selectedCityData["id"]);
      controller.updateCityAndCountryIds();
      controller.selectedCity.value = city!;
      controller.selectedInstituteName.value = institute ?? "";
      var selectedInstitute = controller.filteredInstitutes.firstWhere(
        (element) => element['name'] == institute,
        orElse: () => {},
      );
      controller.iId.value = selectedInstitute['id'].toString();
      controller.imani.value = selectedInstitute["is_imani"] == 0 ? "O" : "I";

      controller.edate.value = endYear!;

      final fieldName = standard;

      final fieldItems = controller.studyOptions
          .map((e) => {"id": e["id"], "name": e["name"]})
          .toList();

      final matchedField = fieldItems.firstWhere(
            (e) => e['name'].toString().toLowerCase() == fieldName?.toLowerCase(),
        orElse: () => {},
      );

      if (matchedField.isNotEmpty) {
        // IMPORTANT: use the *same object reference* from the list
        final originalItem = controller.studyOptions.firstWhere(
              (item) => item['id'] == matchedField['id'],
          orElse: () => {},
        );

        controller.fieldOfStudy2.value = originalItem;
        controller.sId.value = originalItem['id'].toString();

        controller.courseIndexPoint.value = null;

        controller.filterCourseOptions(originalItem['id']);

        // pass the numeric IDs into your filter functions
        final marhalaId = controller
            .selectedMarhala2.value?['id'] as int?;
        filterByMarhalaAndStudy(
          marhalaId,
          originalItem['id'] as int,
        );
        controller.filterFields(originalItem['id'] as int);

        await Future.delayed(Duration(milliseconds: 100)); // ensures courseOptions has time to update

        final subjectName = course;

        final courseMatch = controller.courseOptions.firstWhere(
              (item) => item['name'].toString().toLowerCase() == subjectName?.toLowerCase(),
          orElse: () => {},
        );

        if (courseMatch.isNotEmpty) {
          controller.selectedSubject1.value = courseMatch;
          controller.subId.value = [courseMatch['id'].toString()];
        }
      }

      final matchedDuration = controller.courseDurationOptions.firstWhere(
            (e) => e['id'] == 12,
        orElse: () => {},
      );

      if (matchedDuration.isNotEmpty) {
        controller.selectedCourseDuration.value = matchedDuration;
      }

    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            MarhalaEducationCarousel(
                controller: controller,
                globalStateController: globalStateController),
            Row(
              spacing: 8,
              children: [
                Flexible(
                  child: _buildDropdown2(
                    label: "Select Marhala",
                    selectedValue: controller.selectedMarhala2,
                    items: controller.predefinedMarhalas,
                    isEnabled: isEdit == true ? false : true,
                    onChanged: (value) {
                      controller.selectedMarhala.value = value!['id'];
                      controller.selectedClass.value = null;
                      controller.selectedSubject1.value = null;
                      controller.fieldOfStudy2.value = null;
                      // extract the numeric marhala ID from the selected map
                      final marhalaId =
                          controller.selectedMarhala2.value?['id'] as int?;
                      // get the classes for that marhala (or empty if none selected)
                      controller.filteredClasses.value = marhalaId != null
                          ? controller.getClassesByMarhala(marhalaId)
                          : <Map<String, dynamic>>[];
                      // 4) now load the new valid studies/courses
                      filterStudyOptions(value['id'] as int);
                    },
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
                                e['name'] as String) // Extract city names
                            .toList();
                      },
                      selectedItem:
                          controller.selectedCity.value, // Bind selected city
                      isEnabled: isEdit == true
                          ? false
                          : controller.cities
                              .isNotEmpty, // Enable only if cities are available
                      onChanged: (String? cityName) {
                        if (cityName != null) {
                          //controller.selectedCity.value = cityName;
                          // Find city ID based on name and update selectedCityId
                          final selectedCityData = controller.cities.firstWhere(
                            (city) => city['name'] == cityName,
                            orElse: () => {
                              "id": null
                            }, // Ensure it returns a valid default
                          );
                          controller.selectCity(selectedCityData["id"]);
                          controller.updateCityAndCountryIds();
                        }
                      },
                    ),
                  ),
                ),
                // Dropdown for selecting Class (filtered by Marhala)
              ],
            ),
            Row(
              spacing: 8,
              children: [
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
                      isEnabled: isEdit == true
                          ? false
                          : controller.selectedCity.value.isNotEmpty &&
                              controller.selectedCity.value != "Select City",
                      onChanged: (String? institute) {
                        controller.selectedInstituteName.value =
                            institute ?? "";

                        var selectedInstitute =
                            controller.filteredInstitutes.firstWhere(
                          (element) => element['name'] == institute,
                          orElse: () => {},
                        );

                        controller.iId.value =
                            selectedInstitute['id'].toString();
                        controller.imani.value =
                            selectedInstitute["is_imani"] == 0 ? "O" : "I";
                      },
                    ),
                  ),
                ),
                Obx(() {
                  final marhalaId = controller.selectedMarhala2.value?['id'];
                  if (marhalaId != 1) {
                    return Flexible(
                      child: Obx(() {
                        // extract the numeric marhala ID from the selected map
                        // final marhalaId =
                        //     controller.selectedMarhala2.value?['id'] as int?;
                        // // get the classes for that marhala (or empty if none selected)
                        // controller.filteredClasses.value = marhalaId != null
                        //     ? controller.getClassesByMarhala(marhalaId)
                        //     : <Map<String, dynamic>>[];

                        return _buildDropdown2(
                          label: getLabel(),
                          selectedValue: controller
                              .selectedClass, // Rxn<Map<String,dynamic>>
                          items: controller
                              .filteredClasses, // each has id, name, standard_id
                          isEnabled: isEdit == true ? false : marhalaId != null,
                          onChanged: (value) {
                            // value is the full map { "id":…, "name":…, "standard_id":… }
                            controller.selectedClass.value = value;
                            if (marhalaId != null &&
                                marhalaId < 4 &&
                                value != null) {
                              controller.sId.value =
                                  value['standard_id'].toString();
                            }
                          },
                        );
                      }),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ],
            ),
            Obx(() {
              var marhalaId2 = controller.selectedMarhala2.value?['id'];
              RxString classname = ''.obs;
              if (isEdit) {
                if (marhalaId == 2 || marhalaId == 3) {
                  marhalaId2 = 1;
                }
                classname.value = className!;
              }
              if (marhalaId2 == 1) {
                return isEdit
                    ? ClassSelectionWidget(
                        controller: controller, preselectedClassName: classname)
                    : ClassSelectionWidget(
                        controller: controller,
                      );
              } else {
                return const SizedBox.shrink();
              }
            }),
            Obx(
              () => Visibility(
                //visible: true,
                visible: controller.selectedMarhala2.value != null &&
                    controller.selectedMarhala2.value?["id"]! > 3,
                child: Row(
                  spacing: 10,
                  children: [
                    Flexible(
                      child: _buildDropdown2(
                          label: "Field of Study",
                          // Now holds the selected map, not just an int
                          selectedValue: controller.fieldOfStudy2,
                          items: controller.studyOptions,
                          isEnabled: true,
                          onChanged: (value) {
                            if (value != null) {
                              controller.sId.value = value['id'].toString();
                              controller.fieldOfStudy2.value = value;
                              controller.courseIndexPoint.value = null;
                              controller.filterCourseOptions(value['id']);
                              final marhalaId = controller
                                  .selectedMarhala2.value?['id'] as int?;
                              filterByMarhalaAndStudy(
                                marhalaId,
                                value['id'] as int,
                              );
                              controller.filterFields(value['id'] as int);
                            }
                          },
                        ),
                    ),
                    Flexible(
                      child: _buildDropdown2(
                          label: getSubject(),
                          selectedValue: controller.selectedSubject1,
                          items: controller.courseOptions,
                          //isEnabled: controller.fieldOfStudy.value != null,  // or whatever your enable logic is
                          onChanged: (value) {
                            if (value != null) {
                              controller.subId.value = [value['id'].toString()];
                              controller.selectedSubject1.value = value;
                            }
                          },
                        ),
                    ),
                  ],
                ),
              ),
            ),
            Row(spacing: 8, children: [
              Flexible(
                child: _buildField2(
                  "End Year",
                  controller.edate,
                  context: context,
                  controller: controller,
                ),
              ),
              Flexible(
                  child: _buildDropdown2(
                label: "Course Duration",
                isEnabled: controller.selectedMarhala.value != 1,
                selectedValue: controller.selectedCourseDuration,
                items: controller.courseDurationOptions, // List<{id,name}>
                onChanged: (value) {
                  // Keep selectedScholarship2 in sync
                  controller.selectedCourseDuration.value = value;
                },
              )),
            ]),
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
            Obx(() {
              return Column(
                spacing: 10,
                children: [
                  controller.scholarshipTaken.value == 'Yes'
                      ? Row(spacing: 8, children: [
                          Flexible(
                              child: _buildDropdown2(
                            label: "Qardan",
                            selectedValue: controller
                                .selectedQardan2, // Rxn<Map<String,dynamic>>
                            items: controller.qardanOptions, // List<{id,name}>
                            isEnabled: true,
                            onChanged: (value) {
                              // value is the full map { "id":…, "name":… }
                              controller.selectedQardan2.value = value;
                            },
                          )),

                          Flexible(
                              child: _buildDropdown2(
                            label: "Scholarship",
                            selectedValue: controller
                                .selectedScholarship2, // Rxn<Map<String,dynamic>>
                            items: controller
                                .scholarshipOptions, // List<{id,name}>
                            isEnabled: true,
                            onChanged: (value) {
                              // Keep selectedScholarship2 in sync
                              controller.selectedScholarship2.value = value;
                            },
                          )),
                          // Flexible(
                          //     child: Constants()
                          //         .buildField(
                          //         "Qardan:", controller.qardan, controller)),
                          // Flexible(
                          //     child: _buildField2("Scholarship", controller.scholar)),
                        ])
                      : SizedBox.shrink(),
                ],
              );
            }),
            Obx(() => Text(error.value)),
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  error.value = '';
                  // error.value = validateEducationEntry(
                  //   user: globalStateController.user.value,
                  //   marhalaId: int.parse(controller.selectedMarhala.value.toString()),
                  //   className: controller.selectedClass.value!['name'],
                  //   endDateStr: controller.edate.value,
                  //   durationMonths: controller.selectedCourseDuration.value!['id'],
                  // )!;

                  if (error.value.isEmpty) {
                    if (controller.selectedMarhala.value == 1) {
                      await controller.getProfileDataforMarhala1();
                      return;
                    }
                    await controller.getProfileData();
                  }
                },
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
                child: const Text("Update"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void printProfileData(UpdateProfileRequest data) {}

  String? validateEducationEntry({
    required UserProfile user,
    required int marhalaId,
    required String className,
    required String endDateStr, // full date e.g. "2024-06-15"
    required int durationMonths,
  }) {
    final educationList = user.education ?? [];

    final endDate = DateTime.tryParse(endDateStr);
    if (endDate == null) {
      return "Invalid end date format.";
    }

    final startDate = endDate.subtract(Duration(days: durationMonths * 30));

    // 1️⃣ Get previous education (same or lower marhala)
    final previousEdus = educationList
        .where(
            (e) => (e.marhalaId == marhalaId || e.marhalaId == marhalaId - 1))
        .where((e) => DateTime.tryParse(e.endDate ?? "") != null)
        .toList()
      ..sort((a, b) =>
          DateTime.parse(b.endDate!).compareTo(DateTime.parse(a.endDate!)));

    final previous = previousEdus.isNotEmpty ? previousEdus.first : null;
    if (previous != null) {}

    // 2️⃣ Get next education (next marhala)
    final nextEdus = educationList
        .where((e) => e.marhalaId == marhalaId + 1)
        .where((e) => DateTime.tryParse(e.startDate ?? "") != null)
        .toList()
      ..sort((a, b) =>
          DateTime.parse(a.startDate!).compareTo(DateTime.parse(b.startDate!)));

    final next = nextEdus.isNotEmpty ? nextEdus.first : null;
    if (next != null) {}

    // ✅ Rule: start must be after previous end
    final lastEnd = previous?.endDate;
    if (lastEnd != null && DateTime.parse(lastEnd).isAfter(startDate)) {
      return "Start date must be after previous education ends (${_formatDate(lastEnd)}).";
    }

    // ✅ Rule: end must be before next start
    final nextStart = next?.startDate;
    if (nextStart != null && endDate.isAfter(DateTime.parse(nextStart))) {
      return "End date must be before next education starts (${_formatDate(nextStart)}).";
    }

    return '';
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      return dateStr;
    }
  }

  Future<List<Map<String, dynamic>>> loadStudyData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonData = json.decode(response);
    return jsonData.cast<Map<String, dynamic>>();
  }

  Future<void> filterStudyOptions(int marhala) async {
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
              onTap: isDateField
                  ? () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.tryParse(rxValue.value) ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        final formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        rxValue.value = formattedDate;
                        controller.validateForm();
                      }
                    }
                  : null,
              onChanged: (value) {
                if (!isDateField) {
                  rxValue.value = value;
                  controller.validateForm();
                }
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
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse(rxValue.value) ??
                                DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            final formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            rxValue.value = formattedDate;
                            controller.validateForm();
                          }
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
