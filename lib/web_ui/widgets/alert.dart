import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Alert extends StatelessWidget {
  final String title;
  final String subtitle;
  final String okText;
  final String cancelText;
  final VoidCallback onOk;
  final VoidCallback? onCancel;
  final bool preventBack;

  const Alert({
    super.key,
    this.title = "Fetching your document...",
    this.subtitle = "This may take 20–30 seconds. Please wait.",
    required this.onOk,
    this.onCancel,
    this.okText = "OK",
    this.cancelText = "Cancel",
    this.preventBack = false,
  });

  /// 🔘 Use this to show the dialog from anywhere
  static void show({
    String? title,
    String? subtitle,
    required VoidCallback onOk,
    VoidCallback? onCancel,
    String okText = "OK",
    String cancelText = "Cancel",
  }) {
    Get.dialog(
      Alert(
        title: title ?? "Fetching your document...",
        subtitle: subtitle ?? "This may take 20–30 seconds. Please wait.",
        onOk: onOk,
        onCancel: onCancel,
        okText: okText,
        cancelText: cancelText,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: const Color(0xffffead1),
      child: IntrinsicWidth(
        stepWidth: 120,
        child: Container(
          padding: const EdgeInsets.all(20),
          //margin: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
          child: Column(
            spacing: 25,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: onCancel==null ? MainAxisAlignment.center :MainAxisAlignment.spaceBetween,
                children: [
                  if (onCancel != null)
                    ElevatedButton(
                      onPressed: () {
                        if(preventBack) {
                          Get.back();
                        }
                        onCancel!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(cancelText,style: TextStyle(color: Colors.white),),
                    ),
                  if (onCancel != null) const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      onOk();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(okText, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}