// class StudentProfile {
//   final int its;
//   final String fullName;
//   final String gender;
//   final String dateOfBirth;
//   final int age;
//   final String firstName;
//   final String middleName;
//   final String lastName;
//   final String residenceAddress;
//   final String residencePhone;
//   final String image;
//   final String imaniInstitute;
//   final String previousInstitute;
//   final String previousClass;
//   final String profileCompleted;
//   final Parent father;
//   final Parent mother;
//
//   StudentProfile({
//     required this.its,
//     required this.fullName,
//     required this.gender,
//     required this.dateOfBirth,
//     required this.age,
//     required this.firstName,
//     required this.middleName,
//     required this.lastName,
//     required this.residenceAddress,
//     required this.residencePhone,
//     required this.image,
//     required this.imaniInstitute,
//     required this.previousInstitute,
//     required this.previousClass,
//     required this.profileCompleted,
//     required this.father,
//     required this.mother,
//   });
//
//   factory StudentProfile.fromJson(Map<String, dynamic> json) {
//     return StudentProfile(
//       its: json['its'],
//       fullName: json['full_name'],
//       gender: json['gender'],
//       dateOfBirth: json['date_of_birth'],
//       age: json['age'],
//       firstName: json['first_name'],
//       middleName: json['middle_name'],
//       lastName: json['last_name'],
//       residenceAddress: json['residence_address'],
//       residencePhone: json['residence_phone'],
//       image: json['image'],
//       imaniInstitute: json['imani_institute'],
//       previousInstitute: json['previous_institute'],
//       previousClass: json['previous_class'],
//       profileCompleted: json['profile_completed'],
//       father: Parent.fromJson(json['father']),
//       mother: Parent.fromJson(json['mother']),
//     );
//   }
// }
//
// class Parent {
//   final int id;
//   final int itsId;
//   final int hofId;
//   final int? motherIts;
//   final int? fatherIts;
//   final int? spouseIts;
//   final int sfNo;
//   final int jamaatId;
//   final String fullName;
//   final String firstName;
//   final String suffix;
//   final String fatherName;
//   final String fatherSuffix;
//   final String fatherSurname;
//   final String? motherName;
//   final String surname;
//   final String dob;
//   final String gender;
//   final String vatan;
//   final String martialStatus;
//   final String qualification;
//   final String jamiaat;
//   final String? idara;
//   final String organization;
//   final String email;
//   final String mobileNo;
//   final String whatsappNo;
//   final String tanzeem;
//   final int age;
//   final String hifzSanad;
//   final String misaq;
//   final int status;
//   final int completed;
//   final String hometown;
//   final String address;
//   final String currentCity;
//   final String nationality;
//   final String? website;
//   final String profession;
//   final String imageUrl;
//   final String itsStatus;
//   final int marhalaOngoing;
//   final int ambitionId;
//   final int currentMarhala;
//   final String currentClass;
//   final int currentComplete;
//   final int previousComplete;
//   final int progress;
//   final int isApproved;
//   final String? approvedOn;
//   final String? approvedBy;
//   final int isDelete;
//
//   Parent({
//     required this.id,
//     required this.itsId,
//     required this.hofId,
//     this.motherIts,
//     this.fatherIts,
//     this.spouseIts,
//     required this.sfNo,
//     required this.jamaatId,
//     required this.fullName,
//     required this.firstName,
//     required this.suffix,
//     required this.fatherName,
//     required this.fatherSuffix,
//     required this.fatherSurname,
//     this.motherName,
//     required this.surname,
//     required this.dob,
//     required this.gender,
//     required this.vatan,
//     required this.martialStatus,
//     required this.qualification,
//     required this.jamiaat,
//     this.idara,
//     required this.organization,
//     required this.email,
//     required this.mobileNo,
//     required this.whatsappNo,
//     required this.tanzeem,
//     required this.age,
//     required this.hifzSanad,
//     required this.misaq,
//     required this.status,
//     required this.completed,
//     required this.hometown,
//     required this.address,
//     required this.currentCity,
//     required this.nationality,
//     this.website,
//     required this.profession,
//     required this.imageUrl,
//     required this.itsStatus,
//     required this.marhalaOngoing,
//     required this.ambitionId,
//     required this.currentMarhala,
//     required this.currentClass,
//     required this.currentComplete,
//     required this.previousComplete,
//     required this.progress,
//     required this.isApproved,
//     this.approvedOn,
//     this.approvedBy,
//     required this.isDelete,
//   });
//
//   factory Parent.fromJson(Map<String, dynamic> json) {
//     return Parent(
//       id: json['id'],
//       itsId: json['its_id'],
//       hofId: json['hof_id'],
//       motherIts: json['mother_its'],
//       fatherIts: json['father_its'],
//       spouseIts: json['spouse_its'],
//       sfNo: json['sf_no'],
//       jamaatId: json['jamaat_id'],
//       fullName: json['full_name'],
//       firstName: json['first_name'],
//       suffix: json['suffix'],
//       fatherName: json['father_name'],
//       fatherSuffix: json['father_suffix'],
//       fatherSurname: json['father_surname'],
//       motherName: json['mother_name'],
//       surname: json['surname'],
//       dob: json['dob'],
//       gender: json['gender'],
//       vatan: json['vatan'],
//       martialStatus: json['martial_status'],
//       qualification: json['qualification'],
//       jamiaat: json['jamiaat'],
//       idara: json['idara'],
//       organization: json['organization'],
//       email: json['email'],
//       mobileNo: json['mobile_no'],
//       whatsappNo: json['whatsapp_no'],
//       tanzeem: json['tanzeem'],
//       age: json['age'],
//       hifzSanad: json['hifz_sanad'],
//       misaq: json['misaq'],
//       status: json['status'],
//       completed: json['completed'],
//       hometown: json['hometown'],
//       address: json['address'],
//       currentCity: json['current_city'],
//       nationality: json['nationality'],
//       website: json['website'],
//       profession: json['profession'],
//       imageUrl: json['image_url'],
//       itsStatus: json['its_status'],
//       marhalaOngoing: json['marhala_ongoing'],
//       ambitionId: json['ambition_id'],
//       currentMarhala: json['current_marhala'],
//       currentClass: json['current_class'],
//       currentComplete: json['current_complete'],
//       previousComplete: json['previous_complete'],
//       progress: json['progress'],
//       isApproved: json['is_approved'],
//       approvedOn: json['approved_on'],
//       approvedBy: json['approved_by'],
//       isDelete: json['is_delete'],
//     );
//   }
// }