class Family {
  int? its;
  String? fullName;
  String? gender;
  String? dateOfBirth;
  int? age;
  String? firstName;
  String? middleName;
  String? lastName;
  String? residenceAddress;
  String? residencePhone;
  String? image;
  String? imaniInstitute;
  String? previousInstitute;
  String? previousClass;
  String? profileCompleted;
  Parent? father;
  Parent? mother;

  Family({
    this.its,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.firstName,
    this.middleName,
    this.lastName,
    this.residenceAddress,
    this.residencePhone,
    this.image,
    this.imaniInstitute,
    this.previousInstitute,
    this.previousClass,
    this.profileCompleted,
    this.father,
    this.mother,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      its: json['ITS'],
      fullName: json['Full Name'],
      gender: json['Gender'],
      dateOfBirth: json['Date of Birth'],
      age: json['Age'],
      firstName: json['First Name'],
      middleName: json['Middle Name'],
      lastName: json['Last Name'],
      residenceAddress: json['Residence Address'],
      residencePhone: json['Residence Phone'],
      image: json['Image'],
      imaniInstitute: json['Imani Institute'],
      previousInstitute: json['Previous Institute'],
      previousClass: json['Previous Class'],
      profileCompleted: json['Profile Completed'],
      father: (json['father'] is Map<String, dynamic>)
          ? Parent.fromJson(json['father'])
          : null,
      mother: (json['mother'] is Map<String, dynamic>)
          ? Parent.fromJson(json['mother'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ITS': its,
      'Full Name': fullName,
      'Gender': gender,
      'Date of Birth': dateOfBirth,
      'Age': age,
      'First Name': firstName,
      'Middle Name': middleName,
      'Last Name': lastName,
      'Residence Address': residenceAddress,
      'Residence Phone': residencePhone,
      'Image': image,
      'Imani Institute': imaniInstitute,
      'Previous Institute': previousInstitute,
      'Previous Class': previousClass,
      'Profile Completed': profileCompleted,
      'father': father?.toJson(),
      'mother': mother?.toJson(),
    };
  }
}

class Parent {
  int? itsId;
  String? name;
  String? qualification;
  String? occupation;
  String? organisation;
  String? idara;
  String? sabaq;
  String? image;
  String? officeAddress;
  String? officePhone;
  String? annualIncome;
  String? mobile;
  String? email;
  String? imaniInstitute;
  String? previousInstitute;
  String? previousClass;
  String? profileCompleted;

  Parent({
    this.itsId,
    this.name,
    this.qualification,
    this.occupation,
    this.organisation,
    this.idara,
    this.sabaq,
    this.image,
    this.officeAddress,
    this.officePhone,
    this.annualIncome,
    this.mobile,
    this.email,
    this.imaniInstitute,
    this.previousInstitute,
    this.previousClass,
    this.profileCompleted,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      itsId: json['Father ITS ID'] ?? json['Mother ITS ID'],
      name: json['Father Name'] ?? json['Mother Name'],
      qualification: json['Qualification'] ?? '',
      occupation: json['Occupation'] ?? '',
      organisation: json['Organisation'] ?? '',
      idara: json['Idara'] ?? '',
      sabaq: json['Sabaq'] ?? '',
      image: json['Image'] ?? '',
      officeAddress: json['Office Address'] ?? '',
      officePhone: json['Office Phone'] ?? '',
      annualIncome: json['Annual Income'] ?? '',
      mobile: json['Mobile'] ?? '',
      email: json['Email'] ?? '',
      imaniInstitute: json['Imani Institute'] ?? '',
      previousInstitute: json['Previous Institute'] ?? '',
      previousClass: json['Previous Class'] ?? '',
      profileCompleted: json['Profile Completed'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ITS ID': itsId,
      'Name': name,
      'Qualification': qualification,
      'Occupation': occupation,
      'Organisation': organisation,
      'Idara': idara,
      'Sabaq': sabaq,
      'Image': image,
      'Office Address': officeAddress,
      'Office Phone': officePhone,
      'Annual Income': annualIncome,
      'Mobile': mobile,
      'Email': email,
      'Imani Institute': imaniInstitute,
      'Previous Institute': previousInstitute,
      'Previous Class': previousClass,
      'Profile Completed': profileCompleted,
    };
  }
}