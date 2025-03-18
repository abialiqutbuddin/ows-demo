import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/constants/constants.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool showLoading;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    this.onCancel,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Color(0xffffead1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Optional Loading Indicator
              if (showLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: CircularProgressIndicator(),
                ),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (cancelText != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: onCancel ?? () => Get.back(),
                      child: Text(
                        cancelText!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants().green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: onConfirm,
                    child: Text(
                      confirmText,
                      style: const TextStyle(color: Colors.white),
                    ),
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

// Usage Example:
void showCustomDialog({
  required String title,
  required String message,
  required String confirmText,
  String? cancelText,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  bool showLoading = false,
}) {
  Get.dialog(
    CustomDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      showLoading: showLoading,
    ),
    barrierDismissible: true, // Allow dismissing the dialog
  );
}