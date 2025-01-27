import 'package:get/get.dart';

class StateController extends GetxController {
  // Observable variable to track the loading state
  var isLoading = false.obs;

  // Method to toggle loading state
  void toggleLoading(bool value) {
    isLoading.value = value;
  }

}