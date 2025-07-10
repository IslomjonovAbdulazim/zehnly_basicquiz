import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zehnly_basicquiz/pages/word_blitz_page.dart';
import '../controllers/main_controller.dart';

class MainPage extends StatelessWidget {
  final MainController controller = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller.fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: controller.fadeAnimation.value,
              child: Transform.scale(
                scale: controller.scaleAnimation.value,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Recently played title
                      Center(
                        child: Text(
                          'Recently played',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff232323),
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      // Recently played card
                      _buildRecentlyPlayedCard(),

                      // Game cards
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: controller.allGames.map((game) {
                            int index = controller.allGames.indexOf(game);
                            return _buildGameCard(game, index);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayedCard() {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showComingSoon();
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFD9CAFA), // #D9CAFA
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Text(
                    'Anagram Attack',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff232323),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameCard(Game game, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Obx(() {
                final isSelected = controller.selectedGameIndex.value == index;
                return AnimatedScale(
                  scale: isSelected ? 0.95 : 1.0,
                  duration: Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTapDown: (_) {
                      HapticFeedback.lightImpact();
                      controller.selectedGameIndex.value = index;
                    },
                    onTapUp: (_) {
                      if (game.title == "Word Blitz") {
                        Get.to(WordBlitzPage());
                      }
                      controller.selectedGameIndex.value = -1;
                    },
                    onTapCancel: () {
                      controller.selectedGameIndex.value = -1;
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: _getCardColor(game.color),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          game.title,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff232323),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Color _getCardColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'anagram':
        return Color(0xFFDFEDD6); // #DFEDD6
      case 'blitz':
        return Color(0xFFFFF0D7); // #FFF0D7
      case 'definition':
        return Color(0xFFC9F1FC); // #C9F1FC
      default:
        return Color(0xFFE0E0E0);
    }
  }

  void _showComingSoon() {
    Get.snackbar(
      'Coming Soon!',
      'This game will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 2),
    );
  }
}