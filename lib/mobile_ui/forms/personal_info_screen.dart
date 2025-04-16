import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/api/api.dart';
import 'package:ows/constants/constants.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../controller/forms/form_screen_controller.dart';
import '../../web_ui/forms/application_form_web.dart';
import 'financials.dart';

class FormScreenM extends StatefulWidget {
  const FormScreenM({super.key});

  @override
  State<FormScreenM> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreenM> {
  String itsId = '30445124';
  final FormController controller = Get.find<FormController>();
  late SuperTooltipController tooltipControllers;

  // RxBool to track expanded state
  final RxBool isPersonalExpanded = false.obs;
  final RxBool isStudentExpanded = false.obs;
  final RxBool isFamilyExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text("Personal Information",style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xfffffcf6),
      ),
      backgroundColor: Color(0xfffffcf6),
      body: ListView(
        children: [
          _buildCollapsibleSection(
              "Personal Information", isPersonalExpanded, personalInfo,complete: controller.isPersonalInfoComplete),
          _buildCollapsibleSection(
              "Student Info", isStudentExpanded, studentInfo,complete: controller.isStudentInfoComplete),
          _buildCollapsibleSection("Family Info", isFamilyExpanded, familyInfo,complete: controller.isFamilyInfoComplete),
          Obx(() => Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: (controller.isPersonalInfoComplete.value && controller.isStudentInfoComplete.value && controller.isFamilyInfoComplete.value) ? () {
                // Handle next action here
                print("Next button clicked!");
              } : null, // Disabled if form is invalid
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.checkPersonalInfo() ? Colors.brown : Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Next",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Icon(Icons.navigate_next_rounded,color: Colors.white,size: 24,)
                ],
              ),
            ),
          )),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Get.to(FinancialFormScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Go Next (Enabled for testing)",
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
          ),
        ],
      ),
    );
  }

  /// **Function to build collapsible sections with animation**
  Widget _buildCollapsibleSection(String title, RxBool isExpanded, Widget Function() content,{RxBool? complete}) {
    //bool isValid = controller.validatePersonalInfoFields();
    return Obx(() => Stack(
      children: [
        Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xffffead1),
                border: Border.all(
                  color: complete!.value ? Colors.green : Colors.transparent,
                  width: 2
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      isExpanded.value =
                          !isExpanded.value; // Toggle expand/collapse
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.brown)),
                        AnimatedRotation(
                          turns: isExpanded.value
                              ? 0.5
                              : 0.0, // Rotates 180° when expanded
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Icon(
                            Icons
                                .keyboard_arrow_down, // Keep only one icon and rotate it
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 10, color: Colors.white, thickness: 2),
                  AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isExpanded.value ? content() : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        if (complete.value)
          Positioned(
            top: 0,
            right: 25,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Text(
                "Completed",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    ));
  }



  Widget personalInfo() {
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
            Row(
              spacing: 8,
              children: [
                Flexible(child: _buildField("SF No.", controller.sfNo)),
                Flexible(child: _buildField("HOF ITS", controller.hofIts)),
              ],
            ),
            _buildDropdown(
              label: "Mohalla",
              selectedValue: controller.selectedMohalla,
              items: controller.mohalla,
              onChanged: (value) {
                controller.selectedMohalla.value = value!;
                controller.selectedMohalla(value);
                controller.mohallaName.value = controller.mohalla.firstWhere((e) =>
                e["id"] == controller.selectedMohalla.value)["name"];

              },
              isEnabled: true,
            ),
            _buildField("Family Surname", controller.familySurname,function: () => controller.validatePersonalInfoFields()),
          ],
        ),
    );
  }

  Widget studentInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffffead1),
      ),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField("Full Name", controller.fullName,function: ()=> controller.validateStudentInfoFields()),
          _buildField("CNIC", controller.cnic,function: ()=> controller.validateStudentInfoFields()),
          _buildField("Date of Birth", controller.dateOfBirth,function: ()=> controller.validateStudentInfoFields()),
          Row(
            spacing: 8,
            children: [
              Flexible(child: _buildField("Mobile No.", controller.mobileNo,function: ()=> controller.validateStudentInfoFields())),
              Flexible(child: _buildField("WhatsApp No.", controller.whatsappNo,function: ()=> controller.validateStudentInfoFields())),
            ],
          ),
          _buildField("Email", controller.email,function: ()=> controller.validateStudentInfoFields()),
          _buildField("Residential Address", controller.residentialAddress, height: 120,function: ()=> controller.validateStudentInfoFields()),
        ],
      ),
    );
  }

  Widget familyInfo() {
    return Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 15,
                children: [
                  Text(
                    "Father",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.brown),
                  ),
                  _buildField("Name", controller.fatherName,function: ()=> controller.validateFamilyInfoFields()),
                  _buildField("CNIC", controller.fatherCnic,function: ()=> controller.validateFamilyInfoFields()),
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        //color: const Color(0xffffead1),
                        color: Color(0xfffffcf6)
                        //border: Border.all(color:Colors.grey,width: 1)
                        ),
                    child: Icon(Icons.upload_file_outlined,size: 50,color: Constants().green,),
                  ),

                ],
              )),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  //color: const Color(0xffffead1),
                  color: Color(0xffecdacc)
                  //border: Border.all(color:Colors.grey,width: 1)
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 15,
                children: [
                  Text(
                    "Mother",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.brown),
                  ),
                  _buildField("Name", controller.motherName,function: ()=> controller.validateFamilyInfoFields()),
                  _buildField("CNIC", controller.motherCnic,function: ()=> controller.validateFamilyInfoFields()),
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        //color: const Color(0xffffead1),
                        color: Color(0xfffffcf6)
                      //border: Border.all(color:Colors.grey,width: 1)
                    ),
                    child: Icon(Icons.upload_file_outlined,size: 50,color: Constants().green,),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  //color: const Color(0xffffead1),
                  color: Color(0xffecdacc)
                  //border: Border.all(color:Colors.grey,width: 1)
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 15,
                children: [
                  Text(
                    "Guardian",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.brown),
                  ),
                  _buildField("Name", controller.guardianName,function: ()=> controller.validateFamilyInfoFields()),
                  _buildField("CNIC", controller.guardianCnic,function: ()=> controller.validateFamilyInfoFields()),
                  _buildField("Relation to Student", controller.relationToStudent,function: ()=> controller.validateFamilyInfoFields()),
                ],
              )),
        ],
      ),
    );
  }


  Widget _buildField(String label, RxString rxValue, {double? height, Function()? function}) {
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
              textInputAction: TextInputAction.done,
              cursorColor: Colors.brown,
              controller: TextEditingController(text: rxValue.value)
                ..selection = TextSelection.collapsed(offset: rxValue.value.length),
              onChanged: (value) {
                rxValue.value = value;
                controller.validateForm();
                function?.call();  // Call function safely
                //controller.validatePersonalInfoFields();
              },
              textCapitalization: TextCapitalization.sentences,
              maxLines: isDescription ? 3 : 1,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: isValid ? Icon(Icons.check_circle_rounded,color: Colors.green,) : GestureDetector(
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
                        color: Colors.black.withValues(alpha: 0.2), // Light shadow
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                    toggleOnTap: true,
                    content: Text(
                      isEmpty ? "This field is required" : error ?? "",
                      style: const TextStyle(color: Colors.black, fontSize: 12),
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
                labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                filled: true,
                fillColor: const Color(0xfffffcf6),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                backgroundColor: Color(0xffE9D502).withValues(alpha: 0.9),
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
                  color: Colors.amber,
                ),
              ),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            label: Text(label),
            labelStyle: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.brown),
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
            fillColor: const Color(0xfffffcf6), // Background color
            //contentPadding: EdgeInsets.zero
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
