import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> formSections;
  final RxMap<String, RxString> textFields;
  final RxMap<String, Rxn<int>> dropdownFields;
  final Map<String, RxList<Map<String, dynamic>>> repeatableEntries;
  final Map<String, List<Map<String, dynamic>>> dropdownOptions;
  final void Function(String sectionKey)? onBackToEdit;

  const ReviewScreen({
    super.key,
    required this.formSections,
    required this.textFields,
    required this.dropdownFields,
    required this.repeatableEntries,
    required this.dropdownOptions,
    this.onBackToEdit,
  });

  String getDropdownLabel(String key, int? id) {
    final options = dropdownOptions[key] ?? [];
    final match = options.firstWhereOrNull((opt) => opt['id'] == id);
    return match != null ? match['name'] : '';
  }

  Widget buildFieldBlock(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xfffffcf6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.brown,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
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
              if (onBackToEdit != null)
                TextButton(
                  onPressed: () => onBackToEdit!(section['key']),
                  child: const Text(
                    "Edit",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                )
            ],
          ),
          const Divider(thickness: 1.5, color: Colors.white),
          ...subSections.map<Widget>((sub) {
            final subTitle = sub['title'] ?? '';
            final subKey = sub['key'];
            final fields = sub['fields'] ?? [];

            if (sub['type'] == 'repeatable') {
              final entries = repeatableEntries[subKey] ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subTitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        subTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ...entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.brown.shade100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: fields.map<Widget>((f) {
                          final key = f['key'];
                          final label = f['label'];
                          final type = f['type'];

                          if (type == 'dropdown') {
                            return buildFieldBlock(
                              label,
                              getDropdownLabel(f['itemsKey'], entry[key]?.value),
                            );
                          }

                          return buildFieldBlock(label, entry[key]?.value ?? '');
                        }).toList(),
                      ),
                    );
                  }),
                ],
              );
            }

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
                ...fields.map<Widget>((field) {
                  final key = field['key'];
                  final label = field['label'] ?? '';
                  final type = field['type'];

                  if (type == 'dropdown') {
                    final selectedVal = dropdownFields[key]?.value;
                    final baseLabel = getDropdownLabel(field['itemsKey'], selectedVal);

                    List<Widget> widgets = [
                      buildFieldBlock(label, baseLabel),
                    ];

                    if (field.containsKey('showTextFieldIf') &&
                        selectedVal == field['showTextFieldIf']) {
                      final textKey = field['textFieldKey'];
                      final linkedLabel = field['textFieldLabel'];
                      final linkedVal = textFields[textKey]?.value ?? '';
                      widgets.add(buildFieldBlock(linkedLabel, linkedVal));
                    }

                    if (field.containsKey('showDropdownIf') &&
                        selectedVal == field['showDropdownIf']) {
                      final dropdownKey = field['dropdownKey'];
                      final linkedLabel = field['dropdownLabel'];
                      final linkedVal = dropdownFields[dropdownKey]?.value;
                      final itemsKey = field['itemsKey2'];
                      widgets.add(buildFieldBlock(
                          linkedLabel, getDropdownLabel(itemsKey, linkedVal)));
                    }

                    return Column(children: widgets);
                  }

                  if (type == 'radio') {
                    final val = textFields[key]?.value ?? '';
                    List<Widget> widgets = [buildFieldBlock(label, val)];

                    if (field.containsKey('showTextFieldIf') &&
                        val == field['showTextFieldIf']) {
                      final textKey = field['textFieldKey'];
                      final linkedLabel = field['textFieldLabel'];
                      final linkedVal = textFields[textKey]?.value ?? '';
                      widgets.add(buildFieldBlock(linkedLabel, linkedVal));
                    }

                    if (field.containsKey('showDropdownIf') &&
                        val == field['showDropdownIf']) {
                      final dropdownKey = field['dropdownKey'];
                      final linkedLabel = field['dropdownLabel'];
                      final linkedVal = dropdownFields[dropdownKey]?.value;
                      final itemsKey = field['itemsKey'];
                      widgets.add(buildFieldBlock(
                          linkedLabel, getDropdownLabel(itemsKey, linkedVal)));
                    }

                    return Column(children: widgets);
                  }

                  if (type == 'text') {
                    return buildFieldBlock(label, textFields[key]?.value ?? '');
                  }

                  return const SizedBox.shrink();
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffcf6),
      appBar: AppBar(
        title: const Text("Review Your Application"),
        backgroundColor: Colors.brown.shade100,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          ...formSections.map(buildSection),
        ],
      ),
    );
  }
}