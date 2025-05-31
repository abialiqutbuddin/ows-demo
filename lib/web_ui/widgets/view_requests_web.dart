import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/api/api.dart';
import 'package:ows/constants/app_routes.dart';
import '../../controller/state_management/state_manager.dart';
import '../../model/request_form_model.dart';

GlobalStateController statecontroller = Get.find<GlobalStateController>();

class ReqFormResponsiveUI extends StatelessWidget {
  final List<RequestFormModel> requests;
  final ScrollController scrollController;
  final Function(RequestFormModel) onEditForms;
  final Function(RequestFormModel) onViewPdf;

  const ReqFormResponsiveUI({
    super.key,
    required this.requests,
    required this.scrollController,
    required this.onViewPdf,
    required this.onEditForms,
  });

  // If you still need admin‐only stats, keep admin toggle:
  final bool admin = false;

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to switch between table (desktop) and card (mobile)
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    if (isMobile) {
      return _buildMobileCardList();
    } else {
      return _buildTableView();
    }
  }

  /// ─── MOBILE CARD VIEW ─────────────────────────────────────────────────────
  Widget _buildMobileCardList() {
    if (requests.isEmpty) {
      return const Center(child: Text("No Request Data"));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Index + Action Icons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Serial number
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      // Edit icon
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF795548)),
                        onPressed: () async {
                          if (req.appId == null) {
                            if (req.draftId != null) {
                              statecontroller.draftId.value = req.draftId!;
                              statecontroller.reqId.value = req.reqId!;
                              statecontroller.intentCompleted.value = true;
                              Get.toNamed(AppRoutes.application_form);
                            } else {
                              int? draftId =
                              await Api.createDraftAndGetId(req.reqId!);
                              statecontroller.draftId.value = draftId!;
                              statecontroller.reqId.value = req.reqId!;
                              statecontroller.intentCompleted.value = true;
                              Get.toNamed(AppRoutes.application_form);
                            }
                          }
                        },
                        tooltip: "Edit",
                      ),
                      // View icon
                      IconButton(
                        icon:
                        const Icon(Icons.remove_red_eye, color: Color(0xFF795548)),
                        onPressed: () => onViewPdf(req),
                        tooltip: "View PDF",
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Status Badge
                  Align(
                    alignment: Alignment.centerRight,
                    child: _statusBadge(req.currentStatus),
                  ),

                  const SizedBox(height: 12),

                  // Details: ITS, Name, Contact, Organization, Funds, Mohalla
                  _buildDetailRow("ITS", req.toJson()["ITS"] ?? ""),
                  _buildDetailRow("Name", req.toJson()["reqByName"] ?? ""),
                  _buildDetailRow("Contact", req.toJson()["contactNo"] ?? ""),
                  _buildDetailRow("Organization", req.toJson()["organization"] ?? ""),
                  _buildDetailRow(
                    "Funds",
                    req.toJson()["fundAsking"].toString(),
                  ),
                  _buildDetailRow("Mohalla", req.toJson()["mohalla"] ?? ""),

                  // (Optional) Add spacing between cards
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$label:",
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

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
            style: const TextStyle(
              color: Colors.brown,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ─── DESKTOP TABLE VIEW (EXISTING) ────────────────────────────────────────
  Widget _buildTableView() {
    int totalRequests = requests.length;
    int totalAIUT =
        requests.where((r) => r.toJson()["organization"] == "AIUT").length;
    int totalSTSMF =
        requests.where((r) => r.toJson()["organization"] == "STSMF").length;
    int totalAMBT =
        requests.where((r) => r.toJson()["organization"] == "AMBT").length;
    int totalDeeni = requests.where((r) {
      String org = r.toJson()["organization"] ?? "";
      return org.isNotEmpty &&
          org != "AIUT" &&
          org != "STSMF" &&
          org != "AMBT";
    }).length;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (admin == true)
            _buildStatsRow(
              totalRequests: totalRequests,
              totalAIUT: totalAIUT,
              totalSTSMF: totalSTSMF,
              totalAMBT: totalAMBT,
              totalDeeni: totalDeeni,
            ),
          _buildTableHeader(),
          requests.isEmpty
              ? const Center(child: Text("No Request Data"))
              : Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 0,
                    spreadRadius: 1,
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
          value: totalDeeni,
          icon: Icons.domain,
          color: Colors.brown,
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xffdbbb99),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: const [
          _TableHeaderCell(text: "S.#", flex: 1),
          _TableHeaderCell(text: "Actions", flex: 3),
          _TableHeaderCell(text: "Status", flex: 4),
          _TableHeaderCell(text: "ITS", flex: 3),
          _TableHeaderCell(text: "Name", flex: 5),
          _TableHeaderCell(text: "Contact", flex: 3),
          _TableHeaderCell(text: "Organization", flex: 3),
          _TableHeaderCell(text: "Funds", flex: 3),
          _TableHeaderCell(text: "Mohalla", flex: 5),
        ],
      ),
    );
  }

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
              color: hovered ? Colors.white : const Color(0xfffff7ec),
              boxShadow: hovered
                  ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
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
                _TableCell(
                  flex: 3,
                  child: Row(
                    children: [
                      Flexible(
                        child: _TableIconCell(
                          icon: Icons.edit,
                          color: const Color(0xFF795548),
                          onTap: () async {
                            if (req.appId == null) {
                              if (req.draftId != null) {
                                statecontroller.draftId.value = req.draftId!;
                                statecontroller.reqId.value = req.reqId!;
                                statecontroller.intentCompleted.value = true;
                                Get.toNamed(AppRoutes.application_form);
                              } else {
                                int? draftId =
                                await Api.createDraftAndGetId(req.reqId!);
                                statecontroller.draftId.value = draftId!;
                                statecontroller.reqId.value = req.reqId!;
                                statecontroller.intentCompleted.value = true;
                                Get.toNamed(AppRoutes.application_form);
                              }
                            }
                          },
                          flex: 1,
                        ),
                      ),
                      Flexible(
                        child: _TableIconCell(
                          icon: Icons.remove_red_eye,
                          color: const Color(0xFF795548),
                          onTap: () {},
                          flex: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                _TableCell(flex: 4, child: _statusBadge(req.currentStatus)),
                _TableCell(text: req.toJson()["ITS"] ?? "", flex: 3),
                _TableCell(text: req.toJson()["reqByName"] ?? "", flex: 5),
                _TableCell(text: req.toJson()["contactNo"] ?? "", flex: 3),
                _TableCell(text: req.toJson()["organization"] ?? "", flex: 3),
                _TableCell(
                  text: req.toJson()["fundAsking"].toString(),
                  flex: 3,
                ),
                _TableCell(text: req.toJson()["mohalla"] ?? "", flex: 5),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _TableHeaderCell({required this.text, required this.flex});

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
                text ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),
        ),
      ),
    );
  }
}

class _TableIconCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int flex;

  const _TableIconCell({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
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
          color: const Color(0xffffead1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}