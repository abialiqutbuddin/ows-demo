import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/state_management/state_manager.dart';
import '../../controller/update_paktalim_controller.dart';

class MarhalaEducationCarousel extends StatefulWidget {
  final UpdatePaktalimController controller;
  final GlobalStateController globalStateController;

  const MarhalaEducationCarousel({
    super.key,
    required this.controller,
    required this.globalStateController,
  });

  @override
  State<MarhalaEducationCarousel> createState() =>
      _MarhalaEducationCarouselState();
}

class _MarhalaEducationCarouselState extends State<MarhalaEducationCarousel> {
  final ScrollController _scrollController = ScrollController();

  void scrollBy(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedId = widget.controller.selectedMarhala2.value?['id'];
      if (selectedId == null) return const SizedBox();

      final allEducation =
          widget.globalStateController.user.value.education ?? [];

      final filtered = allEducation
          .where((edu) => selectedId == 1
          ? [1, 2, 3].contains(edu.marhalaId)
          : edu.marhalaId == selectedId)
          .toList()
        ..sort((a, b) =>
        DateTime.tryParse(b.startDate ?? '')?.compareTo(
            DateTime.tryParse(a.startDate ?? '') ?? DateTime(1900)) ??
            0);

      if (filtered.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            "No education record found for selected Marhala${selectedId == 1 ? 's (1-3)' : ''}.",
            style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🎓 Education Details (Selected Marhala)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () => scrollBy(-300),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showCenter = filtered.length <= 2;
                    return SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: Align(
                          alignment:
                          showCenter ? Alignment.center : Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: filtered.reversed.map((edu) {
                              return Container(
                                width: 320,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFCF6),
                                  border: Border.all(color: Colors.brown.shade200),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    )
                                  ],
                                ),
                                child: Column(
                                  spacing: 3,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("🏫 Class: ${edu.className ?? '-'}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,fontSize: 12)),
                                    Text("📅 ${edu.startDate ?? '-'} → ${edu.endDate ?? '-'}",style: TextStyle(fontSize: 12)),
                                    if ((edu.institute ?? '').isNotEmpty) ...[
                                      Text("🏛 Institute: ${edu.institute}",style: TextStyle(fontSize: 12)),
                                    ],
                                    if ((edu.subject ?? '').isNotEmpty) ...[
                                      Text("📘 Subject: ${edu.subject}",style: TextStyle(fontSize: 12),),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () => scrollBy(300),
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.brown),
              ),
            ],
          ),
          SizedBox(height: 10,)
        ],
      );
    });
  }
}