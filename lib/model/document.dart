import 'dart:io';
import 'package:flutter/foundation.dart';

class Document {
  final File? file; // For mobile
  final Uint8List? bytes; // For web
  final String? fileName;
  final String? filePath;

  Document({
    this.file,
    this.bytes,
    this.fileName,
    this.filePath,
  });
}
class DocumentRequirement {
  final String name;
  final String type;
  final bool required;
  final String docType;

  DocumentRequirement({
    required this.name,
    required this.type,
    required this.required,
    required this.docType,
  });

  factory DocumentRequirement.fromJson(Map<String, dynamic> json) {
    return DocumentRequirement(
      name: json['name'],
      type: json['type'],
      required: json['required'],
      docType: json['docType'],
    );
  }
}
