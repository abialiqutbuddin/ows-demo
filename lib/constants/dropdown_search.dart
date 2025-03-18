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
  final double? height;

  CustomDropdownSearch({
    super.key,
    required this.label,
    required this.itemsLoader,
    required this.onChanged,
    this.selectedItem,
    this.isEnabled = true,
    this.height = 40,
  });

  final RequestFormController controller = Get.find<RequestFormController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
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
                fit: FlexFit.loose,
                constraints: BoxConstraints(
                  maxHeight: 250,
                ),
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: "Search Here", 
                    labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.brown),
                    filled: true,
                    fillColor: Colors.white, // Background color of search box
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.brown, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.brown, width: 2),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.black), // Change text style
                ),
                itemBuilder: (context, item, isSelected, isHovered) {
                  return ListTile(
                    title: Text(
                      item.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 0,// Adjust size
                        fontWeight: FontWeight.w600, // Bold text
                        color: isSelected
                            ? Colors.blue
                            : Colors.black, // Change color when selected
                      ),
                    ),
                  );
                },
                showSearchBox: true,
                menuProps: MenuProps(
                  borderRadius: BorderRadius.circular(5),
                  backgroundColor: const Color(0xfffffcf6),
                ),
              ),
              decoratorProps: DropDownDecoratorProps(
                baseStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: isEnabled ? '' : "Select City First",
                  hintStyle: TextStyle(
                      color: Colors.grey, fontSize: 14, letterSpacing: 0,fontWeight: FontWeight.w600),
                  filled: true,
                  fillColor: const Color(0xfffffcf6),
                  suffixIcon: Icon(Icons.arrow_drop_down,
                      color: isEnabled ? Colors.black : Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
      ],
    );
  }

  String hintText() {
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
