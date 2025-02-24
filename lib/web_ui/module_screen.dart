import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ows/controller/module_controller.dart';
import 'package:ows/controller/state_management/state_manager.dart';

class ModuleSelectionScreenW extends StatefulWidget {
  final String its;

  const ModuleSelectionScreenW({super.key, required this.its});

  @override
  ModuleSelectionScreenState createState() => ModuleSelectionScreenState();
}

class ModuleSelectionScreenState extends State<ModuleSelectionScreenW> {
  final ModuleController controller = Get.find<ModuleController>();
  final GlobalStateController statecontroller = Get.find<GlobalStateController>();
  late final String its;

  @override
  void initState() {
    super.initState();
    its = widget.its;
    controller.fetchModules(its);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EC),
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87),
        ),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              if (controller.modules.isEmpty) {
                return const Center(
                  child: Text(
                    "No modules available",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Fixed for Desktop
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.4,
                ),
                itemCount: controller.modules.length,
                itemBuilder: (context, index) {
                  var module = controller.modules[index];
                  return _buildModuleCard(module);
                },
              );
            }),
          ),
          // Loading Animation Overlay
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withValues(alpha: 0.2),
                child: Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
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
        onTap: () => module.onModuleOpen?.call(module.featureIds, statecontroller.userIts.value,"KHI (AL-MAHALAT-TUL-BURHANIYAH)"),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: module.isHovered ? const Color(0xFFFFDDC1) : const Color(0xFFFFEAD1), // Hover Effect
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(4, 4),
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
                  child: Text(module.icon, style: const TextStyle(fontSize: 50)),
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
}