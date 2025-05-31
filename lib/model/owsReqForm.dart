class OwsReqForm {
  final int? reqId;
  final String its;
  final String reqByIts;
  final String reqByName;
  final String? city;
  final String? institution;
  final String? classDegree;
  final String? fieldOfStudy;
  final String? subjectCourse;
  final int? yearOfStart;
  final String? grade;
  final String? email;
  final String? contactNo;
  final String? whatsappNo;
  final String? purpose;
  final double? fundAsking;
  final String? classification;
  final String? organization;
  final String? description;
  final String? currentStatus;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mohalla;
  final String? studentName;
  final int? draftId;
  final int? applicationId;

  // Additional fields
  final String? studentCnic;
  final String? gender;

  OwsReqForm({
    this.reqId,
    required this.its,
    required this.reqByIts,
    required this.reqByName,
    this.city,
    this.institution,
    this.classDegree,
    this.fieldOfStudy,
    this.subjectCourse,
    this.yearOfStart,
    this.grade,
    this.email,
    this.contactNo,
    this.whatsappNo,
    this.purpose,
    this.fundAsking,
    this.classification,
    this.organization,
    this.description,
    this.currentStatus,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.mohalla,
    this.studentName,
    this.draftId,
    this.applicationId,
    this.studentCnic,
    this.gender,
  });

  factory OwsReqForm.fromJson(Map<String, dynamic> json) {
    return OwsReqForm(
      reqId: json['reqId'],
      its: json['ITS'],
      reqByIts: json['reqByITS'],
      reqByName: json['reqByName'],
      city: json['city'],
      institution: json['institution'],
      classDegree: json['class_degree'],
      fieldOfStudy: json['fieldOfStudy'],
      subjectCourse: json['subject_course'],
      yearOfStart: json['yearOfStart'],
      grade: json['grade'],
      email: json['email'],
      contactNo: json['contactNo'],
      whatsappNo: json['whatsappNo'],
      purpose: json['purpose'],
      fundAsking: (json['fundAsking'] as num?)?.toDouble(),
      classification: json['classification'],
      organization: json['organization'],
      description: json['description'],
      currentStatus: json['currentStatus'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      mohalla: json['mohalla'],
      studentName: json['studentName'],
      draftId: json['draft_id'],
      applicationId: json['application_id'],
      studentCnic: json['student_cnic'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reqId': reqId,
      'ITS': its,
      'reqByITS': reqByIts,
      'reqByName': reqByName,
      'city': city,
      'institution': institution,
      'class_degree': classDegree,
      'fieldOfStudy': fieldOfStudy,
      'subject_course': subjectCourse,
      'yearOfStart': yearOfStart,
      'grade': grade,
      'email': email,
      'contactNo': contactNo,
      'whatsappNo': whatsappNo,
      'purpose': purpose,
      'fundAsking': fundAsking,
      'classification': classification,
      'organization': organization,
      'description': description,
      'currentStatus': currentStatus,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'mohalla': mohalla,
      'studentName': studentName,
      'draft_id': draftId,
      'application_id': applicationId,
      'student_cnic': studentCnic,
      'gender': gender,
    };
  }
}