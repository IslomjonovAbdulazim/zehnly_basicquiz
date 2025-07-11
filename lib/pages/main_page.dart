import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zehnly_basicquiz/pages/anagram_page.dart';
import 'package:zehnly_basicquiz/pages/guess_definition_page.dart';
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
                      // Recently played section
                      Obx(() {
                        if (controller.recentlyPlayedGame.value != null) {
                          return Column(
                            children: [
                              Center(
                                child: Text(
                                  'Recently played',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff232323),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildRecentlyPlayedCard(),
                              SizedBox(height: 20),
                            ],
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      }),

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
    return Obx(() {
      final recentGame = controller.recentlyPlayedGame.value!;
      final isSelected = controller.selectedRecentGame.value;

      return AnimatedScale(
        scale: isSelected ? 0.95 : 1.0,
        duration: Duration(milliseconds: 200),
        child: GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            controller.selectRecentGame();
          },
          onTapUp: (_) {
            _navigateToGame(recentGame.color);
            controller.selectedRecentGame.value = false;
          },
          onTapCancel: () {
            controller.selectedRecentGame.value = false;
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: _getCardColor(recentGame.color),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Center(
              child: Text(
                recentGame.title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff232323),
                ),
              ),
            ),
          ),
        ),
      );
    });
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
                      controller.selectGame(index);
                      _navigateToGame(game.color);
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

  void _navigateToGame(String gameColor) {
    switch (gameColor.toLowerCase()) {
      case 'definition':
        Get.to(() => GuessDefinitionPage());
        break;
      case 'blitz':
        Get.to(() => WordBlitzPage());
        break;
      case 'anagram':
      default:
        Get.to(() => AnagramPage());
        break;
    }
  }

  Color _getCardColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'anagram':
        return Color(0xFFDFEDD6);
      case 'blitz':
        return Color(0xFFFFF0D7);
      case 'definition':
        return Color(0xFFC9F1FC);
      default:
        return Color(0xFFE0E0E0);
    }
  }
}