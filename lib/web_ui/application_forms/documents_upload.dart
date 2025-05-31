import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:ows/api/api.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/model/document.dart';

class DocumentsFormScreenW extends StatefulWidget {
  const DocumentsFormScreenW({Key? key}) : super(key: key);

  @override
  State<DocumentsFormScreenW> createState() => _DocumentsFormScreenWState();
}

class _DocumentsFormScreenWState extends State<DocumentsFormScreenW> {
  static final GlobalStateController _global = Get.find();
  final String _its = _global.user.value.itsId.toString();
  final String _reqId = _global.reqId.toString();

  // your mock requirements JSON
  static const _mockJson = '''[
  {"name":"Raza Letter","type":"pdf,png,jpg","required":true,"docType":"raza_letter"},
  {"name":"Safai chitti","type":"pdf,png,jpg","required":true,"docType":"safai_chitti"},
  {"name":"CNIC Front","type":"pdf,png,jpg","required":true,"docType":"cnic_front"},
  {"name":"CNIC Back","type":"pdf,png,jpg","required":true,"docType":"cnic_back"},
  {"name":"ITS Card","type":"pdf","required":false,"docType":"its_card"},
  {"name":"Course Prospectus","type":"pdf,png,jpg","required":true,"docType":"course_prospectus"},
  {"name":"Financial Proof","type":"any","required":false,"docType":"financial_proof_documents"},
  {"name":"Others","type":"any","required":false,"docType":"others"}
]''';

  bool areRequiredDocsUploaded(Map<String, Document?> documents) {
    const requiredDocTypes = [
      'raza_letter',
      'safai_chitti',
      'cnic_front',
      'cnic_back',
      'its_card',
    ];

    bool allUploaded = true;

    for (var docType in requiredDocTypes) {
      final hasDoc = documents.containsKey(docType) && documents[docType] != null;
      print('Checking $docType: ${hasDoc ? "Found" : "Missing"}');
      if (!hasDoc) allUploaded = false;
    }

    print('All required docs uploaded: $allUploaded');
    return allUploaded;
  }

  late final List<DocumentRequirement> _requirements =
      (jsonDecode(_mockJson) as List)
          .map((e) => DocumentRequirement.fromJson(e))
          .toList();

  Future<void> _pickAndUpload(DocumentRequirement req) async {
    final result = await FilePicker.platform.pickFiles(
      type: req.type == 'any' ? FileType.any : FileType.custom,
      allowedExtensions: req.type == 'any' ? null : req.type.split(','),
      withData: true,
    );
    if (result == null) return;

    final name = result.files.single.name;
    final bytes = result.files.single.bytes;
    final path = result.files.single.path;

    try {
      if (kIsWeb && bytes != null) {
        await Api.uploadDocument(
          docType: req.docType,
          ITS: _its,
          reqId: _reqId,
          bytes: bytes,
          fileName: name,
        );
        _global.documents[req.docType] =
            Document(bytes: bytes, fileName: name, filePath: null, file: null);
      } else if (!kIsWeb && path != null) {
        final file = File(path);
        await Api.uploadDocument(
          docType: req.docType,
          ITS: _its,
          reqId: _reqId,
          file: file,
          fileName: name,
        );
        _global.documents[req.docType] =
            Document(file: file, fileName: name, filePath: path, bytes: null);
      }
      setState(() {});
    } catch (e) {
      Get.snackbar('Upload Failed', 'Could not upload ${req.name}');
    }
  }

  Future<void> _remove(DocumentRequirement req) async {
    await Api.removeDocument(req.docType);
    _global.documents.remove(req.docType);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]),
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Table(
              // Give each column a flex: 3:1:4:3 ratio for Doc / Req / Status / Actions
              columnWidths: const {
                0: FlexColumnWidth(4),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(2),
              },
              border: TableBorder.symmetric(
                inside: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(color: Color(0xffffead1)),
                  children: [
                    _buildHeaderCell('Document'),
                    _buildHeaderCell('Status'),
                    _buildHeaderCell('Actions'),
                  ],
                ),

                // Data rows
                for (var req in _requirements)
                  TableRow(
                    decoration: BoxDecoration(color: Colors.white),
                    children: [
                      // Document Name
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(req.name,
                            style: const TextStyle(fontSize: 16)),
                      ),

                      // Status
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Obx(() {
                          final doc = _global.documents[req.docType];
                          if (doc == null) {
                            return const Text('Not uploaded',
                                style: TextStyle(color: Colors.grey));
                          }
                          final name =
                              kIsWeb ? doc.fileName! : basename(doc.filePath!);
                          return Row(
                            children: [
                              const Icon(Icons.insert_drive_file,
                                  color: Colors.green),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text(name,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          );
                        }),
                      ),

                      // Actions
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Obx(() {
                          final isUploaded =
                              _global.documents.containsKey(req.docType);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(
                                  isUploaded
                                      ? Icons.swap_horiz
                                      : Icons.upload_file,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  isUploaded ? 'Change' : 'Upload',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  minimumSize: const Size(0, 36),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                ),
                                onPressed: () => _pickAndUpload(req),
                              ),
                              if (isUploaded) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _remove(req),
                                ),
                              ],
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void printUploadedDocuments() {
    if (_global.documents.isEmpty) {
      print('No documents uploaded yet.');
      return;
    }

    _global.documents.forEach((docType, doc) {
      final name = kIsWeb
          ? doc?.fileName ?? 'Unnamed file'
          : basename(doc?.filePath ?? 'Unknown path');
      print('Uploaded Document: $docType, File Name: $name');
    });
  }

  Widget _buildHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.brown)),
    );
  }
}
