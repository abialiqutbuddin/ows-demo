import 'dart:io';
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
import '../../mobile_ui/forms/financials.dart';
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

  // RxBool to track expanded state
  final RxBool isPersonalExpanded = false.obs;
  final RxBool isStudentExpanded = false.obs;
  final RxBool isFamilyExpanded = false.obs;
  final RxBool isOccupationExpanded = false.obs;
  final RxBool isKhidmatHrExpanded = false.obs;
  final bool isFCNIC = false;
  final bool isMCNIC = false;
  final RxInt selectedRadio = 0.obs; // Default: No radio selected

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
          // _buildCollapsibleSection(
          //     "Personal Information", isPersonalExpanded, personalInfo,complete: controller.isPersonalInfoComplete),
          //
          // _buildCollapsibleSection(
          //     "Student Info", isStudentExpanded, studentInfo,complete: controller.isStudentInfoComplete),
          //
          _buildCollapsibleSection("Family Info", isFamilyExpanded, familyInfo,complete: controller.isFamilyInfoComplete),
          _buildCollapsibleSection("Main Occupation", isOccupationExpanded, _mainOccupation2,complete: controller.isMainOccupationComplete),
          _buildCollapsibleSection("Khidmat / HR", isKhidmatHrExpanded, khidmatHr,complete: controller.isKhidmatHrComplete),
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
          Row(
            spacing: 8,
            children: [
              Flexible(
                child: _buildDropdown(
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
              ),
              Flexible(child: _buildField("Family Surname", controller.familySurname,function: () => controller.validatePersonalInfoFields())),
            ],
          ),
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
          Row(
            spacing: 8,
            children: [
              Flexible(child: _buildField("CNIC", controller.cnic,function: ()=> controller.validateStudentInfoFields())),
              Flexible(child: _buildField("Date of Birth", controller.dateOfBirth,function: ()=> controller.validateStudentInfoFields())),
              Flexible(child: _buildField("Full Name", controller.fullName,function: ()=> controller.validateStudentInfoFields())),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Flexible(child: _buildField("Mobile No.", controller.mobileNo,function: ()=> controller.validateStudentInfoFields())),
              Flexible(child: _buildField("WhatsApp No.", controller.whatsappNo,function: ()=> controller.validateStudentInfoFields())),
              Flexible(child: _buildField("Email", controller.email,function: ()=> controller.validateStudentInfoFields())),
            ],
          ),
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
                  Row(
                    spacing: 8,
                    children: [
                      Flexible(child: _buildField("Name", controller.fatherName,function: ()=> controller.validateFamilyInfoFields())),
                    Flexible(child: _buildField("CNIC", controller.fatherCnic,function: ()=> controller.validateFamilyInfoFields())),

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
                    child:uploadSection('father_cnic', gController.user.value.itsId.toString(), '81'),

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
                      Flexible(child: _buildField("Name", controller.motherName,function: ()=> controller.validateFamilyInfoFields())),
                      Flexible(child: _buildField("CNIC", controller.motherCnic,function: ()=> controller.validateFamilyInfoFields())),
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
                    child: uploadSection('mother_cnic', gController.user.value.itsId.toString(), '81'),
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
                      Flexible(child: _buildField("Name", controller.guardianName,function: ()=> controller.validateFamilyInfoFields())),
                      Flexible(child: _buildField("CNIC", controller.guardianCnic,function: ()=> controller.validateFamilyInfoFields())),
                      Flexible(child: _buildField("Relation to Student", controller.relationToStudent,function: ()=> controller.validateFamilyInfoFields())),
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
                      child: Obx(() => _buildField(
                        "Burhani Guards",
                        function: ()=> controller.validateKhidmatHr(),
                        controller.bgi,
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
                      child: Obx(() => _buildField(
                        "Tolobatul Kulliyat",
                        function: ()=> controller.validateKhidmatHr(),
                        controller.tkm,
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
                      child: Obx(() => _buildField(
                        "12 Umoor",
                        function: ()=> controller.validateKhidmatHr(),
                        controller.umoor,
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
                      child: Obx(() => _buildField(
                        "Shabab",
                        function: ()=> controller.validateKhidmatHr(),
                        controller.shabab,
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
                      child: Obx(() => _buildField(
                        "Dawat Offices",
                        function: ()=> controller.validateKhidmatHr(),
                        controller.dawat,
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
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
            Text("Student",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
          ],
        ),
        if(controller.occupationInt.value==0)
          Obx(() => Column(
            spacing: 15,
            children: List.generate(controller.occupations.length, (index) {
              RxString occupation = controller.occupations[index]["occupation"];
              RxString wordAddress = controller.occupations[index]["workAddress"];
              RxString workPhone = controller.occupations[index]["workPhone"];

              return Row(
                children: [
                  Expanded(
                    child: Column(
                      spacing: 8,
                      children: [
                        Row(
                          spacing:15,
                          children: [
                            Flexible(
                              child: _buildField(
                                  "Occupation",
                                  occupation,
                                  function: ()=> controller.validateOccupationsList()
                              ),
                            ),
                            Flexible(
                              child: _buildField(
                                  "Work Address",
                                  wordAddress,
                                  function: ()=> controller.validateOccupationsList()
                              ),
                            ),
                            Flexible(
                              child: _buildField(
                                  "Work Phone",
                                  workPhone,
                                  function: ()=> controller.validateOccupationsList()
                              ),
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
        if(controller.occupationInt.value==0)
          TextButton.icon(
            onPressed: () {
              bool allValid = controller.occupations.every((entry) =>
              entry["occupation"].value.isNotEmpty &&
              entry["workAddress"].value.isNotEmpty &&
                  entry["workPhone"].value.isNotEmpty);

              if (!allValid) {
                return;
              }
              controller.occupations.add({"occupation": "".obs, "workAddress": "".obs,"workPhone":"".obs});
              controller.validateOccupationsList();
            },
            icon: Icon(Icons.add,color: Colors.green,size: 20,),
            label: Text("Add Occupation",style: TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),),
          ),
        SizedBox(height: 10,)
      ],
    );
  }

  // Widget mainOccupation() {
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
  //             Flexible(child: _buildField("Occupation", controller.occupation,function: ()=>controller.validateMainOccupationFields())),
  //             Flexible(child: _buildField("Work Address", controller.wordAddress,function: ()=>controller.validateMainOccupationFields())),
  //             Flexible(child: _buildField("Work Phone Number", controller.workPhone,function: ()=>controller.validateMainOccupationFields())),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget uploadSection(String docType, String ITS, String reqId, {int numItems = 1}) {
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
          margin: EdgeInsets.symmetric(vertical: 8), // Adds spacing between sections
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
                            await Api.uploadDocument(specificDocType, ITS, reqId);
                            //validateDocuments(specificDocType);
                          },
                        ),
                        Text("Click here to upload ${specificDocType.replaceAll('_', ' ').toUpperCase()}"),
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


  Widget _buildField(String label, RxString rxValue, {double? height, bool? isEnabled, Function()? function}) {
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
                disabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.grey), // Grey border when disabled
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                filled: true,
                fillColor: (isEnabled ?? true) ? const Color(0xfffffcf6) : Colors.grey[300],
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
