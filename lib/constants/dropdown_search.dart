import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../controller/request_form_controller.dart';

class CustomDropdownSearch<T> extends StatelessWidget {
  final String label;
  final Future<List<T>> Function(String?, dynamic) itemsLoader;
  final T? selectedItem;
  final ValueChanged<T?> onChanged;
  final bool isEnabled;

  CustomDropdownSearch({
    super.key,
    required this.label,
    required this.itemsLoader,
    required this.onChanged,
    this.selectedItem,
    this.isEnabled = true,
  });

  final RequestFormController controller = Get.find<RequestFormController>();


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: DropdownSearch<T>(
              items: itemsLoader,
              selectedItem: selectedItem,
              enabled: isEnabled,
              suffixProps: DropdownSuffixProps(
                  dropdownButtonProps: DropdownButtonProps(isVisible: false)),
              onChanged: onChanged,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                menuProps: MenuProps(
                  backgroundColor: const Color(0xfffffcf6),
                ),
              ),
              // ✅ Modify the style of the selected item in the dropdown
              // dropdownBuilder: (BuildContext context, T? item) {
              //   if (item == null) {
              //     return const Text(
              //       "Select City",
              //       style: TextStyle(fontSize: 14, color: Colors.grey),
              //     );
              //   }
              //   if (item is Map<String, dynamic>) {
              //     return Text(
              //       item["name"] ?? "Unknown",
              //       style: const TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.brown,
              //       ),
              //     );
              //   } else {
              //     return Text(
              //       item.toString(),
              //       style: const TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.brown,
              //       ),
              //     );
              //   }
              // },
              decoratorProps: DropDownDecoratorProps(
                baseStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,letterSpacing: 0),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: isEnabled ? '' : "Select City First",
                  hintStyle: TextStyle(color: Colors.grey,fontSize: 14,letterSpacing: 0),
                  filled: true,
                  fillColor: const Color(0xfffffcf6),
                  suffixIcon: Icon(Icons.arrow_drop_down, color: isEnabled ? Colors.black : Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        width: 1, color: Colors.brown), // Removes the border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        width: 1, color: Colors.brown), // Removes the border
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        width: 1, color: Colors.grey), // Removes the border
                  ),
                ),
              ),
            ),
          ),
        ),
        // Obx(() {
        //   String? error = _validateDropdown(label, controller.selectedInstituteName);
        //   return error != null
        //       ? Text(
        //     error,
        //     style: const TextStyle(color: Colors.red, fontSize: 12),
        //   )
        //       : const SizedBox(
        //       height: 17); // Reserve space for validation message
        // }),
      ],
    );
  }

  String hintText(){
    return isEnabled ? "Select $label" : "Select City First";
  }

  // **Dropdown Validation**
  String? _validateDropdown(String label, Rxn<String> selectedValue) {
    if (selectedValue.value == null || selectedValue.value == '') {
      return "* $label is required"; // 🔹 Error message when empty
    }
    return null;
  }

}
