import 'package:flutter/material.dart';
import 'package:ows/api/api.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  TableScreenState createState() => TableScreenState();
}

class TableScreenState extends State<TableScreen> {
  List<Map<String, dynamic>> requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    List<Map<String, dynamic>> data = await Api.fetchRequests();
    setState(() {
      requests = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Requests List"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : requests.isEmpty
            ? Center(child: Text("No Requests Found"))
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              border: TableBorder.all(color: Colors.grey.shade300),
              columns: [
                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ITS', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Req By Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('City', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Institution', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Contact No', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Funds Request', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: requests.map((request) {
                return DataRow(
                  cells: [
                    DataCell(Text(request["reqId"].toString())),
                    DataCell(Text(request["ITS"] ?? "N/A")),
                    DataCell(Text(request["reqByName"] ?? "N/A")),
                    DataCell(Text(request["city"] ?? "N/A")),
                    DataCell(Text(request["institution"] ?? "N/A")),
                    DataCell(Text(request["email"] ?? "N/A")),
                    DataCell(Text(request["contactNo"] ?? "N/A")),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: request["currentStatus"] == "Approved"
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          request["currentStatus"] ?? "Pending",
                          style: TextStyle(
                            color: request["currentStatus"] == "Approved" ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(request["fundAsking"] ?? "N/A")),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}