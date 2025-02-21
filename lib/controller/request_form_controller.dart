import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../api/api.dart';
import '../mobile_ui/request_form_screen.dart';
import '../model/institutes_model.dart';
import '../model/member_model.dart';
import '../web_ui/request_form.dart';

class RequestFormController extends GetxController {
  // **State Management**
  RxBool isLoading = true.obs;
  RxBool isButtonEnabled = false.obs;

  final double defSpacing = 8;

  RxInt reqId = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? appliedByName;
  String? appliedbyIts;
  final String reqNum = "Request #: ows-req-000";

  RxList<Institute> institutes = <Institute>[].obs;
  RxList<Map<String, dynamic>> cities = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredInstitutes =
      <Map<String, dynamic>>[].obs;

  // **Form Keys**
  final GlobalKey<FormState> mainFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> fundsFormKey = GlobalKey<FormState>();

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
    {'id': 4, 'name': 'Middle School (9th - 10th)'},
    {'id': 5, 'name': 'Higher Studies (11th - 12th)'},
    {'id': 6, 'name': 'Undergraduate'},
    {'id': 7, 'name': 'Postgraduate'},
  ];

  var filteredStudies = <Map<String, dynamic>>[].obs;
  var filteredFields = <Map<String, dynamic>>[].obs;

  var selectedMarhala = Rxn<int>();
  var selectedStudy = Rxn<int>();
  var selectedField = Rxn<int>();
  var selectedCityId = Rxn<int>();
  var selectedInstitute = Rxn<int>();

  RxBool isStudyEnabled = false.obs;
  RxBool isFieldEnabled = false.obs;

  void updateDropdownState() {
    isStudyEnabled.value =
        selectedMarhala.value != null && filteredStudies.isNotEmpty;
    isFieldEnabled.value =
        selectedStudy.value != null && filteredFields.isNotEmpty;
    update();
  }

  Future<void> loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = json.decode(response);
    allData.assignAll(data);

    reqId.value = await Api.fetchNextReqMasId();
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
    filteredStudies.assignAll(
      _extractUniqueValues(
        allData.where((item) => item['marhala_id'] == marhalaId).toList(),
        'study_id',
        (item) => {'id': item['study_id'], 'name': item['study']},
      ),
    );
    selectedStudy.value = null;
    filteredFields.clear();
    selectedField.value = null;
    updateDropdownState();
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
  RxString year = ''.obs;
  RxString email = ''.obs;
  RxString phone = ''.obs;
  RxString whatsapp = ''.obs;
  RxString funds = ''.obs;
  RxString description = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    loadData();
    loadInstitute();

    // Trigger validation when dropdowns change
    //ever(selectedCity, (_) => validateForm());
    ever(selectedSubject, (_) => validateForm());
    ever(selectedCity, (_) => validateForm());
    ever(selectedInstitute, (_) => validateForm());
    ever(classDegree, (_) => validateForm());
    ever(study, (_) => validateForm());
    ever(year, (_) => validateForm());
    ever(email, (_) => validateForm());
    ever(phone, (_) => validateForm());
    ever(whatsapp, (_) => validateForm());
    ever(funds, (_) => validateForm());
    ever(description, (_) => validateForm());
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

  void validateForm() {
    bool isValid =
        //selectedInstitute.value != null &&
        selectedCity.value != 'Select City' &&
        selectedMarhala.value != null &&
        selectedStudy.value != null &&
        selectedField.value != null &&
        year.value.isNotEmpty &&
        _validateYear(year.value) == null && // ✅ Validate year
        email.value.isNotEmpty &&
        _validateEmail(email.value) == null && // ✅ Validate email
        phone.value.isNotEmpty &&
        _validatePhoneNumber(phone.value) == null && // ✅ Validate phone
        whatsapp.value.isNotEmpty &&
        _validatePhoneNumber(whatsapp.value) == null && // ✅ Validate WhatsApp
        funds.value.isNotEmpty &&
        _validateFunds(funds.value) == null && // ✅ Validate funds
        description.value.isNotEmpty;

    if (isValid != isButtonEnabled.value) {
      isButtonEnabled.value = isValid;
      update();
    }
  }

  // Define validation logic here
  String? validateField(String label, String? value) {
    if (value == null || value.isEmpty) {
      return "$label is required";
    }

    switch (label.toLowerCase()) {
      case "year":
        return _validateYear(value);
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
  final UserProfile member;

  const RequestForm({
    required this.member,
    super.key,
  });

  @override
  RequestFormState createState() => RequestFormState();
}

class RequestFormState extends State<RequestForm> {
  final RequestFormController controller = Get.find<RequestFormController>();

  @override
  void initState() {
    fetchDefaultValues(widget.member);
    super.initState();
  }

  void fetchDefaultValues(UserProfile member) {
    controller.email.value = member.email ?? ''; // ✅ Use RxString instead of emailController.text
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
        ? RequestFormM(member: widget.member)
        : RequestFormW(member: widget.member);
  }
}
