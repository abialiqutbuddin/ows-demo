import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/table.dart';
import '../../controller/admin/view_req_forms.dart';

class UsersByMohallaScreen extends StatelessWidget {
  final TextEditingController _mohallaController = TextEditingController();
  final ReqFormController reqFormController = Get.put(ReqFormController());

  @override
  Widget build(BuildContext context) {
    return ReqFormTable(mohalla: 'KHI (AL-MAHALAT-TUL-BURHANIYAH)',);

  }

  // ✅ Show Filter Dialog
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Fields to Display"),
          content: Obx(() {
            return SingleChildScrollView(
              child: Column(
                children: reqFormController.allFields.map((field) {
                  return CheckboxListTile(
                    title: Text(field),
                    value: reqFormController.selectedFields.contains(field),
                    onChanged: (bool? value) {
                      reqFormController.toggleField(field);
                    },
                  );
                }).toList(),
              ),
            );
          }),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () => Get.back(),
            ),
          ],
        );
      },
    );
  }
}