import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';

class ModuleSelectionScreenM extends StatefulWidget {
  const ModuleSelectionScreenM({super.key});

  @override
  ModuleSelectionScreenState createState() => ModuleSelectionScreenState();
}

class ModuleSelectionScreenState extends State<ModuleSelectionScreenM> {
  final ModuleController controller = Get.find<ModuleController>();
  final GlobalStateController globalController =
      Get.find<GlobalStateController>();
  late final String its;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EC),
      appBar: AppBar(
        title: Text("Select a Module",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.modules.isEmpty) {
              return Center(child: Text("No modules available"));
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: 1,
                itemBuilder: (context, index) {
                  var module = controller.modules[index];
                  return GestureDetector(
                    onTap: () => module.onModuleOpen?.call(
                        module.featureIds,
                        globalController.userIts.value,
                        "KHI (AL-MAHALAT-TUL-BURHANIYAH)"),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffffead1),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            blurRadius: 2,
                            spreadRadius: 3,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(module.icon, style: TextStyle(fontSize: 40)),
                            SizedBox(height: 8),
                            Text(
                              module.moduleTitle, // Display module title
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          // Obx(() {
          //   if (controller.isLoading.value) {
          //     return Container(
          //       color: Colors.black.withValues(alpha: 0.5),
          //       child: Center(
          //         child: LoadingAnimationWidget.discreteCircle(
          //           color: Colors.white,
          //           size: 50,
          //         ),
          //       ),
          //     );
          //   }
          //   return const SizedBox.shrink();
          // }),
        ],
      ),
    );
  }
}
