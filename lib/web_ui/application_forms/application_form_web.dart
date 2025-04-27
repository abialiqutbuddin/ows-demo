import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/api/api.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/constants/dummy_data.dart';
import 'package:ows/web_ui/application_forms/review_application.dart';
import '../../constants/multi_select_dropdown.dart';
import '../../controller/state_management/state_manager.dart';
import '../../data/dropdown_options.dart';
import '../../data/form_config.dart';

GlobalStateController stateController = Get.find<GlobalStateController>();

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
  final Map<String, List<Map<String, dynamic>>> dropdownOptions =
      dropdownOptions2;
  late final Map<String, String? Function(String, String)> customValidators;
  final RxMap<String, MultiSelectDropdownController> multiSelectControllers =
      <String, MultiSelectDropdownController>{}.obs;
  final RxInt activeSectionIndex = 0.obs;
  final RxList<SectionStep> sectionSteps = <SectionStep>[].obs;
  final RxBool isLoading = true.obs;
  final GlobalStateController globalController =
      Get.find<GlobalStateController>();
  late final imageUrl;
  late bool fromEdit = false;

  @override
  void initState() {
    super.initState();
    globalController.user.value = userProfile111;

    isLoading.value = true;
    imageUrl = stateController.user.value.imageUrl;

    //Api.fetchImage(globalController.user.value.imageUrl!);
    initializeFormFields().then((_) async {
     // await loadDraftFromBackend('1');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Jump to the first incomplete section
        final firstIncompleteIndex = formSections.indexWhere((section) {
          final key = section['key'];
          return !(sectionCompletion[key]?.value ?? false);
        });

        // sectionCompletion["intendInfo"] = true.obs;
        // subsectionProgress["intendInfo"] = 100.0.obs;

        ///REMOVE
        sectionValidators['workInfo']?.call();


        if (firstIncompleteIndex != -1) {
          ///CHANGE -1 to 0
          activeSectionIndex.value = firstIncompleteIndex-1;
        }

        Future.delayed(const Duration(seconds: 2), () {
          isLoading.value = false;
          //activeSectionIndex.value = 5;
        });

      });
    });

    sectionCompletion["intendInfo"] = true.obs;
    subsectionProgress["intendInfo"] = 100.0.obs;

    sectionCompletion["workInfo"] = true.obs;
    subsectionProgress["workInfo"] = 100.0.obs;

    sectionValidators = {
      for (var section in formSections) ...{
        section['key']: () {
          final type = section['type'];
          if (type == 'repeatable') {
            validateRepeatableSection(section['key']);
          } else {
            validateSection(section['key']);
          }
        },
        for (var sub in (section['subSections'] ?? []))
          sub['key']: () {
            validateSection(section['key']);
          },
      }
    };

    customValidators = {
      'name': _validateName,
      'cnic': _validateCNIC,
      'email': _validateEmail,
      'its': _validateITS,
      'number': _validateNumber,
      'dob': _validateDateOfBirth,
      'address': _validateAddress,
      'phone': _validatePhoneNumber,
      'year': _validateYear,
      'age': _validateAge,
      'amount': _validateAmount,
    };
  }

  Future<void> saveDraft({String? sectionKey}) async {
    final dataToSave = <String, dynamic>{};

    final sectionsToProcess = sectionKey == null
        ? formSections
        : formSections.where((s) => s['key'] == sectionKey);

    for (var section in sectionsToProcess) {
      final subSections = section['subSections'] ?? [];

      for (var sub in subSections) {
        final subKey = sub['key'];
        final type = sub['type'];

        for (var field in sub['fields'] ?? []) {
          final key = field['key'];
          final fieldType = field['type'];

          if ((fieldType == 'text' || fieldType == 'radio') &&
              textFields.containsKey(key)) {
            dataToSave[key] = textFields[key]?.value;

            // ✅ Conditional text field
            if (field.containsKey('textFieldKey')) {
              final subKey = field['textFieldKey'];
              if (textFields.containsKey(subKey)) {
                dataToSave[subKey] = textFields[subKey]?.value;
              }
            }

            // ✅ Conditional dropdown
            if (field.containsKey('dropdownKey')) {
              final subKey = field['dropdownKey'];
              final selectedId = dropdownFields[subKey]?.value;
              final itemsKey = field['itemsKey'];
              final optionList = dropdownOptions2[itemsKey];
              final selectedName = optionList?.firstWhere(
                (item) => item['id'] == selectedId,
                orElse: () => {},
              )['name'];
              dataToSave[subKey] = selectedName ?? selectedId;
            }
          } else if (fieldType == 'dropdown' &&
              dropdownFields.containsKey(key)) {
            final selectedId = dropdownFields[key]?.value;
            final optionsKey = field['itemsKey'];
            final optionList = dropdownOptions2[optionsKey];
            final selectedName = optionList?.firstWhere(
              (item) => item['id'] == selectedId,
              orElse: () => {},
            )['name'];

            dataToSave[key] = selectedName ?? selectedId;

            if (field.containsKey('textFieldKey')) {
              final subKey = field['textFieldKey'];
              if (textFields.containsKey(subKey)) {
                dataToSave[subKey] = textFields[subKey]?.value;
              }
            }

            if (field.containsKey('dropdownKey')) {
              final subKey = field['dropdownKey'];
              final selectedId = dropdownFields[subKey]?.value;
              final itemsKey2 = field['itemsKey2'];
              final optionList2 = dropdownOptions2[itemsKey2];
              final selectedName = optionList2?.firstWhere(
                (item) => item['id'] == selectedId,
                orElse: () => {},
              )['name'];
              dataToSave[subKey] = selectedName ?? selectedId;
            }
          } else if (fieldType == 'multiselect' &&
              multiSelectControllers.containsKey(key)) {
            final values =
                multiSelectControllers[key]?.selectedValues.toList() ?? [];

            dataToSave[key] = values;

            final encoded = base64Encode(utf8.encode(jsonEncode(values)));
            dataToSave['${key}_base64'] = encoded;
          }
        }

        // Handle repeatable sections
        if (type == 'repeatable') {
          final entries = repeatableEntries[subKey];
          if (entries != null) {
            if (entries.isEmpty) {
              dataToSave['${subKey}_base64'] =
                  null; // Set as null if no entries
            } else {
              final List<Map<String, dynamic>> rawData = entries.map((entry) {
                return entry.map(
                    (k, v) => MapEntry(k, v is RxString ? v.value : v.value));
              }).toList();

              final jsonEncoded = jsonEncode(rawData);
              final encoded = base64Encode(utf8.encode(jsonEncoded));

              dataToSave['${subKey}_base64'] = encoded;
            }
          }
        }
      }
    }

    if (dataToSave.isEmpty) {
      print("⚠️ No data to save for section: ${sectionKey ?? 'entire form'}");
    }

    await Api.postDraftUpdateToBackend(dataToSave);
  }

  Future<void> loadDraftFromBackend(String appId) async {
    try {
      final data = await Api.loadDraftFromBackend(appId);
      data.forEach((key, value) {
        if (key.endsWith('_base64')) {
          try {
            if (value != null && value is String) {
              final decodedJson = utf8.decode(base64Decode(value));

              final parsed = jsonDecode(decodedJson);

              final fieldKey = key.replaceAll('_base64', '');

              // Case 1: Multiselect – List<String>
              if (multiSelectControllers.containsKey(fieldKey) &&
                  parsed is List) {
                final values = List<String>.from(parsed);
                multiSelectControllers[fieldKey]
                    ?.selectedValues
                    .assignAll(values);
              }

              // Case 2: Repeatable Section – List<Map<String, dynamic>>
              else if (repeatableEntries.containsKey(fieldKey) &&
                  parsed is List) {
                final mappedList = parsed.map<Map<String, dynamic>>((e) {
                  return (e as Map<String, dynamic>).map((k, v) {
                    if (v is int) return MapEntry(k, Rxn<int>(v));
                    if (v is String) return MapEntry(k, v.obs);
                    return MapEntry(k, ''.obs); // fallback
                  });
                }).toList();

                repeatableEntries[fieldKey]?.assignAll(mappedList);
              }
            }
          } catch (e) {
            throw Exception(e);
          }
        } else if (textFields.containsKey(key)) {
          textFields[key]?.value = value?.toString() ?? '';

          // ⬇️ Check if it's a radio with conditional fields
          final fieldConfig = formSections
              .expand((s) => s['subSections'] ?? [])
              .expand((sub) => sub['fields'] ?? [])
              .cast<Map<String, dynamic>>()
              .firstWhere((f) => f['key'] == key, orElse: () => {});

          if (fieldConfig.isNotEmpty && fieldConfig['type'] == 'radio') {
            final String? radioValue = value?.toString();

            // 🟠 Conditional Text Field
            if (fieldConfig.containsKey('showTextFieldIf') &&
                radioValue == fieldConfig['showTextFieldIf']) {
              final subKey = fieldConfig['textFieldKey'];
              if (subKey != null && textFields.containsKey(subKey)) {
                textFields[subKey]?.value = data[subKey]?.toString() ?? '';
              }
            }

            // 🟡 Conditional Dropdown Field
            if (fieldConfig.containsKey('showDropdownIf') &&
                radioValue == fieldConfig['showDropdownIf']) {
              final subKey = fieldConfig['dropdownKey'];
              final itemsKey = fieldConfig['itemsKey'];
              final optionList = dropdownOptions2[itemsKey];
              final dropdownValue = data[subKey];

              Map<String, dynamic>? match;
              try {
                match = optionList?.firstWhere(
                  (item) =>
                      item['name']?.toString().trim() ==
                      dropdownValue?.toString().trim(),
                  orElse: () => {},
                );
              } catch (_) {
                match = null;
              }

              if (subKey != null && dropdownFields.containsKey(subKey)) {
                Future.delayed(Duration.zero, () {
                  dropdownFields[subKey]?.value = match?['id'] ??
                      int.tryParse(dropdownValue?.toString() ?? '');
                });
              }
            }
          }
        } else if (dropdownFields.containsKey(key)) {
          final fieldConfig = formSections
              .expand((s) => s['subSections'] ?? [])
              .expand((sub) => sub['fields'] ?? [])
              .where((f) => f['key'] == key)
              .cast<Map<String, dynamic>>()
              .toList()
              .firstWhere((_) => true, orElse: () => {});

          if (fieldConfig.isNotEmpty && fieldConfig.containsKey('itemsKey')) {
            final optionsKey = fieldConfig['itemsKey'];
            final optionList = dropdownOptions2[optionsKey];

            Map<String, dynamic>? matched;
            try {
              matched = optionList?.firstWhere(
                (item) =>
                    item['name']?.toString().trim() == value?.toString().trim(),
                orElse: () => {},
              );
            } catch (_) {
              matched = null;
            }

            if (matched != null && matched.containsKey('id')) {
              dropdownFields[key]?.value = matched['id'];
            }
          } else {
            final parsed = int.tryParse(value?.toString() ?? '');
            dropdownFields[key]?.value = parsed;
          }

          // ✅ Conditional dropdown logic
          if (fieldConfig.containsKey('dropdownKey')) {
            final conditionalKey = fieldConfig['dropdownKey'];
            if (dropdownFields.containsKey(conditionalKey) &&
                data.containsKey(conditionalKey)) {
              final optionList = dropdownOptions2[fieldConfig['itemsKey2']];
              final conditionalValue = data[conditionalKey];

              Map<String, dynamic>? match;
              try {
                match = optionList?.firstWhere(
                  (item) =>
                      item['name']?.toString().trim() ==
                      conditionalValue?.toString().trim(),
                  orElse: () => {},
                );
              } catch (_) {
                match = null;
              }

              if (match != null && match.containsKey('id')) {
                // 👇 ensure reactive update after frame build
                Future.delayed(Duration.zero, () {
                  dropdownFields[conditionalKey]?.value = match!['id'];
                });
              }
            }
          }
        } else if (multiSelectControllers.containsKey(key)) {
          final listVal = value is List ? value.cast<String>() : <String>[];
          multiSelectControllers[key]?.selectedValues.assignAll(listVal);
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        sectionValidators.forEach((_, v) => v());
        updateFormProgress();

        // 🔍 Set to first incomplete section
        final firstIncompleteIndex = formSections.indexWhere((section) {
          final key = section['key'];
          return !(sectionCompletion[key]?.value ?? false);
        });

        if (firstIncompleteIndex != -1) {
          activeSectionIndex.value = firstIncompleteIndex;
        }
      });
    } catch (e) {
      debugPrint("❌ Failed to load draft: $e");
    }
  }

  String? validateField(String label, dynamic value, {String? validatorKey}) {
    final strValue = value?.toString() ?? '';
    if (strValue.trim().isEmpty) return "* $label is required";

    if (validatorKey != null && customValidators.containsKey(validatorKey)) {
      return customValidators[validatorKey]!(strValue, label);
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

      // if (section['type'] == 'repeatable') {
      //   repeatableSectionRadio[sectionKey] = 0.obs;
      //   repeatableEntries[sectionKey] = <Map<String, dynamic>>[].obs;
      //   continue;
      // } else if (section['type'] == 'totaling') {
      //   for (var sub in section['subSections'] ?? []) {
      //     for (var field in sub['fields']) {
      //       final key = field['key'];
      //       textFields.putIfAbsent(key, () => ''.obs);
      //     }
      //   }
      // }

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

          if (field['type'] == 'text' || field['type'] == 'fetch-its') {
            textFields.putIfAbsent(key, () => ''.obs);
            // 🚀 Initialize the “work” field:
            if (key == 'work') {
               textFields[key]!.value = 'Demo Text';
            }
            if (field.containsKey('unitKey')) {
              final unitKey = field['unitKey'];
              dropdownFields.putIfAbsent(
                  unitKey, () => Rxn<int>(0)); // default 0
            }
          } else if (field['type'] == 'dropdown') {
            dropdownFields.putIfAbsent(key, () => Rxn<int>());

            if (field.containsKey('textFieldKey')) {
              textFields.putIfAbsent(field['textFieldKey'], () => ''.obs);
            }

            if (field.containsKey('dropdownKey')) {
              dropdownFields.putIfAbsent(
                  field['dropdownKey'], () => Rxn<int>());
            }
          }
          if (field['type'] == 'radio') {
            textFields.putIfAbsent(key, () => ''.obs);

            if (field.containsKey('textFieldKey')) {
              textFields.putIfAbsent(field['textFieldKey'], () => ''.obs);
            }

            if (field.containsKey('dropdownKey')) {
              dropdownFields.putIfAbsent(
                  field['dropdownKey'], () => Rxn<int>());
            }

            // 🛠 NEW: Preinitialize conditional nested radio key
            if (field.containsKey('conditional_value') &&
                field.containsKey('condition_options') &&
                field.containsKey('on_condition')) {
              final nestedKey = "${key}_conditional";
              textFields.putIfAbsent(nestedKey, () => ''.obs);
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

    if (type == 'text' || type == 'fetch-its') {
      if (field.containsKey('unitKey')) {
        final unitKey = field['unitKey'];
        final unitOptions = field['unitOptions'] ?? [];

        return Row(
          children: [
            Expanded(
              flex: 3,
              child: constants.buildField(
                label,
                textFields[key]!,
                this,
                isEnabled: field['enable'],
                function: validationFunction,
                validatorKey: validatorKey,
                validator: (value) => validateField(label, value ?? '',
                    validatorKey: validatorKey),
              ),
            ),
            Expanded(
              flex: 2,
              child: constants.buildDropdown2(
                label: "Unit",
                selectedValue: dropdownFields[unitKey]!,
                items: List.generate(
                    unitOptions.length,
                    (index) => {
                          "id": index,
                          "name": unitOptions[index],
                        }),
                isEnabled: true,
                onChanged: (_) {
                  sectionValidators[sectionKey]?.call();
                },
              ),
            ),
          ],
        );
      }
      return constants.buildField(label, textFields[key]!, this,
          isEnabled: field['enable'],
          function: validationFunction,
          validatorKey: validatorKey,
          hint: field['hint'],
          validator: (value) =>
              validateField(label, value ?? '', validatorKey: validatorKey),
          onChanged: (value) async {
            final fillField = field['fill-field'];
            final functionName = field['function'];

            if (fillField != null && textFields.containsKey(fillField)) {
              if (value.length == 8) {
                if (functionName != null) {
                  final fetchedValue =
                      await runFetchFunction(functionName, value);
                  textFields[fillField]?.value = fetchedValue ?? '';
                  sectionValidators[sectionKey]?.call();
                }
              } else {
                // 🔥 Clear the field if ITS number is not 8 digits
                textFields[fillField]?.value = '';
                sectionValidators[sectionKey]?.call();
              }
            }
          });
    } else if (type == 'dropdown') {
      final options = getOptions(field['itemsKey']);
      final Rxn<int> selectedValue = dropdownFields[key]!;

      Widget? conditionalField;
      if (field.containsKey("showTextFieldIf")) {
        final int showIf = field['showTextFieldIf'];
        final String linkedKey = field["textFieldKey"];
        final String linkedLabel = field["textFieldLabel"];
        final RxString linkedVal = textFields[linkedKey]!;
        dynamic validatorKey = field['textFieldValidator'];

        conditionalField = Obx(() {
          final shouldShow = selectedValue.value == showIf;
          return Visibility(
            visible: shouldShow,
            maintainState: true,
            maintainAnimation: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: constants.buildField(
                linkedLabel,
                linkedVal,
                this,
                function: sectionValidators[sectionKey],
                validatorKey: validatorKey,
                validator: (value) => validateField(label, value ?? '',
                    validatorKey: validatorKey),
              ),
            ),
          );
        });
      } // ✅ Conditional Dropdown
      else if (field.containsKey("showDropdownIf")) {
        final int showIf = field['showDropdownIf'];
        final String linkedKey = field["dropdownKey"];
        final String linkedLabel = field["dropdownLabel"];
        final String itemsKey2 = field["itemsKey2"];
        final Rxn<int> linkedDropdownVal = dropdownFields[linkedKey]!;
        final List<Map<String, dynamic>> dropdownItems = getOptions(itemsKey2);

        conditionalField = Obx(() {
          final shouldShow = selectedValue.value == showIf;
          return Visibility(
            visible: shouldShow,
            maintainState: true,
            maintainAnimation: true,
            child: constants.buildDropdown2(
              label: linkedLabel,
              selectedValue: linkedDropdownVal,
              items: dropdownItems,
              isEnabled: true,
              onChanged: (_) {
                if (sectionValidators[sectionKey] != null) {
                  sectionValidators[sectionKey]!();
                }
              },
            ),
          );
        });
      }

      return Column(
        spacing: 5,
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
        dynamic validatorKey = field['textFieldValidator'];
        print(validatorKey);
        conditionalWidget = constants.buildField(
          field['textFieldLabel'],
          linked,
          this,
          validatorKey: validatorKey,
          validator: (value) =>
              validateField(label, value ?? '', validatorKey: validatorKey),
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

      // if (field.containsKey('conditional_value') &&
      //     field.containsKey('condition_options') &&
      //     field.containsKey('on_condition')) {
      //   final String conditionalLabel = field['conditional_value'];
      //   final List<dynamic> conditionalOptions = field['condition_options'];
      //   final String triggerValue = field['on_condition'];

      //   final nestedRadioKey = "${key}_conditional";
      //   final RxString nestedSelected =
      //       textFields[nestedRadioKey]!; // just access it

      //   conditionalWidget = Obx(() {
      //     final shouldShow = selected.value == triggerValue;
      //     return Visibility(
      //       visible: shouldShow,
      //       maintainState: true,
      //       maintainAnimation: true,
      //       child: radioAsk(
      //         conditionalLabel,
      //         nestedSelected,
      //         option1: conditionalOptions[0],
      //         option2: conditionalOptions[1],
      //         onChanged: () {
      //           if (sectionValidators[sectionKey] != null) {
      //             sectionValidators[sectionKey]!();
      //           }
      //         },
      //       ),
      //     );
      //   });
      // }

      bool hasNestedRadio = field.containsKey('conditional_value') &&
          field.containsKey('condition_options') &&
          field.containsKey('on_condition');

      if (hasNestedRadio) {
        final String conditionalLabel = field['conditional_value'];
        final List<dynamic> conditionalOptions = field['condition_options'];
        final String triggerValue = field['on_condition'];

        final nestedRadioKey = "${key}_conditional";
        final RxString nestedSelected = textFields[nestedRadioKey]!;

        return radioAsk(
          field['label'],
          selected,
          option1: options[0],
          option2: options[1],
          showFieldIf: triggerValue,
          buildConditionalField: true, // 👈 important!
          buildConditionalWidget: () => radioAsk(
            conditionalLabel,
            nestedSelected,
            option1: conditionalOptions[0],
            option2: conditionalOptions[1],
            onChanged: () {
              if (sectionValidators[sectionKey] != null) {
                sectionValidators[sectionKey]!();
              }
            },
          ),
          onChanged: () {
            if (sectionValidators[sectionKey] != null) {
              sectionValidators[sectionKey]!();
            }
          },
        );
      } else {
        // 👇 This was your missing "else" part properly
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
        );
      }
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
    bool buildConditionalField = false, // 🔥 add this
    Widget Function()? buildConditionalWidget, // 🔥 add this
  }) {
    return Column(
      spacing: 0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xfffff7ec),
          ),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Container(
                height: 40,
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
            ],
          ),
        ),
        if (buildConditionalField && buildConditionalWidget != null)
          Obx(() {
            final shouldShow =
                showFieldIf == null || value.value == showFieldIf;
            return shouldShow
                ? buildConditionalWidget()
                : const SizedBox.shrink();
          }),
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
          }),
        //Divider(height: 0,indent: 0,endIndent: 0,color: Colors.black,),
      ],
    );
  }

  void validateSection(String sectionKey) {
    final section =
        formSections.firstWhereOrNull((s) => s['key'] == sectionKey);
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
                    })));

        if (!isSubValid) isValid = false;

        final double subPercent;
        if (isNoExpense) {
          subPercent = 100.0;
        } else {
          final totalFields = entries.length * fields.length;
          final filledFields = entries.fold<int>(0, (sum, entry) {
            return sum +
                fields.where((f) {
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
        if (subsectionProgress[subKey]!.value == 100.0) {
          //saveSubsectionAsDraft(subKey);
        }
      } else {
        int filled = fields.where((f) => validateSingleField(f)).length;
        int total = fields.length;
        final subPercent = total == 0 ? 100.0 : (filled / total) * 100.0;

        if (subsectionProgress.containsKey(subKey)) {
          subsectionProgress[subKey]!.value = subPercent;
        } else {
          subsectionProgress[subKey] = subPercent.obs;
        }

        if (subsectionProgress[subKey]!.value == 100.0) {
          //saveSubsectionAsDraft(subKey);
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

    if (type == 'text' || type == 'fetch-its') {
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

      // ✅ Check conditional dropdown if visible
      if (field.containsKey('showDropdownIf') &&
          val == field['showDropdownIf']) {
        final linkedKey = field['dropdownKey'];
        final linkedVal = dropdownFields[linkedKey]?.value;
        if (linkedVal == null) return false;
      }

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

    if (type == 'repeatable') {
      final entries = repeatableEntries[key];
      final fields = field['fields'] ?? [];

      if (entries == null || entries.isEmpty) {
        return false;
      }

      // validate each mini entry inside repeatable
      for (var entry in entries) {
        for (var f in fields) {
          final miniKey = f['key'];
          final miniType = f['type'];
          final miniVal = entry[miniKey];

          if (miniType == 'dropdown') {
            if (miniVal == null || miniVal.value == null) return false;
          } else {
            if (miniVal == null || miniVal.value.toString().trim().isEmpty)
              return false;
          }
        }
      }

      return true; // ✅ all entries valid
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

    final isRadioChecked = selectedType.value == 1;

    double percent = 0.0;

    if (isRadioChecked) {
      percent = 100.0;
    } else if (entries.isNotEmpty) {
      final totalFields = entries.length * fields.length;
      int filledFields = 0;

      for (var entry in entries) {
        for (var field in fields) {
          final key = field['key'];
          final type = field['type'];
          final val = entry[key];

          if (type == 'dropdown') {
            if (val != null && val.value != null) filledFields++;
          } else {
            if (val != null &&
                val.value != null &&
                val.value.toString().trim().isNotEmpty) {
              filledFields++;
            }
          }
        }
      }

      percent = totalFields == 0 ? 0.0 : (filledFields / totalFields) * 100.0;
    }

    subsectionProgress[repeatableKey] = percent.obs;
    sectionCompletion[repeatableKey]?.value = percent >= 100;
    sectionCompletion.refresh();
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
    final List<dynamic> fields = section['fields'] ?? [];

    if (selectedType == null || entries == null) {
      return const Text(
        "Repeatable section not initialized properly.",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Radio Toggle
        Obx(() => Row(
              children: [
                Radio(
                  value: 1,
                  toggleable: true,
                  groupValue: selectedType.value,
                  onChanged: (value) {
                    selectedType.value = value ?? 0;
                    validateRepeatableSection(
                        sectionKey); // revalidate immediately
                    sectionCompletion
                        .refresh(); // 🛠 refresh all completion states
                    repeatableEntries[sectionKey]!.refresh();
                  },
                ),
                Text(
                  radioLabel,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            )),
        // Repeatable Entries UI
        Obx(() {
          if (selectedType.value != 0) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
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
                    currentRow.add(
                      constants.buildDropdown2(
                        label: label,
                        selectedValue: value as Rxn<int>,
                        items: getOptions(field['itemsKey']),
                        isEnabled: true,
                        onChanged: (_) => validateRepeatableSection(sectionKey),
                      ),
                    );

                    if (currentRow.length == 3) {
                      rows.add(Row(
                        children: currentRow
                            .map((w) => Expanded(
                                  child: w,
                                ))
                            .toList(),
                      ));
                      currentRow = [];
                    }
                  } else {
                    // Add text field to current row
                    currentRow.add(
                      constants.buildField(
                        label,
                        value as RxString,
                        this,
                        validatorKey: field['validator'],
                        validator: (v) => validateField(label, v ?? '',
                            validatorKey: field['validator']),
                        function: () => validateRepeatableSection(sectionKey),
                      ),
                    );

                    if (currentRow.length == 3) {
                      rows.add(Row(
                        children: currentRow
                            .map((w) => Expanded(
                                  child: w,
                                ))
                            .toList(),
                      ));
                      currentRow = [];
                    }
                  }
                }
                if (currentRow.isNotEmpty) {
                  rows.add(Row(
                    children: currentRow
                        .map((w) => Expanded(
                              child: w,
                            ))
                        .toList(),
                  ));
                }

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xfffff7ec),
                  ),
                  child: Column(
                    children: [
                      ...rows,
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10, right: 8),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // full red
                              foregroundColor:
                                  Colors.white, // text and icon will be white
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              elevation: 0,
                            ),
                            onPressed: () {
                              entries.removeAt(index);
                              repeatableEntries[sectionKey]!.refresh();
                              validateRepeatableSection(sectionKey);
                            },
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: const Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // green background
                    foregroundColor: Colors.white, // white text and icon
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
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
                      newEntry[key] =
                          field['type'] == 'dropdown' ? Rxn<int>() : ''.obs;
                    }

                    entries.add(newEntry);
                    repeatableEntries[sectionKey]!.refresh();
                    validateRepeatableSection(sectionKey);
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Add",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
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

  Future<String?> runFetchFunction(
      String functionName, String itsNumber) async {
    try {
      switch (functionName) {
        case 'fetchFatherITS':
          return "QUTUBDDIN";
        case 'fetchMotherITS':
          return "TASNEEM";
        default:
          throw Exception('Unknown function: $functionName');
      }
    } catch (e) {
      debugPrint('Error running function $functionName: $e');
      return null;
    }
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

  String? _validateAmount(String value, String label) {
    if (value.isEmpty) {
      return "$label is required";
    }

    // Match integers or decimals like 25 or 25.00 or 120.5
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      return "$label must be a valid number (up to 2 decimal places)";
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
    // Remove dashes before validating the length and digits
    String numericValue = value.replaceAll('-', '');

    if (!RegExp(r'^\d{13}$').hasMatch(numericValue)) {
      return "CNIC must be 13 digits (e.g., 42301-5722319-5)";
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

  bool isSectionReallyComplete(String sectionKey) {
    final percent = getSectionCompletionPercentByKey(sectionKey);
    return percent >= 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffcf6),
      body: Obx(() => isLoading.value
          ? Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.white,
                size: 80,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin:
                      const EdgeInsets.only(top: 20.0, left: 15, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Imdaad Talimi Application Form",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black87),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          spacing: 10,
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.brown.shade100,
                              child: ClipOval(
                                child: (imageUrl != null && imageUrl.isNotEmpty)
                                    ? Image.network(
                                        Api.fetchImage(imageUrl),
                                        fit: BoxFit
                                            .fitWidth, // 👈 fits the image without zoom/crop
                                        width: 50,
                                        height: 50,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 26,
                                            color: Colors.brown.shade700,
                                          );
                                        },
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 26,
                                        color: Colors.brown.shade700,
                                      ),
                              ),
                            ),
                            Text(
                              //stateController.user.value.itsId.toString(),
                              "Aliasghar Khumusi",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "|",
                              style: TextStyle(fontSize: 26),
                            ),
                            Text(
                                //stateController.user.value.fullName.toString(),
                                "30445124",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // Only progress updates reactively
                Obx(() {
                  final steps = formSections.map<SectionStep>((section) {
                    final key = section['key'];
                    final percent = getSectionCompletionPercentByKey(key);
                    return SectionStep(
                      title: section['title'],
                      completionPercent: percent,
                    );
                  }).toList();

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

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 150),
                      child: Column(
                        children: [
                          // Section UI rebuilds only on section switch
                          Obx(() {
                            final section =
                                formSections[activeSectionIndex.value];
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

                            final isComplete = sectionCompletion[effectiveKey]!;

                            Widget sectionWidget;
                            if (section['type'] == 'repeatable') {
                              sectionWidget = buildCollapsibleSection(
                                sectionKey: sectionKey,
                                title: section['title'],
                                isLocked: false,
                                complete: isComplete,
                                children: [buildRepeatableGroup(section)],
                              );
                            } else {
                              final regularSubsections =
                                  buildRegularSectionFields(section,
                                      sectionIndex: activeSectionIndex.value);
                              sectionWidget = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: regularSubsections,
                              );
                            }

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) =>
                                  SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(-1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                              child: Container(
                                key: ValueKey(sectionKey),
                                child: sectionWidget,
                              ),
                            );
                          }),

                          // Bottom Button Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () => saveDraft(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Save & Exit Application",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),

                              // Only Continue button state is reactive
                              Obx(() {
                                final currentSection =
                                    formSections[activeSectionIndex.value];
                                final subSections =
                                    (currentSection['subSections'] ?? [])
                                        as List<dynamic>;

                                String effectiveKey =
                                    currentSection['key']; // default

                                // 👉 Find the first subSection which is NOT 100% complete
                                for (var sub in subSections) {
                                  final subKey = sub['key'];
                                  final percent =
                                      subsectionProgress[subKey]?.value ?? 0.0;

                                  if (percent < 100) {
                                    effectiveKey = subKey;
                                    break;
                                  }
                                }

                                final isComplete =
                                    isSectionReallyComplete(effectiveKey);
                                final isLast = activeSectionIndex.value ==
                                    formSections.length - 1;

                                return SizedBox(
                                  width: 200,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: isComplete
                                        ? () {
                                            //saveDraft(sectionKey: sectionKey);
                                      if(fromEdit){
                                        Get.to(() => ReviewScreen(
                                          formSections: formSections,
                                          textFields: textFields,
                                          dropdownFields:
                                          dropdownFields,
                                          repeatableEntries:
                                          repeatableEntries,
                                          dropdownOptions:
                                          dropdownOptions,
                                          onBackToEdit:
                                              (String sectionKey) {
                                            final index = formSections
                                                .indexWhere((s) =>
                                            s['key'] ==
                                                sectionKey);
                                            if (index != -1) {
                                              activeSectionIndex
                                                  .value = index;
                                              Get.back();
                                            }
                                              fromEdit = true;
                                          },
                                        ));
                                      }
                                            if (!isLast) {
                                              activeSectionIndex.value++;
                                              scrollController.animateTo(
                                                0.0,
                                                duration:
                                                    Duration(milliseconds: 400),
                                                curve: Curves.easeInOut,
                                              );
                                            } else {
                                              Get.to(() => ReviewScreen(
                                                    formSections: formSections,
                                                    textFields: textFields,
                                                    dropdownFields:
                                                        dropdownFields,
                                                    repeatableEntries:
                                                        repeatableEntries,
                                                    dropdownOptions:
                                                        dropdownOptions,
                                                    onBackToEdit:
                                                        (String sectionKey) {
                                                      final index = formSections
                                                          .indexWhere((s) =>
                                                              s['key'] ==
                                                              sectionKey);
                                                      if (index != -1) {
                                                        activeSectionIndex
                                                            .value = index;
                                                        Get.back();
                                                      }
fromEdit = true;
                                                    },
                                                  ));
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
                                      isLast ? "Submit" : "Continue",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Static Instructions
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Application Filling Instructions:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text("All fields are mandatory"),
                                Text("Each tab has a separate display tab"),
                                Text(
                                    "Applicant may exit form and rejoin from exit point in between"),
                                Text(
                                    "Application fill tab by tab, no forward tab filling"),
                                Text(
                                    "In the end, preview full form with tab edit button"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
    );
  }

  final ScrollController scrollController = ScrollController();
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  List<Widget> buildRegularSectionFields(Map<String, dynamic> section,
      {required int sectionIndex}) {
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
                  List<Widget> fieldRows = [];
                  final fieldsList = fields.asMap().entries.toList();

                  for (int i = 0; i < fieldsList.length; i++) {
                    final entry = fieldsList[i];
                    final field = entry.value;
                    final fieldType = field['type'];

                    if (fieldType == 'repeatable') {
                      // 🔥 Mini Repeatable Field
                      fieldRows.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: buildMiniRepeatableGroup(field, subKey),
                        ),
                      );
                      continue; // ✅ SKIP next steps and go to next i
                    }

                    final rowChildren = <Widget>[];

                    for (int j = i; j < i + 2 && j < fieldsList.length; j++) {
                      final innerEntry = fieldsList[j];
                      final innerFieldIndex = innerEntry.key;
                      final innerField = innerEntry.value;
                      final innerFieldType = innerField['type'];

                      if (innerFieldType == 'repeatable')
                        break; // don't put a repeatable inside normal row

                      rowChildren.add(
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 155),
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xfffff7ec),
                              borderRadius: BorderRadius.circular(8),
                              //border: Border.all(color: Colors.brown.shade100),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${sectionIndex + 1}.${subIndex + 1}.${innerFieldIndex + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                    fontSize: 13,
                                  ),
                                ),
                                buildDynamicField(innerField, subKey),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    fieldRows.add(Row(children: rowChildren));

                    i++; // ✅ MOVE i to next after j (because we did 2 fields at a time)
                  }

                  return Column(children: fieldRows);
                },
              ),
            ],
          ),
        );
      }
    }

    return children;
  }

  Widget buildMiniRepeatableGroup(
      Map<String, dynamic> field, String parentSubKey) {
    final key = field['key'];
    final fields = field['fields'] ?? [];

    final entries =
        repeatableEntries.putIfAbsent(key, () => <Map<String, dynamic>>[].obs);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field['label'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            return Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...entries.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final data = entry.value;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xfffff7ec),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: fields.map<Widget>((f) {
                              final fKey = f['key'];
                              final fLabel = f['label'];
                              final fType = f['type'];
                              final fValidator = f['validator'];

                              if (fType == 'dropdown') {
                                return Flexible(
                                  child: Constants().buildDropdown2(
                                    label: fLabel,
                                    selectedValue: data[fKey],
                                    items: getOptions(f['itemsKey']),
                                    isEnabled: true,
                                    onChanged: (_) {},
                                  ),
                                );
                              } else {
                                return Flexible(
                                  child: Constants().buildField(
                                    fLabel,
                                    data[fKey],
                                    this,
                                    validatorKey: fValidator,
                                    validator: (value) => validateField(
                                        fLabel, value ?? '',
                                        validatorKey: fValidator),
                                  ),
                                );
                              }
                            }).toList(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10, right: 8),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // full red
                                foregroundColor:
                                    Colors.white, // text and icon will be white
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                elevation: 0,
                              ),
                              onPressed: () {
                                entries.removeAt(index);
                                entries.refresh();
                              },
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text(
                                "Delete",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // green background
                        foregroundColor: Colors.white, // white text and icon
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final allValid = entries.every((entry) {
                          return fields.every((f) {
                            final fKey = f['key'];
                            final fType = f['type'];
                            final val = entry[fKey];

                            if (fType == 'dropdown') {
                              return val != null && val.value != null;
                            } else {
                              return val != null &&
                                  val.value != null &&
                                  val.value.toString().trim().isNotEmpty;
                            }
                          });
                        });

                        if (!allValid) {
                          return;
                        }

                        final newEntry = <String, dynamic>{};
                        for (var f in fields) {
                          final fKey = f['key'];
                          newEntry[fKey] =
                              (f['type'] == 'dropdown') ? Rxn<int>() : ''.obs;
                        }
                        entries.add(newEntry);
                        entries.refresh();
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
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

  Widget buildTotalingSubSection(
      Map<String, dynamic> subSection, String subKey) {
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
                    children: fields.asMap().entries.map<Widget>((entry) {
                      final index = entry.key;
                      final field = entry.value;
                      final sectionIndex = formSections.indexWhere((s) =>
                          s['subSections']
                              ?.any((sub) => sub['key'] == subKey) ??
                          false);
                      final subIndex = formSections[sectionIndex]['subSections']
                          .indexWhere((sub) => sub['key'] == subKey);
                      final fieldNumber =
                          "${sectionIndex + 1}.${subIndex + 1}.${index + 1}";

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xfffff7ec),
                        ),
                        child: SizedBox(
                          width: itemWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 13.0, top: 8),
                                child: Text(
                                  fieldNumber,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.brown),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: buildDynamicField(field, subKey),
                              )
                            ],
                          ),
                        ),
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
  final double completionPercent;

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
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          Wrap(
            spacing: 15,
            runSpacing: 8,
            children: sections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
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
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.3),
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
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      section.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: weight,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 250),
            child: Row(
              spacing: 15,
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
                        minHeight: 4,
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
                Text(
                  "${completionPercent.round()}%",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
