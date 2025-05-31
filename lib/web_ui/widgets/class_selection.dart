import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../controller/update_paktalim_controller.dart';
import 'package:intl/intl.dart'; // Needed for optional date formatting

class ClassSelectionWidget extends StatefulWidget {

  final UpdatePaktalimController controller;
  final RxString? preselectedClassName;
  const ClassSelectionWidget({super.key, required this.controller, this.preselectedClassName});

  @override
  State<ClassSelectionWidget> createState() => _StateClassSelectionWidget();
}

class _StateClassSelectionWidget extends State<ClassSelectionWidget> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.preselectedClassName!=null){
      widget.controller.toggleStudied(widget.preselectedClassName!.value);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:  widget.preselectedClassName?.value==null ?
      [
        _sectionHeader(Icons.check_circle, "Studied Classes", Colors.green),
        const SizedBox(height: 8),
        _buildCheckboxWrap(isStudiedSection: true),
        const SizedBox(height: 20),
        _sectionHeader(Icons.remove_circle, "Not Studied Classes", Colors.red),
        const SizedBox(height: 8),
        _buildCheckboxWrap(isStudiedSection: false),
      ] : [
        _buildField2(
          "Class",
            widget.preselectedClassName!,
          context: context,
          controller: widget.controller,
          isEnabled: false
        ),
      ],
    ));
  }

  Widget _buildField2(String label, RxString rxValue,
      {double? height,
        bool? isEnabled,
        required BuildContext context,
        required dynamic controller}) {
    bool isDescription = height != null;
    SuperTooltipController tooltipController = SuperTooltipController();
    Timer? hoverTimer;

    return Obx(() {
      String? error = controller.validateField(label, rxValue.value);
      bool isEmpty = rxValue.value.trim().isEmpty;
      bool isValid = error == null && !isEmpty;
      bool isDateField = label.toLowerCase() == 'end year';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height ?? 50,
            child: TextFormField(
              readOnly: isDateField,
              style: const TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              enabled: isEnabled ?? true,
              textInputAction: TextInputAction.done,
              cursorColor: Colors.brown,
              controller: TextEditingController(text: rxValue.value)
                ..selection =
                TextSelection.collapsed(offset: rxValue.value.length),
              onTap: isDateField
                  ? () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate:
                  DateTime.tryParse(rxValue.value) ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  final formattedDate =
                  DateFormat('yyyy-MM-dd').format(pickedDate);
                  rxValue.value = formattedDate;
                  controller.validateForm();
                }
              }
                  : null,
              onChanged: (value) {
                if (!isDateField) {
                  rxValue.value = value;
                  controller.validateForm();
                }
              },
              textCapitalization: TextCapitalization.sentences,
              maxLines: isDescription ? 3 : 1,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: isDateField
                    ? IconButton(
                  icon: const Icon(Icons.calendar_today,
                      color: Colors.brown),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(rxValue.value) ??
                          DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                      rxValue.value = formattedDate;
                      controller.validateForm();
                    }
                  },
                )
                    : isValid
                    ? const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                )
                    : SuperTooltip(
                  elevation: 1,
                  showBarrier: false,
                  barrierColor: Colors.transparent,
                  controller: tooltipController,
                  arrowTipDistance: 10,
                  arrowTipRadius: 2,
                  arrowLength: 10,
                  borderColor: isEmpty ? Colors.amber : Colors.red,
                  borderWidth: 2,
                  backgroundColor: isEmpty
                      ? Colors.amber.withOpacity(0.9)
                      : Colors.red.withOpacity(0.9),
                  boxShadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  content: Text(
                    isEmpty ? "This field is required" : error ?? "",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
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
                        hoverTimer?.cancel();
                        tooltipController.hideTooltip();
                      },
                      child: Icon(
                        isEmpty
                            ? Icons.info_rounded
                            : Icons.error_rounded,
                        color: isEmpty ? Colors.amber : Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                labelText: label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                filled: true,
                fillColor: (isEnabled ?? true)
                    ? const Color(0xfffffcf6)
                    : Colors.grey[300],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCheckboxWrap({required bool isStudiedSection}) {
    final studied = widget.controller.selectedStudied;
    final notStudied = widget.controller.selectedNotStudied;

    final filteredClasses =
    widget.controller.allClasses.where((cls) => cls['id'] <= 12).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        border: Border.all(color: Colors.brown.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        children: filteredClasses.map((cls) {
          final name = cls['name'];
          final isChecked = isStudiedSection
              ? studied.contains(name)
              : notStudied.contains(name);
          final isDisabled = isStudiedSection
              ? notStudied.contains(name)
              : studied.contains(name);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: isChecked,
                onChanged: isDisabled
                    ? null
                    : (_) {
                  if (isStudiedSection) {
                    widget.controller.toggleStudied(name);
                  } else {
                    widget.controller.toggleNotStudied(name);
                  }
                },
                activeColor: Colors.brown,
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}