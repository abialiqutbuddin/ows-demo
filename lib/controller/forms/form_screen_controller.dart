import 'package:get/get.dart';
import '../../api/api.dart';
import '../../model/submit_application_form.dart';
import '../state_management/state_manager.dart';

class FormController extends GetxController {

  // **Form State**
  RxBool isFinancialInfoButtonEnabled = false.obs;

  RxBool isButtonEnabled = false.obs;

  RxString organization = ''.obs;

  bool checkFinancialInfo(){
    return isFinancialComplete.value
        && isPersonalAssetsComplete.value
        && isBusinessAssetComplete.value;
  }

  bool checkPersonalInfo(){
    return isPersonalInfoComplete.value
        && isStudentInfoComplete.value
        && isFamilyInfoComplete.value && isMainOccupationComplete.value;
  }

  bool checkFinancialExtended(){
    String org = organization.value;

    if (org == 'AIUT') {
      return
          isDependentsComplete.value &&
          isEnayatComplete.value &&
          isTravellingComplete.value &&
          isSOLComplete.value;
    }

    if (org == 'STSMF') {
      return
          isPreviouslyTakenComplete.value &&
          isTravellingComplete.value &&
          isDependentsComplete.value &&
          isQHAppliedComplete.value &&
          isPaymentsComplete.value &&
          isRepaymentsComplete.value &&
          isEnayatComplete.value;
    }

    if (org == 'AMBT') {
      return
          isTravellingComplete.value &&
          isDependentsComplete.value &&
          isFinancialComplete.value;
    }

    return false;
  }

  final RxBool isKhidmatComplete = false.obs;
  final RxBool isMainOccupationComplete = false.obs;
  final RxBool isPreviouslyTakenComplete = false.obs;


  bool isNextButtonEnabled() {
    String org = organization.value; // Get the current organization

    if (org == 'AIUT') {
      return isPersonalInfoComplete.value &&
          isStudentInfoComplete.value &&
          isFamilyInfoComplete.value &&
          isFinancialComplete.value &&
          isKhidmatComplete.value &&
          isMainOccupationComplete.value &&
          isDependentsComplete.value &&
          isEnayatComplete.value &&
          isTravellingComplete.value &&
          isSOLComplete.value; //standard of living
    }

    if (org == 'STSMF') {
      return isPersonalInfoComplete.value &&
          isStudentInfoComplete.value &&
          isFamilyInfoComplete.value &&
          isMainOccupationComplete.value &&
          isFinancialComplete.value &&
          isLiabilitesComplete.value &&
          isPersonalAssetsComplete.value &&
          isBusinessAssetComplete.value &&
          isPreviouslyTakenComplete.value &&
          isTravellingComplete.value &&
          isDependentsComplete.value &&
          isKhidmatComplete.value &&
          isQHAppliedComplete.value &&
          isPaymentsComplete.value &&
          isRepaymentsComplete.value &&
          isEnayatComplete.value;
    }

    if (org == 'AMBT') {
      return isPersonalInfoComplete.value &&
          isStudentInfoComplete.value &&
          isFamilyInfoComplete.value &&
          isMainOccupationComplete.value &&
          isKhidmatComplete.value &&
          isTravellingComplete.value &&
          isDependentsComplete.value &&
          isFinancialComplete.value;
    }

    return false;
  }



  RxBool isValid = false.obs;

  RxBool isPersonalInfoComplete = false.obs;
  RxBool isStudentInfoComplete = false.obs;
  RxBool isFamilyInfoComplete = false.obs;

  final RxBool isFinancialComplete = false.obs;
  final RxBool isPersonalAssetsComplete = false.obs;
  final RxBool isBusinessAssetComplete = false.obs;
  final RxBool isFamilyEduComplete = false.obs;

  final RxBool isSOLComplete = false.obs;
  final RxBool isTravellingComplete = false.obs;
  final RxBool isDependentsComplete = false.obs;
  final RxBool isLiabilitesComplete = false.obs;
  final RxBool isEnayatComplete = false.obs;
  final RxBool isQHAppliedComplete = false.obs;
  final RxBool isPaymentsComplete = false.obs;
  final RxBool isRepaymentsComplete = false.obs;

  final RxBool isDocValid = false.obs;


  final RxInt dependentsInt = 0.obs;
  final RxInt travelledInt = 0.obs;
  final RxInt liabilitiesInt = 0.obs;
  final RxInt qhappliedInt = 0.obs;
  final RxInt enayatInt = 0.obs;
  final RxInt businesAssetInt = 0.obs;

  // bool validateDocuments(String docType) {
  //   // Check if the document exists in the map and is not null
  //   return documents.containsKey(docType) && documents[docType] != null;
  // }

  void validateTravellingsFields() {
    if(travelledInt.value==0) {
      if (travelling.isEmpty) {
        isTravellingComplete.value = false;
        return;
      }

      for (var travel in travelling) {
        if (!travel.containsKey("place")
            || !travel.containsKey("year")
            || !travel.containsKey("purpose")
            || travel["place"] == null
            || travel["place"].toString().trim().isEmpty
            || travel["year"] == null
            || travel["purpose"] == null
            || _validateName(travel["place"].value, '')!=null
            || _validateYear(travel["year"].value, '')!=null
            || travel["purpose"].toString().trim().isEmpty) {
          isTravellingComplete.value = false;
          return;
        }
      }
      isTravellingComplete.value = true;
    }else{
      isTravellingComplete.value = true;
    }
  }

  void validateDependentsFields() {
    if(dependentsInt.value==0) {
      if (dependents.isEmpty) {
        isDependentsComplete.value = false;
        return;
      }

      for (var dependent in dependents) {
        if (!dependent.containsKey("name")
            || !dependent.containsKey("relation")
            || !dependent.containsKey("age")
            || dependent["name"] == null
            || _validateName(dependent["name"].value, '')!=null
            || _validateName(dependent["relation"].value, '')!=null
            || _validateAge(dependent["age"].value, '')!=null
            || dependent["name"].toString().trim().isEmpty
            || dependent["relation"] == null
            || dependent["relation"].toString().trim().isEmpty
            || dependent["age"] == null
            || dependent["age"].toString().trim().isEmpty
        ) {
          isDependentsComplete.value = false;
          return;
        }
      }
      isDependentsComplete.value = true;
    }else{
      isDependentsComplete.value = true;
    }
  }

  void validateLiabilitiesFields() {
    if(liabilitiesInt.value==0) {
      if (liabilities.isEmpty) {
        isLiabilitesComplete.value = false;
        return;
      }

      for (var liability in liabilities) {
        if (!liability.containsKey("type") || !liability.containsKey("its") ||
            !liability.containsKey("purpose") ||
            !liability.containsKey("amount") ||
            !liability.containsKey("balance") ||
            !liability.containsKey("status") ||
            !liability.containsKey("reason") ||
            liability["type"] == null || liability["type"]
            .toString()
            .trim()
            .isEmpty ||
            liability["its"] == null || liability["its"]
            .toString()
            .trim()
            .isEmpty ||
            liability["purpose"] == null || liability["purpose"]
            .toString()
            .trim()
            .isEmpty ||
            liability["amount"] == null || liability["amount"]
            .toString()
            .trim()
            .isEmpty ||
            liability["balance"] == null || liability["balance"]
            .toString()
            .trim()
            .isEmpty ||
            liability["status"] == null || liability["status"]
            .toString()
            .trim()
            .isEmpty
           // || liability["reason"] == null || liability["reason"].toString().trim().isEmpty
        ) {
          isLiabilitesComplete.value = false;
          return;
        }
      }
      isLiabilitesComplete.value = true;
    }else{
      isLiabilitesComplete.value = true;
    }
  }

  void validateEnayatFromFields() {
    if(enayatInt.value==0) {
      if (enayat.isEmpty) {
        isEnayatComplete.value = false;
        return;
      }

      for (var enayat in enayat) {
        if (!enayat.containsKey("its") || !enayat.containsKey("purpose") ||
            !enayat.containsKey("amount") || !enayat.containsKey("date") ||
            enayat["its"] == null || enayat["its"]
            .toString()
            .trim()
            .isEmpty ||
            enayat["purpose"] == null || enayat["purpose"]
            .toString()
            .trim()
            .isEmpty ||
            enayat["amount"] == null || enayat["amount"]
            .toString()
            .trim()
            .isEmpty ||
            enayat["date"] == null || enayat["date"]
            .toString()
            .trim()
            .isEmpty) {
          isEnayatComplete.value = false;
          return;
        }
      }
      isEnayatComplete.value = true;
    }else{
      isEnayatComplete.value = true;
    }
  }

  void validateQHAppliedFields() {
    if(qhappliedInt.value==0) {
      if (guarantor.isEmpty) {
        isQHAppliedComplete.value = false;
        return;
      }

      // Check guarantor fields
      for (var guarantor in guarantor) {
        if (!guarantor.containsKey("name") || !guarantor.containsKey("its") ||
            !guarantor.containsKey("mobile") ||
            guarantor["name"] == null || guarantor["name"]
            .toString()
            .trim()
            .isEmpty ||
            guarantor["its"] == null || guarantor["its"]
            .toString()
            .trim()
            .isEmpty ||
            guarantor["mobile"] == null || guarantor["mobile"]
            .toString()
            .trim()
            .isEmpty) {
          isQHAppliedComplete.value = false;
          return;
        }
      }

      // Check appliedAmount and amanat separately
      if (appliedAmount.value
          .toString()
          .trim()
          .isEmpty || amanat.value
          .toString()
          .trim()
          .isEmpty) {
        isQHAppliedComplete.value = false;
        return;
      }

      isQHAppliedComplete.value = true;
    }else{
      isQHAppliedComplete.value = true;
    }
  }

  void validatePaymentsFields() {
    if (payments.isEmpty) {
      isPaymentsComplete.value = false;
      return;
    }

    for (var payment in payments) {
      if (!payment.containsKey("amount") || !payment.containsKey("date") ||
          payment["amount"] == null || payment["amount"].toString().trim().isEmpty ||
          payment["date"] == null || payment["date"].toString().trim().isEmpty) {
        isPaymentsComplete.value = false;
        return;
      }
    }
    isPaymentsComplete.value = true;
  }

  void validateRePaymentsFields() {
    if (repayments.isEmpty) {
      isRepaymentsComplete.value = false;
      return;
    }

    for (var repayment in repayments) {
      if (!repayment.containsKey("amount") || !repayment.containsKey("date") ||
          !repayment.containsKey("total") || !repayment.containsKey("balance") ||
          repayment["amount"] == null || repayment["amount"].toString().trim().isEmpty ||
          repayment["date"] == null || repayment["date"].toString().trim().isEmpty ||
          repayment["total"] == null || repayment["total"].toString().trim().isEmpty ||
          repayment["balance"] == null || repayment["balance"].toString().trim().isEmpty) {
        isRepaymentsComplete.value = false;
        return;
      }
    }
    isRepaymentsComplete.value = true;
  }

  void validateBusinessAssetsFields() {
    if(businesAssetInt.value==0) {
      if (businessList.isEmpty) {
        isBusinessAssetComplete.value = false;
        return;
      }

      for (var business in businessList) {
        if (!business.containsKey("businessName") ||
            !business.containsKey("assetValue") ||
            business["businessName"] == null || business["businessName"]
            .toString()
            .trim()
            .isEmpty ||
            business["assetValue"] == null || business["assetValue"]
            .toString()
            .trim()
            .isEmpty) {
          isBusinessAssetComplete.value = false;
          return;
        }
      }
      isBusinessAssetComplete.value = true;
    }else{
      isBusinessAssetComplete.value = true;
    }
  }

  void validateFamilyEduFields() {
    if (familyEducationList.isEmpty) {
      isFamilyEduComplete.value = false;
      return;
    }

    for (var family in familyEducationList) {
      print(_validateName(family["name"].value, ''));
      if (!family.containsKey("name")
          || !family.containsKey("age")
          || !family.containsKey("institute")
          || !family.containsKey("class")
          || !family.containsKey("fees")
          || family["name"] == null
          || family["name"].toString().trim().isEmpty
          || family["age"] == null
          || family["age"].toString().trim().isEmpty
          || family["institute"] == null
          || family["institute"].toString().trim().isEmpty
          || family["class"] == null
          || family["class"].toString().trim().isEmpty
          || family["fees"] == null
          || family["fees"].toString().trim().isEmpty
          || _validateName(family["name"].value, '')!=null
          || _validateName(family["institute"].value, '')!=null
          || _validateNumber(family["fees"].value, '')!=null
          || _validateName(family["name"].value, '')!=null
      ) {
        isFamilyEduComplete.value = false;
        return;
      }
    }

    isFamilyEduComplete.value = true;
  }

  void validatePersonalInfoFields() {
    isPersonalInfoComplete.value = sfNo.value.isNotEmpty &&
        _validateNumber(sfNo.value, "") == null &&
        hofIts.value.isNotEmpty &&
        _validateNumber(hofIts.value, "") == null &&
        mohallaName.isNotEmpty &&
        _validateName(familySurname.value, "") == null &&
        familySurname.value.isNotEmpty;
  }

  void validateMainOccupationFields() {
    isMainOccupationComplete.value = occupation.value.isNotEmpty &&
        _validateName(occupation.value, "") == null;
  }

  void validateStudentInfoFields() {
    isStudentInfoComplete.value = fullName.value.isNotEmpty &&
        _validateName(fullName.value, "") == null &&
        cnic.value.isNotEmpty &&
        _validateCNIC(cnic.value) == null &&
        dateOfBirth.isNotEmpty &&
        _validateDateOfBirth(dateOfBirth.value) == null &&
        _validateNumber(mobileNo.value,"") == null &&
        _validateNumber(whatsappNo.value,"") == null &&
        _validateEmail(email.value) == null &&
        _validateAddress(residentialAddress.value) == null &&
        mobileNo.value.isNotEmpty &&
        email.value.isNotEmpty &&
        residentialAddress.value.isNotEmpty &&
        whatsappNo.value.isNotEmpty;
  }

  void validateFamilyInfoFields() {
    isFamilyInfoComplete.value = fatherName.value.isNotEmpty &&
        _validateName(fatherName.value, "") == null &&
        motherName.value.isNotEmpty &&
        _validateName(motherName.value, "") == null &&
        _validateCNIC(fatherCnic.value) == null &&
        fatherCnic.value.isNotEmpty &&
        _validateCNIC(motherCnic.value) == null &&
        motherCnic.value.isNotEmpty;
        // _validateName(guardianName.value, "") == null &&
        // _validateCNIC(guardianCnic.value) == null;
  }

  void validateFinancialAssetsFields() {
    isFinancialComplete.value = personalIncome.value.isNotEmpty &&
        _validateNumber(personalIncome.value, "") == null &&
        otherFamilyIncome.value.isNotEmpty &&
        _validateNumber(otherFamilyIncome.value, "") == null &&
        studentIncome.isNotEmpty &&
        _validateNumber(studentIncome.value, "") == null &&
        (ownedProperty.value.isNotEmpty || rentProperty.value.isNotEmpty || goodwillProperty.value.isNotEmpty);
  }

  void validatePersonalAssetsFields() {
    isPersonalAssetsComplete.value = property.value.isNotEmpty &&
        _validateNumber(property.value, "") == null &&
        jewelry.value.isNotEmpty &&
        _validateNumber(jewelry.value, "") == null &&
        transport.isNotEmpty &&
        _validateNumber(transport.value, "") == null &&
        others.isNotEmpty &&
        _validateNumber(others.value, "") == null;
  }

  RxString its = '30445124'.obs;
  RxString reqId = '001'.obs;

  Future<void> submitForm() async {
    final model = SubmissionFormModel.fromData(
      its: its.value, // Convert RxString to normal String
      reqId: reqId.value,
      sfNo: sfNo.value,
      hofIts: hofIts.value,
      familySurname: familySurname.value,
      fullName: fullName.value,
      cnic: cnic.value,
      dateOfBirth: dateOfBirth.value,
      mobileNo: mobileNo.value,
      whatsappNo: whatsappNo.value,
      email: email.value,
      residentialAddress: residentialAddress.value,
      fatherName: fatherName.value,
      fatherCnic: fatherCnic.value,
      motherName: motherName.value,
      motherCnic: motherCnic.value,
      guardianName: guardianName.value,
      guardianCnic: guardianCnic.value,
      relationToStudent: relationToStudent.value,
      mohallaName: mohallaName.value,
      appliedAmount: appliedAmount.value,
      amanat: amanat.value,
      personalIncome: personalIncome.value,
      otherFamilyIncome: otherFamilyIncome.value,
      studentIncome: studentIncome.value,
      ownedProperty: ownedProperty.value,
      rentProperty: rentProperty.value,
      goodwillProperty: goodwillProperty.value,
      property: property.value,
      jewelry: jewelry.value,
      transport: transport.value,
      others: others.value,
      businessList: businessList.toList(), // Convert RxList to normal List
      familyEducationList: familyEducationList.toList(),
      otherCertificationList: otherCertificationList.toList(),
      travelling: travelling.toList(),
      dependents: dependents.toList(),
      liabilities: liabilities.toList(),
      enayat: enayat.toList(),
      guarantor: guarantor.toList(),
      payments: payments.toList(),
      repayments: repayments.toList(),
    );

    // Call the API to submit form
    await Api.submitForm(model);
  }

  // **Form Fields**
  RxString sfNo = ''.obs;
  RxString hofIts = ''.obs;
  RxString familySurname = ''.obs;
  RxString fullName = ''.obs;
  RxString cnic = ''.obs;
  RxString dateOfBirth = ''.obs;
  RxString mobileNo = ''.obs;
  RxString whatsappNo = ''.obs;
  RxString email = ''.obs;
  RxString residentialAddress = ''.obs;
  RxString fatherName = ''.obs;
  RxString fatherCnic = ''.obs;
  RxString motherName = ''.obs;
  RxString motherCnic = ''.obs;
  RxString guardianName = ''.obs;
  RxString guardianCnic = ''.obs;
  RxString relationToStudent = ''.obs;
  RxString mohallaName = ''.obs;
  RxString appliedAmount = ''.obs;
  RxString amanat = ''.obs;
  RxString occupation = ''.obs;
  RxString wordAddress = ''.obs;
  RxString workPhone = ''.obs;

  ///income
  RxString personalIncome = ''.obs;
  RxString otherFamilyIncome = ''.obs;
  RxString studentIncome = ''.obs;
  RxString ownedProperty = ''.obs;
  RxString rentProperty = ''.obs;
  RxString goodwillProperty = ''.obs;
  RxString property = ''.obs;
  RxString jewelry = ''.obs;
  RxString transport = ''.obs;
  RxString others = ''.obs;
  RxList<Map<String, dynamic>> businessList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> familyEducationList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> otherCertificationList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> travelling = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> dependents = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> liabilities = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> enayat = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> guarantor = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> payments = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> repayments = <Map<String, dynamic>>[].obs;


  // **Dropdown Fields**
  final List<Map<String, dynamic>> mohalla = [
    {'id': 1, 'name': 'Yusufi'},
    {'id': 2, 'name': 'Burhani'},
    {'id': 3, 'name': 'AMB'},
    {'id': 4, 'name': 'AMM'},
  ];

  var selectedMohalla = Rxn<int>();

  // **Validation Methods**
  String? validateField(String label, String value) {
    if (value.trim().isEmpty) return "* $label is required";

    switch (label.toLowerCase()) {
      case "sf no.":
      case "personal income":
      case "other family income":
      case "student income (part time)":
      case "owened":
      case "rent":
      case "goodwill":
      case "property":
      case "jewelry":
      case "transport":
      case "others":
      case "asset value":
      case "fees":
      case "amount":
      case "balance":
      case "qh applied":
      case "total":
        return _validateNumber(value, label);
      case "hof its":
      case "its":
      case "its (mother / father)":
        return _validateITS(value, label);
      case "full name":
      case "father name":
      case "mother name":
      case "guardian name":
      case "business name":
      case "name":
      case "class / degree":
      case "institute name":
      case "remarks":
      case "place":
      case "relation":
      case "occupation":
        return _validateName(value, label);
      case "family surname":
        return _validateSurname(value);
      case "cnic":
      case "father cnic":
      case "mother cnic":
      case "guardian cnic":
        return _validateCNIC(value);
      case "date of birth":
      case "date":
        return _validateDateOfBirth(value);
      case "mobile no.":
      case "mobile number":
      case "whatsapp no.":
        return _validatePhoneNumber(value);
      case "email":
        return _validateEmail(value);
      case "residential address":
        return _validateAddress(value);
      case "relation to student":
        return _validateRelation(value);
      case "year":
        return _validateYear(value,label);
      case "age":
        return _validateAge(value, label);
      default:
        return null;
    }
  }

  String? validateDropdown(String label, Rxn<int> selectedValue) {
    if (selectedValue.value == null) {
      return "* $label is required";
    }
    return null;
  }

  String? _validateITS(String value, String label) {
    if (value.isEmpty) {
      return "$label is required";
    }
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      return "$label must be exactly 8 digits and contain only numbers";
    }
    return null;
  }

  String? _validateAge(String value, String label) {
    if (value.isEmpty) {
      return "$label is required";
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return "$label should contain only numbers";
    }

    int age = int.tryParse(value) ?? 0;
    if (age < 1 || age > 120) {
      return "$label must be between 1 and 120";
    }

    return null;
  }

  // **Individual Validation Helpers**
  String? _validateNumber(String value, String label) {
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return "$label should contain only numbers";
    }
    return null;
  }

  String? _validateYear(String value, String label) {
    if (value.isEmpty) {
      return "$label is required";
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return "$label must be a 4-digit year (e.g., 2024)";
    }
    return null;
  }

  String? _validateName(String value, String label) {
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return "$label should contain only letters and spaces";
    }
    if (value.length < 3) {
      return "$label must be at least 3 characters long";
    }
    return null;
  }

  String? _validateSurname(String value) {
    if (!RegExp(r"^[a-zA-Z\s-]+$").hasMatch(value)) {
      return "Family Surname can only contain letters, spaces, and hyphens";
    }
    return null;
  }

  String? _validateCNIC(String value) {
    if (!RegExp(r'^\d{13}$').hasMatch(value)) {
      return "CNIC must be 13 digits";
    }
    return null;
  }

  String? _validateDateOfBirth(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return "Enter a valid date format (YYYY-MM-DD)";
    }
    return null;
  }

  String? _validatePhoneNumber(String value) {
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
      return "Enter a valid phone number (10-15 digits)";
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? _validateAddress(String value) {
    if (value.length < 10) {
      return "Address must be at least 10 characters";
    }
    return null;
  }

  String? _validateRelation(String value) {
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return "Relation should only contain letters";
    }
    return null;
  }

  // **Form Validation Check**
  void validateForm() {
    bool isValid =
        sfNo.value.isNotEmpty &&
            hofIts.value.isNotEmpty &&
            familySurname.value.isNotEmpty &&
            fullName.value.isNotEmpty &&
            _validateName(fullName.value, "Full Name") == null &&
            cnic.value.isNotEmpty &&
            _validateCNIC(cnic.value) == null &&
            dateOfBirth.value.isNotEmpty &&
            _validateDateOfBirth(dateOfBirth.value) == null &&
            mobileNo.value.isNotEmpty &&
            _validatePhoneNumber(mobileNo.value) == null &&
            whatsappNo.value.isNotEmpty &&
            _validatePhoneNumber(whatsappNo.value) == null &&
            email.value.isNotEmpty &&
            _validateEmail(email.value) == null &&
            residentialAddress.value.isNotEmpty &&
            _validateAddress(residentialAddress.value) == null &&
            fatherName.value.isNotEmpty &&
            _validateName(fatherName.value, "Father Name") == null &&
            fatherCnic.value.isNotEmpty &&
            _validateCNIC(fatherCnic.value) == null &&
            motherName.value.isNotEmpty &&
            _validateName(motherName.value, "Mother Name") == null &&
            motherCnic.value.isNotEmpty &&
            _validateCNIC(motherCnic.value) == null &&
            guardianName.value.isNotEmpty &&
            _validateName(guardianName.value, "Guardian Name") == null &&
            guardianCnic.value.isNotEmpty &&
            _validateCNIC(guardianCnic.value) == null &&
            relationToStudent.value.isNotEmpty &&
            _validateRelation(relationToStudent.value) == null &&
            selectedMohalla.value != null;

    if (isValid != isButtonEnabled.value) {
      isButtonEnabled.value = isValid;
      update();
    }
  }
}