import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/api/api.dart';
import 'package:ows/constants/app_routes.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/web_ui/application_forms/review_application.dart';
import '../../constants/multi_select_dropdown.dart';
import '../../controller/admin/view_req_forms.dart';
import '../../controller/request_form_controller.dart';
import '../../controller/state_management/state_manager.dart';
import '../../data/dropdown_options.dart';
import '../../data/form_config.dart';
import '../../model/document.dart';
import '../widgets/show_instructions_dialog.dart';
import 'documents_upload.dart';

final RxInt activeSectionIndex = 0.obs;
GlobalStateController stateController = Get.find<GlobalStateController>();
List<Map<String, dynamic>> formSections = [];

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
  final RxMap<String, RxBool> sectionCompletion = <String, RxBool>{}.obs;
  final Map<String, RxInt> repeatableSectionRadio = {};
  final Map<String, RxList<Map<String, dynamic>>> repeatableEntries = {};
  late final Map<String, Function()> sectionValidators;
  final Map<String, List<Map<String, dynamic>>> dropdownOptions =
      DropdownValues.dropdownOptions2;
  late final Map<String, String? Function(String, String)> customValidators;
  final RxMap<String, MultiSelectDropdownController> multiSelectControllers =
      <String, MultiSelectDropdownController>{}.obs;
  final RxList<SectionStep> sectionSteps = <SectionStep>[].obs;
  final RxBool isLoading = true.obs;
  final GlobalStateController globalController =
      Get.find<GlobalStateController>();
  late final String imageUrl;
  late bool fromEdit = false;
  Map<String, dynamic>? _initiallyCompletedWorkInfo;
  final ReqFormController reqFormController = Get.find<ReqFormController>();

  Future<List<Map<String, dynamic>>> fetchFormSections() async {
    try {
      formSections = formConfig;
      setState(() {});
      return formSections;
    } catch (e) {
      throw Exception('Failed to load form config from assets: $e');
    }
  }

  initFormSection() async {
    await fetchFormSections();
  }

  late final List<Map<String, dynamic>> guardianOccupation;
  late final List<Map<String, dynamic>> motherOccupation;
  late final List<Map<String, dynamic>> fatherOccupation;

  bool fatherOccupationAvailable = false;
  bool motherOccupationAvailable = false;

  bool _hideWorkInfoInitially = false;

  getWorkInfo() async {
    motherOccupation = await Api.getWorkInfo(stateController.motherITS.value);
    fatherOccupation = await Api.getWorkInfo(stateController.fatherITS.value);

    if (isWorkInfoEmpty(motherOccupation)) {
      fatherOccupationAvailable=false;
    } else {
      fatherOccupationAvailable=true;
    }

    if (isWorkInfoEmpty(fatherOccupation)) {
      fatherOccupationAvailable=false;
    } else {
      fatherOccupationAvailable=true;
    }
  }

  bool isWorkInfoEmpty(List<Map<String, dynamic>> info) {
    if (info.isEmpty) {
      debugPrint("Debug: Work info list is empty.");
      return true;  // no data at all
    }

    final data = info.first;
    debugPrint("Debug: Checking first work info entry: $data");

    final emptyFields = [
      "strModeofWork",
      "strNameOrg",
      "strAddressOrg",
      "strWorkPhone",
      "strWorkEmail",
      "AccountingSystem",
      "InventoryManagement",
      "BusinessWebsite",
      "BusinessDetailedDescription",
      "strLegalbusiness"
    ];

    for (var field in emptyFields) {
      if (data.containsKey(field)) {
        final value = data[field];
        debugPrint("Debug: Field '$field' has value: '$value'");

        if (value != null && value.toString().trim().isNotEmpty && value != 'None') {
          debugPrint("Debug: Meaningful data found in field '$field', returning false.");
          return false; // Found a field with meaningful data
        }
      } else {
        debugPrint("Debug: Field '$field' not present in data.");
      }
    }

    debugPrint("Debug: All checked fields are empty or 'None'. Returning true.");
    return true; // All fields are empty or 'None'
  }

  void removeSubSectionsByKeys(List<String> keysToRemove) {
    for (final section in formSections) {
      if (section['subSections'] != null) {
        final List subSections = section['subSections'] as List;
        subSections.removeWhere((sub) => keysToRemove.contains(sub['key']));
      }
    }
  }

  List<String> aiut = ['enayat_liability', 'expenseBreakdown', 'sourcesofIncome'];
  List<String> stsmf = ['enayat_liability', 'expenseBreakdown', 'sourcesofIncome'];
  List<String> ambt = ['enayat_liability', 'expenseBreakdown', 'sourcesofIncome'];

  @override
  void initState() {
    super.initState();
    isLoading.value = true;
    imageUrl = stateController.user.value.imageUrl!;
    getWorkInfo().then((_) {
      initFormSection().then((_) {
        initializeFormFields().then((_) async {
          repeatableEntries['motherOccupationInfo'] =
              RxList<Map<String, dynamic>>.from(
            motherOccupation.map((entry) => {
                  "mother_mode_work": RxString(entry["strModeofWork"] ?? ""),
                  "mother_name_org": RxString(entry["strNameOrg"] ?? ""),
                  "mother_work_phone": RxString(entry["strWorkPhone"] ?? ""),
                  "mother_work_web": RxString(entry["BusinessWebsite"] ?? ""),
                  "mother_work_form": RxString(entry["strLegalbusiness"] ?? ""),
                  "mother_work_address": RxString(entry["strAddressOrg"] ?? ""),
                  "mother_work_email": RxString(entry["strWorkEmail"] ?? ""),
                  "mother_work_desc":
                      RxString(entry["BusinessDetailedDescription"] ?? ""),
                }),
          );

          repeatableEntries['fatherOccupationInfo'] =
              RxList<Map<String, dynamic>>.from(
            fatherOccupation.map((entry) => {
                  "father_mode_work": RxString(entry["strModeofWork"] ?? ""),
                  "father_name_org": RxString(entry["strNameOrg"] ?? ""),
                  "father_work_phone": RxString(entry["strWorkPhone"] ?? ""),
                  "father_work_web": RxString(entry["BusinessWebsite"] ?? ""),
                  "father_work_form": RxString(entry["strLegalbusiness"] ?? ""),
                  "father_work_address": RxString(entry["strAddressOrg"] ?? ""),
                  "father_work_email": RxString(entry["strWorkEmail"] ?? ""),
                  "father_work_desc":
                      RxString(entry["BusinessDetailedDescription"] ?? ""),
                }),
          );

          if (globalController.intentCompleted.value == true) {
            await loadDraftFromBackend(
                globalController.draftId.value.toString());
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            /// Jump to the first incomplete section
            sectionValidators['workInfo']?.call();
            final workInfoCompleted = sectionCompletion['workInfo']?.value;

            Future.delayed(const Duration(seconds: 1), () {
              isLoading.value = false;
              _hideWorkInfoInitially = workInfoCompleted ?? false;

              ///REMOVE SECTIONS FOR ORG
              //removeSubSectionsByKeys(aiut);

              if (_hideWorkInfoInitially) {
                final idx =
                    formSections.indexWhere((s) => s['key'] == 'workInfo');
                if (idx != -1) {
                  _initiallyCompletedWorkInfo = formSections.removeAt(idx);
                }
              }
              // if (activeSectionIndex.value >= formSections.length) {
              //   activeSectionIndex.value = formSections.length - 1;
              // }

              int lastCompleted = -1;
              for (var i = 0; i < formSections.length; i++) {
                final key = formSections[i]['key'] as String;
                final done = sectionCompletion[key]?.value ?? false;
                if (done) {
                  lastCompleted = i;
                } else {
                  // stop as soon as we hit the first incomplete
                  break;
                }
              }

              // if we found at least one completed section, jump there:
              if (lastCompleted >= 0) {
                activeSectionIndex.value = lastCompleted;
              }

              if (globalController.intentCompleted.value == true) {
                if (activeSectionIndex.value == 0) {
                  sectionCompletion["intendInfo"] = true.obs;
                  subsectionProgress["intendInfo"] = 100.0.obs;
                  activeSectionIndex.value++;
                }
              }
              isLoading.value = false;
            });
          });
        });

        //activeSectionIndex.value = 6;
        // sectionCompletion["documents"] = false.obs;
        // subsectionProgress["documents"] = 0.0.obs;

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

        final List<String> instructions = [
          "All fields are mandatory.",
          "Fill tab-by-tab.",
          "You can exit and resume at any point.",
          "Tabs must be filled in order (no skipping ahead).",
          "Preview and edit tabs before final submission."
        ];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          showInstructionsDialog(() {}, instructions,
              "Instructions: How to fill Imdaad Talimi Application");
          _setupDisableFallbacks();
        });
      });
    });


    // sectionCompletion["documents"] = false.obs;
    // subsectionProgress["documents"] = 0.0.obs;

    // sectionCompletion["intendInfo"] = false.obs;
    // subsectionProgress["intendInfo"] = 0.0.obs;
    //_hideWorkInfoInitially = sectionCompletion["workInfo"]!.value;
    //Api.fetchImage(globalController.user.value.imageUrl!);
  }

  bool areRequiredDocsUploaded(Map<String, Document?> documents) {
    const requiredDocTypes = [
      'raza_letter',
      'safai_chitti',
      'cnic_front',
      'cnic_back',
      'its_card',
    ];

    return requiredDocTypes.every(
          (docType) => documents.containsKey(docType) && documents[docType] != null,
    );
  }

  void _setupDisableFallbacks() {
    for (var section in formSections) {
      for (var sub in section['subSections'] ?? []) {
        for (var field in sub['fields'] ?? []) {
          final parentKey = field['parent_key'] as String?;
          final trigger = field['enable_child_on'] as String?;
          if (parentKey == null || trigger == null) continue;

          final childKey = field['key'] as String;
          final type = field['type'] as String;

          // ─── DROPDOWNS ──────────────────────────────────────────────────────
          if (type == 'dropdown' &&
              dropdownFields.containsKey(childKey) &&
              field.containsKey('itemsKey')) {
            final itemsKey = field['itemsKey'] as String;
            ever<int?>(dropdownFields[parentKey]!, (_) {
              final enabled =
                  dropdownFields[parentKey]!.value?.toString() == trigger;
              final opts = dropdownOptions[itemsKey]!;

              if (!enabled) {
                // 1️⃣ inject N/A if missing
                if (!opts.any((opt) => opt['id'] == -1)) {
                  opts.insert(0, {'id': -1, 'name': 'N/A'});
                }
                // 2️⃣ select it
                dropdownFields[childKey]!.value = -1;
              } else {
                // 3️⃣ remove N/A entry
                opts.removeWhere((opt) => opt['id'] == -1);
                // 4️⃣ if we were still on -1, clear selection
                if (dropdownFields[childKey]!.value == -1) {
                  dropdownFields[childKey]!.value = null;
                }
              }
            });
          }

          // ─── TEXT / FETCH-ITS ──────────────────────────────────────────────
          else if ((type == 'text' || type == 'fetch-its') &&
              textFields.containsKey(childKey)) {
            ever<String>(textFields[parentKey]!, (_) {
              final enabled = textFields[parentKey]!.value == trigger;
              if (!enabled) {
                textFields[childKey]!.value = 'N/A';
              }
              //if you want to clear back when enabled, you could:
              else {
                textFields[childKey]!.value = '';
              }
            });
          }
        }
      }
    }
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
        final subType = sub['type'];

        for (var field in sub['fields'] ?? []) {
          final key = field['key'];
          final type = field['type'];

          // TEXT / RADIO
          if ((type == 'text' || type == 'radio') &&
              textFields.containsKey(key)) {
            dataToSave[key] = textFields[key]?.value;
          }

          // DROPDOWN
          else if (type == 'dropdown' && dropdownFields.containsKey(key)) {
            final selectedId = dropdownFields[key]?.value;
            final optionsKey = field['itemsKey'];
            final optionList = DropdownValues.dropdownOptions2[optionsKey];
            final selected = optionList?.firstWhere(
              (item) => item['id'] == selectedId,
              orElse: () => {},
            );
            final selectedName = selected?['name'];

            if (key == 'member_name' ||
                key == 'dependent_name' ||
                key == 'familyMember') {
              dataToSave['${key}_its'] = selectedId;
              dataToSave['${key}_name'] = selectedName ?? '';
            } else {
              dataToSave[key] = selectedName ?? selectedId;
            }
          }

          // MULTISELECT
          else if (type == 'multiselect' &&
              multiSelectControllers.containsKey(key)) {
            final values =
                multiSelectControllers[key]?.selectedValues.toList() ?? [];
            dataToSave[key] = values;
            dataToSave['${key}_base64'] =
                base64Encode(utf8.encode(jsonEncode(values)));
          }

          // UNIT (e.g., heightUnit)
          if (field.containsKey('unitKey')) {
            final unitKey = field['unitKey'];
            final unitId = dropdownFields[unitKey]?.value;
            final unitOptions = field['unitOptions'] ?? [];

            if (unitId != null && unitId >= 0 && unitId < unitOptions.length) {
              dataToSave[unitKey] = unitOptions[unitId];
            }
          }

          // REPEATABLE FIELD (like incomeTypes)
          if (field['type'] == 'repeatable') {
            final nestedKey = field['key'];
            final nestedEntries = repeatableEntries[nestedKey];

            if (nestedEntries != null) {
              if (nestedEntries.isEmpty) {
                dataToSave['${nestedKey}_base64'] = null;
                debugPrint("🔁 [$nestedKey] is empty, saving as null");
              } else {
                debugPrint('--- 🔄 Processing nestedKey: $nestedKey ---');
                debugPrint('nestedEntries length: ${nestedEntries.length}');
                final List<Map<String, dynamic>> rawData = [];

                for (var i = 0; i < nestedEntries.length; i++) {
                  final entry = nestedEntries[i];
                  debugPrint('📋 Entry #$i: $entry');
                  final result = <String, dynamic>{};

                  entry.forEach((k, v) {
                    debugPrint('  ▶️ key="$k", raw value="$v" (type=${v.runtimeType})');

                    // unwrap an Rx if necessary
                    dynamic value;
                    try {
                      value = v is Rx ? v.value : v;
                    } catch (e) {
                      debugPrint('    ❗ Error unwrapping Rx on key="$k": $e');
                      value = v.toString();
                    }
                    debugPrint('    ↪️ processed value="$value"');

                    if (k == 'member_name') {
                      // resolve itemsKey (could be a String or a Function)
                      final dynamic ik = field['itemsKey'];
                      final String itemsKey = ik is String
                          ? ik
                          : ik is Function
                          ? (ik() as String)
                          : 'familyMembers';
                      debugPrint('    🔑 itemsKey="$itemsKey"');

                      final familyList = DropdownValues.dropdownOptions2[itemsKey] ?? [];
                      debugPrint('    📂 familyList[$itemsKey].length=${familyList.length}');

                      Map<String, dynamic> matched;
                      try {
                        matched = familyList.firstWhere((item) => item['id'] == value);
                        debugPrint('    ✅ matched item: $matched');
                      } catch (_) {
                        matched = {'id': value, 'name': 'Unknown'};
                        debugPrint('    ⚠️ no match found, using fallback: $matched');
                      }

                      result['member_name'] = matched['id'];
                      // if you also want to capture its:
                      // result['member_its'] = matched['id'];
                    } else {
                      result[k] = value;
                    }
                  });

                  debugPrint('  🎯 result map: $result');
                  rawData.add(result);
                }

                debugPrint('🔢 Complete rawData: $rawData');
                final jsonString = jsonEncode(rawData);
                debugPrint('📦 JSON string: $jsonString');
                final encoded = base64Encode(utf8.encode(jsonString));
                debugPrint('🔐 base64 length: ${encoded.length}');

                dataToSave['${nestedKey}_base64'] = encoded;
                debugPrint('✅ Saved "$nestedKey" with ${rawData.length} entr${rawData.length == 1 ? "y" : "ies"}');
              }
            }
          }
        }

        // REPEATABLE SUBSECTION (like fatherOccupationInfo)
        if (subType == 'repeatable') {
          final entries = repeatableEntries[subKey];
          if (entries != null) {
            final rawData = entries.map((entry) {
              final result = <String, dynamic>{};
              entry.forEach((k, v) {
                if (v is RxString) {
                  result[k] = v.value;
                } else if (v is Rxn<int>)
                  result[k] = v.value;
                else if (v is Rxn<String>)
                  result[k] = v.value;
                else if (v is RxInt)
                  result[k] = v.value;
                else if (v is RxBool)
                  result[k] = v.value;
                else
                  result[k] = v;
              });
              return result;
            }).toList();

            dataToSave['${subKey}_base64'] =
                base64Encode(utf8.encode(jsonEncode(rawData)));
          }
        }
      }
    }

    if (dataToSave.isEmpty) {
    } else {
      await Api.postDraftUpdateToBackend(dataToSave,stateController.draftId.toString());
    }
  }

  Future<void> loadDraftFromBackend(String appId) async {
    try {
      final data = await Api.loadDraftFromBackend(appId);
      debugPrint("📥 Loaded draft from backend: $data");

      data.forEach((key, value) {
        // ➤ Handle base64: repeatables or multiselect
        if (key.endsWith('_base64') && value is String && value.isNotEmpty) {
          final decoded = utf8.decode(base64Decode(value));
          final parsed = jsonDecode(decoded);
          final fieldKey = key.replaceAll('_base64', '');

          // ➤ Multiselect
          if (multiSelectControllers.containsKey(fieldKey) && parsed is List) {
            multiSelectControllers[fieldKey]?.selectedValues.assignAll(
                  List<String>.from(parsed),
                );
          }

          // ➤ Repeatable (top-level or nested)
          else if (parsed is List) {
            final mapped = parsed.map<Map<String, dynamic>>((entry) {
              final casted = Map<String, dynamic>.from(entry);
              return casted.map((k, v) {
                if (v is int) return MapEntry(k, Rxn<int>(v));
                if (v is String) return MapEntry(k, v.obs);
                return MapEntry(k, ''.obs); // fallback
              });
            }).toList();

            if (repeatableEntries.containsKey(fieldKey)) {
              repeatableEntries[fieldKey]?.assignAll(mapped);
            } else {
              // ✅ Try to detect nested repeatables
              for (final section in formSections) {
                final subSections = section['subSections'] ?? [];
                for (final sub in subSections) {
                  final fields = sub['fields'] ?? [];
                  for (final field in fields) {
                    if (field['type'] == 'repeatable' &&
                        field['key'] == fieldKey) {
                      repeatableEntries[fieldKey]?.assignAll(mapped);
                      debugPrint("✅ Loaded nested repeatable: $fieldKey");
                      return;
                    }
                  }
                }
              }
            }
          }

          return;
        }

        // ➤ Text
        if (textFields.containsKey(key)) {
          textFields[key]?.value = value?.toString() ?? '';
          return;
        }

        // ➤ Dropdowns
        if (dropdownFields.containsKey(key)) {
          final fieldConfig = formSections
              .expand((s) => s['subSections'] ?? [])
              .expand((sub) => sub['fields'] ?? [])
              .cast<Map<String, dynamic>>()
              .firstWhere(
                (f) => f['key'] == key,
                orElse: () => <String, dynamic>{},
              );

          final itemsKey = fieldConfig['itemsKey'];
          final options = DropdownValues.dropdownOptions2[itemsKey];

          if (options != null && value is String) {
            final matched = options.firstWhere(
              (item) => item['name']?.toString().trim() == value.trim(),
              orElse: () => <String, dynamic>{},
            );

            if (matched.containsKey('id')) {
              dropdownFields[key]?.value = matched['id'];
            }
          } else {
            dropdownFields[key]?.value = int.tryParse(value.toString());
          }

          return;
        }

        // ➤ Raw multiselect fallback
        if (multiSelectControllers.containsKey(key)) {
          final listVal = value is List ? value.cast<String>() : <String>[];
          multiSelectControllers[key]?.selectedValues.assignAll(listVal);
          return;
        }
      });

      // ➤ Final UI updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sectionValidators.forEach((_, validate) => validate());
        updateFormProgress();

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

            if (field.containsKey('unitKey')) {
              final unitKey = field['unitKey'];
              dropdownFields.putIfAbsent(
                  unitKey, () => Rxn<int>(0)); // default 0
            }
          } else if (field['type'] == 'dropdown') {
            dropdownFields.putIfAbsent(key, () => Rxn<int>());
          } else if (field['type'] == 'radio') {
            textFields.putIfAbsent(key, () => ''.obs);
          } else if (field['type'] == 'multiselect') {
            multiSelectControllers.putIfAbsent(
                key, () => MultiSelectDropdownController());
          } else if (field['type'] == 'repeatable') {
            repeatableEntries[field['key']] = <Map<String, dynamic>>[].obs;
          }
        }
      }
    }
  }

  List<Map<String, dynamic>> getOptions(String key) {
    return dropdownOptions[key] ?? [];
  }

  Widget buildDynamicField(
      Map<String, dynamic> field, String sectionKey, String textWidget) {
    final String type = field['type'];
    final String label = field['label'];
    final String key = field['key'];
    final validationFunction = sectionValidators[sectionKey];
    final validatorKey = field['validator'];

    if (type == 'text' || type == 'fetch-its') {
      Widget fieldWidget;

      // 1️⃣ Preserve your existing unitKey row
      if (field.containsKey('unitKey')) {
        final unitKey = field['unitKey'];
        final unitOptions = field['unitOptions'] ?? [];

        fieldWidget = Row(
          children: [
            Expanded(
              flex: 3,
              child: constants.buildField(
                label,
                textFields[key]!,
                this,
                isEnabled: field['enable'], // still respected
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
                  },
                ),
                isEnabled: true,
                onChanged: (_) => sectionValidators[sectionKey]?.call(),
              ),
            ),
          ],
        );
      }
      // 2️⃣ Otherwise keep your existing single-field with fetch-its logic
      else {
        fieldWidget = constants.buildField(
          text: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$textWidget) ',
                  style: TextStyle(
                      color: Colors.brown,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${field['label']} ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          label,
          textFields[key]!,
          this,
          isEnabled: field['enable'],
          function: validationFunction,
          validatorKey: validatorKey,
          hint: field['hint'],
          validator: (value) =>
              validateField(label, value ?? '', validatorKey: validatorKey),
          onChanged: (value) async {
            sectionValidators[sectionKey]?.call();
          },
        );
      }

      // 3️⃣ Now wrap with the same disableable helper using parent_key & enable_child_on
      final String? parentKey = field['parent_key'];
      final String? enableOnValue = field['enable_child_on'];

      return _wrapWithDisableable(
        child: fieldWidget,
        parentKey: parentKey,
        enableOnValue: enableOnValue,
        // fieldKey: key,
        // fieldType: 'text',
      );
    }

    /// Inside your buildDynamicField(...)
    else if (type == 'dropdown') {
      // 1️⃣ Gather your raw data
      final options = getOptions(field['itemsKey']);
      final Rxn<int> selectedValue = dropdownFields[key]!;

      // 2️⃣ Read your conditional‐enable keys
      final String? parentKey = field['parent_key'] as String?;
      final String? enableOnValue = field['enable_child_on'] as String?;

      // 3️⃣ Build the dropdown, including your "$textWidget) Label" prefix
      final Widget dropdownWithLabel = constants.buildDropdown2(
        text: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$textWidget) ',
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: label,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        label: label,
        selectedValue: selectedValue,
        items: options,
        isEnabled: true, // we'll handle actual enabling in the wrapper
        onChanged: (val) {
          selectedValue.value = val;
          sectionValidators[sectionKey]?.call();
        },
      );

      // 4️⃣ Wrap it so that it's always displayed, but only enabled when the condition matches
      return _wrapWithDisableable(
        child: dropdownWithLabel,
        parentKey: parentKey,
        enableOnValue: enableOnValue,
        // fieldKey: key,
        // fieldType: 'dropdown',
      );
    } else if (type == 'multiselect') {
      final optionsList = getOptions(field['itemsKey']);
      final dropdownItems = optionsList
          .map((e) => DropdownOption(displayName: e['name']))
          .toList();

      // Pull parent info off the field itself
      final String? parentKey = field['parent_key'];
      final String? enableOnValue = field['enable_child_on'];
      Widget text = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$textWidget) ',
              style: TextStyle(
                color: Colors.brown,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );

      // Build the base multiselect widget once:
      final Widget multiSelectWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text,
          MultiSelectDropdown(
            controller: multiSelectControllers[key]!,
            options: dropdownItems,
            hintText: "Select $label",
          ),
        ],
      );

      if (parentKey == null || enableOnValue == null) {
        return multiSelectWidget;
      }

      // Otherwise wrap it in Obx + IgnorePointer + grey overlay:
      return Obx(() {
        final bool enabled = textFields[parentKey]?.value == enableOnValue;
        return Stack(
          children: [
            // 1️⃣ The real widget, wrapped so it only accepts input when enabled
            IgnorePointer(
              ignoring: !enabled,
              child: Opacity(
                opacity: enabled ? 1.0 : 0.6, // optional dimming
                child: multiSelectWidget,
              ),
            ),

            // 2️⃣ A grey overlay when it’s disabled
            if (!enabled)
              Positioned.fill(
                child: Container(
                  width: double.infinity,
                  //margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        );
      });
    } else if (type == 'radio') {
      final options = field['options'] as List<dynamic>;
      final RxString selected = textFields[key]!;

      // 1️⃣ Build the main radio widget
      final Widget radioWidget = radioAsk(
        text: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$textWidget) ',
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: field['label'],
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        field['label'],
        selected,
        option1: options[0],
        option2: options[1],
        onChanged: () => sectionValidators[sectionKey]?.call(),
        conditionalField: null,
        showFieldIf: null,
      );

      return radioWidget;
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

  Widget radioAsk(String title, RxString value,
      {String option1 = 'Yes',
      String option2 = 'No',
      Widget? conditionalField,
      String? showFieldIf,
      VoidCallback? onChanged,
      bool buildConditionalField = false, // 🔥 add this
      Widget Function()? buildConditionalWidget, // 🔥 add this
      Text? text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (text != null) text,
              if (text == null)
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              Container(
                height: 30,
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

      return true;
    }

    if (type == 'radio') {
      final value = textFields[key]?.value ?? '';
      if (value.trim().isEmpty) return false;

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
            if (miniVal == null || miniVal.value.toString().trim().isEmpty) {
              return false;
            }
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

  // Helper inside buildDynamicField:
  /// Wraps any widget in “disableable” logic and also sets fallback values.
  Widget _wrapWithDisableable({
    required Widget child,
    required String? parentKey,
    required String? enableOnValue,
  }) {
    if (parentKey == null || enableOnValue == null) return child;

    return Obx(() {
      final bool enabled;
      if (dropdownFields.containsKey(parentKey)) {
        final trigger = int.tryParse(enableOnValue);
        enabled = dropdownFields[parentKey]!.value == trigger;
      } else {
        enabled = textFields[parentKey]!.value == enableOnValue;
      }

      return Stack(
        children: [
          IgnorePointer(
            ignoring: !enabled,
            child: Opacity(
              opacity: enabled ? 1 : 0.6,
              child: child,
            ),
          ),
          if (!enabled)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      );
    });
  }

  // Separate method for special occupation layout
  Widget _buildOccupationFields(
      String sectionKey, List<dynamic> fields, BuildContext context) {
    final entries = repeatableEntries[sectionKey]!;
    if (entries.isEmpty) {
      // initialize one entry
      final newEntry = <String, dynamic>{};
      for (var f in fields) {
        newEntry[f['key']] = f['type'] == 'dropdown' ? Rxn<int>() : ''.obs;
      }
      entries.add(newEntry);
    }

    final entry = entries.first;
    final List<Widget> rows = [];
    for (int i = 0; i < fields.length; i += 4) {
      final chunk = fields.sublist(
        i,
        i + 4 > fields.length ? fields.length : i + 4,
      );
      rows.add(Row(
        children: chunk.map<Widget>((field) {
          final key = field['key'] as String;
          final label = field['label'] as String? ?? '';
          final type = field['type'] as String? ?? 'text';
          final dynamic value = entry[key];

          if (type == 'dropdown') {
            return Flexible(
              fit: FlexFit.tight,
              child: constants.buildDropdown2(
                label: label,
                selectedValue: value as Rxn<int>? ?? Rxn<int>(),
                items: getOptions(field['itemsKey']),
                isEnabled: true,
                onChanged: (_) {
                  validateRepeatableSection(sectionKey);
                  entries.refresh();
                },
              ),
            );
          } else {
            return Flexible(
              fit: FlexFit.tight,
              child: constants.buildField(
                label,
                value as RxString,
                this,
                validatorKey: field['validator'],
                validator: (v) => validateField(label, v ?? '',
                    validatorKey: field['validator']),
                function: () => validateRepeatableSection(sectionKey),
              ),
            );
          }
        }).toList(),
      ));
    }
    return Column(children: rows);
  }

  Widget buildRepeatableGroup(Map<String, dynamic> section) {
    final String sectionKey = section['key'] ?? 'unknown_key';
    final String radioLabel = sectionKey == 'motherOccupationInfo'
        ? 'House Wife'
        : sectionKey == 'fatherOccupationInfo'
            ? 'Retired'
            : section['radioLabel'] ?? 'None';
    final selectedType = repeatableSectionRadio[sectionKey];
    final entries = repeatableEntries[sectionKey];
    final List<dynamic> fields = section['fields'] ?? [];

    if (selectedType == null || entries == null) {
      return const Text(
        "Repeatable section not initialized properly.",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    final bool isOccupationSection = sectionKey == 'fatherOccupationInfo' ||
        sectionKey == 'motherOccupationInfo';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Radio Toggle
        Obx(() => Row(
              children: [
                Radio<int>(
                  value: 1,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  toggleable: true,
                  groupValue: selectedType.value,
                  onChanged: (value) {
                    final newVal = value ?? 0;
                    selectedType.value = newVal;
                    // Clear entries per requirements:
                    if (isOccupationSection) {
                      if (newVal == 1) {
                        entries.clear();
                      }
                    } else {
                      // normal sections: always clear on toggle
                      entries.clear();
                    }
                    entries.refresh();
                    validateRepeatableSection(sectionKey);
                  },
                ),
                Text(
                  radioLabel,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            )),

        // Entries Display
        Obx(() {
          if (selectedType.value != 0) return const SizedBox.shrink();

          // Special case: use separate widget
          if (isOccupationSection) {
            return _buildOccupationFields(sectionKey, fields, context);
          }

          // Default layout: vertical list of entries with add/remove
          return Column(
            children: [
              ...entries.asMap().entries.map((entryPair) {
                final int index = entryPair.key;
                final Map<String, dynamic> entry = entryPair.value;

                final List<Widget> fieldWidgets = fields.map<Widget>((field) {
                  final key = field['key'] as String;
                  final label = field['label'] as String? ?? '';
                  final type = field['type'] as String? ?? 'text';
                  final dynamic value = entry[key];

                  if (type == 'dropdown') {
                    var items = getOptions(field['itemsKey']).toList();
                    if (field['itemsKey'] == 'familyMembers') {
                      final taken = entries
                          .where((e) => e != entry)
                          .map((e) => (e[key] as Rxn<int>?)?.value)
                          .whereType<int>()
                          .toSet();
                      items = items
                          .where((opt) => !taken.contains(opt['id']))
                          .toList();
                    }
                    return Expanded(
                      child: constants.buildDropdown2(
                        label: label,
                        selectedValue: value as Rxn<int>? ?? Rxn<int>(),
                        items: items,
                        isEnabled: true,
                        onChanged: (_) {
                          validateRepeatableSection(sectionKey);
                          entries.refresh();
                        },
                      ),
                    );
                  } else {
                    return Expanded(
                      child: constants.buildField(
                        label,
                        value as RxString,
                        this,
                        validatorKey: field['validator'],
                        validator: (v) => validateField(label, v ?? '',
                            validatorKey: field['validator']),
                        function: () => validateRepeatableSection(sectionKey),
                      ),
                    );
                  }
                }).toList();

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff7ec),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ...fieldWidgets,
                      Padding(
                        padding: const EdgeInsets.only(top: 22.0),
                        child: IconButton(
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          onPressed: () {
                            entries.removeAt(index);
                            entries.refresh();
                            validateRepeatableSection(sectionKey);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  onPressed: () {
                    final allValid = entries.every((e) => fields.every((f) {
                          final val = e[f['key']];
                          return f['type'] == 'dropdown'
                              ? (val as Rxn<int>?)?.value != null
                              : (val as RxString).value.trim().isNotEmpty;
                        }));
                    if (!allValid) return;
                    final newEntry = <String, dynamic>{};
                    for (var f in fields) {
                      newEntry[f['key']] =
                          f['type'] == 'dropdown' ? Rxn<int>() : ''.obs;
                    }
                    entries.add(newEntry);
                    entries.refresh();
                    validateRepeatableSection(sectionKey);
                  },
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

      ///IF OCCUPATION IS COMPELTED HIDE THAT
      return
          // sectionKey=='fatherOccupationInfo' && percent==100
          //   || sectionKey=='motherOccupationInfo' && percent==100
          //   ? SizedBox.shrink()
          //   :
          Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
              spacing: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 2, color: Colors.white, thickness: 2),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xfffff7ec),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(children: children)),
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

  Future<Map<String, dynamic>> collectFormDataForBackend() async {
    final Map<String, dynamic> finalData = {
      "student": <String, dynamic>{},
      "occupation": <String, dynamic>{},
      "repeatables": <String, dynamic>{},
    };

    final List<String> occupationFields = [
      "mode_work",
      "name_org",
      "work_phone",
      "work_web",
      "work_form",
      "work_address",
      "work_email",
      "work_desc"
    ];

    for (final section in formSections) {
      final subSections = section['subSections'] ?? [];

      for (final sub in subSections) {
        final type = sub['type'];
        final subKey = sub['key'];

        // 🔁 Repeatables
        if (type == 'repeatable') {
          final List<Map<String, dynamic>> allEntries = [];
          final entries = repeatableEntries[subKey];

          if (entries != null && entries.isNotEmpty) {
            for (final entry in entries) {
              final Map<String, dynamic> repeatableMap = {};
              for (final field in sub['fields']) {
                final fieldKey = field['key'];
                final fieldType = field['type'];
                final itemsKey = field['itemsKey'];

                if (fieldType == 'text') {
                  repeatableMap[fieldKey] = entry[fieldKey]?.value ?? '';
                } else if (fieldType == 'dropdown') {
                  final dropdownId = entry[fieldKey]?.value;
                  final options =
                      DropdownValues.dropdownOptions2[itemsKey] ?? [];

                  final selected = options.firstWhere(
                      (opt) => opt['id'] == dropdownId,
                      orElse: () => {'name': null, 'id': null});

                  repeatableMap[fieldKey] = selected['name'];

                  if (field.containsKey("itsFieldKey")) {
                    final itsField = field["itsFieldKey"];
                    repeatableMap[itsField] = selected['id']?.toString();
                  }
                }
              }
              allEntries.add(repeatableMap);
            }
          }

          finalData["repeatables"][subKey] = allEntries;
          continue;
        }

        // 🔤 Regular fields
        for (final field in sub['fields']) {
          final fieldKey = field['key'];
          final fieldType = field['type'];
          final isOccupation = occupationFields.contains(fieldKey);

          final targetMap =
              isOccupation ? finalData["occupation"] : finalData["student"];

          if (fieldType == 'text' || fieldType == 'radio') {
            final value = textFields[fieldKey]?.value ?? '';

            if (field.containsKey('unitKey')) {
              final unitKey = field['unitKey'];
              final unitId = dropdownFields[unitKey]?.value;
              final unitOptions = field['unitOptions'] ?? [];

              String? unitLabel;
              if (unitId != null &&
                  unitId >= 0 &&
                  unitId < unitOptions.length) {
                unitLabel = unitOptions[unitId];
              }

              targetMap[fieldKey] =
                  unitLabel != null ? "$value $unitLabel" : value;
            } else {
              targetMap[fieldKey] = value;
            }

            // handle conditional text fields
            if (field.containsKey("textFieldKey")) {
              final tfKey = field["textFieldKey"];
              targetMap[tfKey] = textFields[tfKey]?.value ?? '';
            }

            // ✅ Conditional dropdown (like child_death_cause)
            if (field.containsKey("dropdownKey") &&
                field.containsKey("showDropdownIf")) {
              final condition = field["showDropdownIf"];
              if (value == condition) {
                final dropdownKey = field["dropdownKey"];
                final dropdownVal = dropdownFields[dropdownKey]?.value;
                final itemsKey = field["itemsKey2"];
                final options = DropdownValues.dropdownOptions2[itemsKey] ?? [];

                final selected = options.firstWhere(
                    (opt) => opt['id'] == dropdownVal,
                    orElse: () => {'name': null, 'id': null});

                targetMap[dropdownKey] = selected['name'];

                // 🧠 Store ITS if needed
                if (field.containsKey("itsFieldKey")) {
                  final itsKey = field["itsFieldKey"];
                  targetMap[itsKey] = selected['id']?.toString();
                }
              }
            }

            if (field.containsKey("conditional_value") &&
                field.containsKey("condition_options") &&
                field.containsKey("on_condition") &&
                field.containsKey("condtional_key")) {
              final conditionTrigger = field["on_condition"];
              final conditionalKey = field["condtional_key"];
              if (value == conditionTrigger) {
                final conditionalValue =
                    textFields[conditionalKey]?.value ?? '';
                targetMap[conditionalKey] = conditionalValue;
              }
            }
          } else if (fieldType == 'dropdown') {
            final val = dropdownFields[fieldKey]?.value;
            final itemsKey = field['itemsKey'];
            final options = DropdownValues.dropdownOptions2[itemsKey] ?? [];

            final selected = options.firstWhere((opt) => opt['id'] == val,
                orElse: () => {'name': null, 'id': null});

            targetMap[fieldKey] = selected['name'];

            // ⛓️ Conditional Dropdown
            if (field.containsKey('dropdownKey')) {
              final linkedKey = field['dropdownKey'];
              final linkedVal = dropdownFields[linkedKey]?.value;
              final linkedOptions =
                  DropdownValues.dropdownOptions2[field['itemsKey2']] ?? [];

              final linkedItem = linkedOptions.firstWhere(
                (opt) => opt['id'] == linkedVal,
                orElse: () => {'name': null, 'id': null},
              );

              targetMap[linkedKey] = linkedItem['name'];

              if (field.containsKey("itsFieldKey")) {
                final itsField = field['itsFieldKey'];
                targetMap[itsField] = linkedItem['id']?.toString();
              }
            }
          } else if (fieldType == 'multiselect') {
            final values =
                multiSelectControllers[fieldKey]?.selectedValues.toList() ?? [];
            targetMap[fieldKey] = values.join(', ');
          }
        }
      }
    }

    debugPrint(jsonEncode(finalData));
    return finalData;
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

  getPadding() {
    if (activeSectionIndex.value == 0) {
      return EdgeInsets.symmetric(horizontal: 20);
    } else {
      return EdgeInsets.symmetric(horizontal: 150.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Imdaad Talimi Application Form"),
      ),
      backgroundColor: const Color(0xfffffcf6),
      body: Stack(
        children: [
          Obx(() {
            if (isLoading.value || formSections.isEmpty) {
              return Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: Colors.white,
                  size: 80,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 150.0),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stateController.user.value.itsId == null
                            ? "30445124"
                            : stateController.user.value.itsId.toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                          stateController.user.value.fullName == null
                              ? "Aliasghar Khumusi"
                              : stateController.user.value.fullName.toString(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Only progress updates reactively
                Obx(() {
                  // 1️⃣ Directly map each section into a SectionStep
                  final steps = formSections.map<SectionStep>((section) {
                    final pct =
                        getSectionCompletionPercentByKey(section['key']);
                    return SectionStep(
                      title: section['title'],
                      completionPercent: pct,
                    );
                  }).toList();

                  // 2️⃣ Compute overall percent
                  final totalPercent = steps.isEmpty
                      ? 0.0
                      : steps
                              .map((s) => s.completionPercent)
                              .reduce((a, b) => a + b) /
                          steps.length;

                  // 3️⃣ Render your stepper as before
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
                      padding: getPadding(),
                      child: Column(
                        children: [
                          Obx(() {
                            final section = formSections[activeSectionIndex.value];
                            final sectionKey = section['key'];



                            // ✅ Inject custom full-widget override for section `intendInfo`
                            if (sectionKey == 'intendInfo') {
                              return RequestForm();
                            }

                            if (sectionKey == 'documents') {
                              return DocumentsFormScreenW();
                            }

                            // // Hide workInfo section completely if it's already complete
                            // if (sectionKey == 'workInfo' &&
                            //     sectionCompletion['workInfo']!.value == true) {
                            //   return const SizedBox.shrink();
                            // }

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

                            //stateController.currentSection.value = effectiveKey;

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
                                  onPressed: () async {
                                    await saveDraft();
                                    Get.toNamed(AppRoutes.select_module);
                                  },
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
                                RequestFormController reqform =
                                    Get.find<RequestFormController>();
                                final bool isComplete;
                                final currentSection =
                                    formSections[activeSectionIndex.value];
                                String effectiveKey = currentSection['key'];
                                final isLast = activeSectionIndex.value ==
                                    formSections.length - 1;
                                if(isLast){
                                  final allUploaded = areRequiredDocsUploaded(stateController.documents);
                                  isComplete = allUploaded;
                                  ///REMOVE
                                  //isComplete = true;
                                }else {
                                  if (activeSectionIndex.value == 0) {
                                    isComplete = reqform.isSubmitEnabled.value;
                                    // if(isComplete==true){
                                    //   sectionCompletion["documents"] = true.obs;
                                    //   subsectionProgress["documents"] = 100.0.obs;
                                    // }
                                  } else {
                                    final subSections =
                                    (currentSection['subSections'] ?? [])
                                    as List<dynamic>;

                                    // 👉 Find the first subSection which is NOT 100% complete
                                    for (var sub in subSections) {
                                      final subKey = sub['key'];
                                      final percent =
                                          subsectionProgress[subKey]?.value ??
                                              0.0;

                                      if (percent < 100) {
                                        effectiveKey = subKey;
                                        break;
                                      }
                                    }

                                    isComplete =
                                        isSectionReallyComplete(effectiveKey);
                                  }
                                }

                                return SizedBox(
                                  width: 200,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: isComplete
                                        ? () async {
                                            if (activeSectionIndex.value == 0) {
                                              reqform.onSubmitPress(
                                                  activeSectionIndex,
                                                  sectionCompletion[
                                                      "intendInfo"],
                                                  subsectionProgress[
                                                      "intendInfo"]);
                                               reqFormController.fetchRequests('', '', stateController.user.value.itsId.toString(), '');
                                            } else {
                                              saveDraft(
                                                  sectionKey: effectiveKey);
                                              if (fromEdit) {
                                                Get.to(() => ReviewScreen(
                                                      formSections:
                                                          formSections,
                                                      initiallyCompletedWorkInfo:
                                                          _initiallyCompletedWorkInfo,
                                                      // 👈 add this

                                                      textFields: textFields,
                                                      dropdownFields:
                                                          dropdownFields,
                                                      multiSelectControllers:
                                                          multiSelectControllers,
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
                                                //effectiveKey
                                                // final nextSection =
                                                // formSections[activeSectionIndex.value++]['key'];
                                                //stateController.currentSection.value =  nextSection;
                                                saveDraft(
                                                    sectionKey: effectiveKey);
                                                collectFormDataForBackend();
                                                activeSectionIndex.value++;
                                                scrollController.animateTo(
                                                  0.0,
                                                  duration: Duration(
                                                      milliseconds: 400),
                                                  curve: Curves.easeInOut,
                                                );
                                              } else {
                                                saveDraft(
                                                    sectionKey: effectiveKey);
                                                Get.to(() => ReviewScreen(
                                                      formSections:
                                                          formSections,
                                                      textFields: textFields,
                                                      initiallyCompletedWorkInfo:
                                                          _initiallyCompletedWorkInfo,
                                                      // 👈 add this
                                                      multiSelectControllers:
                                                          multiSelectControllers,
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
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(()=> InstructionsWidget(instructionsKey: activeSectionIndex.value==0 ? 'intent' : formSections[activeSectionIndex.value]['key'])),
              ],
            );
          }),
          Obx(() {
            if (stateController.app_form_loading.value) {
              return Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          })
        ],
      ),
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
      // Add condition here to skip rendering certain subSections:
      if(sub["key"] == 'motherOccupationInfo') {
        if (motherOccupationAvailable) {
          continue;
        }
      }
      if(sub["key"] == 'fatherOccupationInfo'){
        if (fatherOccupationAvailable) {
          continue;
        }
      }

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

                      if (innerFieldType == 'repeatable') {
                        break; // don't put a repeatable inside normal row
                      }

                      rowChildren.add(
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 2),
                            child: buildDynamicField(innerField, subKey,
                                '${sectionIndex + 1}.${subIndex + 1}.${innerFieldIndex + 1}'),
                          ),
                        ),
                      );
                    }

                    // 🧱 Ensure two columns: if only 1 field added, add a blank box
                    if (rowChildren.length == 1) {
                      rowChildren.add(const Expanded(child: SizedBox()));
                    }

                    fieldRows.add(Row(children: rowChildren));

                    i += rowChildren.length -
                        1; // 🔁 Advance i by number of fields used (1 or 2)
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
    Map<String, dynamic> field,
    String parentSubKey,
  ) {
    final String key = field['key'] as String;
    final List<Map<String, dynamic>> fields =
        (field['fields'] as List<dynamic>).cast<Map<String, dynamic>>();
    final RxList<Map<String, dynamic>> entries =
        repeatableEntries.putIfAbsent(key, () => <Map<String, dynamic>>[].obs);

    // 🚀 if no rows yet, enqueue one add
    if (entries.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addEntry(fields, entries);
      });
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title
          Text(
            field['label'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.brown,
            ),
          ),

          const SizedBox(height: 8),

          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xfff0e6d8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Action Column Header
                SizedBox(
                  width: 25,
                ),

                // One header per field
                ...fields.map((f) {
                  final String header = f['label'] as String? ?? '';
                  return Expanded(
                    child: Text(
                      header,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Data Rows
          Obx(() {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: const Color(0xfffff7ec),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: entries.asMap().entries.map((entryPair) {
                  final int index = entryPair.key;
                  final Map<String, dynamic> data = entryPair.value;

                  return Row(
                    children: [
                      // 1️⃣ Delete button cell
                      SizedBox(
                        width: 25,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            entries.removeAt(index);
                            entries.refresh();
                            validateRepeatableSection(key);
                          },
                        ),
                      ),

                      // 2️⃣ One Expanded cell per field
                      ...fields.map<Widget>((f) {
                        final String fKey = f['key'] as String;
                        final String fType = f['type'] as String? ?? 'text';
                        final String? fv = f['validator'] as String?;
                        final dynamic value = data[fKey];

                        if (fType == 'dropdown') {
                          // Filter duplicates for familyMembers
                          List<Map<String, dynamic>> items =
                              getOptions(f['itemsKey'] as String).toList();

                          // Optional: exclude a specific ID
                          final int? excludedId = stateController.user.value
                              .itsId; // Pass this via config if needed
                          if (f['itemsKey'] == 'familyMembers') {
                            final taken = entries
                                .where((e) => e != data)
                                .map((e) => (e[fKey] as Rxn<int>?)?.value)
                                .whereType<int>()
                                .toSet();

                            items = items
                                .where((opt) =>
                                    !taken.contains(opt['id']) &&
                                    (excludedId == null ||
                                        opt['id'] != excludedId))
                                .toList();
                          }

                          return Expanded(
                            child: constants.buildDropdown2(
                              label: f['label'],
                              showtitle: false,
                              selectedValue: value as Rxn<int>? ?? Rxn<int>(),
                              items: items,
                              isEnabled: true,
                              onChanged: (newId) {
                                (value as Rxn<int>).value = newId;
                                entries.refresh();
                                validateRepeatableSection(key);
                              },
                            ),
                          );
                        } else {
                          return Expanded(
                            child: constants.buildField(
                              showtitle: false,
                              f['label'],
                              value as RxString,
                              this,
                              validatorKey: fv,
                              validator: (v) => validateField(
                                  f['label'] ?? '', v ?? '',
                                  validatorKey: fv),
                              function: () => validateRepeatableSection(key),
                            ),
                          );
                        }
                      }),
                    ],
                  );
                }).toList(),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Add Button
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              onPressed: () {
                addEntry(fields, entries);
              },
            ),
          ),
        ],
      ),
    );
  }

  void addEntry(
    List<Map<String, dynamic>> fields,
    RxList<Map<String, dynamic>> entries,
  ) {
    // Only add if existing rows valid
    final allValid = entries.every((e) => fields.every((f) {
          final val = e[f['key']];
          if (f['type'] == 'dropdown') {
            return (val as Rxn<int>?)?.value != null;
          }
          return (val as RxString).value.trim().isNotEmpty;
        }));
    if (!allValid) return;

    // Create a new blank entry
    final newEntry = <String, dynamic>{};
    for (var f in fields) {
      newEntry[f['key']] = (f['type'] == 'dropdown') ? Rxn<int>() : ''.obs;
    }
    entries.add(newEntry);
    entries.refresh();
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xfffff7ec),
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
                      children: fields.asMap().entries.map<Widget>((entry) {
                        final index = entry.key;
                        final field = entry.value;
                        final sectionIndex = formSections.indexWhere((s) =>
                            s['subSections']
                                ?.any((sub) => sub['key'] == subKey) ??
                            false);
                        final subIndex = formSections[sectionIndex]
                                ['subSections']
                            .indexWhere((sub) => sub['key'] == subKey);
                        final fieldNumber =
                            "${sectionIndex + 1}.${subIndex + 1}.${index + 1}";

                        return SizedBox(
                          width: itemWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: buildDynamicField(
                                    field, subKey, fieldNumber),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
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

class InstructionsWidget extends StatefulWidget {
  final String instructionsKey;

  const InstructionsWidget({super.key, required this.instructionsKey});

  @override
  InstructionsWidgetState createState() => InstructionsWidgetState();
}

class InstructionsWidgetState extends State<InstructionsWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _showReadMore = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  String? _fullText;

  @override
  void initState() {
    super.initState();
    _loadInstructions();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _loadInstructions() {
    final data = stateController.appInstructions?[widget.instructionsKey];
    if (data == null) {
      _fullText = null;
    } else {
      final rawList = List<String>.from(data);
      _fullText = rawList.join('\n').trim();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateOverflow();
    });
  }

  void _calculateOverflow() {
    if (!mounted || _fullText == null) return;

    final span = TextSpan(
      text: _fullText,
      style: const TextStyle(fontSize: 13.5, height: 1.4),
    );

    final painter = TextPainter(
      text: span,
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );

    final maxTextWidth = MediaQuery.of(context).size.width - 250; // Adjust to match your layout

    painter.layout(maxWidth: maxTextWidth);

    setState(() {
      _showReadMore = painter.didExceedMaxLines;
    });
  }

  @override
  void didUpdateWidget(covariant InstructionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.instructionsKey != widget.instructionsKey) {
      _loadInstructions();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_fullText == null || _fullText!.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final bgColor = const Color(0xffffead1);

    return MouseRegion(
      onExit: (_) {
        if (_expanded) {
          setState(() {
            _expanded = false;
            _controller.reverse();
          });
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: bgColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          spacing: 5,
          children: [
            Text(
              "📌 Application Instructions",
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _buildTextWithToggle(),
                  ),
                  if (_showReadMore) _readButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextWithToggle() {
    return Text(
      _fullText!,
      maxLines: _expanded ? null : 2,
      overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13.5, height: 1.4),
    );
  }

  Widget _readButton() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              child: Text(_expanded ? "Hide details" : "Read more"),
            ),
          ],
        ),
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
          formSections[activeSectionIndex.value]['key'] != 'documents' && activeSectionIndex.value!=0 ? Text(
                activeSectionIndex.value == 1
                    ? "Fill By Student"
                    : "Filled by HOF",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                    fontSize: 16)) : SizedBox.shrink()

        ],
      ),
    );
  }
}
