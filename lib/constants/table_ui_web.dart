import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_table_view/material_table_view.dart';
import '../model/request_form_model.dart';

class ReqFormTableUI extends StatelessWidget {
  final List<RequestFormModel> requests;
  final Map<String, String> columnNames;
  final Map<String, double> columnWidths;
  final ScrollController scrollController;
  final bool allowEditStatus;
  final Function(RequestFormModel, String) onStatusChanged;

  const ReqFormTableUI({
    super.key,
    required this.requests,
    required this.columnNames,
    required this.columnWidths,
    required this.scrollController,
    required this.allowEditStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3), // Subtle shadow
          ),
        ],
      ),
      child: requests.isEmpty ? Center(child: Text("No Request Data")) :
      CupertinoScrollbar(
        child: SingleChildScrollView(
          primary: true,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: columnWidths.values.reduce((a, b) => a + b),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: columnNames.values.map((title) {
                      return Container(
                        width: columnWidths[columnNames.keys.firstWhere((key) => columnNames[key] == title)] ?? 150,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade400, width: 0.8),
                            bottom: BorderSide(color: Colors.grey.shade500, width: 1),
                          ),
                        ),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: TableView.builder(
                    columns: [
                      for (String field in columnNames.keys)
                        TableColumn(width: columnWidths[field] ?? 150),
                    ],
                    rowCount: requests.length,
                    rowHeight: 56.0,
                    rowBuilder: (context, row, contentBuilder) {
                      final req = requests[row];
                              
                      return MouseRegion(
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            child: contentBuilder(
                              context,
                                  (context, column) {
                                String field = columnNames.keys.elementAt(column);
                              
                                // ✅ Fix Serial Number (S.#) starting from 1
                                if (field == "sNo") {
                                  return Text(
                                    (row + 1).toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  );
                                }
                              
                                // ✅ Status Badge with Click Event
                                if (field == "currentStatus") {
                                  return GestureDetector(
                                    onTap: allowEditStatus ? () => onStatusChanged(req, req.currentStatus) : null,
                                    child: _statusBadge(req.currentStatus),
                                  );
                                }
                              
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  child: Text(
                                    req.toJson()[field]?.toString() ?? "",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **🔹 Polished Status Badge UI**
  Widget _statusBadge(String status) {
    Color badgeColor;
    Color borderColor;
    IconData statusIcon;

    switch (status) {
      case "Approved":
        badgeColor = Colors.green.shade50;
        borderColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "Denied":
        badgeColor = Colors.red.shade50;
        borderColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case "Pending":
        badgeColor = Colors.orange.shade50;
        borderColor = Colors.orange;
        statusIcon = Icons.hourglass_bottom;
        break;
      case "Payment Released":
        badgeColor = Colors.blue.shade50;
        borderColor = Colors.blue;
        statusIcon = Icons.payments;
        break;
      default:
        badgeColor = Colors.grey.shade200;
        borderColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: borderColor, size: 16),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: borderColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}