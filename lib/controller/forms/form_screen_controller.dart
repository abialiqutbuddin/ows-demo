import 'package:get/get.dart';

class FormController extends GetxController {
  // **Form State**
  RxBool isButtonEnabled = false.obs;

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
      case "hof its":
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
      case "age":
      case "fees":
        return _validateNumber(value, label);
      case "full name":
      case "father name":
      case "mother name":
      case "guardian name":
      case "business name":
      case "name":
      case "class / degree":
      case "institute name":
      case "remarks":
        return _validateName(value, label);
      case "family surname":
        return _validateSurname(value);
      case "cnic":
      case "father cnic":
      case "mother cnic":
      case "guardian cnic":
        return _validateCNIC(value);
      case "date of birth":
        return _validateDateOfBirth(value);
      case "mobile no.":
      case "whatsapp no.":
        return _validatePhoneNumber(value);
      case "email":
        return _validateEmail(value);
      case "residential address":
        return _validateAddress(value);
      case "relation to student":
        return _validateRelation(value);
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

  // **Individual Validation Helpers**
  String? _validateNumber(String value, String label) {
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return "$label should contain only numbers";
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