import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/constants/constants.dart';
import 'constants/multi_select_dropdown.dart';
import 'data/dropdown_options.dart';
import 'data/form_config.dart';

class DynamicFormBuilder extends StatefulWidget {
  const DynamicFormBuilder({super.key});

  @override
  State<DynamicFormBuilder> createState() => _DynamicFormBuilderState();
}

class _DynamicFormBuilderState extends State<DynamicFormBuilder> {
  final Constants constants = Constants();
  final RxMap<String, RxString> textFields = <String, RxString>{}.obs;
  final RxMap<String, Rxn<int>> dropdownFields = <String, Rxn<int>>{}.obs;
  final Map<String, RxBool> sectionStates = {};
  final List<Map<String, dynamic>> formSections = formConfig;
  final RxMap<String, RxBool> sectionCompletion = <String, RxBool>{}.obs;
  final Map<String, RxInt> repeatableSectionRadio = {};
  final Map<String, RxList<Map<String, dynamic>>> repeatableEntries = {};
  late final Map<String, Function()> sectionValidators;
  final Map<String, List<Map<String, dynamic>>> dropdownOptions = dropdownOptions2;
  late final Map<String, String? Function(String, String)> customValidators;
  final RxMap<String, MultiSelectDropdownController> multiSelectControllers = <String, MultiSelectDropdownController>{}.obs;
  final RxInt activeSectionIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    initializeFormFields();
    sectionCompletion["intendInfo"] = true.obs;
    subsectionProgress["intendInfo"] = 100.0.obs;
    activeSectionIndex.value = 1;
    sectionValidators = {
      for (var section in formSections)
        section['key']: () {
          final type = section['type'];
          if (type == 'repeatable') {
            validateRepeatableSection(section['key']);
          } else {
            validateSection(section['key']); // includes 'totaling' and normal
          }
        }
    };

    customValidators = {
      'name': (val, label) => _validateName(val, label),
      'cnic': (val, label) => _validateCNIC(val, label),
      'email': (val, label) => _validateEmail(val, label),
      'its': (val, label) => _validateITS(val, label),
      'number': (val, label) => _validateNumber(val, label),
      'dob': (val, label) => _validateDateOfBirth(val, label),
      'address': (val, label) => _validateAddress(val, label),
      'phone': (val, label) => _validatePhoneNumber(val, label),
      'year': (val, label) => _validateYear(val, label),
      'age': (val, label) => _validateAge(val, label),
    };
  }

  String? validateField(String label, String value, {String? validatorKey}) {
    if (value.trim().isEmpty) return "* $label is required";

    if (validatorKey != null && customValidators.containsKey(validatorKey)) {
      return customValidators[validatorKey]!(value, label);
    }

    return null;
  }

  String? validateDropdown(String label, Rxn<int> selectedValue) {
    if (selectedValue.value == null) {
      return "* $label is required";
    }
    return null;
  }

  Future<void> initializeFormFields() async {
    for (var section in formSections) {
      final sectionKey = section['key'];
      sectionStates[sectionKey] = false.obs;
      sectionCompletion[sectionKey] = false.obs;

      if (section['type'] == 'repeatable') {
        repeatableSectionRadio[sectionKey] = 0.obs;
        repeatableEntries[sectionKey] = <Map<String, dynamic>>[].obs;
        continue;
      } else if (section['type'] == 'totaling') {
        for (var sub in section['subSections'] ?? []) {
          for (var field in sub['fields']) {
            final key = field['key'];
            textFields.putIfAbsent(key, () => ''.obs);
          }
        }
      }

      for (var sub in section['subSections'] ?? []) {
        final subKey = sub['key'];

        if (sub['type'] == 'repeatable') {
          repeatableSectionRadio[subKey] = 0.obs;
          repeatableEntries[subKey] = <Map<String, dynamic>>[].obs;
          sectionCompletion[subKey] = false.obs;
          continue;
        }

        for (var field in sub['fields']) {
          final key = field['key'];

          if (field['type'] == 'text') {
            textFields.putIfAbsent(key, () => ''.obs);
          } else if (field['type'] == 'dropdown') {
            dropdownFields.putIfAbsent(key, () => Rxn<int>());

            if (field.containsKey('textFieldKey')) {
              textFields.putIfAbsent(field['textFieldKey'], () => ''.obs);
            }

            if (field.containsKey('dropdownKey')) {
              dropdownFields.putIfAbsent(
                  field['dropdownKey'], () => Rxn<int>());
            }
          } else if (field['type'] == 'radio') {
            textFields.putIfAbsent(key, () => ''.obs);
            if (field.containsKey("textFieldKey")) {
              textFields.putIfAbsent(field["textFieldKey"], () => ''.obs);
            }
            if (field.containsKey("dropdownKey")) {
              dropdownFields.putIfAbsent(
                  field["dropdownKey"], () => Rxn<int>());
            }
          } else if (field['type'] == 'multiselect') {
            multiSelectControllers.putIfAbsent(
                key, () => MultiSelectDropdownController());
          }
        }
      }
    }
  }

  List<Map<String, dynamic>> getOptions(String key) {
    return dropdownOptions[key] ?? [];
  }

  Widget buildDynamicField(Map<String, dynamic> field, String sectionKey) {
    final String type = field['type'];
    final String label = field['label'];
    final String key = field['key'];
    final validationFunction = sectionValidators[sectionKey];
    Widget? conditionalWidget;
    final validatorKey = field['validator'];

    if (type == 'text') {
      return constants.buildField(
        label,
        textFields[key]!,
        this,
        function: validationFunction,
        validatorKey: validatorKey,
        validator: (value) =>
            validateField(label, value ?? '', validatorKey: validatorKey),
      );
    } else if (type == 'dropdown') {
      final options = getOptions(field['itemsKey']);
      final Rxn<int> selectedValue = dropdownFields[key]!;

      Widget? conditionalField;
      if (field.containsKey("showTextFieldIf")) {
        final int showIf = field['showTextFieldIf'];
        final String linkedKey = field["textFieldKey"];
        final String linkedLabel = field["textFieldLabel"];

        final RxString linkedVal = textFields[linkedKey]!;

        conditionalField = Obx(() {
          final shouldShow = selectedValue.value == showIf;
          return Visibility(
            visible: shouldShow,
            maintainState: true,
            maintainAnimation: true,
            child: constants.buildField(
              linkedLabel,
              linkedVal,
              this,
              function: sectionValidators[sectionKey],
            ),
          );
        });
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          constants.buildDropdown2(
            label: label,
            selectedValue: selectedValue,
            items: options,
            isEnabled: true,
            onChanged: (val) {
              if (sectionValidators[sectionKey] != null) {
                sectionValidators[sectionKey]!();
              }
            },
          ),
          if (conditionalField != null) conditionalField,
        ],
      );
    } else if (type == 'multiselect') {
      final optionsList = getOptions(field['itemsKey']);
      final List<DropdownOption> dropdownItems = optionsList
          .map((e) => DropdownOption(displayName: e['name']))
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.brown)),
          MultiSelectDropdown(
            controller: multiSelectControllers[key]!,
            options: dropdownItems,
            hintText: "Select $label",
          ),
        ],
      );
    } else if (type == 'radio') {
      final options = field['options'] as List<dynamic>;
      final RxString selected = textFields[key]!;

      if (field.containsKey("textFieldKey")) {
        final RxString linked = textFields[field['textFieldKey']]!;
        conditionalWidget = constants.buildField(
          field['textFieldLabel'],
          linked,
          this,
          function: sectionValidators[sectionKey],
        );
      }

      if (field.containsKey("dropdownKey")) {
        final Rxn<int> dropdownVal = dropdownFields[field['dropdownKey']]!;
        final items = getOptions(field['itemsKey']);
        conditionalWidget = Obx(() {
          final enabled = selected.value == field['showDropdownIf'];
          return constants.buildDropdown2(
            label: field['dropdownLabel'],
            selectedValue: dropdownVal,
            items: items,
            isEnabled: enabled,
            onChanged: enabled
                ? (val) => sectionValidators[sectionKey]?.call()
                : (_) {},
          );
        });
      }

      return radioAsk(
        field['label'],
        selected,
        option1: options[0],
        option2: options[1],
        conditionalField: conditionalWidget,
        showFieldIf: field['showTextFieldIf'] ?? field['showDropdownIf'],
        onChanged: () {
          if (validationFunction != null) validationFunction();
        },
        // field: conditionalField,
        //enableFieldOn: field['showTextFieldIf'],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _radioOption(String label, RxString group, {VoidCallback? onChanged}) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: group.value,
          onChanged: (val) {
            group.value = val!;
            if (onChanged != null) onChanged(); // 🔥 validate on change
          },
        ),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget radioAsk(
    String title,
    RxString value, {
    String option1 = 'Yes',
    String option2 = 'No',
    Widget? conditionalField,
    String? showFieldIf,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xffecdacc),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xfffffcf6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.brown, width: 1),
                  ),
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _radioOption(option1, value,
                              onChanged: () => onChanged!()),
                          _radioOption(option2, value,
                              onChanged: () => onChanged!()),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
        if (conditionalField != null)
          Obx(() {
            final shouldShow =
                showFieldIf == null || value.value == showFieldIf;
            return Visibility(
              visible: shouldShow,
              maintainState: true,
              maintainAnimation: true,
              child: conditionalField,
            );
          })
      ],
    );
  }

  void validateSection(String sectionKey) {
    final section = formSections.firstWhereOrNull((s) => s['key'] == sectionKey);
    if (section == null) return;

    bool isValid = true;

    if (section['type'] == 'totaling') {
      for (var sub in section['subSections'] ?? []) {
        for (var field in sub['fields'] ?? []) {
          if (!validateSingleField(field)) isValid = false;
        }
      }
      sectionCompletion[sectionKey]?.value = isValid;
      return;
    }

    for (var sub in section['subSections'] ?? []) {
      final subKey = sub['key'];
      final fields = sub['fields'] ?? [];

      if (sub['type'] == 'repeatable') {
        final entries = repeatableEntries[subKey];
        final radio = repeatableSectionRadio[subKey];

        if (entries == null || radio == null) continue;

        final isNoExpense = radio.value == 1;

        final isSubValid = isNoExpense ||
            (entries.isNotEmpty &&
                entries.every((entry) => fields.every((f) {
                  final key = f['key'];
                  final fieldType = f['type'];
                  final val = entry[key];

                  if (fieldType == 'dropdown') {
                    return val is Rxn<int> && val.value != null;
                  } else {
                    return val is RxString && val.value.trim().isNotEmpty;
                  }
                })
                ));

        if (!isSubValid) isValid = false;

        // ✅ FIX: If 'No Expense' selected, force 100% progress
        final double subPercent;
        if (isNoExpense) {
          subPercent = 100.0;
        } else {
          final totalFields = entries.length * fields.length;
          final filledFields = entries.fold<int>(0, (sum, entry) {
            return sum + fields.where((f) {
              final key = f['key'];
              final fieldType = f['type'];
              final val = entry[key];

              if (fieldType == 'dropdown') {
                return val is Rxn<int> && val.value != null;
              } else {
                return val is RxString && val.value.trim().isNotEmpty;
              }
            }).length as int;
          });

          subPercent =
          totalFields == 0 ? 0.0 : (filledFields / totalFields) * 100.0;
        }

        if (subsectionProgress.containsKey(subKey)) {
          subsectionProgress[subKey]!.value = subPercent;
        } else {
          subsectionProgress[subKey] = subPercent.obs;
        }

        sectionCompletion[subKey]?.value = isSubValid;
      } else {
        // Non-repeatable subsection logic
        int filled = fields.where((f) => validateSingleField(f)).length;
        int total = fields.length;
        final subPercent = total == 0 ? 100.0 : (filled / total) * 100.0;

        if (subsectionProgress.containsKey(subKey)) {
          subsectionProgress[subKey]!.value = subPercent;
        } else {
          subsectionProgress[subKey] = subPercent.obs;
        }

        if (filled != total) isValid = false;
        sectionCompletion[subKey]?.value = filled == total;
      }
    }

    sectionCompletion[sectionKey]?.value = isValid;
    sectionCompletion.refresh();
  }

  bool validateSingleField(Map<String, dynamic> field) {
    final String? type = field['type'];
    final String? key = field['key'];
    final String label = field['label'] ?? '';

    if (key == null || type == null) return true; // skip invalid field

    if (type == 'text') {
      final value = textFields[key]?.value ?? '';
      final String? validatorKey = field['validator'];
      final customValidator =
          validatorKey != null ? customValidators[validatorKey] : null;
      final result = customValidator != null
          ? customValidator(value, label)
          : (value.trim().isEmpty ? "$label is required" : null);
      return result == null;
    }

    if (type == 'dropdown') {
      final val = dropdownFields[key]?.value;
      if (val == null) return false;

      if (field.containsKey('showTextFieldIf') &&
          val == field['showTextFieldIf']) {
        final linkedKey = field['textFieldKey'];
        final linkedVal = textFields[linkedKey]?.value ?? '';
        if (linkedVal.trim().isEmpty) return false;
      }

      return true;
    }

    if (type == 'radio') {
      final value = textFields[key]?.value ?? '';
      if (value.trim().isEmpty) return false;

      if (field.containsKey('textFieldKey') &&
          value == field['showTextFieldIf']) {
        final linkedVal = textFields[field['textFieldKey']]?.value ?? '';
        if (linkedVal.trim().isEmpty) return false;
      }

      if (field.containsKey('dropdownKey') &&
          value == field['showDropdownIf']) {
        final linkedDropdownVal = dropdownFields[field['dropdownKey']]?.value;
        if (linkedDropdownVal == null) return false;
      }

      return true;
    }

    if (type == 'multiselect') {
      final controller = multiSelectControllers[key];
      return controller != null && controller.selectedValues.isNotEmpty;
    }

    return true; // default to true for unknown types
  }

  void validateRepeatableSection(String repeatableKey) {
    final entries = repeatableEntries[repeatableKey];
    final selectedType = repeatableSectionRadio[repeatableKey];
    final fields = _findRepeatableFieldsByKey(repeatableKey);

    if (entries == null || selectedType == null || fields == null) return;

    final isStudent = selectedType.value == 1;

    final isValid = isStudent ||
        (entries.isNotEmpty &&
            entries.every((entry) => fields.every((f) {
                  final key = f['key'];
                  final val = entry[key]?.value.trim();
                  return val != null && val.isNotEmpty;
                })));

    subsectionProgress[repeatableKey] = RxDouble(isStudent ? 100.0 : isValid ? 100.0 : 0.0);
    sectionCompletion[repeatableKey]?.value = isValid;
    updateFormProgress();
  }

  List<dynamic>? _findRepeatableFieldsByKey(String key) {
    for (var section in formSections) {
      // Top-level repeatable section
      if (section['type'] == 'repeatable' && section['key'] == key) {
        return section['fields'] as List<dynamic>;
      }

      // Subsection repeatables
      for (var sub in section['subSections'] ?? []) {
        if (sub['type'] == 'repeatable' && sub['key'] == key) {
          return sub['fields'] as List<dynamic>;
        }
      }
    }
    return null;
  }

  Widget buildRepeatableGroup(Map<String, dynamic> section) {
    final String sectionKey = section['key'] ?? 'unknown_key';
    final String radioLabel = section['radioLabel'] ?? "None";

    final selectedType = repeatableSectionRadio[sectionKey];
    final entries = repeatableEntries[sectionKey];

    if (selectedType == null || entries == null) {
      return const Text(
        "Repeatable section not initialized properly.",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    final List<dynamic> fields = section['fields'] ?? [];

    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   section['title'] ?? '',
        //   style: const TextStyle(
        //       fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
        // ),
        Row(
          children: [
            Obx(() => Radio(
              value: 1,
              toggleable: true,
              groupValue: selectedType.value,
              onChanged: (value) {
                selectedType.value = value ?? 0;
                validateRepeatableSection(sectionKey);
              },
            )),
            Text(
              radioLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Obx(() => selectedType.value == 0
            ? Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(entries.length, (index) {
              final entry = entries[index];

              List<Widget> rows = [];
              List<Widget> currentRow = [];

              for (var field in fields) {
                final String key = field['key'];
                final String label = field['label'] ?? 'Field';
                final String type = field['type'] ?? 'text';
                final dynamic value = entry[key];

                if (type == 'dropdown') {
                  // Flush current row before adding dropdown
                  if (currentRow.isNotEmpty) {
                    rows.add(Row(
                      children: currentRow
                          .map((w) => Expanded(child: Padding(
                        padding:
                        const EdgeInsets.only(right: 12.0),
                        child: w,
                      )))
                          .toList(),
                    ));
                    currentRow = [];
                  }

                  rows.add(Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: constants.buildDropdown2(
                      label: label,
                      selectedValue: value as Rxn<int>,
                      items: getOptions(field['itemsKey']),
                      isEnabled: true,
                      onChanged: (_) =>
                          validateRepeatableSection(sectionKey),
                    ),
                  ));
                } else {
                  // Add text field to current row
                  currentRow.add(
                    constants.buildField(
                      label,
                      value as RxString,
                      this,
                      validatorKey: field['validator'],
                      validator: (v) => validateField(
                          label, v ?? '', validatorKey: field['validator']),
                      function: () => validateRepeatableSection(sectionKey),
                    ),
                  );

                  if (currentRow.length == 3) {
                    rows.add(Row(
                      children: currentRow
                          .map((w) => Expanded(child: Padding(
                        padding:
                        const EdgeInsets.only(right: 12.0),
                        child: w,
                      )))
                          .toList(),
                    ));
                    currentRow = [];
                  }
                }
              }

              // Add leftover row if any
              if (currentRow.isNotEmpty) {
                rows.add(Row(
                  children: currentRow
                      .map((w) => Expanded(child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: w,
                  )))
                      .toList(),
                ));
              }

              return Column(
                children: [
                  ...rows,
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete_forever,
                          color: Colors.red),
                      onPressed: () {
                        entries.removeAt(index);
                        repeatableEntries[sectionKey]!.refresh();
                        validateRepeatableSection(sectionKey);
                      },
                    ),
                  ),
                  const Divider(thickness: 1, color: Colors.brown),
                ],
              );
            }),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                final allValid = entries.every((entry) => fields.every((f) {
                  final key = f['key'];
                  final val = entry[key];

                  if (f['type'] == 'dropdown') {
                    return val != null && val.value != null;
                  }
                  return val != null &&
                      val.value != null &&
                      val.value.trim().isNotEmpty;
                }));

                if (!allValid) return;

                final newEntry = <String, dynamic>{};
                for (var field in fields) {
                  final String key = field['key'];
                  if (field['type'] == 'dropdown') {
                    newEntry[key] = Rxn<int>();
                  } else {
                    newEntry[key] = ''.obs;
                  }
                }

                entries.add(newEntry);
                repeatableEntries[sectionKey]!.refresh();
                validateRepeatableSection(sectionKey);
              },
              icon: const Icon(Icons.add, color: Colors.green),
              label: const Text(
                "Add",
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            )
          ],
        )
            : const SizedBox.shrink())
      ],
    );
  }

  final RxMap<String, RxDouble> subsectionProgress = <String, RxDouble>{}.obs;

  Widget buildCollapsibleSection({
    required String title,
    required RxBool complete,
    required List<Widget> children,
    bool isLocked = false,
    required String sectionKey,
  }) {
    return Obx(() {
      final double percent = subsectionProgress[sectionKey]?.value ?? 0.0;

      final progressColor = percent >= 100
          ? Colors.green
          : percent >= 70
          ? Colors.lightGreen
          : percent >= 40
          ? Colors.orange
          : Colors.redAccent;

      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xffffead1),
              border: Border.all(
                color: percent >= 100 ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 10, color: Colors.white, thickness: 2),
                Column(children: children),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: percent >= 100 ? Colors.green : progressColor,
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
              child: Text(
                percent >= 100 ? "Completed" : "${percent.round()}%",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      );
    });
  }

  void validateForm() {
    for (var validator in sectionValidators.values) {
      validator();
    }
  }

  String? _validateITS(String value, String label) {
    if (value.isEmpty) {
      return "$label is required";
    }
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      return "$label must be exactly 8 digits and contain only numbers";
    }
    return null;
  }

  String? _validateAge(String value, String label) {
    if (value.isEmpty) {
      return "$label is required";
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return "$label should contain only numbers";
    }

    int age = int.tryParse(value) ?? 0;
    if (age < 1 || age > 120) {
      return "$label must be between 1 and 120";
    }

    return null;
  }

  // **Individual Validation Helpers**
  String? _validateNumber(String value, String label) {
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return "$label should contain only numbers";
    }
    return null;
  }

  String? _validateYear(String value, String label) {
    if (value.isEmpty) {
      return "$label is required";
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return "$label must be a 4-digit year (e.g., 2024)";
    }
    return null;
  }

  String? _validateName(String value, String label) {
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return "$label should contain only letters and spaces";
    }
    if (value.length < 3) {
      return "$label must be at least 3 characters long";
    }
    return null;
  }

  String? _validateCNIC(String value, String label) {
    if (!RegExp(r'^\d{13}$').hasMatch(value)) {
      return "CNIC must be 13 digits";
    }
    return null;
  }

  String? _validateDateOfBirth(String value, String label) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return "Enter a valid date format (YYYY-MM-DD)";
    }
    return null;
  }

  String? _validatePhoneNumber(String value, String label) {
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
      return "Enter a valid phone number (10-15 digits)";
    }
    return null;
  }

  String? _validateEmail(String value, String label) {
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? _validateAddress(String value, String label) {
    if (value.length < 10) {
      return "Address must be at least 10 characters";
    }
    return null;
  }

  Widget buildTotalingSection(Map<String, dynamic> section) {
    final sectionKey = section['key'];
    final List<dynamic> subSections = section['subSections'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subSections.map<Widget>((sub) {
        final List<dynamic> fields = sub['fields'] ?? [];

        return Obx(() {
          int total = fields.fold(0, (sum, field) {
            final key = field['key'];
            final value = textFields[key]?.value ?? '';
            return sum + (int.tryParse(value) ?? 0);
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sub['title'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    sub['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown,
                    ),
                  ),
                ),
              Text("Total: $total",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black)),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffffead1),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double maxWidth = constraints.maxWidth;
                        const int itemsPerRow = 3;
                        const double spacing = 16;
                        final double itemWidth =
                            (maxWidth - (spacing * (itemsPerRow - 1))) /
                                itemsPerRow;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: fields.map<Widget>((field) {
                            return SizedBox(
                              width: itemWidth,
                              child: buildDynamicField(field, sectionKey),
                            );
                          }).toList(),
                        );
                      },
                    )),
              ),
            ],
          );
        });
      }).toList(),
    );
  }

  List<List<Map<String, dynamic>>> chunkFields(
      List<Map<String, dynamic>> fields, int chunkSize) {
    List<List<Map<String, dynamic>>> chunks = [];
    for (var i = 0; i < fields.length; i += chunkSize) {
      int end = (i + chunkSize < fields.length) ? i + chunkSize : fields.length;
      chunks.add(fields.sublist(i, end));
    }
    return chunks;
  }

  final RxList<SectionStep> sectionSteps = <SectionStep>[].obs;
  //final RxInt activeSectionIndex = 0.obs;

  double getSectionCompletionPercentByKey(String sectionKey) {

    if (sectionCompletion[sectionKey]?.value == true) {
      return 100.0;
    }

    final section = formSections
        .cast<Map<String, dynamic>>()
        .firstWhere((s) => s['key'] == sectionKey, orElse: () => {});

    if (section.isEmpty) return 0.0;

    double percent = 0.0;

    if (section['type'] == 'repeatable') {
      // Top-level repeatable
      final entries =
          repeatableEntries[sectionKey] ?? <Map<String, RxString>>[].obs;
      final List<dynamic> fields = section['fields'] ?? [];
      final repeatableRadio = repeatableSectionRadio[sectionKey];

      if (repeatableRadio != null && repeatableRadio.value == 1) {
        percent = 100.0;
      } else {
        final int totalFields = entries.length * fields.length;
        final int filledFields = entries.fold<int>(0, (sum, entry) {
          return sum +
              fields.where((f) {
                final key = f['key'];
                final val = entry[key]?.value.trim();
                return val != null && val.isNotEmpty;
              }).length;
        });

        percent = totalFields == 0
            ? 0.0
            : (filledFields.toDouble() / totalFields.toDouble()) * 100.0;
      }
    } else {
      // Regular or totaling sections with potential repeatable subSections
      final subSections = section['subSections'] ?? [];
      double totalWeight = 0;
      double totalPercent = 0;

      for (var sub in subSections) {
        if (sub['type'] == 'repeatable') {
          final subKey = sub['key'];
          final percentVal =
              sectionCompletion[subKey]?.value == true ? 100.0 : 0.0;
          totalWeight += 1;
          totalPercent += percentVal;
        } else {
          final fields = sub['fields'] ?? [];
          int total = fields.length;
          int filled =
              fields.where((field) => validateSingleField(field)).length;
          final subPercent = total == 0 ? 100.0 : (filled / total) * 100.0;

          totalWeight += 1;
          totalPercent += subPercent;
        }
      }

      percent = totalWeight == 0 ? 0.0 : (totalPercent / totalWeight);
    }

    return percent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Imdaad Talimi Application Form"),
        backgroundColor: const Color(0xfffffcf6),
      ),
      backgroundColor: const Color(0xfffffcf6),
      body: Column(
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Obx(() {
              final steps = formSections.map<SectionStep>((section) {
                final key = section['key'];
                final percent = getSectionCompletionPercentByKey(key);
                return SectionStep(
                  title: section['title'],
                  completionPercent: percent,
                );
              }).toList();

              // Calculate overall progress across all sections
              final double totalPercent = steps.isEmpty
                  ? 0.0
                  : steps
                          .map((s) => s.completionPercent)
                          .reduce((a, b) => a + b) /
                      steps.length;

              return SectionStepper(
                sections: steps,
                activeIndex: activeSectionIndex.value,
                completionPercent: totalPercent,
              );
            }),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 150),
                  child: Column(
                    spacing: 10,
                    children: [
                      Obx(() {
                        final section = formSections[activeSectionIndex.value];
                        final sectionKey = section['key'];
                        final subSections =
                            (section['subSections'] ?? []) as List<dynamic>;
                        final repeatableSub = subSections
                            .cast<Map<String, dynamic>>()
                            .firstWhere((s) => s['type'] == 'repeatable',
                                orElse: () => {});
                        final effectiveKey = repeatableSub.isNotEmpty
                            ? repeatableSub['key']
                            : sectionKey;
                        final RxBool isComplete =
                            sectionCompletion[effectiveKey]!;
                        final isLocked = false;

                        Widget sectionWidget;

                        if (section['type'] == 'repeatable') {
                          sectionWidget = buildCollapsibleSection(
                            sectionKey: sectionKey,
                            title: section['title'],
                            isLocked: isLocked,
                            complete: isComplete,
                            children: [buildRepeatableGroup(section)],
                          );
                        } else if (section['type'] == 'totaling') {
                          sectionWidget = buildCollapsibleSection(
                            sectionKey: sectionKey,
                            title: section['title'],
                            isLocked: isLocked,
                            complete: isComplete,
                            children: [buildTotalingSection(section)],
                          );
                        } else {
                          final regularSubsections =
                          buildRegularSectionFields(section, sectionIndex: activeSectionIndex.value);
                          sectionWidget = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: regularSubsections,
                          );
                        }

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            // In animation
                            final slideIn = Tween<Offset>(
                              begin: const Offset(-1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation);

                            final fadeIn = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(animation);

                            return SlideTransition(
                              position: slideIn,
                              child: FadeTransition(
                                opacity: fadeIn,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            key: ValueKey(
                                sectionKey), // Trigger animation on section change
                            child: sectionWidget,
                          ),
                        );
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.redAccent, // Button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Rounded rectangle
                                ),
                              ),
                              child: Text(
                                "Exit Application",
                                style: TextStyle(
                                    color: Colors.white), // Text color
                              ),
                            ),
                          ),
                          Obx(() {
                            final currentSection =
                                formSections[activeSectionIndex.value];
                            final sectionKey = currentSection['key'];
                            final isComplete =
                                sectionCompletion[sectionKey]?.value ?? false;
                            final isLastSection = activeSectionIndex.value ==
                                formSections.length - 1;

                            return SizedBox(
                              width: 200,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: isComplete
                                    ? () {
                                        if (!isLastSection) {
                                          activeSectionIndex.value++;
                                        } else {
                                          // 🔔 Final submit logic or go to review screen
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  isLastSection ? "Submit" : "Continue",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          })
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildRegularSectionFields(Map<String, dynamic> section, {required int sectionIndex}) {
    final List<Widget> children = [];

    final subSections = section['subSections'] ?? [];
    for (int subIndex = 0; subIndex < subSections.length; subIndex++) {
      final sub = subSections[subIndex];
      final subKey = sub['key'];
      final title = sub['title'] ?? 'Untitled';
      final numberLabel = "${sectionIndex + 1}.${subIndex + 1} $title";

      final RxBool isSubComplete = sectionCompletion[subKey] ?? false.obs;

      if (sub['type'] == 'repeatable') {
        children.add(
          buildCollapsibleSection(
            title: numberLabel,
            complete: isSubComplete,
            sectionKey: subKey,
            children: [buildRepeatableGroup(sub)],
          ),
        );
      } else if (sub['type'] == 'totaling') {
        children.add(
          buildCollapsibleSection(
            title: numberLabel,
            complete: isSubComplete,
            sectionKey: subKey,
            children: [buildTotalingSubSection(sub, subKey)],
          ),
        );
      } else {
        final fields = sub['fields'] ?? [];

        children.add(
          buildCollapsibleSection(
            title: numberLabel,
            complete: isSubComplete,
            sectionKey: subKey,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double fullWidth = constraints.maxWidth;
                  const double spacing = 16;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: fields.map<Widget>((field) {
                      return SizedBox(
                        width: fullWidth,
                        child: buildDynamicField(field, subKey),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      }
    }

    return children;
  }

  Map<String, dynamic>? getSectionOrSubSectionByKey(String key) {
    for (final section in formSections) {
      if (section['key'] == key) return section;
      for (final sub in section['subSections'] ?? []) {
        if (sub['key'] == key) return sub;
      }
    }
    return null;
  }

  Widget buildTotalingSubSection(Map<String, dynamic> subSection, String subKey) {
    final fields = subSection['fields'] ?? [];

    return Obx(() {
      int total = fields.fold(0, (sum, field) {
        final key = field['key'];
        final value = textFields[key]?.value ?? '';
        return sum + (int.tryParse(value) ?? 0);
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total: $total",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black)),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xffffead1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxWidth = constraints.maxWidth;
                  const int itemsPerRow = 3;
                  const double spacing = 16;
                  final double itemWidth =
                      (maxWidth - (spacing * (itemsPerRow - 1))) / itemsPerRow;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: fields.map<Widget>((field) {
                      return SizedBox(
                        width: itemWidth,
                        child: buildDynamicField(field, subKey),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  final RxDouble formCompletionPercent = 0.0.obs;

  void updateFormProgress() {
    double totalPercent = 0;
    int totalSections = formSections.length;

    for (var section in formSections) {
      final key = section['key'] as String?;
      if (key == null) continue;

      final percent = getSectionCompletionPercentByKey(key);
      totalPercent += percent;
    }

    final formCompletion =
        totalSections == 0 ? 0.0 : (totalPercent / totalSections);
    formCompletionPercent.value = formCompletion;
  }
}

class StepperProgressDot extends StatelessWidget {
  final double percent;

  const StepperProgressDot({super.key, required this.percent});

  Color getProgressColor() {
    if (percent >= 100) return Colors.green;
    if (percent >= 70) return Colors.lightGreen;
    if (percent >= 40) return Colors.orange;
    if (percent > 0) return Colors.blueGrey;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = getProgressColor();

    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 3,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          percent >= 100
              ? const Icon(Icons.check, size: 10, color: Colors.green)
              : Text(
                  "${percent.round()}%",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
        ],
      ),
    );
  }
}

class SectionStep {
  final String title;
  final double completionPercent; // changed from bool to percent

  SectionStep({required this.title, required this.completionPercent});

  bool get isComplete => completionPercent >= 100;
}

class SectionStepper extends StatelessWidget {
  final List<SectionStep> sections;
  final int activeIndex;
  final double completionPercent;

  const SectionStepper({
    super.key,
    required this.sections,
    required this.activeIndex,
    required this.completionPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1),
      child: Column(
        spacing: 10,
        children: [
          Wrap(
            spacing: MediaQuery.of(context).size.width*0.02,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.015),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ITS: 30445124",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("Name: Abi Ali Qutbuddin",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ...List.generate(sections.length, (index) {
                final section = sections[index];
                final isActive = index == activeIndex;

                Color textColor = Colors.grey.shade700;
                FontWeight weight = FontWeight.w500;
                Color bgColor = Colors.grey.shade200;
                Color borderColor = Colors.transparent;

                if (section.isComplete) {
                  textColor = Colors.green.shade700;
                  bgColor = Colors.green.shade50;
                  borderColor = Colors.green.shade300;
                }

                if (isActive) {
                  textColor = Colors.brown.shade900;
                  weight = FontWeight.bold;
                  bgColor = const Color(0xfffce8d5);
                  borderColor = Colors.brown;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.brown.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        section.isComplete
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: section.isComplete
                            ? Colors.green
                            : isActive
                                ? Colors.brown
                                : Colors.grey.shade400,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        section.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: weight,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                );
              })
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 250),
            child: Row(
              children: [
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween:
                        Tween<double>(begin: 0, end: completionPercent / 100),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(20),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          value >= 1.0
                              ? Colors.green
                              : value >= 0.7
                                  ? Colors.lightGreen
                                  : value >= 0.4
                                      ? Colors.orange
                                      : Colors.redAccent,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  "${completionPercent.round()}%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
