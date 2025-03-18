import 'dart:convert';

class UpdateProfileRequest {
  final String pId;
  final String itsId;
  final String mId;
  final String jId;
  final String cId;
  final String cityId;
  final String imani;
  final String iId;
  final List<String>? subId;
  final String scholarshipTaken;
  final String? qardan;
  final String? cert;
  final String? scholar;
  final String classId;
  final String sId;
  final String edate;
  final String sdate;
  final String duration;

  UpdateProfileRequest({
    required this.pId,
    required this.itsId,
    required this.mId,
    required this.jId,
    required this.cId,
    required this.cityId,
    required this.imani,
    required this.iId,
    this.subId,
    required this.scholarshipTaken,
    this.qardan,
    this.cert,
    this.scholar,
    required this.classId,
    required this.sId,
    required this.edate,
    required this.sdate,
    required this.duration,
  });

  /// **Validation Function**
  String? validate() {
    if (!_isValidId(pId)) return "Invalid p_id";
    if (!_isValidId(itsId, 8)) return "Invalid its_id (max 8 digits)";
    if (!_isValidId(mId, 1) || !_isInRange(mId, 1, 8)) return "Invalid m_id (must be between 1-8)";
    if (!_isValidId(jId)) return "Invalid j_id";
    if (!_isValidId(cId)) return "Invalid c_id";
    if (!_isValidId(cityId)) return "Invalid city_id";
    if (!_isValidImani(imani)) return "Invalid imani (allowed: 'O' or 'I')";
    if (!_isValidId(iId)) return "Invalid i_id";
    if (subId != null && subId!.any((id) => !_isValidId(id))) return "Invalid sub_id";
    if (!_isBinary(scholarshipTaken)) return "Invalid scholarship_taken (must be 0 or 1)";
    if (qardan != null && qardan!.isEmpty) return "Qardan cannot be empty";
    if (scholar != null && scholar!.isEmpty) return "Scholar cannot be empty";
    if (classId.isEmpty) return "Class ID cannot be empty";
    if (!_isValidId(sId)) return "Invalid s_id";
    if (!_isValidDate(edate)) return "Invalid edate (format: YYYY-MM-DD)";
    if (!_isValidDate(sdate)) return "Invalid sdate (format: YYYY-MM-DD)";
    if (!_isValidDuration(duration)) return "Invalid duration (must be a multiple of 3, between 3-60)";
    return null; // ✅ No validation errors
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    "p_id": pId,
    "its_id": itsId,
    "m_id": mId,
    "j_id": jId,
    "c_id": cId,
    "city_id": cityId,
    "imani": imani,
    "i_id": iId,
    "sub_id": subId,
    "scholarship_taken": scholarshipTaken,
    "qardan": qardan,
    "cert": cert,
    "scholar": scholar,
    "class_id": classId,
    "s_id": sId,
    "edate": edate,
    "sdate": sdate,
    "duration": duration,
  };

  @override
  String toString() => jsonEncode(toJson());

  // 🔹 **Helper Validation Methods**
  bool _isValidId(String value, [int? maxLength]) =>
      RegExp(r'^[0-9]+$').hasMatch(value) &&
          (maxLength == null || value.length <= maxLength);

  bool _isInRange(String value, int min, int max) =>
      int.tryParse(value) != null &&
          int.parse(value) >= min &&
          int.parse(value) <= max;

  bool _isValidImani(String value) => ["O", "I"].contains(value);

  bool _isBinary(String value) => value == "0" || value == "1";

  bool _isValidDate(String value) =>
      RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);

  bool _isValidDuration(String value) =>
      RegExp(r'^[0-9]+$').hasMatch(value) &&
          int.parse(value) >= 3 &&
          int.parse(value) <= 60 &&
          int.parse(value) % 3 == 0;
}