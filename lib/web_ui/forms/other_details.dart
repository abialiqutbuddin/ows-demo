// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path/path.dart';
// import 'package:get/get.dart';
// import 'package:ows/constants/constants.dart';
// import 'package:super_tooltip/super_tooltip.dart';
// import '../../api/api.dart';
// import '../../constants/multi_select_dropdown.dart';
// import '../../controller/forms/form_screen_controller.dart';
// import '../../controller/state_management/state_manager.dart';
// import '../../model/document.dart';
// import 'financials.dart';
//
// class OtherDetailsScreenW extends StatefulWidget {
//   const OtherDetailsScreenW({super.key});
//
//   @override
//   State<OtherDetailsScreenW> createState() => _FormScreenState();
// }
//
// class _FormScreenState extends State<OtherDetailsScreenW> {
//   String itsId = '30445124';
//   final FormController controller = Get.find<FormController>();
//   final GlobalStateController gController = Get.find<GlobalStateController>();
//   late SuperTooltipController tooltipControllers;
//
//   final MultiSelectDropdownController dropdownController =
//   Get.put(MultiSelectDropdownController());
//
//   final List<DropdownOption> dropdownItems = [
//     DropdownOption(displayName: 'Gas Stove'),
//     DropdownOption(displayName: 'TV'),
//     DropdownOption(displayName: 'Radio'),
//     DropdownOption(displayName: 'Telephone / Mobile'),
//     DropdownOption(displayName: 'Computer / Laptop'),
//     DropdownOption(displayName: 'Animal Cart'),
//     DropdownOption(displayName: 'Bicycle'),
//     DropdownOption(displayName: 'Motorbike'),
//     DropdownOption(displayName: 'Refrigerator'),
//     DropdownOption(displayName: 'Washing Machine'),
//     DropdownOption(displayName: 'Car'),
//     DropdownOption(displayName: 'Truck'),
//   ];
//
//   // RxBool to track expanded state
//   final RxBool isPersonalExpanded = false.obs;
//   final RxBool isStudentExpanded = false.obs;
//   final RxBool isFamilyExpanded = false.obs;
//   final RxBool isOccupationExpanded = false.obs;
//   final RxBool isKhidmatHrExpanded = false.obs;
//   final RxBool isHousingExpanded = false.obs;
//   final RxBool isDeeniInfoExpanded = false.obs;
//   final RxBool isNutriInfoExpanded = false.obs;
//   final RxBool isMedicalInfoExpanded = false.obs;
//   final RxBool isExpensesInfoExpanded = false.obs;
//   final bool isFCNIC = false;
//   final bool isMCNIC = false;
//   final RxInt selectedRadio = 0.obs; // Default: No radio selected
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         surfaceTintColor: Colors.transparent,
//         centerTitle: false,
//         title: Text(
//           "Personal Information",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Color(0xfffffcf6),
//       ),
//       backgroundColor: Color(0xfffffcf6),
//       body: ListView(
//         children: [
//           // _buildCollapsibleSection(
//           //     "Personal Information", isPersonalExpanded, personalInfo,complete: controller.isPersonalInfoComplete),
//           //
//           // _buildCollapsibleSection(
//           //     "Student Info", isStudentExpanded, studentInfo,complete: controller.isStudentInfoComplete),
//           //
//           _buildCollapsibleSection("Housing Info", isHousingExpanded, housingInfo, complete: controller.isFamilyInfoComplete),
//           _buildCollapsibleSection("Deeni Info", isDeeniInfoExpanded, deeniInfo, complete: controller.isFamilyInfoComplete),
//           _buildCollapsibleSection("Nutrition Info", isNutriInfoExpanded, nutriInfo, complete: controller.isFamilyInfoComplete),
//           _buildCollapsibleSection("Medical Info", isMedicalInfoExpanded, medicalInfo, complete: controller.isFamilyInfoComplete),
//           _buildCollapsibleSection("Monthly Expences", isExpensesInfoExpanded, expensesInfo, complete: controller.isFamilyInfoComplete),
//           Obx(() => Padding(
//             padding: EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: (controller.isPersonalInfoComplete.value &&
//                   controller.isStudentInfoComplete.value &&
//                   controller.isFamilyInfoComplete.value)
//                   ? () {
//                 // Handle next action here
//                 print("Next button clicked!");
//               }
//                   : null, // Disabled if form is invalid
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: controller.checkPersonalInfo()
//                     ? Colors.brown
//                     : Colors.grey,
//                 padding: EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Next",
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                   Icon(
//                     Icons.navigate_next_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   )
//                 ],
//               ),
//             ),
//           )),
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   controller.selectedIndex.value = 1;
//                 });
//                 //Get.to(FinancialFormScreen());
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.brown,
//                 padding: EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Go Next (Enabled for testing)",
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                   Icon(
//                     Icons.navigate_next_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// **Function to build collapsible sections with animation**
//   Widget _buildCollapsibleSection(
//       String title, RxBool isExpanded, Widget Function() content,
//       {RxBool? complete}) {
//     //bool isValid = controller.validatePersonalInfoFields();
//     return Obx(() => Stack(
//       children: [
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           margin: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               color: Color(0xffffead1),
//               border: Border.all(
//                   color:
//                   complete!.value ? Colors.green : Colors.transparent,
//                   width: 2)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   isExpanded.value =
//                   !isExpanded.value; // Toggle expand/collapse
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(title,
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                             color: Colors.brown)),
//                     AnimatedRotation(
//                       turns: isExpanded.value
//                           ? 0.5
//                           : 0.0, // Rotates 180° when expanded
//                       duration: Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                       child: Icon(
//                         Icons
//                             .keyboard_arrow_down, // Keep only one icon and rotate it
//                         color: Colors.brown,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Divider(height: 10, color: Colors.white, thickness: 2),
//               AnimatedSize(
//                 alignment: Alignment.topCenter,
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 child: isExpanded.value ? content() : SizedBox.shrink(),
//               ),
//             ],
//           ),
//         ),
//         if (complete.value)
//           Positioned(
//             top: 0,
//             right: 25,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.green,
//                 borderRadius: BorderRadius.all(Radius.circular(50)),
//               ),
//               child: Text(
//                 "Completed",
//                 style: TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ),
//       ],
//     ));
//   }
//
// }
