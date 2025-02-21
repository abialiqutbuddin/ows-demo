import 'package:get/get.dart';

import '../../api/api.dart';
import '../../model/request_form_model.dart';

class ReqFormController extends GetxController {
  var isLoading = false.obs;
  var reqForms = <RequestFormModel>[].obs;
  var errorMessage = ''.obs;

  // ✅ List of all available fields
  final List<String> allFields = [
    'reqId', 'reqByName', 'city', 'mohalla', 'institution', 'fieldOfStudy',
    'subjectCourse', 'yearOfStart', 'grade', 'email', 'contactNo', 'purpose',
    'fundAsking', 'classification', 'organization', 'description', 'currentStatus'
  ].obs;

  // ✅ List of selected fields (Default selection)
  var selectedFields = [
    'reqId', 'reqByName', 'city', 'mohalla', 'institution', 'fieldOfStudy',
    'subjectCourse', 'yearOfStart', 'grade', 'email', 'contactNo', 'purpose',
    'fundAsking', 'classification', 'organization', 'description', 'currentStatus'
  ].obs;

  // ✅ Fetch Requests by Mohalla
  Future<void> fetchRequests(String mohalla) async {
    //isLoading(true);
    errorMessage('');
    try {
      var results = await Api.fetchRequestsByMohalla(mohalla);
      print(results);
      reqForms.assignAll(results);
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      //isLoading(false);
    }
  }

  // ✅ Update Status
  Future<void> updateStatus(int reqId, String newStatus) async {
    bool success = await Api.updateRequestStatus(reqId, newStatus);
    if (success) {
      reqForms[reqForms.indexWhere((r) => r.reqId == reqId)] =
          reqForms.firstWhere((r) => r.reqId == reqId)
              .copyWith(currentStatus: newStatus);
      reqForms.refresh();
    }
  }

  // ✅ Toggle field selection
  void toggleField(String field) {
    if (selectedFields.contains(field)) {
      selectedFields.remove(field);
    } else {
      selectedFields.add(field);
    }
  }
}