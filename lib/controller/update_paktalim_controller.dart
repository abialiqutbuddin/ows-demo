import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import '../api/api.dart';
import '../model/institutes_model.dart';
import '../model/member_model.dart';
import '../model/update_paktalim_model.dart';
import 'package:intl/intl.dart';

class UpdatePaktalimController extends GetxController {

  final GlobalStateController statecontroller = Get.find<GlobalStateController>();


  var mId = "".obs;
  var jId = "".obs;
  var cId = "".obs;
  var cityId = "".obs;
  var imani = "".obs;
  var iId = "".obs;
  var subId = <String>[].obs; // ✅ Updated as a list
  var scholarshipTaken = "0".obs;
  var qardan = "".obs; // ✅ Nullable
  var cert = "".obs; // ✅ Nullable
  var scholar = "".obs; // ✅ Nullable
  Rxn<int> classId = Rxn<int>();
  var className = "".obs;
  var sId = "".obs;
  var edate = "".obs;
  var sdate = "".obs;
  var duration = "".obs;

  var countryCityData = <Map<String, dynamic>>[].obs; // Stores parsed JSON data
  var jamaatData = <Map<String, dynamic>>[].obs; // Stores parsed JSON data

  Future<void> loadCountryCityData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/country_city.json');
      List<dynamic> jsonData = jsonDecode(jsonString);
      countryCityData.assignAll(jsonData.cast<Map<String, dynamic>>()); // Assign parsed data
    } catch (e) {
    }
  }

  Future<void> submitForm(UpdateProfileRequest profileData) async {
    //printProfileData(profileData);
    Map<String,dynamic> response = await Api.postProxiedData(
        pId: int.parse(profileData.pId),
        mId: int.parse(profileData.mId),
        jId: int.parse(profileData.jId),
        itsId: int.parse(profileData.itsId),
        cId: int.parse(profileData.cId),
        cityId: int.parse(profileData.cityId),
        imani: profileData.imani,
        iId: int.parse(profileData.iId),
        subId: profileData.subId ?? [],
        scholarshipTaken: int.parse(profileData.scholarshipTaken),
        qardan: profileData.qardan.toString(),
        scholar: profileData.scholar.toString(),
        className: profileData.classId,
        sId: profileData.sId,
        edate: profileData.edate,
        duration: profileData.duration,
        sdate: profileData.sdate);
    if(response.containsKey('success')) {
      statecontroller.updateProfileLoading.value = true;
      Get.back();
      Get.snackbar("result",response['success'],backgroundColor: Colors.brown);
      final userProfile = await Api.fetchUserProfile(statecontroller.user.value.itsId.toString());
      if (userProfile != null) {
        GetStorage().write('user', userProfile);
        statecontroller.user.value = userProfile;
        statecontroller.lastMarhala.value = fetchHighestMarhalaId(userProfile)!;
        //await reqFormController.fetchRequests('', '', stateController.user.value.itsId.toString(), '');
        statecontroller.updateProfileLoading.value = false;
      } else {
        statecontroller.updateProfileLoading.value = false;
        Get.snackbar("Error", "Profile not found for ITS ID: ${statecontroller.user.value.itsId.toString()}");
      }
    }else{
      Get.snackbar("result",response.toString(),backgroundColor: Colors.redAccent);
    }
  }

  int? fetchHighestMarhalaId(UserProfile profile) {
    final edus = profile.education;
    if (edus == null || edus.isEmpty) return 0;

    int? maxId;
    for (final e in edus) {
      if (maxId == null || e.marhalaId! > maxId) {
        maxId = e.marhalaId;
      }
    }
    return maxId;
  }


  /// Load JSON data from assets
  Future<void> loadJamaatData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/jamat_jamiat.json'); // Update with correct filename
      List<dynamic> jsonData = jsonDecode(jsonString);
      jamaatData.assignAll(jsonData.cast<Map<String, dynamic>>()); // Assign parsed data
    } catch (e) {
    }
  }

  Future<void> updateJamaatId() async {
    var match = jamaatData.firstWhere(
          (element) => element["jamaat_name"] == statecontroller.user.value.tanzeem,
      orElse: () => {},
    );

    if (match.isNotEmpty) {
      jId.value = match["jamaat_id"].toString(); // Convert to string
    } else {
      jId.value = "";
    }
  }

  void updateCityAndCountryIds() {
    var match = countryCityData.firstWhere(
          (element) => element["city_name"] == selectedCity.value,
      orElse: () => {},
    );

    if (match.isNotEmpty) {
      cId.value = match["country_id"].toString(); // Convert to string
      cityId.value = match["city_id"].toString(); // Convert to string
    } else {
      cId.value = "";
      cityId.value = "";
    }
  }

  /// **Create UpdateProfileRequest object from Rx values**
  Future<void> getProfileData() async {
    await updateJamaatId();

    String className = selectedClass.value!['name'];

    await calculateStartDate(selectedCourseDuration.value!['id'], edate.value.toString());

    print('pId: ${statecontroller.user.value.id.toString()}');
    print('itsId: ${statecontroller.user.value.itsId.toString()}');
    print('mId: ${selectedMarhala.value.toString()}');
    print('jId: ${jId.value}');
    print('cId: ${cId.value}');
    print('cityId: ${cityId.value}');
    print('imani: ${imani.value}');
    print('iId: ${iId.value}');
    print('subId: ${subId.isNotEmpty ? subId.toList() : null}');
    print('scholarshipTaken: ${scholarshipTaken.value == 'Yes' ? 1.toString() : 0.toString()}');
    print('qardan: ${selectedQardan2.value != null ? selectedQardan2.value!['name'] ?? '' : 'None'}');
    print('cert: ${cert.value}');
    print('scholar: ${selectedScholarship2.value?['name'] ?? 'None'}');
    print('classId: $className');
    print('sId: ${sId.value}');
    print('edate: ${edate.value}');
    print('sdate: ${sdate.value}');
    print('duration: ${selectedCourseDuration.value!['id']}');

    var profileData =  UpdateProfileRequest(
      pId: statecontroller.user.value.id.toString(),
      itsId: statecontroller.user.value.itsId.toString(),
      mId: selectedMarhala.value.toString(),
      jId: statecontroller.user.value.jamaatId.toString(),
      cId: cId.value,
      cityId: cityId.value,
      imani: imani.value,
      iId: iId.value,
      subId: subId.isNotEmpty ? subId.toList() : null,
      scholarshipTaken: scholarshipTaken.value=='Yes' ? 1.toString() : 0.toString(),
      qardan: selectedQardan2.value != null ? selectedQardan2.value!['name'] ?? '' : 'None',
      cert: cert.value,
      scholar: selectedScholarship2.value?['name'] ?? 'None',
      classId: className,
      sId: sId.value,
      edate: edate.value,
      sdate: sdate.value,
      duration: selectedCourseDuration.value!['id'].toString(),
    );
    await submitForm(profileData);
  }

  int getStandardIdByClassName(String className) {
    for (var classItem in allClasses) {
      if (classItem['name'].toString().toLowerCase() == className.toLowerCase()) {
        return classItem['standard_id'];
      }
    }
    return 0; // Return null if class not found or standard_id not available
  }

  int getMarhalaIdbyClassName(String className) {
    for (var classItem in allClasses) {
      if (classItem['name'].toString().toLowerCase() == className.toLowerCase()) {
        return classItem['marhala'];
      }
    }
    return 0;
  }

  void sortSelectedStudiedByRank() {
    selectedStudied.sort((a, b) {
      final classA = allClasses.firstWhere((element) => element['name'] == a);
      final classB = allClasses.firstWhere((element) => element['name'] == b);
      return classA['rank'].compareTo(classB['rank']);
    });
  }

  void sortSelectedNotStudiedByRank() {
    selectedNotStudied.sort((a, b) {
      final classA = allClasses.firstWhere((element) => element['name'] == a);
      final classB = allClasses.firstWhere((element) => element['name'] == b);
      return classA['rank'].compareTo(classB['rank']);
    });
  }


  Future<void> getProfileDataforMarhala1() async {
    await updateJamaatId();
    sortSelectedStudiedByRank();
    var qardanName;
    var scholarName;
    if(selectedScholarship2.value!=null){
      scholarName = selectedScholarship2.value!['name'];
    }else{
      scholarName = 'None';
    }
    if(selectedQardan2.value!=null){
      qardanName = selectedQardan2.value!['name'];
    }else{
      qardanName = 'None';
    }
    // Shared profile fields
    String pId = statecontroller.user.value.id.toString();
    String itsId = statecontroller.user.value.itsId.toString();
    String jIdValue = statecontroller.user.value.jamaatId.toString();
    String cIdValue = cId.value;
    String cityIdValue = cityId.value;
    String imaniValue = imani.value;
    String iIdValue = iId.value;
    String qardanValue = qardanName;
    String certValue = cert.value;
    String scholarValue = scholarName;
    String scholarshipTakenValue = scholarshipTaken.value == 'Yes' ? "1" : "0";

    // Initial end date
    DateTime endDate = DateFormat("yyyy-MM-dd").parse(edate.value);

    // Generate and print a profile for each selected class
    for (int i = selectedStudied.length - 1; i >= 0; i--) {
      String className = selectedStudied[i];
      DateTime startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
      int sId = getStandardIdByClassName(className);
      int mId = getMarhalaIdbyClassName(className);

      final profile = UpdateProfileRequest(
        pId: pId,
        itsId: itsId,
        mId: mId.toString(),
        jId: jIdValue,
        cId: cIdValue,
        cityId: cityIdValue,
        imani: imaniValue,
        iId: iIdValue,
        subId: null,
        scholarshipTaken: scholarshipTakenValue,
        qardan: qardanValue,
        cert: certValue,
        scholar: scholarValue,
        classId: className,
        sId: sId.toString(),
        edate: DateFormat("yyyy-MM-dd").format(endDate),
        sdate: DateFormat("yyyy-MM-dd").format(startDate),
        duration: "12",
      );

      await submitForm(profile);
      endDate = startDate.subtract(Duration(days: 1));
    }
  }

  int getMonthDifference(DateTime startDate, DateTime endDate) {
    int yearsDiff = endDate.year - startDate.year;
    int monthsDiff = endDate.month - startDate.month;

    return (yearsDiff * 12) + monthsDiff; // Convert years to months and add remaining months
  }

  Future<void> calculateStartDate(int courseDuration, String edate) async {
    if (edate.isNotEmpty) {
      try {
        int durationMonths = courseDuration;
        DateTime endDate = DateFormat("yyyy-MM-dd").parse(edate);
        DateTime startDate = DateTime(endDate.year, endDate.month - durationMonths, endDate.day);
        sdate.value = DateFormat("yyyy-MM-dd").format(startDate);
      } catch (e) {
        sdate.value = ""; // Default value in case of error
      }
    } else {
      sdate.value = ""; // Default if inputs are empty
    }
  }

  final List<Map<String, dynamic>> qardanOptions = [
    {"id": 1, "name": "Self Arranged"},
    {"id": 2, "name": "Qardan through Dawat Institution"},
    {"id": 3, "name": "None"},
  ];

  final List<Map<String, dynamic>> courseDurationOptions = List.generate(
    20, // because (60 - 3)/3 + 1 = 20
        (index) {
      int duration = (index + 1) * 3;
      return {
        "id": duration,
        "name": "$duration months",
      };
    },
  );

  final List<Map<String, dynamic>> scholarshipOptions = [
    {"id": 1, "name": "Self-Arranged"},
    {"id": 2, "name": "AIUT"},
    {"id": 3, "name": "STSMF"},
    {"id": 4, "name": "Local Jamaat"},
    {"id": 5, "name": "None"},
  ];

  Map<String, dynamic>? getClassByName(List<Map<String, dynamic>> classes, String name) {
    try {
      return classes.firstWhere(
            (element) => element['name']?.toString().toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null; // Not found
    }
  }

  List<Map<String, dynamic>> allClasses = [
    {"id": 1, "name": "Play Group", "rank": 1, "marhala": 1,"standard_id":1},
    {"id": 2, "name": "Nursery", "rank": 2, "marhala": 1,"standard_id":2},
    {"id": 3, "name": "Junior Kindergarten", "rank": 3, "marhala": 1,"standard_id":3},
    {"id": 4, "name": "Senior Kindergarten", "rank": 4, "marhala": 1,"standard_id":4},
    {"id": 5, "name": "1st", "rank": 5, "marhala": 2,"standard_id":6},
    {"id": 6, "name": "2nd", "rank": 6, "marhala": 2,"standard_id":7},
    {"id": 7, "name": "3rd", "rank": 7, "marhala": 2,"standard_id":8},
    {"id": 8, "name": "4th", "rank": 8, "marhala": 2,"standard_id":9},
    {"id": 9, "name": "5th", "rank": 9, "marhala": 3,"standard_id":10},
    {"id": 10, "name": "6th", "rank": 10, "marhala": 3,"standard_id":11},
    {"id": 11, "name": "7th", "rank": 11, "marhala": 3,"standard_id":12},
    {"id": 12, "name": "8th", "rank": 12, "marhala": 3,"standard_id":13},
    {"id": 13, "name": "9th", "rank": 13, "marhala": 4},
    {"id": 14, "name": "O-Level(I)", "rank": 14, "marhala": 4},
    {"id": 15, "name": "10th", "rank": 15, "marhala": 4},
    {"id": 16, "name": "O-Level(II)", "rank": 15, "marhala": 4},
    {"id": 17, "name": "11th", "rank": 16, "marhala": 5},
    {"id": 18, "name": "AS-Level", "rank": 16, "marhala": 5},
    {"id": 19, "name": "Diploma/ Vocational Training", "rank": 17, "marhala": 5},
    {"id": 20, "name": "Diploma of Associate Engineer (DAE)", "rank": 17, "marhala": 5},
    {"id": 21, "name": "12th", "rank": 17, "marhala": 5},
    {"id": 22, "name": "A2-Level", "rank": 17, "marhala": 5},
    {"id": 23, "name": "Associated Degree Programs", "rank": 18, "marhala": 6},
    {"id": 24, "name": "Bachelors Degree Programs", "rank": 18, "marhala": 6},
    {"id": 25, "name": "Professional Programs", "rank": 18, "marhala": 6},
    {"id": 26, "name": "Diploma/ Vocational Training", "rank": 18, "marhala": 6},
    {"id": 27, "name": "Masters/ M. Phil.", "rank": 19, "marhala": 7},
    {"id": 28, "name": "Ph.D", "rank": 19, "marhala": 7},
    {"id": 29, "name": "Post Doctorate", "rank": 19, "marhala": 7},
  ];

  // var selectedClasses = <String>[].obs;
  //
  //
  // List<Map<String, dynamic>> get selectedClassList =>
  //     allClasses.where((cls) => selectedClasses.contains(cls["name"])).toList();
  //
  // List<Map<String, dynamic>> get unselectedClassList =>
  //     allClasses
  //         .where((cls) =>
  //     cls["rank"] != null &&
  //         cls["rank"] <= 12 &&
  //         !selectedClasses.contains(cls["name"]))
  //         .toList();

  final RxList<String> selectedStudied = <String>[].obs;
  final RxList<String> selectedNotStudied = <String>[].obs;

  void toggleStudied(String name) {
    if (selectedStudied.contains(name)) {
      selectedStudied.remove(name);
    } else {
      selectedStudied.add(name);
      selectedNotStudied.remove(name); // remove from other
    }
  }

  void toggleNotStudied(String name) {
    if (selectedNotStudied.contains(name)) {
      selectedNotStudied.remove(name);
    } else {
      selectedNotStudied.add(name);
      selectedStudied.remove(name); // remove from other
    }
  }

  List<Map<String, dynamic>> getClassesByMarhala(int? selectedMarhala) {

    return allClasses
        .where((element) => element["marhala"] == selectedMarhala)
        .map((e) => {"id": e["id"], "name": e["name"],"standard_id":e["standard_id"] ?? 0}) // Ensuring dropdown format
        .toList();
  }


  RxString selectedEducationType = "".obs;
  Rxn<int> selectedMarhala = Rxn<int>();
  RxString selectedCategory = "".obs;
  RxString selectedDeeniType = "".obs;
  RxString purpose = "".obs;
  RxString grade = "".obs;

  RxBool isSubmitEnabled = false.obs;
  RxString startDate = ''.obs;
  RxString endDate = ''.obs;

  RxString organization = ''.obs;

  // Convert to Rxn<int> for dropdown selections
  Rxn<int> standardIndex = Rxn<int>(null);
  Rxn<int> fieldOfStudyIndex = Rxn<int>(null);
  Rxn<int> courseIndexPoint = Rxn<int>(null);
  Rxn<int> selectedQardan = Rxn<int>(null);
  Rxn<int> selectedScholarship = Rxn<int>(null);
  Rxn<int> degreeProgramIndex = Rxn<int>(null);
  Rxn<int> marhala4Index = Rxn<int>(null);
  Rxn<int> marhala5Index = Rxn<int>(null);
  Rxn<int> madrasaIndex = Rxn<int>(null);
  Rxn<int> hifzProgramIndex = Rxn<int>(null);
  Rxn<int> darajaIndex = Rxn<int>(null);

  // Form Fields (Strings)
  RxString standard = "".obs;
  RxString fieldOfStudy = "".obs;
  RxString subject = "".obs;
  //RxString degreeProgram = "".obs;
  RxString course = "".obs;
  RxString madrasaName = "".obs;
  RxString darajaName = "".obs;
  RxString hifzProgress = "".obs;
  RxString hifzProgramName = "".obs;

  void resetFields(){
    sId.value = '';
    className.value = '';
    iId.value = '';
    subId.value = [];
    edate.value = '';
    sdate.value = '';
    studyOptions.clear();
    filteredStudies.clear();
    courseOptions.clear();
    selectedInstitute.value=null;
    selectedCity.value='Select City';
    selectedInstituteName.value='';
    selectedCityId.value=null;
  }

  RxList<Map<String, dynamic>> studyOptions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> courseOptions = <Map<String, dynamic>>[].obs;

  // **State Management**
  RxBool isLoading = true.obs;
  RxBool isButtonEnabled = true.obs;

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
    { 'id': 1, 'name': 'Pre-Primary to 8th (Marhala 1–3)' },
    { 'id': 4, 'name': '9th – 10th (Marhala 4)' },
    { 'id': 5, 'name': '11th – 12th (Marhala 5)' },
    { 'id': 6, 'name': 'Undergraduate (Marhala 6)' },
    { 'id': 7, 'name': 'Postgraduate (Marhala 7)' },
  ];

  Map<String, dynamic>? getMarhalaById(List<Map<String, dynamic>> marhalas, int id) {
    try {
      return marhalas.firstWhere((m) => m['id'] == id);
    } catch (e) {
      return null; // Not found
    }
  }

  final RxList<Map<String, dynamic>> filteredClasses = <Map<String, dynamic>>[].obs;


  Rxn<Map<String, dynamic>> selectedMarhala2 = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> selectedClass = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> fieldOfStudy2 = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> selectedSubject1 = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> selectedQardan2 = Rxn<Map<String,dynamic>>();
  Rxn<Map<String, dynamic>> selectedScholarship2 = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> selectedCourseDuration = Rxn<Map<String, dynamic>>();


  void resetSelections() {
  }


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
          .map((u) => {"id": u.id, "name": u.name,"is_imani":u.isImani})
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

  List<Map<String, dynamic>> _extractUniqueValues(
      List<dynamic> data,
      String key,
      Map<String, dynamic> Function(dynamic) mapFunction) {
    final seenKeys = <dynamic>{};
    final result = <Map<String, dynamic>>[];

    for (var item in data) {
      final value = item[key];

      if (value != null) {
        if (seenKeys.add(value)) {
          final mapped = mapFunction(item);
          result.add(mapped);
        } else {
        }
      } else {
      }
    }

    return result;
  }


  // Function to Validate Form Based on Selections
  void validateForm() {
    List<String> requiredFields = ["purpose","marhala"];
    List<String> missingFields = []; // To store missing required fields

    if (fieldOfStudyIndex.value != null) {
      fieldOfStudy.value = studyOptions.firstWhere((e) =>
      e["id"] == fieldOfStudyIndex.value)["name"];

    }

    if (courseIndexPoint.value != null) {
      subject.value = courseOptions.firstWhere((e) =>
      e["id"] == courseIndexPoint.value)["name"];
    }

    // Check required fields and store missing ones
    for (var field in requiredFields) {
      if (getFieldValue(field).isEmpty) {
        missingFields.add(field);
      }
    }

    isSubmitEnabled.value = missingFields.isEmpty;
  }

  void filterCourseOptions(int studyId) {

    final filtered = allData
        .where((item) {
      final match = item['study_id'] == studyId;
      return match;
    })
        .map((item) {
      final mapped = {'id': item['id'], 'name': item['name']};
      return mapped;
    })
        .toList();


    courseOptions.assignAll(filtered);
    selectedField.value = null;
    update(); // ✅ Ensure UI updates
  }

  RxString degreeProgram = ''.obs;

  // Get Field Value Dynamically
  String getFieldValue(String fieldName) {
    switch (fieldName) {
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

  @override
  Future<void> onInit() async {
    super.onInit();
    loadJamaatData();
    loadCountryCityData();
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

}