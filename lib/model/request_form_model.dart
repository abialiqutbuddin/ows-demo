// Model class to save entered data
class RequestFormModel {
  String classDegree;
  String institution;
  String city;
  String study;
  String subject;
  String year;
  String email;
  String phoneNumber;
  String whatsappNumber;
  String fundAmount;
  String fundDescription;
  String memberITS;
  String appliedbyIts;
  String appliedbyName;
  String applyDate;
  String mohalla;
  String address;
  String dob;
  String firstName;
  String fullName;

  RequestFormModel({
    required this.classDegree,
    required this.institution,
    required this.city,
    required this.study,
    required this.subject,
    required this.year,
    required this.email,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.fundAmount,
    required this.memberITS,
    required this.appliedbyIts,
    required this.appliedbyName,
    required this.applyDate,
    required this.fundDescription,
    required this.mohalla,
    required this.address,
    required this.dob,
    required this.fullName,
    required this.firstName,
  });

  Map<String, dynamic> toJson() {
    return {
      'classDegree': classDegree,
      'institution': institution,
      'city': city,
      'study': study,
      'subject': subject,
      'year': year,
      'email': email,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'fundAmount': fundAmount,
      'fundDescription': fundDescription,
      'memberITS': memberITS,
      'appliedbyIts': appliedbyIts,
      'appliedbyName': appliedbyName,
      'applyDate': applyDate,
      'mohalla': mohalla,
      'address': address,
      'dob': dob,
      'fullName': fullName,
      'firstName':firstName,
    };
  }

  @override
  String toString() {
    return '''
RequestFormModel(
  classDegree: $classDegree,
  institution: $institution,
  city: $city,
  study: $study,
  subject: $subject,
  year: $year,
  email: $email,
  phoneNumber: $phoneNumber,
  whatsappNumber: $whatsappNumber,
  fundAmount: $fundAmount,
  memberITS: $memberITS,
  appliedbyIts: $appliedbyIts,
  appliedbyName: $appliedbyName,
  applyDate: $applyDate
  fundDescription: $fundDescription
  mohalla: $mohalla
  address: $address
  dob: $dob
  fullName: $fullName
  firstName: $firstName
)
    ''';
  }
}