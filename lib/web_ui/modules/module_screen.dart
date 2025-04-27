import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/controller/admin/view_req_forms.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/web_ui/widgets/view_requests_web.dart';

class ModuleSelectionScreenW extends StatefulWidget {
  const ModuleSelectionScreenW({super.key});

  @override
  ModuleSelectionScreenState createState() => ModuleSelectionScreenState();
}

class ModuleSelectionScreenState extends State<ModuleSelectionScreenW> {
  ModuleController controller = Get.find<ModuleController>();
  GlobalStateController statecontroller = Get.find<GlobalStateController>();
  final ReqFormController reqFormController = Get.find<ReqFormController>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFilteredRequests();
  }

  Future<void> fetchFilteredRequests() async {
    setState(() => _isLoading = true);
    try {
      await reqFormController.fetchRequests('ALL', '', '30445124', 'admin');
    } catch (e) {
      Get.snackbar("Error", "Failed to load data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modules = controller.modules;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EC),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0, left: 15, bottom: 10),
                child: const Text(
                  "Dashboard",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.black87),
                ),
              ),
              Row(
                children: modules.map((module) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: SizedBox(
                      width: 350,
                      height: 200,
                      child: _buildModuleCard(module),
                    ),
                  );
                }).toList(),
              ),
              Expanded(
                child: ReqFormTableUI(
                  requests: reqFormController.reqForms,
                  scrollController: _scrollController,
                  allowEditStatus: false,
                  onStatusChanged: (req, newStatus) {
                    // if (widget.featureIds.contains(7)) {
                    //   _showStatusChangeDialog(req, widget.featureIds);
                    // }
                  },
                  onViewDetails: (req) {
                    // _showRequestDetailsPopup(
                    //     context, req, widget.featureIds.contains(7));
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(dynamic module) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => module.isHovered = true),
      onExit: (_) => setState(() => module.isHovered = false),
      child: GestureDetector(
        onTap: () => module.onModuleOpen?.call(module.featureIds,
            statecontroller.userIts.value, "KHI (AL-MAHALAT-TUL-BURHANIYAH)"),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: module.isHovered
                ? const Color(0xFFFFDDC1)
                : const Color(0xFFFFEAD1), // Hover Effect
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                spreadRadius: 1,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7), // Glass effect
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child:
                      Text(module.icon, style: const TextStyle(fontSize: 50)),
                ),
                const SizedBox(height: 12),
                Text(
                  module.moduleTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  Widget buildRequestsTable(BuildContext context) {
    return ReqFormTableUI(
        requests: reqFormController.reqForms,
        scrollController: _scrollController,
        allowEditStatus: false,
        onStatusChanged: (req, newStatus) {
          // if (widget.featureIds.contains(7)) {
          //   _showStatusChangeDialog(req, widget.featureIds);
          // }
        },
        onViewDetails: (req) {
          //   _showRequestDetailsPopup(
          //       context, req, widget.featureIds.contains(7));
          // },
        });
  }
}
