import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropdownOption {
  final String displayName;

  DropdownOption({required this.displayName});
}

class MultiSelectDropdown extends StatefulWidget {
  final List<DropdownOption> options;
  final MultiSelectDropdownController controller;
  final String hintText;
  final int maxSelection;

  const MultiSelectDropdown({
    super.key,
    required this.options,
    required this.controller,
    this.hintText = 'Select Values',
    this.maxSelection = 5,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  final RxBool isDropdownVisible = false.obs;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () => isDropdownVisible.toggle(),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 55),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xfffffcf6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.brown
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.2),
                  //     spreadRadius: 0.5,
                  //     blurRadius: 4,
                  //     offset: const Offset(0, 2),
                  //   ),
                  // ],
                ),
                child: Obx(() {
                  final selected = widget.controller.selectedValues;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selected.isEmpty)
                        Text(
                          widget.hintText,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: const Color(0xFF848382)),
                        ),
                      if (selected.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: selected
                                  .map((value) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0x80DBDBFE),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  value,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                      color: const Color(0xFF3E4958),
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                                  .toList(),
                            ),
                          ),
                        ),
                      AnimatedRotation(
                        turns: isDropdownVisible.value ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (!isDropdownVisible.value) return const SizedBox.shrink();

              return Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      children: widget.options.map((option) {
                        return Obx(() {
                          final selectedList = widget.controller.selectedValues;
                          final isSelected = selectedList.contains(option.displayName);
                          final isMax = selectedList.length >= widget.maxSelection;

                          return CheckboxListTile(
                            title: Text(option.displayName),
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value == true && !isSelected && !isMax) {
                                selectedList.add(option.displayName);
                              } else if (value == false) {
                                selectedList.remove(option.displayName);
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            enabled: isSelected || !isMax,
                          );
                        });
                      }).toList(),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class MultiSelectDropdownController extends GetxController {
  final RxList<String> selectedValues = <String>[].obs;
}
