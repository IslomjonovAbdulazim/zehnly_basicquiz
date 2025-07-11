import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Live button
              _buildImageButton(
                imagePath: 'assets/live.jpg',
                buttonType: 'live',
                overlayText: 'Live Battle',
                onTap: controller.selectLive,
              ),

              SizedBox(height: 20),

              // Blitz button
              _buildImageButton(
                imagePath: 'assets/blitz.jpg',
                buttonType: 'blitz',
                overlayText: 'Blitz Mode',
                onTap: controller.selectBlitz,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton({
    required String imagePath,
    required String buttonType,
    required String overlayText,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final isSelected = controller.selectedButton.value == buttonType;

      return AnimatedScale(
        scale: isSelected ? 0.95 : 1.0,
        duration: Duration(milliseconds: 200),
        child: GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            controller.selectedButton.value = buttonType;
          },
          onTapUp: (_) {
            controller.selectedButton.value = '';
            onTap();
          },
          onTapCancel: () {
            controller.selectedButton.value = '';
          },
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Stack(
              children: [
                // Background image
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Text overlay with blur effect
                Positioned(
                  top: 12,
                  right: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          overlayText,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}