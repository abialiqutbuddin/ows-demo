import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/controller/admin/view_req_forms.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/web_ui/application_forms/application_form_web.dart';
import 'package:ows/web_ui/widgets/view_requests_web.dart';

import '../../api/api.dart';
import '../../constants/app_routes.dart';
import '../../constants/constants.dart';
import '../../constants/custom_dialog.dart';
import '../../constants/more_student_info.dart';
import '../../model/module_model.dart';
import '../../model/request_form_model.dart';
import '../widgets/show_instructions_dialog.dart';

class ModuleSelectionScreenW extends StatefulWidget {
  const ModuleSelectionScreenW({super.key});

  @override
  ModuleSelectionScreenState createState() => ModuleSelectionScreenState();
}

class ModuleSelectionScreenState extends State<ModuleSelectionScreenW> {
  ModuleController controller = Get.find<ModuleController>();
  GlobalStateController statecontroller = Get.find<GlobalStateController>();
  final ReqFormController reqFormController = Get.find<ReqFormController>();
  bool _isLoading = false;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    fetchFilteredRequests();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(statecontroller.devMode.value!=true){
        checkForActions();
      }
      //showInstructionsDialog();
    });
  }

  Future<void> checkForActions() async {
    bool error = false;
    String title = "";
    String message = "";
    String confirmText = "";
    String? cancelText;
    Function? onConfirm;
    Function? onCancel;

    //profileComplete = false;
    // profileComplete = true;
    //familyComplete = true;

    if (!statecontroller.profileComplete.value) {
      title = "Profile Incomplete";
      message = "Please update your profile";
      confirmText = "Update Profile";
      cancelText = "Cancel";
      onCancel = () {
        Get.back();
      };
      onConfirm = () {
        Get.back();
        Get.toNamed(AppRoutes.profile_preview);
      };
      error = true;
    }

    if (!statecontroller.profileComplete.value && !statecontroller.familyProfileComplete.value) {
      title = "Self and Family Profile Incomplete";
      message = "Please update your and your family profile";
      confirmText = "Update My Profile";
      cancelText = "Cancel";
      onCancel = () {
        Get.back();
      };
      onConfirm = () {
        Get.back();
        Get.toNamed(AppRoutes.profile_preview);
      };
      error = true;
    }

    if (!statecontroller.familyProfileComplete.value && statecontroller.profileComplete.value) {
      title = "Family Data Incomplete";
      message = "Please update your family education data on Pak Talim";
       cancelText = "Cancel";
      onCancel = () {
        Get.back();
      };
      error = true;
    }

    if (!error) {
      title = "You are eligble to fill Imdad Talimi Application!";
      message =
          "Click on Education Assistance Icon for Imdad Talimi Application";
      confirmText = "Okay";
      onConfirm = () {
        Get.back();
      };
    }

    Get.dialog(CustomDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: () => onConfirm!(),
      onCancel: () => onCancel!(),
    ));
  }

  Future<void> fetchFilteredRequests() async {
    setState(() => _isLoading = true);

    try {
      // Ensure user is set in state
      if (statecontroller.user.value.itsId == null) {
        final userData = box.read('user');

        if (userData == null) {
          throw Exception("User data not found in storage");
        }

        final user = UserProfile.fromJson(userData);
        statecontroller.user.value = user;
      }
    } catch (e, stackTrace) {
      debugPrint("fetchFilteredRequests error: $e");
      debugPrintStack(stackTrace: stackTrace);
      Get.snackbar("Error", "An error occurred. Please login again");
      Get.offAllNamed(
          AppRoutes.login); // more secure than pushing another login
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modules = controller.modules;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EC),
      body: Stack(
        children: [
          _isLoading == true
              ? Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    size: 80,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          top: 20.0, left: 15, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Dashboard",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Colors.black87),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Row(
                              children: [
                                Text(
                                  //"Abiali",
                                  stateController.user.value.fullName
                                      .toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black87),
                                ),
                                Text(
                                  " | ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black87),
                                ),
                                Text(
                                  //"30445124",
                                  stateController.user.value.itsId.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black87),
                                ),
                                SizedBox(width: 15),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        side: BorderSide(
                                            color: const Color(0xFF008759),
                                            width: 2),
                                      ),
                                    ),
                                    elevation: WidgetStateProperty.all(0),
                                  ),
                                  onPressed: () => Get.back(),
                                  child: Text("Back",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: modules.map((module) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: SizedBox(
                            width: 350,
                            height: 120,
                            child: _buildModuleCard(module),
                          ),
                        );
                      }).toList(),
                    ),
                    Expanded(
                      child: ReqFormResponsiveUI(
                        requests: reqFormController.reqForms,
                        scrollController: _scrollController,
                        onViewPdf: (req) {
                          // if (widget.featureIds.contains(7)) {
                          //   _showStatusChangeDialog(req, widget.featureIds);
                          // }
                        },
                        onEditForms: (req) {
                          _showRequestDetailsPopup(context, req, false);
                        },
                      ),
                    )
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(ModuleModel module) {
    var isEnabled = module.isEnabled;
    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isEnabled) setState(() => module.isHovered = true);
      },
      onExit: (_) {
        if (isEnabled) setState(() => module.isHovered = false);
      },
      child: GestureDetector(
        onTap:
        //module.onModuleOpen,
        isEnabled ? module.onModuleOpen : null,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: module.isHovered
                    ? const Color(0xFFFFDDC1)
                    : const Color(0xFFFFEAD1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // Left Icon Section
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            module.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Text Content
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module.moduleTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (module.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    module.subtitle!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  if (module.note != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      module.note!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Constants().green,
                                        //fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                            if (module.profileText! == true)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Self Complete: ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        "${module.profileComplete}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Constants().green),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Family Complete: ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        "${module.familyComplete}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Constants().green),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isEnabled)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  // Widget buildRequestsTable(BuildContext context) {
  //   return ReqFormTableUI(
  //       requests: reqFormController.reqForms,
  //       scrollController: _scrollController,
  //       onStatusChanged: (req, newStatus) {
  //         // if (widget.featureIds.contains(7)) {
  //         //   _showStatusChangeDialog(req, widget.featureIds);
  //         // }
  //       },
  //       onViewDetails: (req) {
  //         _showRequestDetailsPopup(context, req, false);
  //       });
  // }

  void _showRequestDetailsPopup(
      BuildContext context, RequestFormModel req, bool allowEdit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Adds rounded corners
          ),
          insetPadding:
              const EdgeInsets.all(20), // Controls padding around the popup
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.95, // 95% of screen width
            height: MediaQuery.of(context).size.height *
                0.95, // 95% of screen height
            padding:
                const EdgeInsets.all(16), // Inner padding inside the dialog
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: MoreStudentInfo(
              req: req,
              allowEdit: allowEdit,
            ),
          ),
        );
      },
    );
  }
}
