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
  final int? id;
  final int? itsId;
  final int? hofId;
  final int? motherIts;
  final int? fatherIts;
  final int? spouseIts;
  final int? sfNo;
  final int? jamaatId;
  final String? fullName;
  final String? firstName;
  final String? suffix;
  final String? fatherName;
  final String? fatherSuffix;
  final String? fatherSurname;
  final String? motherName;
  final String? surname;
  final String? dob;
  final String? gender;
  final String? vatan;
  final String? martialStatus;
  final String? qualification;
  final String? jamiaat;
  final String? idara;
  final String? organization;
  final String? email;
  final String? mobileNo;
  final String? whatsappNo;
  final String? tanzeem;
  final int? age;
  final String? hifzSanad;
  final String? misaq;
  final int? status;
  final int? completed;
  final String? hometown;
  final String? address;
  final String? currentCity;
  final String? nationality;
  final String? website;
  final String? profession;
  final String? imageUrl;
  final String? itsStatus;
  final int? marhalaOngoing;
  final int? ambitionId;
  final int? currentMarhala;
  final String? currentClass;
  final int? currentComplete;
  final int? previousComplete;
  final int? progress;
  final int? isApproved;
  final String? approvedOn;
  final String? approvedBy;
  final int? isDelete;

  Parent({
    this.id,
    this.itsId,
    this.hofId,
    this.motherIts,
    this.fatherIts,
    this.spouseIts,
    this.sfNo,
    this.jamaatId,
    this.fullName,
    this.firstName,
    this.suffix,
    this.fatherName,
    this.fatherSuffix,
    this.fatherSurname,
    this.motherName,
    this.surname,
    this.dob,
    this.gender,
    this.vatan,
    this.martialStatus,
    this.qualification,
    this.jamiaat,
    this.idara,
    this.organization,
    this.email,
    this.mobileNo,
    this.whatsappNo,
    this.tanzeem,
    this.age,
    this.hifzSanad,
    this.misaq,
    this.status,
    this.completed,
    this.hometown,
    this.address,
    this.currentCity,
    this.nationality,
    this.website,
    this.profession,
    this.imageUrl,
    this.itsStatus,
    this.marhalaOngoing,
    this.ambitionId,
    this.currentMarhala,
    this.currentClass,
    this.currentComplete,
    this.previousComplete,
    this.progress,
    this.isApproved,
    this.approvedOn,
    this.approvedBy,
    this.isDelete,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'],
      itsId: json['its_id'],
      hofId: json['hof_id'],
      motherIts: json['mother_its'],
      fatherIts: json['father_its'],
      spouseIts: json['spouse_its'],
      sfNo: json['sf_no'],
      jamaatId: json['jamaat_id'],
      fullName: json['full_name'],
      firstName: json['first_name'],
      suffix: json['suffix'],
      fatherName: json['father_name'],
      fatherSuffix: json['father_suffix'],
      fatherSurname: json['father_surname'],
      motherName: json['mother_name'],
      surname: json['surname'],
      dob: json['dob'],
      gender: json['gender'],
      vatan: json['vatan'],
      martialStatus: json['martial_status'],
      qualification: json['qualification'],
      jamiaat: json['jamiaat'],
      idara: json['idara'],
      organization: json['organization'],
      email: json['email'],
      mobileNo: json['mobile_no'],
      whatsappNo: json['whatsapp_no'],
      tanzeem: json['tanzeem'],
      age: json['age'],
      hifzSanad: json['hifz_sanad'],
      misaq: json['misaq'],
      status: json['status'],
      completed: json['completed'],
      hometown: json['hometown'],
      address: json['address'],
      currentCity: json['current_city'],
      nationality: json['nationality'],
      website: json['website'],
      profession: json['profession'],
      imageUrl: json['image_url'],
      itsStatus: json['its_status'],
      marhalaOngoing: json['marhala_ongoing'],
      ambitionId: json['ambition_id'],
      currentMarhala: json['current_marhala'],
      currentClass: json['current_class'],
      currentComplete: json['current_complete'],
      previousComplete: json['previous_complete'],
      progress: json['progress'],
      isApproved: json['is_approved'],
      approvedOn: json['approved_on'],
      approvedBy: json['approved_by']?.toString(),
      isDelete: json['is_delete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'its_id': itsId,
      'hof_id': hofId,
      'mother_its': motherIts,
      'father_its': fatherIts,
      'spouse_its': spouseIts,
      'sf_no': sfNo,
      'jamaat_id': jamaatId,
      'full_name': fullName,
      'first_name': firstName,
      'suffix': suffix,
      'father_name': fatherName,
      'father_suffix': fatherSuffix,
      'father_surname': fatherSurname,
      'mother_name': motherName,
      'surname': surname,
      'dob': dob,
      'gender': gender,
      'vatan': vatan,
      'martial_status': martialStatus,
      'qualification': qualification,
      'jamiaat': jamiaat,
      'idara': idara,
      'organization': organization,
      'email': email,
      'mobile_no': mobileNo,
      'whatsapp_no': whatsappNo,
      'tanzeem': tanzeem,
      'age': age,
      'hifz_sanad': hifzSanad,
      'misaq': misaq,
      'status': status,
      'completed': completed,
      'hometown': hometown,
      'address': address,
      'current_city': currentCity,
      'nationality': nationality,
      'website': website,
      'profession': profession,
      'image_url': imageUrl,
      'its_status': itsStatus,
      'marhala_ongoing': marhalaOngoing,
      'ambition_id': ambitionId,
      'current_marhala': currentMarhala,
      'current_class': currentClass,
      'current_complete': currentComplete,
      'previous_complete': previousComplete,
      'progress': progress,
      'is_approved': isApproved,
      'approved_on': approvedOn,
      'approved_by': approvedBy,
      'is_delete': isDelete,
    };
  }
}