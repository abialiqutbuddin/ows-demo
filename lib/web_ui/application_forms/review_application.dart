import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:ows/web_ui/application_forms/application_form_web.dart';
import 'package:ows/web_ui/application_forms/application_pdf.dart';
import '../../api/api.dart';
import '../../constants/multi_select_dropdown.dart';
import '../../controller/state_management/state_manager.dart';
import '../../data/dropdown_options.dart';

class ReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> formSections;
  final RxMap<String, RxString> textFields;
  final RxMap<String, Rxn<int>> dropdownFields;
  final Map<String, RxList<Map<String, dynamic>>> repeatableEntries;
  final Map<String, List<Map<String, dynamic>>> dropdownOptions;
  final RxMap<String, MultiSelectDropdownController> multiSelectControllers;
  final void Function(String sectionKey)? onBackToEdit;
  final Map<String, dynamic>? initiallyCompletedWorkInfo;


  ReviewScreen({
    super.key,
    required this.formSections,
    required this.textFields,
    required this.dropdownFields,
    required this.repeatableEntries,
    required this.dropdownOptions,
    this.onBackToEdit,
    required this.multiSelectControllers, this.initiallyCompletedWorkInfo,
  });

  final RxBool isSubmitting = false.obs;
  final RxnInt submittedApplicationId = RxnInt();

  Future<Map<String, dynamic>> collectFormDataForBackend({
    required List<Map<String, dynamic>> formSections,
    required RxMap<String, RxString> textFields,
    required RxMap<String, Rxn<int>> dropdownFields,
    Map<String, dynamic>? initiallyCompletedWorkInfo, // 👈 Add this
    required Map<String, RxList<Map<String, dynamic>>> repeatableEntries,
    required Map<String, List<Map<String, dynamic>>> dropdownOptions,
    required RxMap<String, MultiSelectDropdownController>
        multiSelectControllers,
  }) async {
    final Map<String, dynamic> finalData = {
      "application": <String, dynamic>{},
      "repeatables": <String, dynamic>{},
    };

    List<Map<String, dynamic>> allSections = [...formSections];

    // ✅ Inject workInfo manually if missing
    if (!formSections.any((s) => s['key'] == 'workInfo') &&
        initiallyCompletedWorkInfo != null) {
      allSections.add(initiallyCompletedWorkInfo);
    }

    for (final section in allSections) {
      final subSections = section['subSections'] ?? [];

      for (final sub in subSections) {
        final type = sub['type'];
        final subKey = sub['key'];

        if (type == 'repeatable') {
          // Grab your entries for this subsection
          final List<Map<String, dynamic>>? rawEntries = repeatableEntries[subKey];
          final int count = rawEntries?.length ?? 0;
          debugPrint('🔄 Processing repeatable section "$subKey": $count entries');

          if (rawEntries != null && rawEntries.isNotEmpty) {
            // “Main table” special case flattens into application
            if ([
              'fatherOccupationInfo',
              'motherOccupationInfo',
              'guardianOccupationInfo'
            ].contains(subKey)) {
              debugPrint('  ⚙️ Flattening main table fields for "$subKey"');
              final firstEntry = rawEntries.first;
              firstEntry.forEach((fieldKey, reactiveVal) {
                // unwrap Rx or call if it's a Function
                final dynamic raw = reactiveVal is Rx
                    ? reactiveVal.value
                    : reactiveVal is Function
                    ? reactiveVal()
                    : reactiveVal;
                debugPrint('    • Field "$fieldKey": raw="$raw"');
                finalData["application"][fieldKey] = raw;
              });
              debugPrint('  ✅ Flattened fields: ${firstEntry.keys.toList()}');
            } else {
              // Regular repeatable rows
              final List<Map<String, dynamic>> rows = [];
              for (var entry in rawEntries) {
                debugPrint('  ▶️ New repeatable entry: $entry');
                final Map<String, dynamic> row = {};

                entry.forEach((k, v) {
                  final dynamic raw = v is Rx
                      ? v.value
                      : v is Function
                      ? v()
                      : v;
                  debugPrint('    • Field "$k": raw="$raw"');

                  if (k == 'member_name') {
                    // force your dropdown options into the right type
                    final List<Map<String, dynamic>> opts =
                    List<Map<String, dynamic>>.from(
                        dropdownOptions['familyMembers'] ?? []);
                    debugPrint('      – Looking up member_name in ${opts.length} options');
                    final sel = opts.firstWhere(
                          (opt) => opt['id'].toString() == raw.toString(),
                      orElse: () {
                        debugPrint('      ⚠️ No match for member_name="$raw", using fallback');
                        return <String, dynamic>{'id': raw, 'name': 'Unknown'};
                      },
                    );
                    debugPrint('      ✅ Matched option: $sel');
                    row['member_name'] = sel['name'];
                    row['member_its']  = sel['id'];
                  } else {
                    row[k] = raw;
                  }
                });

                debugPrint('    ✔️ Built row: $row');
                rows.add(row);
              }

              finalData["repeatables"][subKey] = rows;
              debugPrint('  ✅ Added ${rows.length} rows to repeatables["$subKey"]\n');
            }
          } else {
            debugPrint('  ℹ️ No entries for "$subKey", skipping');
          }

          continue;
        }

        for (final field in sub['fields'] ?? []) {
          final key = field['key'];
          final fieldType = field['type'];

          // 1) Nested repeatable
          if (fieldType == 'repeatable') {
            final List<Map<String, dynamic>> entries =
                repeatableEntries[key] ?? <Map<String, dynamic>>[];
            debugPrint('🔄 Processing repeatable section "$key": ${entries.length} entries');

            if (entries.isEmpty) {
              debugPrint('  ℹ️ No entries for "$key", skipping');
              continue;
            }

            final List<Map<String, dynamic>> rows = entries.map((entry) {
              debugPrint('  ▶️ New raw entry: $entry');
              final Map<String, dynamic> row = {};

              entry.forEach((k, v) {
                // unwrap Rx, call if Function, otherwise take it as-is:
                final dynamic raw = v is Rx
                    ? v.value
                    : v is Function
                    ? v()
                    : v;
                debugPrint('    • Field "$k": raw="$v" ➔ unwrapped="$raw"');

                if (k == 'member_name') {
                  // itemsKey might itself be a String or a Function returning String
                  final dynamic ik = field['itemsKey'];
                  final String itemsKey = ik is String
                      ? ik
                      : ik is Function
                      ? ik() as String
                      : 'familyMembers';

                  // force the dropdown options into the right type
                  final List<Map<String, dynamic>> opts =
                  List<Map<String, dynamic>>.from(
                    DropdownValues.dropdownOptions2[itemsKey] ?? <Map<String, dynamic>>[],
                  );
                  debugPrint('      – Looking up in ${opts.length} options');

                  final Map<String, dynamic> selected = opts.firstWhere(
                        (opt) => opt['id'] == raw,
                    orElse: () {
                      debugPrint('      ⚠️ No match for member_name="$raw", using fallback');
                      return <String, dynamic>{'id': raw, 'name': 'Unknown'};
                    },
                  );

                  debugPrint('      ✅ Matched option: $selected');
                  row['member_name'] = selected['name'];
                  row['member_its']  = selected['id'];
                } else {
                  row[k] = raw;
                }
              });

              debugPrint('    ✔️ Built row: $row');
              return row;
            }).toList();

            finalData["repeatables"][key] = rows;
            debugPrint('✅ Finished "$key", wrote ${rows.length} rows\n');
            continue;
          }

          // ✅ Text / Radio
          if (fieldType == 'text' || fieldType == 'radio') {
            String value = textFields[key]?.value ?? '';

            // If unit attached
            if (field.containsKey('unitKey')) {
              final unitKey = field['unitKey'];
              final unitIndex = dropdownFields[unitKey]?.value;
              final unitOptions = field['unitOptions'] ?? [];

              if (unitIndex != null &&
                  unitIndex >= 0 &&
                  unitIndex < unitOptions.length) {
                value = "$value ${unitOptions[unitIndex]}";
                finalData["application"][unitKey] = unitOptions[unitIndex];
              }
            }

            finalData["application"][key] = value;
          }

          // ✅ Dropdown
          else if (fieldType == 'dropdown') {
            final selectedId = dropdownFields[key]?.value;
            final options = dropdownOptions[field['itemsKey']] ?? [];

            final selectedOption = options.firstWhere(
              (opt) => opt['id'] == selectedId,
              orElse: () => {'id': null, 'name': null},
            );

              finalData["application"][key] = selectedOption['name'];
          }

          // ✅ Multiselect
          else if (fieldType == 'multiselect') {
            final selectedValues =
                multiSelectControllers[key]?.selectedValues ?? [];
            finalData["application"][key] = selectedValues.join(',');
          }
        }
      }
    }

    return finalData;
  }

  String getDropdownLabel(String key, int? id) {
    final options = dropdownOptions[key] ?? [];
    final match = options.firstWhereOrNull((opt) => opt['id'] == id);
    return match != null ? match['name'] : '';
  }

  Widget buildFieldBlock(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xfffffcf6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade100),
      ),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.brown,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<int> submitApplication({
    required String endpointUrl,
  }) async {
    try {
      final formData = await collectFormDataForBackend(
        formSections: formSections,
        textFields: textFields,
        dropdownFields: dropdownFields,
        repeatableEntries: repeatableEntries,
        dropdownOptions: dropdownOptions,
        initiallyCompletedWorkInfo: initiallyCompletedWorkInfo,
        multiSelectControllers: multiSelectControllers,
      );

      formData['reqId'] = statecontroller.reqId.value;

      print(JsonEncoder.withIndent('  ').convert(formData));

      final response = await http.post(
        Uri.parse(endpointUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formData),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['success'] == true && result.containsKey('id')) {
          final int appId = result['id'];
          submittedApplicationId.value = appId;
          print('✅ Application submitted. ID: $appId');
          return appId;
        } else {
          throw Exception(result['message'] ?? 'Submission failed');
        }
      } else {
        throw Exception('❌ Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Submission error: $e');
      Get.snackbar("Submission Failed", e.toString());
      return 0;
    }
  }

  Widget buildSection(Map<String, dynamic> section) {
    final title = section['title'] ?? 'Untitled';
    final List<dynamic> subSections = section['subSections'] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffffead1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
              if (onBackToEdit != null && submittedApplicationId.value == null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                  onPressed: () => onBackToEdit!(section['key']),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
            ],
          ),
          const Divider(thickness: 1.5, color: Colors.white),

          // ── Sub‐sections ───────────────────────────────────────────────
          ...subSections.map<Widget>((sub) {
            final subTitle = sub['title'] ?? '';
            final subKey = sub['key'];
            final fields = sub['fields'] ?? [];

            // ── Repeatable ───────────────────────────────────────────
            if (sub['type'] == 'repeatable') {
              final entries = repeatableEntries[subKey] ?? [];
              if (entries.isEmpty) return const SizedBox.shrink();

              // 1) Section heading
              final widgets = <Widget>[];
              if (subTitle.isNotEmpty) {
                widgets.add(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    subTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown,
                    ),
                  ),
                ));
              }

              // 2) Occupation sections: 4 fields in a row
              const specialKeys = {
                'motherOccupationInfo',
                'fatherOccupationInfo',
                'guardianOccupationInfo',
              };
              if (specialKeys.contains(subKey)) {
                for (final entry in entries) {
                  widgets.add(Row(
                    children: [
                      Expanded(
                        child: buildFieldBlock(
                          'Mode of Work',
                          entry['${subKey.startsWith('mother') ? 'mother' : subKey.startsWith('father') ? 'father' : 'guardian'}_mode_work']
                                  ?.value ??
                              '',
                        ),
                      ),
                      Expanded(
                        child: buildFieldBlock(
                          'Organisation',
                          entry['${subKey.startsWith('mother') ? 'mother' : subKey.startsWith('father') ? 'father' : 'guardian'}_name_org']
                                  ?.value ??
                              '',
                        ),
                      ),
                      Expanded(
                        child: buildFieldBlock(
                          'Work Phone',
                          entry['${subKey.startsWith('mother') ? 'mother' : subKey.startsWith('father') ? 'father' : 'guardian'}_work_phone']
                                  ?.value ??
                              '',
                        ),
                      ),
                      Expanded(
                        child: buildFieldBlock(
                          'Website',
                          entry['${subKey.startsWith('mother') ? 'mother' : subKey.startsWith('father') ? 'father' : 'guardian'}_work_web']
                                  ?.value ??
                              '',
                        ),
                      ),
                    ],
                  ));
                  widgets.add(const SizedBox(height: 12));
                }
              } else {
                // 3) Generic repeatable → render as a table
                widgets.add(
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowColor:
                          WidgetStateProperty.all(const Color(0xfff0e6d8)),
                      dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          // even rows white, odd rows light grey
                          return states.contains(WidgetState.selected)
                              ? Colors.brown[100]
                              : null;
                        },
                      ),
                      columns: [
                        for (final f in fields)
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                f['label'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                      rows: [
                        for (int rowIndex = 0;
                            rowIndex < entries.length;
                            rowIndex++)
                          DataRow(
                            color: WidgetStateProperty.resolveWith((states) {
                              // stripe: even-index rows
                              return rowIndex.isEven
                                  ? Colors.white
                                  : Colors.grey[50];
                            }),
                            cells: [
                              for (final f in fields)
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      () {
                                        final raw = entries[rowIndex][f['key']];
                                        if (f['type'] == 'dropdown') {
                                          return getDropdownLabel(
                                            f['itemsKey'],
                                            (raw as Rxn<int>?)?.value,
                                          );
                                        }
                                        return (raw as RxString).value;
                                      }(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgets,
              );
            }

            // ── Regular (non-repeatable) ──────────────────────────────

            // split out nested repeatables
            final simpleFields =
                fields.where((f) => f['type'] != 'repeatable').toList();
            final nestedRepeatables =
                fields.where((f) => f['type'] == 'repeatable').toList();

            // 1) First render any nested-repeatable tables:
            final nestedWidgets = <Widget>[];
            for (final mini in nestedRepeatables) {
              nestedWidgets.add(_buildMiniRepeatableTable(mini, subKey));
              nestedWidgets.add(const SizedBox(height: 16));
            }

// 2) Now build your two-column grid from the simple fields:
            final fieldWidgets = simpleFields.map<Widget>((field) {
              final key = field['key'];
              final label = field['label'] as String? ?? '';
              final type = field['type'] as String;

              if (type == 'multiselect') {
                final values =
                    multiSelectControllers[key]?.selectedValues.toList() ?? [];
                final disp =
                    values.isNotEmpty ? values.join(', ') : 'None Selected';
                return buildFieldBlock(label, disp);
              }
              if (type == 'dropdown') {
                final val = dropdownFields[key]?.value;
                return buildFieldBlock(
                    label, getDropdownLabel(field['itemsKey'], val));
              }
              if (type == 'radio') {
                final val = textFields[key]?.value ?? '';
                return buildFieldBlock(label, val);
              }
              // text / fetch-its
              return buildFieldBlock(label, textFields[key]?.value ?? '');
            }).toList();

// chunk into rows of two
            final rows = <Widget>[];
            for (var i = 0; i < fieldWidgets.length; i += 2) {
              rows.add(Row(
                children: [
                  Expanded(child: fieldWidgets[i]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: i + 1 < fieldWidgets.length
                        ? fieldWidgets[i + 1]
                        : const SizedBox.shrink(),
                  ),
                ],
              ));
              rows.add(const SizedBox(height: 12));
            }

// 3) Combine nested-repeatable tables + two-col grid
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subTitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                    child: Text(
                      subTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.brown,
                      ),
                    ),
                  ),

                // nested repeatables first
                ...nestedWidgets,

                // then the two-column regular fields
                ...rows,
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniRepeatableTable(
    Map<String, dynamic> field,
    String parentSubKey,
  ) {
    final key = field['key'] as String;
    final label = field['label'] as String;
    final miniDefs =
        (field['fields'] as List<dynamic>).cast<Map<String, dynamic>>();
    final entries = repeatableEntries[key] ?? [];

    if (entries.isEmpty) {
      return Text('No $label added.',
          style: const TextStyle(fontStyle: FontStyle.italic));
    }

    // build columns
    final columns = miniDefs.map((f) {
      return DataColumn(
          label: Text(f['label'],
              style: const TextStyle(fontWeight: FontWeight.bold)));
    }).toList();

    // build rows
    final rows = entries.map((entry) {
      return DataRow(
          cells: miniDefs.map((f) {
        final raw = entry[f['key']];
        final text = f['type'] == 'dropdown'
            ? getDropdownLabel(f['itemsKey'], (raw as Rxn<int>?)?.value)
            : (raw as RxString).value;
        return DataCell(Text(text.isNotEmpty ? text : '—'));
      }).toList());
    }).toList();

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      constraints: BoxConstraints(minWidth: double.infinity),
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: WidgetStateProperty.all(Colors.brown[50]),
        dataRowColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.brown[100]
                : Colors.white),
        columns: columns,
        rows: rows,
      ),
    );
  }

  Future<void> handleSubmit(BuildContext context) async {
    isSubmitting.value = true;

    try {
      const endpointUrl =
          'https://one-login.attalimiyah.com.pk/ows/api/submit-application';

      int appid = await submitApplication(
        endpointUrl: endpointUrl,
      );

      if(appid!=0) {
        submittedApplicationId.value = appid;
        Get.to(() => ApplicationPdf(id: appid));
      }else{
        throw Exception();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to submit application please try again later of contact support team");
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffcf6),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Obx(
              () => Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(
                                top: 20.0, left: 15, bottom: 10),
                            child: Text(
                              "Imdaad Talimi Application Form",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.black87),
                            )),
                        //headerProfile(context),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 200, vertical: 10),
                          child: Column(
                            children: [
                              ...[
                                ...formSections
                                    .where((section) => section['key'] != 'intendInfo')
                                    .map(buildSection),

                                if (!formSections.any((s) => s['key'] == 'workInfo') &&
                                    initiallyCompletedWorkInfo != null &&
                                    repeatableEntries['motherOccupationInfo']?.isNotEmpty == true &&
                                    repeatableEntries['fatherOccupationInfo']?.isNotEmpty == true)
                                  buildSection(initiallyCompletedWorkInfo!),
                              ],
                              const SizedBox(height: 24),
                              if (submittedApplicationId.value == null)
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: isSubmitting.value
                                        ? null
                                        : () => handleSubmit(context),
                                    icon: const Icon(Icons.send, color: Colors.white),
                                    label: const Text(
                                      "Submit Application",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Constants().green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Set your desired radius
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 20),
                                      textStyle: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              if (submittedApplicationId.value != null)
                                Center(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      const Icon(Icons.check_circle,
                                          color: Colors.green, size: 40),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Application Submitted!",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          "Application ID: ${submittedApplicationId.value}"),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSubmitting.value)
                    Container(
                      color: Colors.black.withValues(alpha: 0.2),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.brown),
                      ),
                    )
                ],
              ),
            ),
          ),
          InstructionsWidget(instructionsKey: 'review')
        ],
      ),
    );
  }

  void showSubmissionSuccessDialog(
      BuildContext context, int applicationId, VoidCallback onClose) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: const Color(0xffffead1),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 50, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                "Application Submitted!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Your Application ID is: $applicationId",
                style: TextStyle(fontSize: 14, color: Colors.brown.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.check),
                label: const Text("OK"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  final GlobalStateController statecontroller =
      Get.find<GlobalStateController>();
  final double defSpacing = 8;

  Widget headerProfile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xfffff7ec),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants().subHeading("Personal Information"),
          Divider(),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  Api.fetchImage(statecontroller.user.value.imageUrl!),
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statecontroller.user.value.fullName ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' | '),
                        Text(
                          statecontroller.user.value.itsId.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Row(
                      spacing: defSpacing,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.location_on_rounded),
                            SizedBox(
                                width: 600,
                                child: Text(
                                    statecontroller.user.value.address ?? '')),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.location_on_rounded),
                            Text(
                              statecontroller.user.value.jamiaat ?? '',
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      spacing: defSpacing,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.calendar_month_rounded),
                            Text(statecontroller.user.value.dob ?? ''),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.calendar_month_rounded),
                            Text(
                                "${calculateAge(statecontroller.user.value.dob ?? '')} years old"),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.email),
                            Text(statecontroller.user.value.email!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(statecontroller.user.value.mobileNo!),
                          ],
                        ),
                        Row(
                          spacing: defSpacing,
                          children: [
                            Icon(Icons.phone),
                            Text(statecontroller.user.value.whatsappNo!),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 15,
                  children: [
                    profileBox('Applied By', 'ITS', context),
                    profileBox('Name', 'Name', context),
                  ],
                ),
              )
            ],
          ),
          lastEducation()
        ],
      ),
    );
  }

  Widget lastEducation() {
    if (statecontroller.user.value.education == null ||
        statecontroller.user.value.education!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Constants().subHeading("Last Education"),
            Divider(),
            Text(
              "No education data available",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Constants().subHeading("Last Education"),
          Divider(),
          Wrap(
            spacing: 20, // Space between items
            runSpacing: 10, // Space between lines when wrapped
            children: [
              buildEducationRow("Class/ Degree Program: ",
                  statecontroller.user.value.education![0].className),
              buildEducationRow("Institution: ",
                  statecontroller.user.value.education![0].institute),
              buildEducationRow("Field of Study: ",
                  statecontroller.user.value.education![0].subject),
              buildEducationRow(
                  "City: ", statecontroller.user.value.education![0].city),
            ],
          ),
          SizedBox()
        ],
      ),
    );
  }

  // ✅ Helper Widget to Ensure Consistent Text Styling
  Widget buildEducationRow(String label, String? value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, color: Colors.black), // Default style
        children: [
          TextSpan(text: label, style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: value ?? "Not available",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Constants().green),
          ),
        ],
      ),
    );
  }

  Widget profileBox(String title, String value, BuildContext context) {
    if (value == 'ITS') {
      value = statecontroller.appliedByITS.value;
    } else {
      value = statecontroller.appliedByName.value;
    }
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(10),
      width: Constants().responsiveWidth(context, 0.12),
      decoration: BoxDecoration(
          color: Color(0xffffead1),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: [
          Text(title,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(value,
              style: TextStyle(
                  color: Constants().green, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  int calculateAge(String dobString) {
    // Parse the string into a DateTime object
    final dob = DateTime.parse(dobString);
    final today = DateTime.now();
    int age = today.year - dob.year;
    // Adjust age if the current date is before the birthday this year
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }
}
