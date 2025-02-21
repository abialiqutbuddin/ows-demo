//
//
// Widget _buildField(String label, RxString rxValue, {double? height}) {
//   bool isDescription = height != null;
//   SuperTooltipController tooltipController = SuperTooltipController();
//
//   return Obx(() {
//     String? error = controller.validateField(label, rxValue.value);
//     bool isEmpty = rxValue.value.trim().isEmpty;
//     bool isValid = error == null && !isEmpty;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: height ?? 50,
//           child: TextFormField(
//             textInputAction: TextInputAction.done,
//             cursorColor: Colors.brown,
//             controller: TextEditingController(text: rxValue.value)
//               ..selection = TextSelection.collapsed(offset: rxValue.value.length),
//             onChanged: (value) {
//               rxValue.value = value;
//               controller.validateForm();
//             },
//             textCapitalization: TextCapitalization.sentences,
//             maxLines: isDescription ? 3 : 1,
//             decoration: InputDecoration(
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               suffixIcon: isValid ? Icon(Icons.check_circle_rounded,color: Colors.green,) : GestureDetector(
//                 onTap: () async {
//                   if (!isValid && !isEmpty) {
//                     await tooltipController.showTooltip();
//                   }
//                 },
//                 child: SuperTooltip(
//                   elevation: 1,
//                   showBarrier: true,
//                   barrierColor: Colors.transparent,
//                   controller: tooltipController,
//                   arrowTipDistance: 10,
//                   arrowTipRadius: 2,
//                   arrowLength: 10,
//                   borderColor: isEmpty
//                       ? Colors.amber // ⚠️ Yellow for info
//                       : Colors.red, // ❌ Red for error
//                   borderWidth: 2,
//                   backgroundColor: isEmpty
//                       ? Colors.amber.withValues(alpha: 0.9) // ⚠️ Yellow
//                       : Colors.red.withValues(alpha: 0.9), // ❌ Red
//                   boxShadows: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.2), // Light shadow
//                       blurRadius: 6,
//                       spreadRadius: 2,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                   toggleOnTap: true,
//                   content: Text(
//                     isEmpty ? "This field is required" : error ?? "",
//                     style: const TextStyle(color: Colors.black, fontSize: 12),
//                   ),
//                   child: Icon(
//                     isEmpty
//                         ? Icons.info_rounded // ⚠️ Yellow info icon
//                         : Icons.error_rounded, // ❌ Red error icon
//                     color: isEmpty ? Colors.amber : Colors.red,
//                   ),
//                 ),
//               ),
//               labelText: label,
//               labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
//               enabledBorder: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//                 borderSide: BorderSide(width: 1, color: Colors.brown),
//               ),
//               focusedBorder: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//                 borderSide: BorderSide(width: 1, color: Colors.brown),
//               ),
//               filled: true,
//               fillColor: const Color(0xfffffcf6),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//             ),
//           ),
//         ),
//       ],
//     );
//   });
// }
//
// Widget _buildDropdown({
//   required String label,
//   required Rxn<int> selectedValue,
//   required List<Map<String, dynamic>> items,
//   required ValueChanged<int?> onChanged,
//   required bool isEnabled,
// }) {
//   SuperTooltipController tooltipController = SuperTooltipController();
//   String? error = controller.validateDropdown(label, selectedValue);
//
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Obx(() => DropdownButtonFormField2<int>(
//         value: selectedValue.value,
//         decoration: InputDecoration(
//           suffixIcon: error == null
//               ? SizedBox.shrink()
//               : GestureDetector(
//             onTap: () async {
//               await tooltipController.showTooltip();
//             },
//             child: SuperTooltip(
//               elevation: 1,
//               //showBarrier: true, // Allows tapping outside to close
//               barrierColor: Colors
//                   .transparent, // Keep it visible without dark overlay
//               showBarrier: true,
//               controller: tooltipController,
//               arrowTipDistance: 10,
//               arrowTipRadius: 2,
//               arrowLength: 10,
//               borderColor: Color(0xffE9D502),
//               borderWidth: 2,
//               backgroundColor: Color(0xffE9D502).withValues(alpha: 0.9),
//               boxShadows: [
//                 BoxShadow(
//                   color: Colors.black
//                       .withValues(alpha: 0.2), // Light shadow color
//                   blurRadius: 6, // Soft blur effect
//                   spreadRadius: 2,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//               toggleOnTap: true,
//               content: Text(error,
//                   style: const TextStyle(
//                       color: Colors.black, fontSize: 12)),
//               child: Icon(
//                 Icons.error,
//                 color: Color(0xffE9D502),
//               ),
//             ),
//           ),
//           floatingLabelBehavior: FloatingLabelBehavior.always,
//           label: Text(label),
//           labelStyle: TextStyle(
//               fontWeight: FontWeight.bold, color: Colors.brown),
//           filled: true,
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(
//                 width: 1, color: Colors.brown), // Removes the border
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(width: 1, color: Colors.brown),
//           ),
//           fillColor: const Color(0xfffffcf6), // Background color
//           //contentPadding: EdgeInsets.zero
//           contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         ),
//         dropdownStyleData: DropdownStyleData(
//             decoration: BoxDecoration(
//                 color: Color(0xfffffcf6),
//                 borderRadius: BorderRadius.circular(8))),
//         items: items.map((Map<String, dynamic> item) {
//           return DropdownMenuItem<int>(
//             value: item['id'],
//             child: Text(item['name']),
//           );
//         }).toList(),
//         onChanged: isEnabled
//             ? (value) {
//           selectedValue.value = value;
//           onChanged(value);
//           controller.validateForm();
//         }
//             : null, // Disable when needed
//         //disabledHint: Text("Select ${_getDisabledHint(label)}"),
//       )),
//     ],
//   );
// }