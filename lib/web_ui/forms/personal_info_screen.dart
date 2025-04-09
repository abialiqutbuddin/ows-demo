import 'dart:io';
import 'package:ows/constants/multi_select_dropdown.dart';
import 'package:path/path.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../api/api.dart';
import '../../controller/forms/form_screen_controller.dart';
import '../../model/document.dart';

class FormScreenW extends StatefulWidget {
  const FormScreenW({super.key});

  @override
  State<FormScreenW> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreenW> {
  String itsId = '30445124';
  final FormController controller = Get.find<FormController>();
  final GlobalStateController gController = Get.find<GlobalStateController>();
  late SuperTooltipController tooltipControllers;

  final MultiSelectDropdownController dropdownController =
  Get.put(MultiSelectDropdownController());

  final List<DropdownOption> dropdownItems = [
    DropdownOption(displayName: 'Gas Stove'),
    DropdownOption(displayName: 'TV'),
    DropdownOption(displayName: 'Radio'),
    DropdownOption(displayName: 'Telephone / Mobile'),
    DropdownOption(displayName: 'Computer / Laptop'),
    DropdownOption(displayName: 'Animal Cart'),
    DropdownOption(displayName: 'Bicycle'),
    DropdownOption(displayName: 'Motorbike'),
    DropdownOption(displayName: 'Refrigerator'),
    DropdownOption(displayName: 'Washing Machine'),
    DropdownOption(displayName: 'Car'),
    DropdownOption(displayName: 'Truck'),
  ];

  // RxBool to track expanded state
  final RxBool isPersonalExpanded = false.obs;
  final RxBool isStudentExpanded = false.obs;
  final RxBool isFamilyExpanded = false.obs;
  final RxBool isOccupationExpanded = false.obs;
  final RxBool isKhidmatHrExpanded = false.obs;
  final RxBool isHousingExpanded = false.obs;
  final RxBool isDeeniInfoExpanded = false.obs;
  final RxBool isNutriInfoExpanded = false.obs;
  final RxBool isMedicalInfoExpanded = false.obs;
  final RxBool isExpensesInfoExpanded = false.obs;
  final RxBool isSourcesofIncome = false.obs;
  final bool isFCNIC = false;
  final bool isMCNIC = false;
  final RxInt selectedRadio = 0.obs; // Default: No radio selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          "Personal Information",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xfffffcf6),
      ),
      backgroundColor: Color(0xfffffcf6),
      body: ListView(
        children: [
          // _buildCollapsibleSection(
          //     "Personal Information", isPersonalExpanded, personalInfo,complete: controller.isPersonalInfoComplete),
          //
          // _buildCollapsibleSection(
          //     "Student Info", isStudentExpanded, studentInfo,complete: controller.isStudentInfoComplete),
          //
          _buildCollapsibleSection("Family Info", isFamilyExpanded, familyInfo, complete: controller.isFamilyInfoComplete),
          _buildCollapsibleSection("Housing Info", isHousingExpanded, housingInfo, complete: controller.isFamilyInfoComplete),
          _buildCollapsibleSection("Deeni Info", isDeeniInfoExpanded, deeniInfo, complete: controller.isFamilyInfoComplete),
          _buildCollapsibleSection("Nutrition Info", isNutriInfoExpanded, nutriInfo, complete: controller.isFamilyInfoComplete),
          _buildCollapsibleSection("Medical Info", isMedicalInfoExpanded, medicalInfo, complete: controller.isFamilyInfoComplete),
          _buildCollapsibleSection("Monthly Expences", isExpensesInfoExpanded, expensesInfo, complete: controller.isFamilyInfoComplete),
          _buildCollapsibleSection("Sources of Icome", isSourcesofIncome, incomeInfo, complete: controller.isFamilyInfoComplete),
          _buildCollapsibleSection(
              "Main Occupation", isOccupationExpanded, _mainOccupation2,
              complete: controller.isMainOccupationComplete),
          _buildCollapsibleSection(
              "Khidmat / HR", isKhidmatHrExpanded, khidmatHr,
              complete: controller.isKhidmatHrComplete),
          Obx(() => Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: (controller.isPersonalInfoComplete.value &&
                          controller.isStudentInfoComplete.value &&
                          controller.isFamilyInfoComplete.value)
                      ? () {
                          // Handle next action here
                          print("Next button clicked!");
                        }
                      : null, // Disabled if form is invalid
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.checkPersonalInfo()
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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  controller.selectedIndex.value = 1;
                });
                //Get.to(FinancialFormScreen());
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
  Widget _buildCollapsibleSection(
      String title, RxBool isExpanded, Widget Function() content,
      {RxBool? complete}) {
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
                      color:
                          complete!.value ? Colors.green : Colors.transparent,
                      width: 2)),
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

  // Widget personalInfo() {
  //   return Container(
  //     //padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
  //     margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       color: const Color(0xffffead1),
  //     ),
  //     child: Column(
  //       spacing: 15,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           spacing: 8,
  //           children: [
  //             Flexible(child: _buildField("SF No.", controller.sfNo)),
  //             Flexible(child: _buildField("HOF ITS", controller.hofIts)),
  //           ],
  //         ),
  //         Row(
  //           spacing: 8,
  //           children: [
  //             Flexible(
  //               child: _buildDropdown(
  //                 label: "Mohalla",
  //                 selectedValue: controller.selectedMohalla,
  //                 items: controller.mohalla,
  //                 onChanged: (value) {
  //                   controller.selectedMohalla.value = value!;
  //                   controller.selectedMohalla(value);
  //                   controller.mohallaName.value = controller.mohalla.firstWhere((e) =>
  //                   e["id"] == controller.selectedMohalla.value)["name"];
  //
  //                 },
  //                 isEnabled: true,
  //               ),
  //             ),
  //             Flexible(child: _buildField("Family Surname", controller.familySurname,function: () => controller.validatePersonalInfoFields())),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget studentInfo() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       color: const Color(0xffffead1),
  //     ),
  //     child: Column(
  //       spacing: 15,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           spacing: 8,
  //           children: [
  //             Flexible(child: _buildField("CNIC", controller.cnic,function: ()=> controller.validateStudentInfoFields())),
  //             Flexible(child: _buildField("Date of Birth", controller.dateOfBirth,function: ()=> controller.validateStudentInfoFields())),
  //             Flexible(child: _buildField("Full Name", controller.fullName,function: ()=> controller.validateStudentInfoFields())),
  //           ],
  //         ),
  //         Row(
  //           spacing: 8,
  //           children: [
  //             Flexible(child: _buildField("Mobile No.", controller.mobileNo,function: ()=> controller.validateStudentInfoFields())),
  //             Flexible(child: _buildField("WhatsApp No.", controller.whatsappNo,function: ()=> controller.validateStudentInfoFields())),
  //             Flexible(child: _buildField("Email", controller.email,function: ()=> controller.validateStudentInfoFields())),
  //           ],
  //         ),
  //         _buildField("Residential Address", controller.residentialAddress, height: 120,function: ()=> controller.validateStudentInfoFields()),
  //       ],
  //     ),
  //   );
  // }

  Widget incomeInfo() {
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
          Constants().buildDropdown2(label: 'Income type dropdown (HOF)', selectedValue: controller.sourcesInt, items: controller.sourcesofIcomeOption, onChanged: (value){}, isEnabled: true),
          Constants().buildField("Family Member Name", controller.familymemname, controller),
          Constants().buildField("Student Part time  (Misc. others)", controller.studentparttime, controller),
          radioAsk("Does any family member have a disability or chronic illness affecting earning capacity?", controller.shadi,field: Constants().buildField("Details", controller.spouseITS, controller,isEnabled: controller.isSpouseButtonEnabled.value)),
          radioAsk("Is any member of the household unemployed but capable of working?", controller.shadi,field: Constants().buildField("Details", controller.spouseITS, controller,isEnabled: controller.isSpouseButtonEnabled.value)),
        ],
      ),
    );
  }

  Widget deeniInfo() {
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
          radioAsk("Have you studied Kalemat-ul-shahadah and 7 Daim ul Islam in school/madrasa?", controller.Kalemat),
          radioAsk("Have you memorized names of Dai-al- Zaman TUS / Mazoon Saheb / Mukasir saheb?", controller.memorized),
          radioAsk("Does you offer in Sila Fitra / Vajebaat ? (Only HOF)", controller.waj),
          radioAsk("When have you latest attended misaq majlis to Dai-al-Zamaan TUS?", controller.misaq),
          radioAsk("Have you come to contact with any moharramaat – (prohibited activities)- Alcoholic substances/drugs/cigarette/Riba/ in your life?", controller.moharamat),
          radioAsk("Has he/she done ziyarat of Raudat Tahera ?", controller.zyarat),
          radioAsk("Does he/she attend all 9 days of Ashara Mubarakah punctually ?", controller.ashara,option1: 'All Days',option2: 'Few Days'),
          radioAsk("Does he/she pray Namaz daily ?", controller.namaz,option1: 'All Faraz',option2: 'Some Faraz'),
          radioAsk("Shadi?", controller.shadi,field: Constants().buildField("ITS of Spouse", controller.spouseITS, controller,isEnabled: controller.isSpouseButtonEnabled.value)),
        ],
      ),
    );
  }

  Widget medicalInfo() {
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
          radioAsk("Is there anyone who is physically or mental challenged in the house (HOF)", controller.Kalemat),
          radioAsk(
              "Has any child died in the past 5 years?",
              dropdown: Constants().buildDropdown2(
                  label: "Cause",
                  selectedValue: controller.causeInt,
                  items: controller.causeOptions,
                  onChanged: (value){},
                  isEnabled: controller.isChildDead.value),
              controller.memorized,
              option1: "Yes",
              option2: "No"),
          radioAsk("Are all children in the hiusehold taking/taken the required vaccinations? (HOF)", controller.memorized,option1: "Yes for 1 Time",option2: "Yes for 2 Times"),
          //radioAsk("Any Chronic (long term, incurable) illness?", controller.memorized,option1: "Yes for 1 Time",option2: "Yes for 2 Times"),
        ],
      ),
    );
  }

  Widget nutriInfo() {
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
          radioAsk("Are you taking FMB Thali? (HOF)", controller.Kalemat),
          radioAsk("Does the quantity suffice for the whole family? ", controller.memorized,option1: "Yes for 1 Time",option2: "Yes for 2 Times"),
          Constants().buildField(
              "BMI - Body Mass Index (HOF / Student)", controller.bmi, controller,)
        ],
      ),
    );
  }

  Widget radioAsk(String title,RxString value,{String option1 = 'Yes',String option2 = 'No',Widget? field,Widget? dropdown,String? option}){
    return Container(
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
            Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.brown),),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xfffffcf6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.brown, width: 1),
              ),
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _radioOption(option1, value,option: title),
                  _radioOption(option2, value,option: title),
                ],
              ),
            ),
            if(dropdown!=null)
              dropdown,
            if(field!=null)
              field
          ],
        ));
  }

  Widget housingInfo() {
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
          Row(
            children: [
              Flexible(
                child: Constants().buildDropdown2(
                    label: "House Title?",
                    selectedValue: controller.houseInt,
                    items: controller.houseTitleOptions,
                    onChanged: (value){},
                    isEnabled: true
                ),
              ),
              Flexible(
                child: Constants().buildDropdown2(
                    label: "Area of the house?",
                    selectedValue: controller.areaInt,
                    items: controller.houseAreaOptions,
                    onChanged: (value){},
                    isEnabled: true
                ),
              ),
              Flexible(
                child: Constants().buildDropdown2(
                    label: "House Neighbourhood?",
                    selectedValue: controller.neighborInt,
                    items: controller.neighborhoodOptions,
                    onChanged: (value){},
                    isEnabled: true
                ),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: Constants().buildDropdown2(
                    label: "Drinking Water?",
                    selectedValue: controller.drinkingInt,
                    items: controller.drinkingWaterOptions,
                    onChanged: (value){},
                    isEnabled: true
                ),
              ),
              Flexible(
                child: Constants().buildDropdown2(
                    label: "Sanitation (Bathroom / Tiolet)?",
                    selectedValue: controller.sanitationInt,
                    items: controller.sanitationOptions,
                    onChanged: (value){},
                    isEnabled: true
                ),
              ),
            ],
          ),
          radioAsk("Are all walls/ roof/ flooring structure made of natural or light materials? (i.e. mud, clay sand, cane, tree trunks, grass, bamboo, plastic,raw wood, stones, cardboard, tentetc", controller.selectedYes),
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

                  Text("How Many Assets Do You Have?", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown),),
                  MultiSelectDropdown(
                    options: dropdownItems,
                    controller: dropdownController,
                    hintText: "Choose Assets",
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _radioOption(String label, RxString controllerVariable,{String? option}) {
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
              print(label+value);
              if(option!= null && option=='Shadi?'){
                if (value == 'Yes') {
                  controller.isSpouseButtonEnabled.value = true;
                }else{
                  controller.isSpouseButtonEnabled.value = false;
                }
              }
              if(option=='Has any child died in the past 5 years?') {
                if (value == 'Yes') {
                  controller.isChildDead.value = true;
                } else {
                  controller.isChildDead.value = false;
                }
              }
            }),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ));
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
                  Row(
                    spacing: 8,
                    children: [
                      Flexible(
                          child: Constants().buildField(
                              "Name", controller.fatherName, controller,
                              function: () =>
                                  controller.validateFamilyInfoFields())),
                      Flexible(
                          child: Constants().buildField(
                              "CNIC", controller.fatherCnic, controller,
                              function: () =>
                                  controller.validateFamilyInfoFields())),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 170,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        //color: const Color(0xffffead1),
                        color: Color(0xfffffcf6)
                        //border: Border.all(color:Colors.grey,width: 1)
                        ),
                    child: uploadSection('father_cnic',
                        gController.user.value.itsId.toString(), '81'),
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
                  Row(
                    spacing: 8,
                    children: [
                      Flexible(
                          child: Constants().buildField(
                              "Name", controller.motherName, controller,
                              function: () =>
                                  controller.validateFamilyInfoFields())),
                      Flexible(
                          child: Constants().buildField(
                              "CNIC", controller.motherCnic, controller,
                              function: () =>
                                  controller.validateFamilyInfoFields())),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 170,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        //color: const Color(0xffffead1),
                        color: Color(0xfffffcf6)
                        //border: Border.all(color:Colors.grey,width: 1)
                        ),
                    child: uploadSection('mother_cnic',
                        gController.user.value.itsId.toString(), '81'),
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
                  Row(
                    spacing: 8,
                    children: [
                      Flexible(
                          child: Constants().buildField(
                              "Name", controller.guardianName, controller,
                              function: () =>
                                  controller.validateFamilyInfoFields())),
                      Flexible(
                          child: Constants().buildField(
                              "CNIC", controller.guardianCnic, controller,
                              function: () =>
                                  controller.validateFamilyInfoFields())),
                      Flexible(
                          child: Constants().buildField("Relation to Student",
                              controller.relationToStudent, controller,
                              function: () =>
                                  controller.validateFamilyInfoFields())),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget khidmatHr() {
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
            children: [
              Flexible(
                child: Row(
                  children: [
                    Obx(() => Radio(
                          value: 1,
                          groupValue: selectedRadio.value,
                          onChanged: (value) {
                            controller.tkm.value = '';
                            controller.shabab.value = '';
                            controller.umoor.value = '';
                            controller.dawat.value = '';
                            selectedRadio.value = value as int;
                          },
                        )),
                    Expanded(
                      child: Obx(() => Constants().buildField(
                            "Burhani Guards",
                            function: () => controller.validateKhidmatHr(),
                            controller.bgi,
                            controller,
                            isEnabled: selectedRadio.value == 1,
                          )),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  children: [
                    Obx(() => Radio(
                          value: 2,
                          groupValue: selectedRadio.value,
                          onChanged: (value) {
                            selectedRadio.value = value as int;
                            controller.shabab.value = '';
                            controller.umoor.value = '';
                            controller.dawat.value = '';
                            controller.bgi.value = '';
                          },
                        )),
                    Expanded(
                      child: Obx(() => Constants().buildField(
                            "Tolobatul Kulliyat",
                            function: () => controller.validateKhidmatHr(),
                            controller.tkm,
                            controller,
                            isEnabled: selectedRadio.value ==
                                2, // Enable when radio is checked
                          )),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  children: [
                    Obx(() => Radio(
                          value: 3,
                          groupValue: selectedRadio.value,
                          onChanged: (value) {
                            selectedRadio.value = value as int;
                            controller.tkm.value = '';
                            controller.shabab.value = '';
                            controller.dawat.value = '';
                            controller.bgi.value = '';
                          },
                        )),
                    Expanded(
                      child: Obx(() => Constants().buildField(
                            "12 Umoor",
                            function: () => controller.validateKhidmatHr(),
                            controller.umoor,
                            controller,
                            isEnabled: selectedRadio.value ==
                                3, // Enable when radio is checked
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: Row(
                  children: [
                    Obx(() => Radio(
                          value: 4,
                          groupValue: selectedRadio.value,
                          onChanged: (value) {
                            selectedRadio.value = value as int;
                            controller.tkm.value = '';
                            controller.umoor.value = '';
                            controller.dawat.value = '';
                            controller.bgi.value = '';
                          },
                        )),
                    Expanded(
                      child: Obx(() => Constants().buildField(
                            "Shabab",
                            function: () => controller.validateKhidmatHr(),
                            controller.shabab,
                            controller,
                            isEnabled: selectedRadio.value ==
                                4, // Enable when radio is checked
                          )),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  children: [
                    Obx(() => Radio(
                          value: 5,
                          groupValue: selectedRadio.value,
                          onChanged: (value) {
                            selectedRadio.value = value as int;
                            controller.tkm.value = '';
                            controller.shabab.value = '';
                            controller.umoor.value = '';
                            controller.bgi.value = '';
                          },
                        )),
                    Expanded(
                      child: Obx(() => Constants().buildField(
                            "Dawat Offices",
                            function: () => controller.validateKhidmatHr(),
                            controller.dawat,
                            controller,
                            isEnabled: selectedRadio.value ==
                                5, // Enable when radio is checked
                          )),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _mainOccupation2() {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Occupations",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
        ),
        Row(
          children: [
            Obx(() => Radio(
                  value: 1,
                  toggleable: true,
                  groupValue: controller.occupationInt.value,
                  onChanged: (value) {
                    if (value == null) {
                      controller.occupationInt.value = 0;
                    } else {
                      controller.occupationInt.value = value;
                      controller.validateOccupationsList();
                    }
                  },
                )),
            Text(
              "Student",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
        if (controller.occupationInt.value == 0)
          Obx(() => Column(
                spacing: 15,
                children: List.generate(controller.occupations.length, (index) {
                  RxString occupation =
                      controller.occupations[index]["occupation"];
                  RxString wordAddress =
                      controller.occupations[index]["workAddress"];
                  RxString workPhone =
                      controller.occupations[index]["workPhone"];

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 8,
                          children: [
                            Row(
                              spacing: 15,
                              children: [
                                Flexible(
                                  child: Constants().buildField(
                                      "Occupation", occupation, controller,
                                      function: () =>
                                          controller.validateOccupationsList()),
                                ),
                                Flexible(
                                  child: Constants().buildField(
                                      "Work Address", wordAddress, controller,
                                      function: () =>
                                          controller.validateOccupationsList()),
                                ),
                                Flexible(
                                  child: Constants().buildField(
                                      "Work Phone", workPhone, controller,
                                      function: () =>
                                          controller.validateOccupationsList()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.occupations.removeAt(index);
                          controller.validateOccupationsList();
                        },
                      ),
                    ],
                  );
                }),
              )),
        if (controller.occupationInt.value == 0)
          TextButton.icon(
            onPressed: () {
              bool allValid = controller.occupations.every((entry) =>
                  entry["occupation"].value.isNotEmpty &&
                  entry["workAddress"].value.isNotEmpty &&
                  entry["workPhone"].value.isNotEmpty);

              if (!allValid) {
                return;
              }
              controller.occupations.add({
                "occupation": "".obs,
                "workAddress": "".obs,
                "workPhone": "".obs
              });
              controller.validateOccupationsList();
            },
            icon: Icon(
              Icons.add,
              color: Colors.green,
              size: 20,
            ),
            label: Text(
              "Add Occupation",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget expensesInfo() {
    int total = (
        (int.tryParse(controller.asharaExpenses.value) ?? 0)
        + (int.tryParse(controller.wajebaatExpenses.value) ?? 0)
        + (int.tryParse(controller.niyazExpenses.value) ?? 0)
        + (int.tryParse(controller.sabeelExpenses.value) ?? 0)
        + (int.tryParse(controller.zyaratExpenses.value) ?? 0)
        + (int.tryParse(controller.qardanHasana.value) ?? 0)
        + (int.tryParse(controller.otherExpenses.value) ?? 0)
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Total: $total",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black)),
        Container(
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
                      "Expenses",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.brown),
                    ),
                    Row(
                      spacing: 15,
                      children: [
                        Flexible(child: Constants().buildField("Wajebaat / Khumus", controller.wajebaatExpenses, controller )),
                        Flexible(child: Constants().buildField("FMB Thaali / Niyaaz", controller.niyazExpenses, controller )),
                        Flexible(child: Constants().buildField("Jamaat Expenses /  sabeel", controller.sabeelExpenses, controller )),
                      ],
                    ),
                    Row(
                      spacing: 15,
                      children: [
                        Flexible(child: Constants().buildField("Ziyarat", controller.zyaratExpenses, controller )),
                        Flexible(child: Constants().buildField("Ashara Mubarakah", controller.asharaExpenses, controller )),
                        Flexible(child: Constants().buildField("Qardan Hasana", controller.qardanHasana, controller )),
                        Flexible(child: Constants().buildField("Others", controller.otherExpenses, controller )),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget uploadSection(String docType, String ITS, String reqId,
      {int numItems = 1}) {
    // Define specific names for multiple items if docType is "cNIC"
    List<String> docTypesList;
    if (docType == 'cNIC' && numItems == 2) {
      docTypesList = ['cNIC_front', 'cNIC_back'];
    } else {
      docTypesList = List.generate(numItems, (index) => "${docType}_$index");
    }

    return Column(
      children: docTypesList.map((specificDocType) {
        return Container(
          margin: EdgeInsets.symmetric(
              vertical: 8), // Adds spacing between sections
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xfffffcf6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GetX<GlobalStateController>(
                builder: (controller) {
                  var document = controller.documents[specificDocType];
                  if (document != null) {
                    return ListTile(
                      leading: Icon(
                        Icons.insert_drive_file,
                        size: 40,
                        color: Constants().green,
                      ),
                      title: Text(
                        basename(document.file!.path),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          Api.removeDocument(specificDocType);
                        },
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.upload_file_outlined,
                            size: 50,
                            color: Constants().green,
                          ),
                          onPressed: () async {
                            await _pickFile(specificDocType);
                            await Api.uploadDocument(
                                specificDocType, ITS, reqId);
                            //validateDocuments(specificDocType);
                          },
                        ),
                        Text(
                            "Click here to upload ${specificDocType.replaceAll('_', ' ').toUpperCase()}"),
                        Text(
                          "Supported Format: PDF",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickFile(String docType) async {
    // Check if a file is already picked for the docType, if yes, return
    if (gController.documents[docType] != null) {
      return;
    }

    // Use FilePicker to pick a single file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Allow only one file
      type: FileType
          .any, // You can specify specific types (e.g., FileType.custom) if needed
    );

    if (result != null) {
      // Get the file path of the selected file
      File selectedFile = File(result.files.single.path!);

      // Update the documents map with the picked file
      setState(() {
        gController.documents[docType] = Document(
            file: selectedFile,
            filePath: null); // Store the file object dynamically
      });
    } else {
      print("No file selected for $docType");
    }
  }
}
