class FamilyMember {
  final int itsNumber;
  final int hofItsNumber;
  final int sfNo;
  final String fullName;
  final String emailAddress;
  final String mobile;
  final String gender;
  final int age;
  final String profileImage;

  FamilyMember({
    required this.itsNumber,
    required this.hofItsNumber,
    required this.sfNo,
    required this.fullName,
    required this.emailAddress,
    required this.mobile,
    required this.gender,
    required this.age,
    required this.profileImage,
  });

  // Factory constructor to create a FamilyMember from JSON
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      itsNumber: json["its_number"] ?? 0,
      hofItsNumber: json["hof_its_number"] ?? 0,
      sfNo: json["sf_no"] ?? 0,
      fullName: json["full_name"] ?? "",
      emailAddress: json["email_address"] ?? "",
      mobile: json["mobile"] ?? "",
      gender: json["gender"] ?? "",
      age: json["age"] ?? 0,
      profileImage: json["profile_image"] ?? "",
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "its_number": itsNumber,
      "hof_its_number": hofItsNumber,
      "sf_no": sfNo,
      "full_name": fullName,
      "email_address": emailAddress,
      "mobile": mobile,
      "gender": gender,
      "age": age,
      "profile_image": profileImage,
    };
  }
}