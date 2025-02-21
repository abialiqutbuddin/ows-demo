import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/admin/view_req_forms.dart';
import '../model/request_form_model.dart';

class ReqFormTable extends StatefulWidget {
  final String mohalla;

  const ReqFormTable({Key? key, required this.mohalla}) : super(key: key);

  @override
  _ReqFormTableState createState() => _ReqFormTableState();
}

class _ReqFormTableState extends State<ReqFormTable> {
  final ReqFormController reqFormController = Get.put(ReqFormController());

  @override
  void initState() {
    super.initState();
    fetchFilteredRequests();
  }

  // 🔹 Fetch Requests Based on Mohalla
  Future<void> fetchFilteredRequests() async {
    setState(() {
      reqFormController.isLoading.value = true;
    });

    await reqFormController.fetchRequests(widget.mohalla);

    setState(() {
      reqFormController.isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Request Table ${widget.mohalla}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87),
        ),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            // ✅ Table Header
            Container(
              padding: EdgeInsets.all(10),
              color: const Color(0xFF008759),
              child: Center(
                child: Text(
                  "Request Forms (${widget.mohalla})",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

            // ✅ Show Loading Indicator While Fetching Data
            Obx(() {
              if (reqFormController.isLoading.value) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (reqFormController.reqForms.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                );
              }

              return Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columnWidths: {
                        0: FixedColumnWidth(50.0),
                        for (var i = 1; i <= reqFormController.selectedFields.length; i++)
                          i: IntrinsicColumnWidth(),
                      },
                      children: [
                        // ✅ Header Row
                        TableRow(
                          decoration: BoxDecoration(color: const Color(0xffffead1)),
                          children: [
                            _tableHeaderCell("#"),
                            for (var field in reqFormController.selectedFields)
                              _tableHeaderCell(field.toUpperCase()),
                            _tableHeaderCell("ACTIONS"),
                          ],
                        ),

                        // ✅ Data Rows
                        for (var i = 0; i < reqFormController.reqForms.length; i++)
                          _buildTableRow(reqFormController.reqForms[i], i, context),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ✅ Header Cell Widget
  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
      ),
    );
  }

  // ✅ Row Builder with Status Clickable
  TableRow _buildTableRow(RequestFormModel req, int index, BuildContext context) {
    return TableRow(
      decoration: BoxDecoration(
        color: index.isEven ? const Color(0xfffffcf6) : const Color(0xffffead1),
      ),
      children: [
        _tableCell("${index + 1}"), // Row Number
        for (var field in reqFormController.selectedFields)
          field == "currentStatus"
              ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showUpdateStatusDialog(context, req),
              child: _statusBadge(req.currentStatus ?? 'N/A'),
            ),
          )
              : _tableCell(_getFieldValue(req, field)),

        // ✅ Update Status Button
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            ),
            onPressed: () => _showUpdateStatusDialog(context, req),
            child: Text("Update", style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  // ✅ Standard Cell Widget
  Widget _tableCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
    );
  }

  // ✅ Extract Field Value
  String _getFieldValue(RequestFormModel req, String field) {
    switch (field) {
      case "reqId":
        return req.reqId?.toString() ?? "N/A";
      case "reqByName":
        return req.reqByName ?? "N/A";
      case "city":
        return req.city ?? "N/A";
      case "mohalla":
        return req.mohalla ?? "N/A";
      case "institution":
        return req.institution ?? "N/A";
      case "fieldOfStudy":
        return req.fieldOfStudy ?? "N/A";
      case "subjectCourse":
        return req.subjectCourse ?? "N/A";
      case "yearOfStart":
        return req.yearOfStart ?? "N/A";
      case "grade":
        return req.grade ?? "N/A";
      case "email":
        return req.email ?? "N/A";
      case "contactNo":
        return req.contactNo ?? "N/A";
      case "purpose":
        return req.purpose ?? "N/A";
      case "fundAsking":
        return req.fundAsking ?? "N/A";
      case "classification":
        return req.classification ?? "N/A";
      case "organization":
        return req.organization ?? "N/A";
      case "description":
        return req.description ?? "N/A";
      case "currentStatus":
        return req.currentStatus ?? "N/A";
      default:
        return "N/A";
    }
  }

  // ✅ Status Badge Widget (Clickable)
  Widget _statusBadge(String status) {
    return Container(
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue),
      ),
      child: Text(status, style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // ✅ Status Update Dialog
  void _showUpdateStatusDialog(BuildContext context, RequestFormModel req) {
    String selectedStatus = req.currentStatus;
    bool isUpdated = false;

    List<String> statusOptions = {
      "Request Generated",
      "Request Approved",
      "Application Approved",
      "Request Denied",
      "Application Denied",
      "Payment in Process",
      "First Payment Done",
    }.toList();  // ✅ Removes duplicates

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Update Status"),
              content: DropdownButton<String>(
                isExpanded: true,
                value: statusOptions.contains(selectedStatus) ? selectedStatus : null,  // ✅ Fix issue
                hint: Text("Select Status"),
                items: statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                    isUpdated = true;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isUpdated
                      ? () async {
                    await reqFormController.updateStatus(req.reqId!, selectedStatus);
                    Navigator.pop(context);
                    fetchFilteredRequests();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Update", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}