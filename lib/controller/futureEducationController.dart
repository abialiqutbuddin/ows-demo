import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FutureEducationController extends GetxController {
  // Form Fields
  RxString isHifzNiyat = ''.obs;
  RxString niyatHifzEnrolled = ''.obs;
  RxString isTilawatNiyat = ''.obs;
  RxString tilawatPreferredDays = ''.obs;
  RxString tilawatPreferredTimings = ''.obs;
  RxString willAsbaaq = ''.obs;
  RxString willKhidmat = ''.obs;
  RxString khidmat = ''.obs;
  RxString comments = ''.obs;

  // Study Details
  RxString studyLocation = ''.obs;
  RxString cityId = ''.obs;
  RxString institute = ''.obs;
  RxString course = ''.obs;
  RxString countryId = ''.obs;
  RxString relativeAbroad = ''.obs;
  RxString relationship = ''.obs;
  RxString relationshipIts = ''.obs;
  RxString stayTogether = ''.obs;
  RxInt selectedCityId = 0.obs;
  RxInt selectedCountryId = 0.obs;
  RxInt selectedInstituteId = 0.obs;

  var cities = <Map<String, dynamic>>[].obs;
  var filteredInstitutes = <Map<String, dynamic>>[].obs;
  var allInstitutes = <Map<String, dynamic>>[];

  final Rxn<Map<String, dynamic>> selectedCity = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> selectedInstitute = Rxn<Map<String, dynamic>>();

  var courseList = <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> selectedCourse = Rxn<Map<String, dynamic>>();

  Future<void> loadCoursesJson() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data.json');
      final List<dynamic> decoded = json.decode(jsonString);
      courseList.value = decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print("Error loading course list: $e");
    }
  }


  /// ✅ Method 1: Load city + country list from JSON
  Future<void> loadCityAndCountryJson() async {
    try {
      final String cityJson = await rootBundle.loadString('assets/country_city.json');
      final List<dynamic> decoded = json.decode(cityJson);
      cities.value = decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print("Error loading city_country.json: $e");
    }
  }



  /// ✅ Load all institutes from JSON (once)
  Future<void> loadInstitutesJson() async {
    try {
      final String instJson = await rootBundle.loadString('assets/institutes.json');
      final List<dynamic> decoded = json.decode(instJson);
      allInstitutes = decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print("Error loading institutes.json: $e");
    }
  }

  /// ✅ Filter institutes by city ID (after both lists are loaded)
  void filterInstitutesByCity(int cityId) {
    selectedCityId.value = cityId;

    // Filter institutes
    filteredInstitutes.value =
        allInstitutes.where((inst) => inst['city_id'] == cityId).toList();

    // Set country ID
    final city = cities.firstWhereOrNull((c) => c['city_id'] == cityId);
    selectedCountryId.value = city?['country_id'] ?? 0;
  }

  void setSelectedInstitute(int id) {
    selectedInstituteId.value = id;
  }

  void reset() {
    isHifzNiyat.value = '';
    niyatHifzEnrolled.value = '';
    isTilawatNiyat.value = '';
    tilawatPreferredDays.value = '';
    tilawatPreferredTimings.value = '';
    willAsbaaq.value = '';
    willKhidmat.value = '';
    khidmat.value = '';
    comments.value = '';

    studyLocation.value = '';
    cityId.value = '';
    institute.value = '';
    course.value = '';
    countryId.value = '';
    relativeAbroad.value = '';
    relationship.value = '';
    relationshipIts.value = '';
    stayTogether.value = '';
  }

  String? validateField(String label, String value) {
    if (value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }


}