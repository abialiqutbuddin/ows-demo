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
      its: json['its'],
      fullName: json['full_name'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      age: json['age'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      residenceAddress: json['residence_address'],
      residencePhone: json['residence_phone'],
      image: json['image'],
      imaniInstitute: json['imani_institute'],
      previousInstitute: json['previous_institute'],
      previousClass: json['previous_class'],
      profileCompleted: json['profile_completed'],
      // Handle cases where father can be a Map, a List, or null
      father: (json['father'] is Map<String, dynamic>)
          ? Parent.fromJson(json['father'])
          : null,

      // Handle cases where mother can be a Map, a List, or null
      mother: (json['mother'] is Map<String, dynamic>)
          ? Parent.fromJson(json['mother'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'its': its,
      'full_name': fullName,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'age': age,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'residence_address': residenceAddress,
      'residence_phone': residencePhone,
      'image': image,
      'imani_institute': imaniInstitute,
      'previous_institute': previousInstitute,
      'previous_class': previousClass,
      'profile_completed': profileCompleted,
      'father': father?.toJson(),
      'mother': mother?.toJson(),
    };
  }
}

class Parent {
  int? its;
  String? fullName;
  String? gender;
  String? dateOfBirth;
  int? age;
  String? residenceAddress;
  String? residencePhone;
  String? image;
  String? imaniInstitute;
  String? previousInstitute;
  String? previousClass;
  String? profileCompleted;

  Parent({
    this.its,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.residenceAddress,
    this.residencePhone,
    this.image,
    this.imaniInstitute,
    this.previousInstitute,
    this.previousClass,
    this.profileCompleted,
  });

  factory Parent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Parent(); // Return empty object if JSON is null
    }

    return Parent(
      its: json['its_id'], // Convert to int safely
      fullName: json['full_name'] ?? "Unknown", // Default value if missing
      gender: json['gender'] ?? "Not Specified",
      dateOfBirth: json['date_of_birth'] ?? "N/A",
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null, // Convert to int safely
      residenceAddress: json['residence_address'] ?? "Not Available",
      residencePhone: json['residence_phone'] ?? "Not Provided",
      image: json['image_url'] ?? "https://example.com/default-profile.jpg", // Default placeholder image
      imaniInstitute: json['imani_institute'] ?? "N/A",
      previousInstitute: json['previous_institute'] ?? "N/A",
      previousClass: json['previous_class'] ?? "N/A",
      profileCompleted: json['profile_completed'] ?? "NO",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'its': its,
      'full_name': fullName,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'age': age,
      'residence_address': residenceAddress,
      'residence_phone': residencePhone,
      'image': image,
      'imani_institute': imaniInstitute,
      'previous_institute': previousInstitute,
      'previous_class': previousClass,
      'profile_completed': profileCompleted,
    };
  }
}