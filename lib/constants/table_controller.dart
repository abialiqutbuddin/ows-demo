import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/constants/table_ui_web.dart';
import '../api/api.dart';
import '../controller/admin/view_req_forms.dart';
import '../model/request_form_model.dart';

class ReqFormTable extends StatefulWidget {
  final String mohalla;
  final String org;
  final List<int> featureIds;

  const ReqFormTable({super.key, required this.mohalla,required this.org, required this.featureIds});

  @override
  _ReqFormTableState createState() => _ReqFormTableState();
}

class _ReqFormTableState extends State<ReqFormTable> {
  final ReqFormController reqFormController = Get.find<ReqFormController>();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;


  final Map<String, String> columnNames = {
    "sNo": "S.#",  // ✅ This will be generated dynamically
    "organization": "Organization",
    "currentStatus": "Status",
    "ITS": "ITS No",
    "reqByITS": "Requested By (ITS)",
    "reqByName": "Requested By (Name)",
    "city": "City",
    "institution": "Institution",
    "class_degree": "Class / Degree",
    "fieldOfStudy": "Field of Study",
    "subject_course": "Subject / Course",
    "yearOfStart": "Year of Start",
    "grade": "Grade",
    "email": "Email",
    "contactNo": "Contact No",
    "whatsappNo": "WhatsApp No",
    "purpose": "Purpose",
    "fundAsking": "Fund Asking",
    "description": "Description",
    "mohalla": "Mohalla"
  };

  Map<String, double> columnWidths = {};

  @override
  void initState() {
    super.initState();
    fetchFilteredRequests();
  }

  Future<void> fetchFilteredRequests() async {
    setState(() => _isLoading = true);
    try {
      await reqFormController.fetchRequests(widget.mohalla,widget.org);
      _calculateColumnWidths();
    } catch (e) {
      Get.snackbar("Error", "Failed to load data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateColumnWidths() {
    columnWidths.clear();
    for (String field in columnNames.keys) {
      double maxWidth = field.length * 10.0;
      for (var req in reqFormController.reqForms) {
        String value = req.toJson()[field]?.toString() ?? "";
        double calculatedWidth = value.length * 8.0;
        if (calculatedWidth > maxWidth) maxWidth = calculatedWidth;
      }
      columnWidths[field] = maxWidth + 20;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Requests - ${widget.mohalla}"), backgroundColor: Colors.teal),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ReqFormTableUI(
        requests: reqFormController.reqForms,
        columnNames: columnNames,
        columnWidths: columnWidths,
        scrollController: _scrollController,
        allowEditStatus: widget.featureIds.contains(7),
        onStatusChanged: (req, newStatus) {
          if(widget.featureIds.contains(7)){
          _showStatusChangeDialog(req,widget.featureIds);
          }
        },
      ),
    );
  }

  void _showStatusChangeDialog(RequestFormModel request, List<int> featureIds) {
    if (!featureIds.contains(7)) {
      Get.snackbar("Access Denied", "You do not have permission to change the status.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return; // ❌ Prevents the dialog from opening if user doesn't have permission
    }

    List<String> statusOptions = [
      "Request Generated",
      "Request Received",
      "Request Denied",
      "Request Pending",
      "Request Approved",
      "Application Applied",
      "Application Denied",
      "Application Pending",
      "Application Approved",
      "Payment in Process",
      "First Payment Done"
    ];

    String selectedStatus = request.currentStatus.isNotEmpty
        ? request.currentStatus
        : statusOptions.first; // ✅ Default to first status if empty

    Get.defaultDialog(
      title: "Change Status",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      backgroundColor: Colors.white,
      radius: 10,
      content: StatefulBuilder(
        builder: (context, setStateDialog) { // 👈 Manages UI inside dialog
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                items: statusOptions
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                    .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setStateDialog(() {
                      selectedStatus = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  bool success = await Api.updateRequestStatus(request.reqId!, selectedStatus);
                  if (success) {
                    Get.back(); // Close dialog

                    /// ✅ **Update the UI immediately**
                    request.currentStatus = selectedStatus; // Update status

                    setState(() {

                    });

                    Get.snackbar("Success", "Status updated successfully!",
                        backgroundColor: Colors.green, colorText: Colors.white);
                  } else {
                    Get.snackbar("Error", "Failed to update status. Try again.",
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

}