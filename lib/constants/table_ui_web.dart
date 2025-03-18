import 'package:flutter/material.dart';
import '../model/request_form_model.dart';

class ReqFormTableUI extends StatelessWidget {
  final List<RequestFormModel> requests;
  final ScrollController scrollController;
  final bool allowEditStatus;
  final Function(RequestFormModel, String) onStatusChanged;
  final Function(RequestFormModel) onViewDetails;

  const ReqFormTableUI({
    super.key,
    required this.requests,
    required this.scrollController,
    required this.allowEditStatus,
    required this.onStatusChanged,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    int totalRequests = requests.length;
    int totalAIUT = requests.where((r) => r.toJson()["organization"] == "AIUT").length;
    int totalSTSMF = requests.where((r) => r.toJson()["organization"] == "STSMF").length;
    int totalAMBT = requests.where((r) => r.toJson()["organization"] == "AMBT").length;
    int totalDeeni = requests
        .where((r) {
      String org = r.toJson()["organization"] ?? ""; // Ensure null safety
      return org.isNotEmpty && org != "AIUT" && org != "STSMF" && org != "AMBT";
    }).length;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: requests.isEmpty
          ? const Center(child: Text("No Request Data"))
          : Column(
        spacing: 10,
        children: [
          _buildStatsRow(
            totalRequests: totalRequests,
            totalAIUT: totalAIUT,
            totalSTSMF: totalSTSMF,
            totalAMBT: totalAMBT,
            totalDeeni: totalDeeni,
          ),
          _buildTableHeader(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 0,
                    spreadRadius: 1,
                    //offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.builder(
                controller: scrollController,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return _buildTableRow(context, requests[index], index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required int totalRequests,
    required int totalAIUT,
    required int totalSTSMF,
    required int totalAMBT,
    required int totalDeeni,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatBox(
          title: "Total Requests",
          value: totalRequests,
          icon: Icons.list,
          color: Colors.blue,
        ),
        _StatBox(
          title: "AIUT Requests",
          value: totalAIUT,
          icon: Icons.business,
          color: Colors.green,
        ),
        _StatBox(
          title: "STSMF Requests",
          value: totalSTSMF,
          icon: Icons.domain,
          color: Colors.orange,
        ),
        _StatBox(
          title: "AMBT Requests",
          value: totalAMBT,
          icon: Icons.domain,
          color: Colors.red,
        ),
        _StatBox(
          title: "Deeni Requests",
          value: totalAMBT,
          icon: Icons.domain,
          color: Colors.brown,
        ),
      ],
    );
  }

  /// **🔹 Custom Table Header**
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xffdbbb99),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: const [
          _TableHeaderCell(text: "S.#",flex: 1),
          _TableHeaderCell(text: "View",flex: 2),
          _TableHeaderCell(text: "Status",flex: 4),
          _TableHeaderCell(text: "ITS",flex:3 ),
          _TableHeaderCell(text: "Name",flex:5 ),
          _TableHeaderCell(text: "Contact",flex:3 ),
          _TableHeaderCell(text: "Organization",flex:3),
          _TableHeaderCell(text: "Funds",flex:3),
          _TableHeaderCell(text: "Mohalla",flex:5  ),
        ],
      ),
    );
  }

  /// **🔹 Custom Table Row**
  /// **🔹 Custom Table Row with Hover Effect**
  /// **🔹 Custom Table Row with Hover Effect**
  Widget _buildTableRow(BuildContext context, RequestFormModel req, int index) {
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: isHovered,
        builder: (context, hovered, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: hovered ? Colors.white : Color(0xfffff7ec),
              boxShadow: hovered
                  ? [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.4),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
                  : [],
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              borderRadius: BorderRadius.circular(hovered ? 8 : 0),
            ),
            child: Row(
              children: [
                _TableCell(text: (index + 1).toString(), flex: 1),
                _TableIconCell(
                  icon: Icons.remove_red_eye,
                  color: Colors.brown,
                  onTap: () => onViewDetails(req),
                  flex: 2,
                ),
                _TableCell(
                  flex: 4,
                  child: _statusBadge(req.currentStatus),
                ),
                _TableCell(text: req.toJson()["ITS"] ?? "", flex: 3),
                _TableCell(text: req.toJson()["reqByName"] ?? "", flex: 5),
                _TableCell(text: req.toJson()["contactNo"] ?? "", flex: 3),
                _TableCell(text: req.toJson()["organization"] ?? "", flex: 3),
                _TableCell(text: req.toJson()["fundAsking"].toString(), flex: 3),
                _TableCell(text: req.toJson()["mohalla"] ?? "", flex: 5),
              ],
            ),
          );
        },
      ),
    );
  }

  /// **🔹 Polished Status Badge UI**
  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            style: TextStyle(
              color: Colors.brown,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// **🔹 Custom Table Header Cell**
class _TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _TableHeaderCell({required this.text,required this.flex});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

/// **🔹 Custom Table Cell**
class _TableCell extends StatelessWidget {
  final String? text;
  final Widget? child;
  final int flex;

  const _TableCell({this.text, this.child, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          alignment: Alignment.center,
          child: child ??
              Text(
                textAlign: TextAlign.center,
                text ?? "",
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),
        ),
      ),
    );
  }
}

/// **🔹 Custom Table Icon Cell**
class _TableIconCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int flex;

  const _TableIconCell({
    required this.icon,
    required this.color, required this.onTap,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(icon, color: color),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Color(0xffffead1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}