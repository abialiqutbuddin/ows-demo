import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'dart:html' as html; // Only works for Flutter Web
import '../controller/module_controller.dart';
import '../controller/profile_pdf_controller.dart';
import '../controller/request_form_controller.dart';
import '../controller/state_management/state_manager.dart';

class Constants {
  Color green = Color(0xFF008759);
  Color blue = Color(0xff005387);

  Widget heading(String value)
  {
    return Text(value,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24));
  }
  Widget subHeading(String value)
  {
    return Text(value,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16));
  }

  double responsiveWidth(BuildContext context, double fraction) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1280) {
      return screenWidth * fraction; // Use the fraction of the screen width
    } else {
      return 1280 * fraction; // Cap the maximum width based on 1280 pixels
    }
  }

  Future<void> saveToPrefs(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> clearSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void Logout() async {
    clearSharedPreferences();
    //GetStorage().
    Get.delete<RequestFormController>();
    Get.delete<PDFScreenController>();
    Get.delete<GlobalStateController>();
    Get.delete<ModuleController>();

    // Redirect to external website
    const String url = "https://www.its52.com";
    if (GetPlatform.isWeb) {
      //html.window.location.href = url;
    } else {
      launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView); // Opens inside the app (Mobile)
    }
  }

  Widget buildField(
      String label,
      RxString rxValue,
      controller,
      {double? height,
        bool? isEnabled,
        Function()? function,
        String? Function(String?)? validator,
        String? validatorKey, // 👈 ADD THIS
      }) {
    bool isDescription = height != null;
    SuperTooltipController tooltipController = SuperTooltipController();

    return Obx(() {
      String? error;
      try {
        error = controller.validateField(label, rxValue.value, validatorKey: validatorKey);
      } catch (_) {
        error = null;
      }
      bool isEmpty = rxValue.value.trim().isEmpty;
      bool isValid = error == null && !isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height ?? 50,
            child: TextFormField(
              enabled: isEnabled ?? true,
              validator: validator,
              textInputAction: TextInputAction.done,
              cursorColor: Colors.brown,
              controller: TextEditingController(text: rxValue.value)
                ..selection = TextSelection.collapsed(offset: rxValue.value.length),
              onChanged: (value) {
                rxValue.value = value;
                controller.validateForm();
                if(function != null){
                  function.call();  // Call function safely
                }
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

  Widget buildDropdown2({
    required String label,
    required Rxn<int> selectedValue,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
    required bool isEnabled,
  }) {
    SuperTooltipController tooltipController = SuperTooltipController();
    String? error = '';
    Timer? hoverTimer;

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xffecdacc),
        ),
        child: Column(
            children: [
        Obx(() => SizedBox(
          height: 50,
          child: Row(
            children: [
              Expanded(
                  flex:3,
                  child:
                  Text(label,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.brown),)),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField2<int>(
                  style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  value: selectedValue.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    suffixIcon: selectedValue.value != null
                        ? Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                    )
                        : SuperTooltip(
                      elevation: 1,
                      barrierColor: Colors.transparent,
                      // Keep it visible without dark overlay
                      controller: tooltipController,
                      arrowTipDistance: 10,
                      showBarrier: false,
                      arrowTipRadius: 2,
                      arrowLength: 10,
                      borderColor: Color(0xffE9D502),
                      borderWidth: 2,
                      backgroundColor:
                      Color(0xffE9D502).withValues(alpha: 0.9),
                      boxShadows: [
                        BoxShadow(
                          color: Colors.black.withValues(
                              alpha: 0.2), // Light shadow color
                          blurRadius: 6, // Soft blur effect
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                      content: Text(error,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 12)),
                      child: MouseRegion(
                        onEnter: (_) {
                          hoverTimer = Timer(
                              const Duration(milliseconds: 300), () {
                            if (!tooltipController.isVisible) {
                              tooltipController.showTooltip();
                            }
                          });
                        },
                        onExit: (_) {
                          hoverTimer
                              ?.cancel(); // ✅ Prevent tooltip from showing if mouse leaves quickly
                          tooltipController.hideTooltip();
                        },
                        child: Icon(
                          Icons.error,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    label: Text(''),
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown),
                    filled: true,
                    enabled: isEnabled,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 1,
                          color: Colors.brown), // Removes the border
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 1, color: Colors.grey), // Removes the border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(width: 1, color: Colors.brown),
                    ),
                    fillColor: const Color(0xfffffcf6), // Background color
                    //contentPadding: EdgeInsets.zero
                    //contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                          color: Color(0xfffffcf6),
                          borderRadius: BorderRadius.circular(8))),
                  items: items
                      .map((item) => DropdownMenuItem<int>(
                    value: item['id'],
                    child: Text(item['name']),
                  ))
                      .toList(),
                  //
                  onChanged: isEnabled
                      ? (value) {
                    selectedValue.value = value;
                    onChanged(value);
                    //controller.validateForm();
                  }
                      : null, // Disable when needed
                  //disabledHint: Text("Select ${_getDisabledHint(label)}"),
                ),
              ),
            ],
          ),
        )),
            ]),
      );
  }

}