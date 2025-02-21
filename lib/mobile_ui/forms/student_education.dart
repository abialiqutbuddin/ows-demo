import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../controller/forms/form_screen_controller.dart';

class StudentEducation extends StatefulWidget {
  const StudentEducation({super.key});

  @override
  State<StudentEducation> createState() => _StudentEducationState();
}

class _StudentEducationState extends State<StudentEducation> {
  String itsId = '30445124';
  final FormController controller = Get.put(FormController());
  late SuperTooltipController tooltipControllers;

  @override
  void initState() {
    super.initState();
    //Api.fetchProxiedData(
    //  'https://paktalim.com/admin/ws_app/GetProfileEducation/${itsId}?access_key=8803c22b50548c9d5b1401e3ab5854812c4dcacb&username=40459629&password=1107865253');
  }

  // RxBool to track expanded state
  final RxBool isFinancialExpanded = false.obs;
  final RxBool isPersonalAssetsExpanded = false.obs;
  final RxBool isBusinessAssetExpanded = false.obs;
  final RxBool isFamilyEduExpanded = false.obs;
  final RxInt selectedRadio = 0.obs; // Default: No radio selected
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          "Financial Information",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xfffffcf6),
      ),
      backgroundColor: Color(0xfffffcf6),
      body: ListView(
        children: [
          _buildCollapsibleSection(
              "Student Education", isFinancialExpanded, studentEducation),
          //  _buildCollapsibleSection("Personal Assets", isPersonalAssetsExpanded, personalAssetsInfo),
          //_buildCollapsibleSection("Business Assets", isBusinessAssetExpanded, _businessAssetSection),
          //_buildCollapsibleSection("Family Education", isFamilyEduExpanded, _familyEducationSection),
          Obx(() => Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: controller.isButtonEnabled.value
                      ? () {
                          // Handle next action here
                        }
                      : null, // Disabled if form is invalid
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isButtonEnabled.value
                        ? Colors.brown
                        : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Next",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Icon(
                        Icons.navigate_next_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// **Function to build collapsible sections with animation**
  Widget _buildCollapsibleSection(
      String title, RxBool isExpanded, Widget Function() content) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xffffead1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  isExpanded.value = !isExpanded.value;
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.brown)),
                      ],
                    ),
                    Row(
                      children: [
                        AnimatedRotation(
                          turns: isExpanded.value
                              ? 0.5
                              : 0.0, // Rotates 180° when expanded
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            // Keep only one icon and rotate it
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 20, color: Colors.white, thickness: 2),
              AnimatedSize(
                alignment: Alignment.topCenter,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded.value ? content() : SizedBox.shrink(),
              ),
            ],
          ),
        ));
  }

  Widget studentEducation() {
    int index = 1;
    return Container(
      //padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffffead1),
      ),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                //color: const Color(0xffffead1),
                color: Color(0xffecdacc)
                //border: Border.all(color:Colors.grey,width: 1)
                ),
            child: Column(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Religious",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown),
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Deeni",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 6,
                            child: _buildField(
                                "Program", controller.personalIncome)),
                        Flexible(
                            flex: 3,
                            child:
                                _buildField("Year", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sabaq",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 6,
                            child: _buildField(
                                "Program", controller.personalIncome)),
                        Flexible(
                            flex: 3,
                            child:
                                _buildField("Year", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hifzul Quran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 6,
                            child: _buildField(
                                "Program", controller.personalIncome)),
                        Flexible(
                            flex: 3,
                            child:
                                _buildField("Year", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tilawatul Quran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 6,
                            child: _buildField(
                                "Program", controller.personalIncome)),
                        Flexible(
                            flex: 3,
                            child:
                                _buildField("Year", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                //_buildField("Other Family Income", controller.otherFamilyIncome),
                //_buildField("Student Income (Part Time)", controller.studentIncome),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                //color: const Color(0xffffead1),
                color: Color(0xffecdacc)
                //border: Border.all(color:Colors.grey,width: 1)
                ),
            child: Column(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "General",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown),
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Masters",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildField("Program", controller.personalIncome),
                    _buildField("Institute", controller.personalIncome),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 1,
                            child:
                                _buildField("Year", controller.personalIncome)),
                        Flexible(
                            flex: 1,
                            child: _buildField(
                                "Grade", controller.personalIncome)),
                        Flexible(
                            flex: 1,
                            child:
                                _buildField("CGPA", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                //_buildField("Personal Income", controller.personalIncome),
                //_buildField("Other Family Income", controller.otherFamilyIncome),
                //_buildField("Student Income (Part Time)", controller.studentIncome),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                //color: const Color(0xffffead1),
                color: Color(0xffecdacc)
                //border: Border.all(color:Colors.grey,width: 1)
                ),
            child: Column(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Other Certificationss",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown),
                ),
                Obx(() => Column(
                      children: List.generate(
                          controller.otherCertificationList.length, (index) {
                        RxString program =
                            controller.otherCertificationList[index]["program"];
                        RxString institute = controller
                            .otherCertificationList[index]["institute"];
                        RxString year =
                            controller.otherCertificationList[index]["year"];
                        RxString age =
                            controller.otherCertificationList[index]["age"];
                        RxString cgpa =
                            controller.otherCertificationList[index]["cgpa"];

                        return Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Container(
                                width: double.infinity,
                                child: Text(
                                  "${index + 1}.",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            _buildField("Program", program, isEnabled: true),
                            _buildField("Institute", institute,
                                isEnabled: true),
                            Row(
                              spacing: 5,
                              children: [
                                Flexible(
                                    flex: 5,
                                    child: _buildField("Year", year,
                                        isEnabled: true)),
                                Flexible(
                                    flex: 4,
                                    child: _buildField("Age", age,
                                        isEnabled: true)),
                                Flexible(
                                    flex: 4,
                                    child: _buildField("CGPA", cgpa,
                                        isEnabled: true)),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                controller.otherCertificationList
                                    .removeAt(index);
                              },
                            ),
                            //Divider(thickness: 1, color: Colors.brown),
                          ],
                        );
                      }),
                    )),
                TextButton.icon(
                  onPressed: () {
                    bool allValid = controller.otherCertificationList.every(
                        (entry) =>
                            entry["program"].value.isNotEmpty &&
                            entry["institute"].value.isNotEmpty &&
                            entry["year"].value.isNotEmpty &&
                            entry["age"].value.isNotEmpty &&
                            entry["cgpa"].value.isNotEmpty);
                    if (!allValid) {
                      return;
                    }
                    controller.otherCertificationList.add({
                      "program": "".obs,
                      "institute": "".obs,
                      "year": "".obs,
                      "grade": "".obs,
                      "age": "".obs,
                      "cgpa": "".obs,
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 20,
                  ),
                  label: Text(
                    "Add Certification",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // Column(
                //   spacing: 10,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text("1.",style: TextStyle(fontWeight: FontWeight.bold),),
                //     _buildField("Program", controller.personalIncome),
                //     _buildField("Institute", controller.personalIncome),
                //     Row(
                //       spacing: 5,
                //       children: [
                //         Flexible(flex: 1,child: _buildField("Year", controller.personalIncome)),
                //         Flexible(flex: 1,child: _buildField("Grade", controller.personalIncome)),
                //         Flexible(flex: 1,child: _buildField("CGPA", controller.personalIncome)),
                //       ],
                //     ),
                //     TextButton.icon(
                //       onPressed: () {
                //         bool allValid = controller.otherCertificationList.every((entry) =>
                //         entry["program"].value.isNotEmpty &&
                //             entry["institute"].value.isNotEmpty &&
                //             entry["year"].value.isNotEmpty &&
                //             entry["grade"].value.isNotEmpty &&
                //             entry["cgpa"].value.isNotEmpty);
                //         if (!allValid) {
                //           return;
                //         }
                //         controller.otherCertificationList.add({
                //           "program": "".obs,
                //           "institute": "".obs,
                //           "year": "".obs,
                //           "grade": "".obs,
                //           "cgpa": "".obs,
                //         });
                //       },
                //       icon: Icon(Icons.add,color: Colors.green,size: 20,),
                //       label: Text("Add Certification",style: TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),),
                //     ),
                //   ],
                // ),
                //_buildField("Personal Income", controller.personalIncome),
                //_buildField("Other Family Income", controller.otherFamilyIncome),
                //_buildField("Student Income (Part Time)", controller.studentIncome),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, RxString rxValue,
      {double? height, bool? isEnabled}) {
    bool isDescription = height != null;
    SuperTooltipController tooltipController = SuperTooltipController();

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
                    : GestureDetector(
                        onTap: () async {
                          if (!isValid && !isEmpty) {
                            await tooltipController.showTooltip();
                          }
                        },
                        child: SuperTooltip(
                          elevation: 1,
                          showBarrier: true,
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
                          toggleOnTap: true,
                          content: Text(
                            isEmpty ? "This field is required" : error ?? "",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                          child: Icon(
                            isEmpty
                                ? Icons.info_rounded // ⚠️ Yellow info icon
                                : Icons.error_rounded, // ❌ Red error icon
                            color: isEmpty ? Colors.amber : Colors.red,
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

  Widget _buildDropdown({
    required String label,
    required Rxn<int> selectedValue,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
    required bool isEnabled,
  }) {
    SuperTooltipController tooltipController = SuperTooltipController();
    String? error = controller.validateDropdown(label, selectedValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => DropdownButtonFormField2<int>(
              value: selectedValue.value,
              decoration: InputDecoration(
                suffixIcon: error == null
                    ? SizedBox.shrink()
                    : GestureDetector(
                        onTap: () async {
                          await tooltipController.showTooltip();
                        },
                        child: SuperTooltip(
                          elevation: 1,
                          //showBarrier: true, // Allows tapping outside to close
                          barrierColor: Colors
                              .transparent, // Keep it visible without dark overlay
                          showBarrier: true,
                          controller: tooltipController,
                          arrowTipDistance: 10,
                          arrowTipRadius: 2,
                          arrowLength: 10,
                          borderColor: Color(0xffE9D502),
                          borderWidth: 2,
                          backgroundColor:
                              Color(0xffE9D502).withValues(alpha: 0.9),
                          boxShadows: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.2), // Light shadow color
                              blurRadius: 6, // Soft blur effect
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                          toggleOnTap: true,
                          content: Text(error,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12)),
                          child: Icon(
                            Icons.error,
                            color: Color(0xffE9D502),
                          ),
                        ),
                      ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                label: Text(label),
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      width: 1, color: Colors.brown), // Removes the border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              dropdownStyleData: DropdownStyleData(
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
            )),
      ],
    );
  }
}
