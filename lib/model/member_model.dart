class UserProfile {
  int? id;
  int? itsId;
  int? hofId;
  int? motherIts;
  int? fatherIts;
  int? spouseIts;
  int? sfNo;
  int? jamaatId;
  String? fullName;
  String? firstName;
  String? suffix;
  String? fatherName;
  String? fatherSuffix;
  String? fatherSurname;
  String? motherName;
  String? surname;
  String? dob;
  String? gender;
  String? vatan;
  String? martialStatus;
  String? qualification;
  String? jamiaat;
  String? idara;
  String? organization;
  String? email;
  String? mobileNo;
  String? whatsappNo;
  String? tanzeem;
  int? age;
  String? hifzSanad;
  String? misaq;
  int? status;
  int? completed;
  String? hometown;
  String? address;
  String? currentCity;
  String? nationality;
  String? website;
  String? profession;
  String? imageUrl;
  String? itsStatus;
  int? marhalaOngoing;
  int? ambitionId;
  int? currentMarhala;
  String? currentClass;
  int? currentComplete;
  int? previousComplete;
  int? progress;
  int? isApproved;
  String? approvedOn;
  int? approvedBy;
  int? isDelete;
  List<FuturePlan>? future;
  List<Education>? education;

  UserProfile({
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
    this.future,
    this.education,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      itsId: json['its_id'] ?? 0,
      hofId: json['hof_id'] ?? 0,
      motherIts: json['mother_its'] ?? 0,
      fatherIts: json['father_its'] ?? 0,
      spouseIts: (json['spouse_its'] is int) ? json['spouse_its'] : int.tryParse(json['spouse_its'].toString()) ?? 0,
      sfNo: json['sf_no'] ?? 0,
      jamaatId: json['jamaat_id'] ?? 0,
      fullName: json['full_name'] ?? "-",
      firstName: json['first_name'] ?? "-",
      suffix: json['suffix'] ?? "-",
      fatherName: json['father_name'] ?? "-",
      fatherSuffix: json['father_suffix'] ?? "-",
      fatherSurname: json['father_surname'] ?? "-",
      motherName: json['mother_name'] ?? "-",
      surname: json['surname'] ?? "-",
      dob: json['dob'] ?? "-",
      gender: json['gender'] ?? "-",
      vatan: json['vatan'] ?? "-",
      martialStatus: json['martial_status'] ?? "-",
      qualification: json['qualification'] ?? "-",
      jamiaat: json['jamiaat'] ?? "-",
      idara: json['idara'] ?? "-",
      organization: json['organization'] ?? "-",
      email: json['email'] ?? "-",
      mobileNo: json['mobile_no'] ?? "-",
      whatsappNo: json['whatsapp_no'] ?? "-",
      tanzeem: json['tanzeem'] ?? "-",
      age: json['age'] ?? 0,
      hifzSanad: json['hifz_sanad'] ?? "-",
      misaq: json['misaq'] ?? "-",
      status: json['status'] ?? 0,
      completed: json['completed'] ?? 0,
      hometown: json['hometown'] ?? "-",
      address: json['address'] ?? "-",
      currentCity: json['current_city'] ?? "-",
      nationality: json['nationality'] ?? "-",
      website: json['website'] ?? "-",
      profession: json['profession'] ?? "-",
      imageUrl: json['image_url'] ?? "-",
      itsStatus: json['its_status'] ?? "-",
      marhalaOngoing: json['marhala_ongoing'] ?? 0,
      ambitionId: json['ambition_id'] ?? 0,
      currentMarhala: json['current_marhala'] ?? 0,
      currentClass: json['current_class'] ?? "-",
      currentComplete: json['current_complete'] ?? 0,
      previousComplete: json['previous_complete'] ?? 0,
      progress: json['progress'] ?? 0,
      isApproved: json['is_approved'] ?? 0,
      approvedOn: json['approved_on'] ?? "-",
      approvedBy: json['approved_by'] ?? 0,
      isDelete: json['is_delete'] ?? 0,
      future: (json['future'] as List<dynamic>?)?.map((item) => FuturePlan.fromJson(item)).toList() ?? [],
      education: (json['education'] as List<dynamic>?)
          ?.map((item) => Education.fromJson(item))
          .toList()
          .where((edu) => edu.marhalaId != null) // Ensure marhalaId is not null
          .toList()
          .cast<Education>()
        ?..sort((a, b) => (b.marhalaId ?? 0).compareTo(a.marhalaId ?? 0)), // Sort in descending order
        );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'its_id': itsId ?? 0,
      'hof_id': hofId ?? 0,
      'mother_its': motherIts ?? 0,
      'father_its': fatherIts ?? 0,
      'spouse_its': spouseIts ?? 0,
      'sf_no': sfNo ?? 0,
      'jamaat_id': jamaatId ?? 0,
      'full_name': fullName ?? "-",
      'first_name': firstName ?? "-",
      'suffix': suffix ?? "-",
      'father_name': fatherName ?? "-",
      'father_suffix': fatherSuffix ?? "-",
      'father_surname': fatherSurname ?? "-",
      'mother_name': motherName ?? "-",
      'surname': surname ?? "-",
      'dob': dob ?? "-",
      'gender': gender ?? "-",
      'vatan': vatan ?? "-",
      'martial_status': martialStatus ?? "-",
      'qualification': qualification ?? "-",
      'jamiaat': jamiaat ?? "-",
      'idara': idara ?? "-",
      'organization': organization ?? "-",
      'email': email ?? "-",
      'mobile_no': mobileNo ?? "-",
      'whatsapp_no': whatsappNo ?? "-",
      'tanzeem': tanzeem ?? "-",
      'age': age ?? 0,
      'hifz_sanad': hifzSanad ?? "-",
      'misaq': misaq ?? "-",
      'status': status ?? 0,
      'completed': completed ?? 0,
      'hometown': hometown ?? "-",
      'address': address ?? "-",
      'current_city': currentCity ?? "-",
      'nationality': nationality ?? "-",
      'website': website ?? "-",
      'profession': profession ?? "-",
      'image_url': imageUrl ?? "-",
      'its_status': itsStatus ?? "-",
      'marhala_ongoing': marhalaOngoing ?? 0,
      'ambition_id': ambitionId ?? 0,
      'current_marhala': currentMarhala ?? 0,
      'current_class': currentClass ?? "-",
      'current_complete': currentComplete ?? 0,
      'previous_complete': previousComplete ?? 0,
      'progress': progress ?? 0,
      'is_approved': isApproved ?? 0,
      'approved_on': approvedOn ?? "-",
      'approved_by': approvedBy ?? 0,
      'is_delete': isDelete ?? 0,
      'future': future?.map((item) => item.toJson()).toList() ?? [],
      'education': education?.map((item) => item.toJson()).toList() ?? [],
    };
  }
  int? _parseInt(dynamic value) {
    if (value == null || value == "" || value.toString().trim().isEmpty) return null;
    return int.tryParse(value.toString()); // Convert safely
  }
}

class FuturePlan{
  int? isHafiz;
  int? isHifzNiyat;
  String? currentHifzEnrolled;
  String? niyatHifzEnrolled;
  int? nextSanad;
  int? isQuranTilawat;
  String? sehatEraab;
  String? sehatHuroof;
  int? isTilawatNiyat;
  String? tilawatPreferredDays;
  String? tilawatPreferredTimings;
  int? attendedCounselling;
  String? comments;
  int? willAsbaaq;
  int? willKhidmat;
  String? study;
  String? city;
  String? institute;
  String? subject;
  String? country;
  int? isRelative;
  String? relation;
  int? relativeIts;

  FuturePlan({
    this.isHafiz,
    this.isHifzNiyat,
    this.currentHifzEnrolled,
    this.niyatHifzEnrolled,
    this.nextSanad,
    this.isQuranTilawat,
    this.sehatEraab,
    this.sehatHuroof,
    this.isTilawatNiyat,
    this.tilawatPreferredDays,
    this.tilawatPreferredTimings,
    this.attendedCounselling,
    this.comments,
    this.willAsbaaq,
    this.willKhidmat,
    this.study,
    this.city,
    this.institute,
    this.subject,
    this.country,
    this.isRelative,
    this.relation,
    this.relativeIts,
  });

  factory FuturePlan.fromJson(Map<String, dynamic> json) {
    return FuturePlan(
      isHafiz: json['is_hafiz'],
      isHifzNiyat: json['is_hifz_niyat'],
      currentHifzEnrolled: json['current_hifz_enrolled'],
      niyatHifzEnrolled: json['niyat_hifz_enrolled'],
      nextSanad: json['next_sanad'],
      isQuranTilawat: json['is_quran_tilawat'],
      sehatEraab: json['sehat_eraab'],
      sehatHuroof: json['sehat_huroof'],
      isTilawatNiyat: json['is_tilawat_niyat'],
      tilawatPreferredDays: json['tilawat_preferred_days'],
      tilawatPreferredTimings: json['tilawat_preferred_timings'],
      attendedCounselling: json['attended_counselling'],
      comments: json['comments'],
      willAsbaaq: json['will_asbaaq'],
      willKhidmat: json['will_khidmat'],
      study: json['study'],
      city: json['city'],
      institute: json['institute'],
      subject: json['subject'],
      country: json['country'],
      isRelative: json['is_relative'],
      relation: json['relation'],
      relativeIts: json['relative_its'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_hafiz': isHafiz,
      'is_hifz_niyat': isHifzNiyat,
      'current_hifz_enrolled': currentHifzEnrolled,
      'niyat_hifz_enrolled': niyatHifzEnrolled,
      'next_sanad': nextSanad,
      'is_quran_tilawat': isQuranTilawat,
      'sehat_eraab': sehatEraab,
      'sehat_huroof': sehatHuroof,
      'is_tilawat_niyat': isTilawatNiyat,
      'tilawat_preferred_days': tilawatPreferredDays,
      'tilawat_preferred_timings': tilawatPreferredTimings,
      'attended_counselling': attendedCounselling,
      'comments': comments,
      'will_asbaaq': willAsbaaq,
      'will_khidmat': willKhidmat,
      'study': study,
      'city': city,
      'institute': institute,
      'subject': subject,
      'country': country,
      'is_relative': isRelative,
      'relation': relation,
      'relative_its': relativeIts,
    };
  }
}

class Education {
  String? jamaat;
  int? marhalaId;
  String? standard;
  int? standardId;
  String? className;
  String? startDate;
  String? endDate;
  String? country;
  String? city;
  int? imaniOtherSchool;
  String? institute;
  String? subject;
  int? duration;
  int? scholarshipTaken;
  String? scholarship;
  String? qardan;
  String? status;

  Education({
    this.jamaat,
    this.marhalaId,
    this.standard,
    this.standardId,
    this.className,
    this.startDate,
    this.endDate,
    this.country,
    this.city,
    this.imaniOtherSchool,
    this.institute,
    this.subject,
    this.duration,
    this.scholarshipTaken,
    this.scholarship,
    this.qardan,
    this.status,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      jamaat: json['jamaat'],
      marhalaId: json['marhala_id'],
      standard: json['standard'],
      standardId: json['standard_id'],
      className: json['class'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      country: json['country'],
      city: json['city'],
      imaniOtherSchool: json['imani_other_school'],
      institute: json['institute'],
      subject: json['subject'],
      duration: json['duration'],
      scholarshipTaken: json['scholarship_taken'],
      scholarship: json['scholarship'],
      qardan: json['qardan'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jamaat': jamaat,
      'marhala_id': marhalaId,
      'standard': standard,
      'standard_id': standardId,
      'class': className,
      'start_date': startDate,
      'end_date': endDate,
      'country': country,
      'city': city,
      'imani_other_school': imaniOtherSchool,
      'institute': institute,
      'subject': subject,
      'duration': duration,
      'scholarship_taken': scholarshipTaken,
      'scholarship': scholarship,
      'qardan': qardan,
      'status': status,
    };
  }
}