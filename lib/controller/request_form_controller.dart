import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import '../api/api.dart';
import '../mobile_ui/request_form_screen.dart';
import '../model/member_model.dart';
import '../web_ui/request_form.dart';

class RequestFormController extends GetxController {

  bool isLoading = true; // Loading state

  final double defSpacing = 8;
  late final UserProfile member;
  bool isButtonEnabled = false;
  final StateController statecontroller = Get.put(StateController());
  late int reqId = 0;

  // Add separate keys for each form section
  final GlobalKey<FormState> mainFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> fundsFormKey = GlobalKey<FormState>();

  // Dropdown values
  String selectedCity = "Select City";
  String selectedSubject = "Select Subject";

  // Dropdown options
  final List<String> cities = ["Select City", "Karachi", "Islamabad", "Lahore"];
  final List<String> subjects = [
    "Select Subject",
    "Math",
    "Science",
    "History",
    "Computer Science"
  ];

  final TextEditingController classDegreeController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController studyController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController fundsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Define validation logic here
  String? validateField(String label, String? value) {
    if (value == null || value.isEmpty) {
      return "* $label is required";
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
    final regex = RegExp(r'^[a-zA-Z0-9\s\-\/\.]+$');

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
    if (value.startsWith('.') || value.startsWith('-') || value.startsWith('_')) {
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

  String? validateDropdown(String label, String value) {
    if (value == "Select City" || value == "Select Subject") {
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

  final RequestFormController controller = Get.put(RequestFormController());

  @override
  void initState() {
    super.initState();
    fetchReqId();
    controller.classDegreeController.addListener(validateForm);
    controller.institutionController.addListener(validateForm);
    controller.studyController.addListener(validateForm);
    controller.yearController.addListener(validateForm);
    controller.emailController.addListener(validateForm);
    controller.phoneController.addListener(validateForm);
    controller.whatsappController.addListener(validateForm);
    controller.fundsController.addListener(validateForm);
    controller.descriptionController.addListener(validateForm);
    fetchDefaultValues();
  }

  Future<void> fetchReqId() async {
    controller.reqId = await Api.fetchNextReqMasId();
    setState(() {
      controller.reqId;
    });
  }

  void fetchDefaultValues() {
    String? email = widget.member.email;
    String? phone = widget.member.mobileNo;
    String? whatsapp = widget.member.whatsappNo;

    if (widget.member.future != [] && widget.member.future != null && widget.member.future!.isNotEmpty) {
      String? subject = widget.member.future!.first.subject ?? '';
      String? institution = widget.member.future!.first.institute ?? '';
      String? city = widget.member.future!.first.city ?? 'Select City';
      String? study = widget.member.future!.first.study ?? '';

      controller.classDegreeController.text = subject;
      controller.institutionController.text = institution;
      controller.selectedCity = city;
      controller.studyController.text = study;
    }

    controller.emailController.text = email ?? '';
    controller.phoneController.text = phone ?? '';
    controller.whatsappController.text = whatsapp ?? '';
  }

  void validateForm() {
    setState(() {
      controller.isButtonEnabled = controller.classDegreeController.text.isNotEmpty &&
          controller.institutionController.text.isNotEmpty &&
          controller.selectedCity != "Select City" &&
          controller.studyController.text.isNotEmpty &&
          controller.selectedSubject != "Select Subject" &&
          controller.yearController.text.isNotEmpty &&
          controller.emailController.text.isNotEmpty &&
          controller.phoneController.text.isNotEmpty &&
          controller.whatsappController.text.isNotEmpty &&
          controller.fundsController.text.isNotEmpty &&
          controller.descriptionController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    controller.classDegreeController.dispose();
    controller.institutionController.dispose();
    controller.studyController.dispose();
    controller.yearController.dispose();
    controller.emailController.dispose();
    controller.phoneController.dispose();
    controller.whatsappController.dispose();
    controller.fundsController.dispose();
    controller.descriptionController.dispose();
    super.dispose();
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