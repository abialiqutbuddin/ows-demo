import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:ows/constants/constants.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../api/api.dart';
import '../../controller/forms/form_screen_controller.dart';
import '../../controller/state_management/state_manager.dart';
import '../../model/document.dart';
import 'financials.dart';

class DocumentsFormScreen extends StatefulWidget {
  const DocumentsFormScreen({super.key});

  @override
  State<DocumentsFormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<DocumentsFormScreen> {
  String itsId = '30445124';
  String reqId = '81';
  final FormController controller = Get.find<FormController>();
  late SuperTooltipController tooltipControllers;
  final GlobalStateController globalController = Get.find<GlobalStateController>();


  // RxBool to track expanded state
  final RxBool isCourseExpanded = false.obs;
  final RxBool isFinancialExpanded = false.obs;
  final RxBool isSafaiChittiExpanded = false.obs;
  final RxBool isRazaExpanded = false.obs;
  final RxBool isCNICExpanded = false.obs;
  final RxBool isITSExpanded = false.obs;
  final RxBool isOthersExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          "Documents Upload",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xfffffcf6),
      ),
      backgroundColor: Color(0xfffffcf6),
      body: ListView(
        children: [
          _buildCollapsibleSection("Course Prospectus", isCourseExpanded,
              uploadSection('course_prospectus', itsId, reqId),
              docType: 'course_prospectus'),
          _buildCollapsibleSection(
              "Financial Proof Documents",
              isFinancialExpanded,
              uploadSection('financial_proof_documents', itsId, reqId),
              docType: 'financial_proof_documents'),
          _buildCollapsibleSection(
              "Safai Chitti for the Purpose Taalim",
              isSafaiChittiExpanded,
              uploadSection('safai_chitti', '30445124', '81'),
              docType: 'safai_chitti'),
          _buildCollapsibleSection("Raza Letter", isRazaExpanded,
              uploadSection('raza_letter', itsId, reqId),
              docType: 'raza_letter'),
          _buildCollapsibleSection("CNIC (Front & Back)", isCNICExpanded,
              uploadSection('cNIC', itsId, reqId, numItems: 2),
              docType: 'cNIC'),
          _buildCollapsibleSection(
              "ITS Card", isITSExpanded, uploadSection('its_card', itsId, reqId),
              docType: 'its_card'),
          _buildCollapsibleSection(
              "Other Supporting Course Documents",
              isOthersExpanded,
              uploadSection('other_documents', itsId, reqId, numItems: 3),
              docType: 'other_documents'),
          Obx(() => Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: controller.isButtonEnabled.value
                      ? () {
                          // Handle next action here
                          print("Next button clicked!");
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

  bool validateDocuments(String docType) {
    if (docType == 'cNIC') {
      // Special case: Check if both cNIC_front and cNIC_back exist
      return globalController.documents.containsKey('cNIC_front') &&
          globalController.documents['cNIC_front'] != null &&
          globalController.documents.containsKey('cNIC_back') &&
          globalController.documents['cNIC_back'] != null;
    }

    // General case: Only check if `docType_0` exists
    return globalController.documents.containsKey("${docType}_0") &&
        globalController.documents["${docType}_0"] != null;
  }

  /// **Function to build collapsible sections with animation**
  Widget _buildCollapsibleSection(
      String title, RxBool isExpanded, Widget content,
      {String? docType}) {
    return Obx(() => Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xffffead1),
                  border: Border.all(
                      color: validateDocuments(docType!)
                          ? Colors.green
                          : Colors.transparent,
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
                        Expanded(
                          child: Text(title,
                              softWrap: true,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.brown)),
                        ),
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
                    child: isExpanded.value ? content : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            if (validateDocuments(docType))
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
                  var document = controller.documents[specificDocType]; // Fetch document for this specific docType

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
                            validateDocuments(specificDocType);
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
    if (globalController.documents[docType] != null) {
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
        globalController.documents[docType] = Document(
            file: selectedFile,
            filePath: null); // Store the file object dynamically
      });
    } else {
      print("No file selected for $docType");
    }
  }
}
