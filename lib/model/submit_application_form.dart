import 'dart:convert';

import 'package:get/get.dart';

class SubmissionFormModel {
  // Unique Identifiers
  final String its;
  final String reqId;

  // Personal information fields
  final String? sfNo;
  final String? hofIts;
  final String? familySurname;
  final String? fullName;
  final String? cnic;
  final String? dateOfBirth;
  final String? mobileNo;
  final String? whatsappNo;
  final String? email;
  final String? residentialAddress;
  final String? fatherName;
  final String? fatherCnic;
  final String? motherName;
  final String? motherCnic;
  final String? guardianName;
  final String? guardianCnic;
  final String? relationToStudent;
  final String? mohallaName;
  final String? appliedAmount;
  final String? amanat;

  // Income fields
  final String? personalIncome;
  final String? otherFamilyIncome;
  final String? studentIncome;
  final String? ownedProperty;
  final String? rentProperty;
  final String? goodwillProperty;
  final String? property;
  final String? jewelry;
  final String? transport;
  final String? others;

  // List fields stored as Base64-encoded JSON strings
  final String businessListEncoded;
  final String familyEducationListEncoded;
  final String otherCertificationListEncoded;
  final String travellingEncoded;
  final String dependentsEncoded;
  final String liabilitiesEncoded;
  final String enayatEncoded;
  final String guarantorEncoded;
  final String paymentsEncoded;
  final String repaymentsEncoded;

  SubmissionFormModel({
    required this.its,
    required this.reqId,
    this.sfNo,
    this.hofIts,
    this.familySurname,
    this.fullName,
    this.cnic,
    this.dateOfBirth,
    this.mobileNo,
    this.whatsappNo,
    this.email,
    this.residentialAddress,
    this.fatherName,
    this.fatherCnic,
    this.motherName,
    this.motherCnic,
    this.guardianName,
    this.guardianCnic,
    this.relationToStudent,
    this.mohallaName,
    this.appliedAmount,
    this.amanat,
    this.personalIncome,
    this.otherFamilyIncome,
    this.studentIncome,
    this.ownedProperty,
    this.rentProperty,
    this.goodwillProperty,
    this.property,
    this.jewelry,
    this.transport,
    this.others,
    required this.businessListEncoded,
    required this.familyEducationListEncoded,
    required this.otherCertificationListEncoded,
    required this.travellingEncoded,
    required this.dependentsEncoded,
    required this.liabilitiesEncoded,
    required this.enayatEncoded,
    required this.guarantorEncoded,
    required this.paymentsEncoded,
    required this.repaymentsEncoded,
  });

  /// **Factory constructor** that takes raw data (lists as normal JSON) and encodes them as Base64.
  factory SubmissionFormModel.fromData({
    required String its,
    required String reqId,
    String? sfNo,
    String? hofIts,
    String? familySurname,
    String? fullName,
    String? cnic,
    String? dateOfBirth,
    String? mobileNo,
    String? whatsappNo,
    String? email,
    String? residentialAddress,
    String? fatherName,
    String? fatherCnic,
    String? motherName,
    String? motherCnic,
    String? guardianName,
    String? guardianCnic,
    String? relationToStudent,
    String? mohallaName,
    String? appliedAmount,
    String? amanat,
    String? personalIncome,
    String? otherFamilyIncome,
    String? studentIncome,
    String? ownedProperty,
    String? rentProperty,
    String? goodwillProperty,
    String? property,
    String? jewelry,
    String? transport,
    String? others,
    required List<Map<String, dynamic>> businessList,
    required List<Map<String, dynamic>> familyEducationList,
    required List<Map<String, dynamic>> otherCertificationList,
    required List<Map<String, dynamic>> travelling,
    required List<Map<String, dynamic>> dependents,
    required List<Map<String, dynamic>> liabilities,
    required List<Map<String, dynamic>> enayat,
    required List<Map<String, dynamic>> guarantor,
    required List<Map<String, dynamic>> payments,
    required List<Map<String, dynamic>> repayments,
  }) {
    /// **Helper function to convert Rx types to normal types**
    dynamic convertToRegularObject(dynamic item) {
      if (item is RxString) return item.value; // Convert RxString -> String
      if (item is RxInt) return item.value; // Convert RxInt -> int
      if (item is RxBool) return item.value; // Convert RxBool -> bool
      if (item is RxList) return item.toList(); // Convert RxList -> List

      if (item is Map) {
        return item.map((key, value) => MapEntry(key, convertToRegularObject(value)));
      }
      if (item is List) {
        return item.map((value) => convertToRegularObject(value)).toList();
      }

      return item; // Return as is if it's already a normal type
    }

    String encodeList(List<Map<String, dynamic>> list) {
      return base64Encode(utf8.encode(jsonEncode(
        list.map((map) => convertToRegularObject(map)).toList(),
      )));
    }

    return SubmissionFormModel(
      its: its,
      reqId: reqId,
      sfNo: sfNo,
      hofIts: hofIts,
      familySurname: familySurname,
      fullName: fullName,
      cnic: cnic,
      dateOfBirth: dateOfBirth,
      mobileNo: mobileNo,
      whatsappNo: whatsappNo,
      email: email,
      residentialAddress: residentialAddress,
      fatherName: fatherName,
      fatherCnic: fatherCnic,
      motherName: motherName,
      motherCnic: motherCnic,
      guardianName: guardianName,
      guardianCnic: guardianCnic,
      relationToStudent: relationToStudent,
      mohallaName: mohallaName,
      appliedAmount: appliedAmount,
      amanat: amanat,
      personalIncome: personalIncome,
      otherFamilyIncome: otherFamilyIncome,
      studentIncome: studentIncome,
      ownedProperty: ownedProperty,
      rentProperty: rentProperty,
      goodwillProperty: goodwillProperty,
      property: property,
      jewelry: jewelry,
      transport: transport,
      others: others,
      businessListEncoded: encodeList(businessList.toList()),
      familyEducationListEncoded: encodeList(familyEducationList.toList()),
      otherCertificationListEncoded: encodeList(otherCertificationList.toList()),
      travellingEncoded: encodeList(travelling.toList()),
      dependentsEncoded: encodeList(dependents.toList()),
      liabilitiesEncoded: encodeList(liabilities.toList()),
      enayatEncoded: encodeList(enayat.toList()),
      guarantorEncoded: encodeList(guarantor.toList()),
      paymentsEncoded: encodeList(payments.toList()),
      repaymentsEncoded: encodeList(repayments.toList()),
    );
  }

  /// **Converts Base64 encoded fields back into a List of Maps**
  List<Map<String, dynamic>> decodeList(String encoded) {
    return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(base64Decode(encoded))));
  }

  /// **Converts the model to a JSON map**
  Map<String, dynamic> toJson() {
    return {
      'its': its,
      'reqId': reqId,
      'sfNo': sfNo,
      'hofIts': hofIts,
      'familySurname': familySurname,
      'fullName': fullName,
      'cnic': cnic,
      'dateOfBirth': dateOfBirth,
      'mobileNo': mobileNo,
      'whatsappNo': whatsappNo,
      'email': email,
      'residentialAddress': residentialAddress,
      'fatherName': fatherName,
      'fatherCnic': fatherCnic,
      'motherName': motherName,
      'motherCnic': motherCnic,
      'guardianName': guardianName,
      'guardianCnic': guardianCnic,
      'relationToStudent': relationToStudent,
      'mohallaName': mohallaName,
      'appliedAmount': appliedAmount,
      'amanat': amanat,
      'personalIncome': personalIncome,
      'otherFamilyIncome': otherFamilyIncome,
      'studentIncome': studentIncome,
      'ownedProperty': ownedProperty,
      'rentProperty': rentProperty,
      'goodwillProperty': goodwillProperty,
      'property': property,
      'jewelry': jewelry,
      'transport': transport,
      'others': others,
      'businessList': decodeList(businessListEncoded), // Decode Base64 to List
      'familyEducationList': decodeList(familyEducationListEncoded),
      'otherCertificationList': decodeList(otherCertificationListEncoded),
      'travelling': decodeList(travellingEncoded),
      'dependents': decodeList(dependentsEncoded),
      'liabilities': decodeList(liabilitiesEncoded),
      'enayat': decodeList(enayatEncoded),
      'guarantor': decodeList(guarantorEncoded),
      'payments': decodeList(paymentsEncoded),
      'repayments': decodeList(repaymentsEncoded),
    };
  }

}