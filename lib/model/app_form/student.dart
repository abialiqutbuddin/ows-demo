class Student {
  String studentId;
  int? studentNo;
  String? sfNo;
  String? itsNo;
  String studentName;
  String surname;
  DateTime? dob;
  String? userImage;
  String? fatherItsNo;
  String fatherName;
  String? fatherMobileNo;
  int fatherOccupationId;
  String? fatherCnic;
  String? motherItsNo;
  String motherName;
  String? motherMobileNo;
  int motherOccupationId;
  String? residentialAddress;
  String? residentialPhoneNo;
  int mohallahId;
  String? gender;
  String? status;
  String? deleteRequest;
  String? madrassaGoing;
  int madrassaId;
  String financeSupport;
  DateTime? faDate;
  String? employerName;
  double monthlyIncome;
  int earningMembers;
  int dependents;
  double flatArea;
  DateTime? createdAt;
  int? createdById;
  DateTime? modifiedAt;
  int? modifiedById;

  Student({
    required this.studentId,
    this.studentNo,
    this.sfNo,
    this.itsNo,
    required this.studentName,
    required this.surname,
    this.dob,
    this.userImage,
    this.fatherItsNo,
    required this.fatherName,
    this.fatherMobileNo,
    required this.fatherOccupationId,
    this.fatherCnic,
    this.motherItsNo,
    required this.motherName,
    this.motherMobileNo,
    required this.motherOccupationId,
    this.residentialAddress,
    this.residentialPhoneNo,
    required this.mohallahId,
    this.gender,
    this.status,
    this.deleteRequest,
    this.madrassaGoing,
    required this.madrassaId,
    required this.financeSupport,
    this.faDate,
    this.employerName,
    required this.monthlyIncome,
    required this.earningMembers,
    required this.dependents,
    required this.flatArea,
    this.createdAt,
    this.createdById,
    this.modifiedAt,
    this.modifiedById,
  });

  Map<String, dynamic> toJson() {
    return {
      "student_id": studentId,
      "student_no": studentNo,
      "sf_no": sfNo,
      "its_no": itsNo,
      "student_name": studentName,
      "surname": surname,
      "dob": dob?.toIso8601String(),
      "user_image": userImage,
      "father_its_no": fatherItsNo,
      "father_name": fatherName,
      "father_mobile_no": fatherMobileNo,
      "father_occupation_id": fatherOccupationId,
      "father_cnic": fatherCnic,
      "mother_its_no": motherItsNo,
      "mother_name": motherName,
      "mother_mobile_no": motherMobileNo,
      "mother_occupation_id": motherOccupationId,
      "residential_address": residentialAddress,
      "residential_phone_no": residentialPhoneNo,
      "mohallah_id": mohallahId,
      "gender": gender,
      "status": status,
      "delete_request": deleteRequest,
      "madrassa_going": madrassaGoing,
      "madrassa_id": madrassaId,
      "finance_support": financeSupport,
      "fa_date": faDate?.toIso8601String(),
      "employer_name": employerName,
      "monthly_income": monthlyIncome,
      "earning_members": earningMembers,
      "dependents": dependents,
      "flat_area": flatArea,
      "created_at": createdAt?.toIso8601String(),
      "created_by_id": createdById,
      "modified_at": modifiedAt?.toIso8601String(),
      "modified_by_id": modifiedById
    };
  }
}