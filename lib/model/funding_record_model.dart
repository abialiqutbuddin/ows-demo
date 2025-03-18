import 'dart:convert';

class FundingRecords {
  final int id;
  final String org;
  final String mohalla;
  final String its;
  final String sf;
  final String student;
  final String father;
  final String school;
  final String parentsP;
  final String orgP;
  final String date;
  final String createdAt;
  final String updatedAt;
  final String amount;

  FundingRecords({
    required this.id,
    required this.org,
    required this.mohalla,
    required this.its,
    required this.sf,
    required this.student,
    required this.father,
    required this.school,
    required this.parentsP,
    required this.orgP,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.amount,
  });

  // Factory method to create an instance from JSON with validations
  factory FundingRecords.fromJson(Map<String, dynamic> json) {
    return FundingRecords(
      id: json['id'] ?? 0,
      org: (json['org'] == null || json['org'].toString().isEmpty) ? "-" : json['org'].toString(),
      mohalla: (json['mohalla'] == null || json['mohalla'].toString().isEmpty) ? "-" : json['mohalla'].toString(),
      its: (json['its'] == null || json['its'].toString().isEmpty) ? "-" : json['its'].toString(),
      sf: (json['sf'] == null || json['sf'].toString().isEmpty) ? "-" : json['sf'].toString(),
      student: (json['student'] == null || json['student'].toString().isEmpty) ? "-" : json['student'].toString(),
      father: (json['father'] == null || json['father'].toString().isEmpty) ? "-" : json['father'].toString(),
      school: (json['school'] == null || json['school'].toString().isEmpty) ? "-" : json['school'].toString(),
      parentsP: (json['parents_p'] == null || json['parents_p'].toString().isEmpty) ? "-" : json['parents_p'].toString(),
      date: (json['date'] == null || json['date'].toString().isEmpty) ? "-" : json['date'].toString(),
      orgP: (json['org_p'] == null || json['org_p'].toString().isEmpty) ? "-" : json['org_p'].toString(),
      amount: (json['amount'] == null || json['amount'].toString().isEmpty) ? "-" : json['amount'].toString(),
      createdAt: (json['created_at'] == null || json['created_at'].toString().isEmpty) ? "-" : json['created_at'].toString(),
      updatedAt: (json['updated_at'] == null || json['updated_at'].toString().isEmpty) ? "-" : json['updated_at'].toString(),
    );
  }

  // Convert an instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org': org,
      'mohalla': mohalla,
      'its': its,
      'sf': sf,
      'student': student,
      'father': father,
      'school': school,
      'parents_p': parentsP,
      'org_p': orgP,
      'date': date,
      'amount': amount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Convert a list of JSON objects into a list of AiutRecord objects with validation
  static List<FundingRecords> fromJsonList(String str) {
    try {
      final jsonData = json.decode(str);
      if (jsonData is List) {
        return jsonData.map((x) => FundingRecords.fromJson(x)).toList();
      } else {
        return []; // Return an empty list if JSON is not an array
      }
    } catch (e) {
      print("Error parsing JSON: $e");
      return [];
    }
  }

  bool isValid() {
    return id > 0 &&
        org.isNotEmpty &&
        student.isNotEmpty &&
        father.isNotEmpty &&
        school.isNotEmpty &&
        its.length == 8; // ITS must be 8 characters long
  }
}