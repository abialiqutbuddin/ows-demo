import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  hintText: isEnabled ? '' : "Select City First",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xfffffcf6),
                  suffixIcon: Icon(Icons.arrow_drop_down, color: isEnabled ? Colors.black : Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ),
        Obx(() {
          String? error = _validateDropdown(label, controller.selectedInstituteName);
          return error != null
              ? Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          )
              : const SizedBox(
              height: 17); // Reserve space for validation message
        }),
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
