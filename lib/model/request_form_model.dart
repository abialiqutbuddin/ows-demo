// Model class to save entered data
class RequestFormModel {
  int? reqId;
  String ITS;
  String studentFirstName;
  String studentFullName;
  String reqByITS;
  String reqByName;
  String city;
  String institution;
  String classDegree;
  String fieldOfStudy;
  String subjectCourse;
  String yearOfStart;
  String grade;
  String email;
  String contactNo;
  String whatsappNo;
  String purpose;
  String fundAsking;
  String classification;
  String organization;
  String description;
  String currentStatus;
  String createdBy;
  String updatedBy;
  String applyDate;
  String mohalla;
  String cnic;
  String? address;
  String? dob;

  RequestFormModel({
    this.reqId,
    required this.ITS,
    required this.studentFirstName,
    required this.studentFullName,
    required this.reqByITS,
    required this.reqByName,
    required this.city,
    required this.institution,
    required this.classDegree,
    required this.fieldOfStudy,
    required this.subjectCourse,
    required this.yearOfStart,
    required this.grade,
    required this.email,
    required this.contactNo,
    required this.whatsappNo,
    required this.purpose,
    required this.fundAsking,
    required this.classification,
    required this.organization,
    required this.description,
    required this.currentStatus,
    required this.createdBy,
    required this.updatedBy,
    required this.applyDate,
    required this.mohalla,
    required this.cnic,
    this.address,
    this.dob,
  });

  // ✅ Add `copyWith` Method
  RequestFormModel copyWith({
    int? reqId,
    String? ITS,
    String? studentName,
    String? reqByITS,
    String? reqByName,
    String? city,
    String? institution,
    String? classDegree,
    String? fieldOfStudy,
    String? subjectCourse,
    String? yearOfStart,
    String? grade,
    String? email,
    String? contactNo,
    String? whatsappNo,
    String? purpose,
    String? fundAsking,
    String? classification,
    String? organization,
    String? description,
    String? currentStatus,
    String? createdBy,
    String? updatedBy,
    String? applyDate,
    String? mohalla,
    String? address,
    String? dob,
    String? cnic,
  }) {
    return RequestFormModel(
      reqId: reqId ?? this.reqId,
      ITS: ITS ?? this.ITS,
      studentFirstName: ITS ?? this.studentFirstName,
      studentFullName: ITS ?? this.studentFullName,
      reqByITS: reqByITS ?? this.reqByITS,
      reqByName: reqByName ?? this.reqByName,
      city: city ?? this.city,
      institution: institution ?? this.institution,
      classDegree: classDegree ?? this.classDegree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      subjectCourse: subjectCourse ?? this.subjectCourse,
      yearOfStart: yearOfStart ?? this.yearOfStart,
      grade: grade ?? this.grade,
      email: email ?? this.email,
      contactNo: contactNo ?? this.contactNo,
      whatsappNo: whatsappNo ?? this.whatsappNo,
      purpose: purpose ?? this.purpose,
      fundAsking: fundAsking ?? this.fundAsking,
      classification: classification ?? this.classification,
      organization: organization ?? this.organization,
      description: description ?? this.description,
      currentStatus: currentStatus ?? this.currentStatus,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      applyDate: applyDate ?? this.applyDate,
      mohalla: mohalla ?? this.mohalla,
      address: address ?? this.address,
      cnic: cnic ?? this.cnic,
      dob: dob ?? this.dob,
    );
  }

  factory RequestFormModel.fromJson(Map<String, dynamic> json) {
    return RequestFormModel(
      reqId: json['reqId'],
      ITS: json['ITS'] ?? '',
      reqByITS: json['reqByITS'] ?? '',
      reqByName: json['reqByName'] ?? '',
      city: json['city'] ?? '',
      institution: json['institution'] ?? '',
      classDegree: json['class_degree'] ?? '', // Matches DB naming
      fieldOfStudy: json['fieldOfStudy'] ?? '',
      subjectCourse: json['subject_course'] ?? '', // Matches DB naming
      yearOfStart: json['yearOfStart'].toString() ?? '',
      grade: json['grade'] ?? '',
      email: json['email'] ?? '',
      contactNo: json['contactNo'] ?? '',
      whatsappNo: json['whatsappNo'] ?? '',
      purpose: json['purpose'] ?? '',
      fundAsking: json['fundAsking'] ?? '',
      classification: json['classification'] ?? '',
      organization: json['organization'] ?? '',
      description: json['description'] ?? '',
      currentStatus: json['currentStatus'] ?? '',
      createdBy: json['created_by'] ?? '', // Matches DB naming
      updatedBy: json['updated_by'] ?? '', // Matches DB naming
      applyDate: json['applyDate'] ?? '',
      mohalla: json['mohalla'] ?? '',
      address: json['address'],
      dob: json['dob'],
      cnic: json['cnic'] ?? '',
      studentFirstName: json['studentFirstName'] ?? '',
      studentFullName: json['studentFullName'] ?? '',
    );
  }

  // ✅ Convert object to JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      'ITS': ITS,
      'studentFirstName': studentFirstName,
      'studentFullName': studentFullName,
      'reqByITS': reqByITS,
      'reqByName': reqByName,
      'city': city,
      'institution': institution,
      'class_degree': classDegree, // Matches DB
      'fieldOfStudy': fieldOfStudy,
      'subject_course': subjectCourse, // Matches DB
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
      'created_by': createdBy, // Matches DB
      'updated_by': updatedBy, // Matches DB
      'applyDate': applyDate,
      'mohalla': mohalla,
      'address': address,
      'cnic': cnic,
      'dob': dob,
    };
  }

  @override
  String toString() {
    return '''
RequestFormModel(
  ITS: $ITS,
  studentFirstName: $studentFirstName,
  studentFullName: $studentFullName,
  reqByITS: $reqByITS,
  reqByName: $reqByName,
  city: $city,
  institution: $institution,
  classDegree: $classDegree,
  fieldOfStudy: $fieldOfStudy,
  subjectCourse: $subjectCourse,
  yearOfStart: $yearOfStart,
  grade: $grade,
  email: $email,
  contactNo: $contactNo,
  whatsappNo: $whatsappNo,
  purpose: $purpose,
  fundAsking: $fundAsking,
  classification: $classification,
  organization: $organization,
  description: $description,
  currentStatus: $currentStatus,
  createdBy: $createdBy,
  updatedBy: $updatedBy,
  applyDate: $applyDate
  mohalla: $mohalla
  address: $address
  dob: $dob
  cnic: $cnic
)
    ''';
  }
}