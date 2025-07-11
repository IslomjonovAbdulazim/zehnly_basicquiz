import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/main_page.dart';

class HomeController extends GetxController {
  var selectedButton = ''.obs;

  void selectLive() {
    selectedButton.value = 'live';

    // Show coming soon
    Get.snackbar(
      'Coming Soon!',
      'Live mode will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 2),
    );

    // Reset selection
    Future.delayed(Duration(milliseconds: 200), () {
      selectedButton.value = '';
    });
  }

  void selectBlitz() {
    selectedButton.value = 'blitz';

    // Navigate to main page
    Get.to(() => MainPage());

    // Reset selection
    Future.delayed(Duration(milliseconds: 200), () {
      selectedButton.value = '';
    });
  }
}