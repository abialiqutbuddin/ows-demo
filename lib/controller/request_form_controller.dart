import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ows/constants/dummy_data.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import '../api/api.dart';
import '../mobile_ui/request_form_screen.dart';
import '../model/institutes_model.dart';
import '../model/member_model.dart';
import '../web_ui/request_form.dart';

class RequestFormController extends GetxController {

  RxString selectedEducationType = "".obs;
  Rxn<int> selectedMarhala = Rxn<int>();
  RxString selectedCategory = "".obs;
  RxString selectedDeeniType = "".obs;
  RxString purpose = "".obs;
  RxString grade = "".obs;
  RxString cnicNo = "".obs;

  RxBool isSubmitEnabled = false.obs;

  RxString organization = ''.obs;

  RxBool isMarhalaSelected = false.obs;
  RxBool isDunyawiSelected = false.obs;
  RxBool isStandardBetween1_3 = false.obs;
  RxBool isStandardBetween4_5 = false.obs;
  RxBool isStandardBetween6_7 = false.obs;
  RxBool isDeeniiSelected = false.obs;
  RxBool isMadrasaSelected = false.obs;
  RxBool isHifzSelected = false.obs;

  // RxBool isStandardSelected = false.obs;
  // RxBool isCitySelected = false.obs;
  // RxBool isInstituteSelected = false.obs;
  // RxBool isYearSelected = false.obs;
  // RxBool isFundsSelected = false.obs;
  // RxBool isDescriptionSelected = false.obs;


  // Convert to Rxn<int> for dropdown selections
  Rxn<int> standardIndex = Rxn<int>(null);
  Rxn<int> fieldOfStudyIndex = Rxn<int>(null);
  Rxn<int> courseIndexPoint = Rxn<int>(null);
  Rxn<int> degreeProgramIndex = Rxn<int>(null);
  Rxn<int> marhala4Index = Rxn<int>(null);
  Rxn<int> marhala5Index = Rxn<int>(null);
  Rxn<int> madrasaIndex = Rxn<int>(null);
  Rxn<int> hifzProgramIndex = Rxn<int>(null);
  Rxn<int> darajaIndex = Rxn<int>(null);

  RxList<Map<String, dynamic>> degreePrograms = [
    {"id": 1, "name": "Associated Degree Programs"},
    {"id": 2, "name": "Bachelors Degree Programs"},
    {"id": 3, "name": "Professional Programs"},
    {"id": 4, "name": "Diploma / Vocational Training"},
  ].obs;
  RxList<Map<String, dynamic>> marhala4Class = [
    {"id": 1, "name": "9th Grade"},
    {"id": 2, "name": "10th Grade"},
    {"id": 3, "name": "Not Applicable"},
  ].obs;

  RxList<Map<String, dynamic>> marhala5Class = [
    {"id": 1, "name": "11th Grade"},
    {"id": 2, "name": "12th Grade"},
    {"id": 3, "name": "Not Applicable"},
  ].obs;

  RxList<Map<String, dynamic>> madrasas = [
    {"id": 1, "name": "Madrasa Hamidiyah"},
    {"id": 2, "name": "Madrasa Taheriyah (Sadar)"},
    {"id": 3, "name": "Zaini Madrasa"},
    {"id": 4, "name": "Hakimi Madrasa (Mahalat Mohammediyah)"},
    {"id": 5, "name": "Madrasa Ezziyah (Burhani Mohalla)"},
    {"id": 6, "name": "Madrasa Burhaniyah (Essa Mohallah)"},
    {"id": 7, "name": "Najmi Madrasa"},
    {"id": 8, "name": "Madrasa Tayyebiyah (Hasani Mohallah)"},
    {"id": 9, "name": "Madrasa Najmiyah (Husaini Mohallah)"},
    {"id": 10, "name": "Madrasa Jamaliyah (Ibrahim Mohallah)"},
    {"id": 11, "name": "Madrasa (UP More MahalatBurhaniyah)"},
    {"id": 12, "name": "Madrasa Taheriyah (Mohammadi Mohallah)"},
    {"id": 13, "name": "Madrasa Hakimiyah (Qutbi Mohallah)"},
    {"id": 14, "name": "Madrasa Saifiyah (Saifee Mohallah)"},
    {"id": 15, "name": "Madrasa Wajihiyah"},
    {"id": 16, "name": "Madrasa Badriyah (MahalatBurhaniyah)"},
    {"id": 17, "name": "Madrasa Fakhriyah (Saleh Mohallah)"},
    {"id": 18, "name": "Madrasa Husamiyah (Taheri Mohallah)"},
    {"id": 19, "name": "Madrasa Mohammediyah (Adam Mohallah)"},
    {"id": 20, "name": "Madrasa QuaidJohar (Yusufi Mohallah)"},
    {"id": 21, "name": "Madrasa Qutbiyah (MahalatBurhaniyah)"},
    {"id": 22, "name": "Husami Madrasa"},
    {"id": 23, "name": "Madrasa Fatemiyah"},
  ].obs;

  RxList<Map<String, dynamic>> hifzPrograms = [
    {"id": 1, "name": "Tahfeez al-Kibar - Mohallah"},
    {"id": 2, "name": "Tahfeez al-Atfal - Mohallah"},
    {"id": 3, "name": "Barnamaj al-Taiseer - Mohallah"},
    {"id": 4, "name": "Tahfeez al-Mujtahedin - School [Mukhayyam]"},
    {"id": 5, "name": "Tahfeez al-Atfal - Imani School"},
    {"id": 6, "name": "Tahfeez E-Learning Quran"},
  ].obs;

  RxList<Map<String, dynamic>> madrasaDarajat = [
    {"id": 0, "name": "ATFAAL", "marhala_id": 1},
    {"id": 1, "name": "Daraja 1", "marhala_id": 2},
    {"id": 2, "name": "Daraja 2", "marhala_id": 2},
    {"id": 3, "name": "Daraja 3", "marhala_id": 2},
    {"id": 4, "name": "Daraja 4", "marhala_id": 2},
    {"id": 5, "name": "Daraja 5", "marhala_id": 3},
    {"id": 6, "name": "Daraja 6", "marhala_id": 3},
    {"id": 7, "name": "Daraja 7", "marhala_id": 3},
    {"id": 8, "name": "Daraja 8", "marhala_id": 3},
    {"id": 9, "name": "Daraja 9", "marhala_id": 4},
    {"id": 10, "name": "Daraja 10", "marhala_id": 4},
  ].obs;

  RxList<Map<String, dynamic>> filteredDarajat = <Map<String, dynamic>>[].obs;

  // Form Fields (Strings)
  RxString standard = "".obs;
  RxString fieldOfStudy = "".obs;
  RxString className = "".obs;
  RxString subject = "".obs;
  //RxString degreeProgram = "".obs;
  RxString course = "".obs;
  RxString madrasaName = "".obs;
  RxString darajaName = "".obs;
  RxString hifzProgress = "".obs;
  RxString hifzProgramName = "".obs;

  void resetFields(){
    madrasaName.value = "";
    darajaName.value = "";
    hifzProgress.value = "";
    hifzProgramName.value = "";
    grade.value = "";
    //purpose.value = "";
    fieldOfStudyIndex.value = null;
    courseIndexPoint.value = null;
    degreeProgramIndex.value = null;
    standardIndex.value = null;
    marhala4Index.value = null;
    marhala5Index.value = null;
    darajaIndex.value = null;
    hifzProgramIndex.value = null;
    filteredDarajat.clear();
    madrasaIndex.value = null;
    studyOptions.clear();
    filteredStudies.clear();
    courseOptions.clear();
    selectedInstitute.value=null;
    selectedCity.value='Select City';
    selectedInstituteName.value='';
    year.value='';
    selectedCityId.value=null;
    standardIndex.value = null;
    selectedCategory.value = '';
    fieldOfStudyIndex.value = null;
    courseIndexPoint.value = null;
    degreeProgramIndex.value = null;
    marhala4Index.value = null;
    marhala5Index.value = null;
    darajaIndex.value = null;
    hifzProgramIndex.value = null;
    madrasaIndex.value = null;
    funds.value='';
    description.value='';
  }

  RxList<Map<String, dynamic>> studyOptions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> courseOptions = <Map<String, dynamic>>[].obs;

  void filterDarajaByMarhala(int marhalaId) {
    filteredDarajat.value =
        madrasaDarajat.where((e) => e["marhala_id"] == marhalaId).toList();
  }

  // **State Management**
  RxBool isLoading = true.obs;
  RxBool isButtonEnabled = true.obs;

  final double defSpacing = 8;

  RxInt reqId = 0.obs;
  String? appliedByName;
  String? appliedbyIts;
  final String reqNum = "Request #: ows-req-000";

  RxList<Institute> institutes = <Institute>[].obs;
  RxList<Map<String, dynamic>> cities = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredInstitutes =
      <Map<String, dynamic>>[].obs;

  // **Dropdown Selections**
  RxString selectedCity = "Select City".obs;
  RxString selectedSubject = "Select Subject".obs;
  RxString selectedMarhalaName = "".obs;
  RxString selectedStudyName = "".obs;
  RxString selectedFieldOfStudy = "".obs;
  RxString selectedSubject2 = "".obs;
  Rxn<String> selectedInstituteName = Rxn<String>();
  var allData = [].obs;

  // Define Marhalas
  final List<Map<String, dynamic>> predefinedMarhalas = [
    {'id': 1, 'marhala': 'Marhala 1','name': 'Pre Primary'},
    {'id': 2, 'marhala': 'Marhala 2 ','name': '1st - 4th'},
    {'id': 3, 'marhala': 'Marhala 3 ','name': '5th - 8th'},
    {'id': 4, 'marhala': 'Marhala 4 ','name': '9th - 10th'},
    {'id': 5, 'marhala': 'Marhala 5 ','name': '11th - 12th'},
    {'id': 6, 'marhala': 'Marhala 6 ','name': 'Undergraduate'},
    {'id': 7, 'marhala': 'Marhala 7 ','name': 'Postgraduate'},
  ];


  void resetSelections() {
  }


  var isDeeniSelected = false.obs;
  var filteredStudies = <Map<String, dynamic>>[].obs;
  var filteredFields = <Map<String, dynamic>>[].obs;

  //var selectedMarhala = Rxn<int>();
  var selectedStudy = Rxn<int>();
  var selectedField = Rxn<int>();
  var selectedCityId = Rxn<int>();
  var selectedInstitute = Rxn<int>();

  RxBool isStudyEnabled = false.obs;
  //RxBool isFieldEnabled = false.obs;

  void updateDropdownState() {
    update();
  }

  Future<void> loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = json.decode(response);
    allData.assignAll(data);

    //reqId.value = await Api.fetchNextReqMasId();
    // Set default university list
  }

  void updateFilteredInstitutes() {
    if (selectedCity.value == "Select City") {
      filteredInstitutes.clear();
      selectedInstitute.value = null;
      selectedInstituteName.value = null;
    } else {
      filteredInstitutes.value = institutes
          .where((u) => u.cityName == selectedCity.value)
          .map((u) => {"id": u.id, "name": u.name})
          .toList();

      if (!filteredInstitutes.any((i) => i['id'] == selectedInstitute.value)) {
        selectedInstitute.value = null;
        selectedInstituteName.value = null;
      }
    }
    update();
  }

  void selectCity(int? cityId) {
    if (cityId == null || cityId == -1) {
      selectedCity.value = "Select City";
      filteredInstitutes.clear();
      //selectInstitute(-1);
    } else {
      selectedCity.value = cities.firstWhere((c) => c['id'] == cityId)['name'];
      selectedCityId.value = cities.firstWhere((c) => c['id'] == cityId)['id'];
      updateFilteredInstitutes();
    }
  }

  void selectInstitute(int? instituteId) {
    selectedInstitute.value = instituteId;
    if (instituteId != null) {
      var selected = filteredInstitutes.firstWhere(
        (inst) => inst['id'] == instituteId,
        orElse: () => {"id": -1, "name": ""},
      );
      selectedInstituteName.value = selected['name'];
    } else {
      selectedInstituteName.value = "";
    }
    update();
  }



  void filterStudies(int marhalaId) {
    if(marhalaId>3) {
      studyOptions.assignAll(
      _extractUniqueValues(
        allData.where((item) => item['marhala_id'] == marhalaId).toList(),
        'study_id',
        (item) => {'id': item['study_id'], 'name': item['study']},
      ),
    );
    }
    //selectedStudy.value = null;
    //filteredFields.clear();
    //selectedField.value = null;
    //updateDropdownState();
  }

  void filterFields(int studyId) {
    filteredFields.assignAll(
      _extractUniqueValues(
        allData.where((item) => item['study_id'] == studyId).toList(),
        'id',
        (item) => {'id': item['id'], 'name': item['name']},
      ),
    );
    selectedField.value = null;
    update(); // ✅ Ensure UI updates
  }

  List<Map<String, dynamic>> _extractUniqueValues(List<dynamic> data,
      String key, Map<String, dynamic> Function(dynamic) mapFunction) {
    final seenKeys = <dynamic>{};
    return data
        .where((item) =>
            item[key] != null && seenKeys.add(item[key])) // Ignore nulls
        .map(mapFunction)
        .toList();
  }

  // **Reactive Input Fields**
  RxString classDegree = ''.obs;
  RxString institution = ''.obs;
  RxString study = ''.obs;
  RxString year = '2025'.obs;
  RxString email = ''.obs;
  RxString phone = ''.obs;
  RxString whatsapp = ''.obs;
  RxString funds = ''.obs;
  RxString description = ''.obs;

  // Function to Validate Form Based on Selections
  void validateForm() {
    List<String> requiredFields = ["purpose","marhala"];
    List<String> missingFields = []; // To store missing required fields

    if (marhala4Index.value != null) {
      classDegree.value = marhala4Class.firstWhere((e) =>
      e["id"] == marhala4Index.value)["name"];
    } else if (marhala5Index.value != null) {
      classDegree.value = marhala5Class.firstWhere((e) =>
      e["id"] == marhala5Index.value)["name"];
    } else if (degreeProgramIndex.value != null) {
      classDegree.value = degreePrograms.firstWhere((e) =>
      e["id"] == degreeProgramIndex.value)["name"];
    }

    if (fieldOfStudyIndex.value != null) {
      fieldOfStudy.value = studyOptions.firstWhere((e) =>
      e["id"] == fieldOfStudyIndex.value)["name"];

    }

    if (courseIndexPoint.value != null) {
      subject.value = courseOptions.firstWhere((e) =>
      e["id"] == courseIndexPoint.value)["name"];
    }

    // 🔹 **Dynamically determine subjectCourse**
    // if (courseIndexPoint.value != null) {
    //   subjectCourse = courseOptions.firstWhere((e) =>
    //   e["id"] == courseIndexPoint.value)["name"];
    // }

    print(subject);
    print(fieldOfStudy);
    print(classDegree);
    print("1 $isDeeniSelected");
    print(isDeeniiSelected);

    if (isMarhalaSelected.value && isDunyawiSelected.value) {
      if (isStandardBetween1_3.value) {
        requiredFields = ["purpose","marhala","standard", "city", "institute", "year", "funds", "description"];
      } else if (isStandardBetween4_5.value) {
        requiredFields = ["classDegree","purpose","marhala","fieldOfStudy", "subject", "city", "institute", "year", "funds", "description"];
      } else if (isStandardBetween6_7.value) {
        requiredFields = ["purpose","marhala","classDegree", "fieldOfStudy", "subject", "city", "institute", "year", "funds", "description"];
      }
    } else if (isMarhalaSelected.value && isDeeniiSelected.value) {
      if (isMadrasaSelected.value) {
        requiredFields = ["purpose","marhala","madrasaName", "darajaName", "year", "funds", "description"];
      } else if (isHifzSelected.value) {
        requiredFields = ["purpose","marhala","hifzProgramName", "year", "funds", "description"];
      }
    }

    // Check required fields and store missing ones
    for (var field in requiredFields) {
      if (getFieldValue(field).isEmpty) {
        missingFields.add(field);
      }
    }

    // Debugging Output
    print("🔹 Required Fields: $requiredFields");
    print("✅ Filled Fields: ${requiredFields.where((field) => getFieldValue(field).isNotEmpty).toList()}");
    print("❌ Missing Fields: $missingFields");

    isSubmitEnabled.value = missingFields.isEmpty;
  }

  RxString degreeProgram = ''.obs;

  // Get Field Value Dynamically
  String getFieldValue(String fieldName) {
    switch (fieldName) {
      case "classDegree":
        return classDegree.value;
      case "marhala":
        return (selectedMarhala.value != null && selectedMarhala.value! > 0)
            ? selectedMarhala.value.toString()
            : '';
        case "purpose":
        return purpose.value;
      case "standard":
        return grade.value;
      case "city":
        return selectedCity.value;
      case "institute":
        return selectedInstituteName.value.toString();
      case "year":
        return year.value;
      case "funds":
        return funds.value;
      case "description":
        return description.value;
      case "fieldOfStudy":
        return fieldOfStudy.value;
      case "className":
        return classDegree.value;
      case "subject":
        return subject.value;
      case "degreeProgram":
        return degreeProgram.value;
      case "course":
        return course.value;
      case "madrasaName":
        return madrasaName.value;
      case "darajaName":
        return darajaName.value;
      case "hifzProgramName":
        return hifzProgramName.value;
      default:
        return "";
    }
  }

  // Function to Reset Other Options When Selecting a New One in a Group
  // void selectOption(RxBool selectedOption, List<RxBool> groupOptions) {
  //   for (var option in groupOptions) {
  //     if (option != selectedOption) {
  //       option.value = false;
  //     }
  //   }
  //   selectedOption.value = true;
  //   validateForm(); // Revalidate after selection
  // }

  @override
  Future<void> onInit() async {
    super.onInit();
    //final GlobalStateController stateController = Get.put(GlobalStateController());
    //print(stateController.user.value);
    //stateController.user.value = GetStorage().read("saved_user");

    everAll([
      isMarhalaSelected,
      isDunyawiSelected,
      isStandardBetween1_3,
      isStandardBetween4_5,
      isStandardBetween6_7,
      isDeeniiSelected,
      isMadrasaSelected,
      isHifzSelected,
      standard,
      selectedCity,
      institution,
      year,
      funds,
      description,
      fieldOfStudy,
      classDegree,
      className,
      subject,
      degreeProgram,
      course,
      madrasaName,
      darajaName,
      hifzProgramName,
      purpose,
      grade
    ], (_) => validateForm());


    loadData();
    loadInstitute();

  }

  Future<void> loadInstitute() async {
    final String response =
        await rootBundle.loadString('assets/institutes.json');
    final List<dynamic> data = json.decode(response);
    institutes.value = data.map((json) => Institute.fromJson(json)).toList();

    // Extract unique cities
    Set<String> uniqueCities = institutes.map((u) => u.cityName).toSet();
    cities.value = [
      {"id": -1, "name": "Select City"},
      ...uniqueCities
          .map((city) => {"id": city.hashCode, "name": city})
    ];
  }

  // void validateForm() {
  //   bool isValid =
  //       //selectedInstitute.value != null &&
  //       selectedCity.value != 'Select City' &&
  //       selectedMarhala.value != null &&
  //       selectedStudy.value != null &&
  //       selectedField.value != null &&
  //       year.value.isNotEmpty &&
  //       _validateYear(year.value) == null && // ✅ Validate year
  //       email.value.isNotEmpty &&
  //       _validateEmail(email.value) == null && // ✅ Validate email
  //       phone.value.isNotEmpty &&
  //       _validatePhoneNumber(phone.value) == null && // ✅ Validate phone
  //       whatsapp.value.isNotEmpty &&
  //       _validatePhoneNumber(whatsapp.value) == null && // ✅ Validate WhatsApp
  //       funds.value.isNotEmpty &&
  //       _validateFunds(funds.value) == null && // ✅ Validate funds
  //       description.value.isNotEmpty;
  // }

  // Define validation logic here
  String? validateField(String label, String? value) {
    if (value == null || value.isEmpty) {
      return "$label is required";
    }

    switch (label.toLowerCase()) {
      case "year":
        return _validateYear(value);
      case "cnic no.":
        return _validateCNIC(value);
      case "class / degree program":
        return _validateDegree(value);
      case "institution":
        return _validateInstitution(value);
      case "email":
        return _validateEmail(value);
      case "phone number":
      case "whatsapp number":
        return _validatePhoneNumber(value);
      case "funds":
        return _validateFunds(value);
      default:
        return null;
    }
  }

  String? _validateDegree(String? value) {
    if (value == null || value.isEmpty) {
      return "Degree is required";
    }

    // Regular expression to allow only alphabets and spaces
    final regex = RegExp(r'^[a-zA-Z0-9\s\-/.]+$');

    if (!regex.hasMatch(value)) {
      return "Degree can only contain alphabets and spaces";
    }

    // Check for minimum length
    if (value.length < 2) {
      return "Degree must be at least 2 characters long";
    }

    // Check for maximum length
    if (value.length > 100) {
      return "Degree cannot exceed 100 characters";
    }

    // Check for leading or trailing spaces
    if (value.trim() != value) {
      return "Degree cannot start or end with spaces";
    }

    return null;
  }

  String? _validateInstitution(String? value) {
    if (value == null || value.isEmpty) {
      return "Institution name is required";
    }

    // Regular expression to allow only alphabets and spaces
    final regex = RegExp(r'^[a-zA-Z\s]+$');

    if (!regex.hasMatch(value)) {
      return "Please enter valid Institution";
    }

    // Check for minimum length
    if (value.length < 2) {
      return "Institution name must be at least 2 characters long";
    }

    // Check for maximum length
    if (value.length > 150) {
      return "Institution name cannot exceed 150 characters";
    }

    // Check for leading or trailing spaces
    if (value.trim() != value) {
      return "Institution name cannot start or end with spaces";
    }

    return null;
  }

  String? _validateYear(String value) {
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return "Enter a valid year (e.g., 2023)";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email address is required";
    }

    // Regular expression for validating email addresses
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address";
    }

    // Check if email starts or ends with invalid characters
    if (value.startsWith('.') ||
        value.startsWith('-') ||
        value.startsWith('_')) {
      return "Email cannot start with a special character";
    }

    if (value.endsWith('.') || value.endsWith('-') || value.endsWith('_')) {
      return "Email cannot end with a special character";
    }

    // Check for consecutive dots
    if (value.contains('..')) {
      return "Email cannot contain consecutive dots";
    }

    return null;
  }

  String? _validatePhoneNumber(String value) {
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
      return "Enter a valid phone number (10-15 digits)";
    }
    return null;
  }

  String? _validateCNIC(String value) {
    if (!RegExp(r'^\d{13}$').hasMatch(value)) {
      return "CNIC must be 13 digits";
    }
    return null;
  }

  String? _validateFunds(String? value) {
    if (value == null || value.isEmpty) {
      return "Funds amount is required";
    }

    // Regular expression to check for numeric input
    final numericRegex = RegExp(r'^\d+$');

    if (!numericRegex.hasMatch(value)) {
      return "Enter a valid numeric amount for funds";
    }

    // Convert to a number for further checks
    final amount = int.tryParse(value);

    if (amount == null) {
      return "Enter a valid numeric amount for funds";
    }

    // Check for non-negative values
    if (amount < 0) {
      return "Funds amount cannot be negative";
    }

    if (amount < 1000) {
      return "Funds amount must be greater than 1000";
    }

    // Check for excessively large amounts
    if (amount > 100000000) {
      return "Funds amount cannot exceed 1,000,000,00";
    }

    // Check for leading zeros
    if (value.length > 1 && value.startsWith('0')) {
      return "Funds amount cannot have leading zeros";
    }

    return null;
  }

  String? validateDropdown(String label, Rxn<int> selectedValue) {
    if (selectedValue.value == null) {
      return "* $label is required";
    }
    if (selectedValue.value == -1){
      return "* $label is required";
    }
    return null;
  }

  int calculateAge(String dobString) {
    // Parse the string into a DateTime object
    final dob = DateTime.parse(dobString);
    final today = DateTime.now();
    int age = today.year - dob.year;
    // Adjust age if the current date is before the birthday this year
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  // **Fetch Next Request ID**
  Future<void> fetchReqId() async {
    reqId.value = await Api.fetchNextReqMasId();
  }
}

class RequestForm extends StatefulWidget {

  const RequestForm({
    super.key,
  });

  @override
  RequestFormState createState() => RequestFormState();
}

class RequestFormState extends State<RequestForm> {
  final RequestFormController controller = Get.find<RequestFormController>();
  final GlobalStateController stateController = Get.find<GlobalStateController>();

  @override
  void initState() {

    stateController.user.value = userProfile11;

    fetchDefaultValues(stateController.user.value);
    super.initState();
  }

  void fetchDefaultValues(UserProfile member) {
    controller.email.value = member.email ?? '';
    controller.phone.value = member.mobileNo ?? '';
    controller.whatsapp.value = member.whatsappNo ?? '';

    if (member.future != null && member.future!.isNotEmpty) {
      controller.classDegree.value = member.future!.first.subject ?? ''; // ✅ Use RxString
      controller.institution.value = member.future!.first.institute ?? '';

      controller.selectedSubject.value = member.future!.first.study ?? '';

      // Check if `selectedCity.value` already has a value
      String? currentCity = controller.selectedCity.value.isNotEmpty && controller.selectedCity.value != 'Select City'
          ? controller.selectedCity.value
          : member.future!.first.city;

      // Find matching city ID
      int cityId = controller.cities.firstWhere(
            (city) => city['name'] == currentCity,
        orElse: () => {"id": -1}, // Default to -1 if not found
      )['id'];

      if (controller.selectedCity.value != (cityId == -1 ? "Select City" : currentCity!)) {
        controller.selectCity(cityId); // ✅
      }
      controller.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define the breakpoint for mobile
    const double mobileBreakpoint = 600;

    return screenWidth <= mobileBreakpoint
        ? RequestFormM()
        : RequestFormW();
  }
}
