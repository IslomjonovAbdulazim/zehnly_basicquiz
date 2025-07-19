// pages/word_blitz_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../controllers/word_blitz_controller.dart';

class WordBlitzPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WordBlitzController controller =
    Get.isRegistered<WordBlitzController>()
        ? Get.find<WordBlitzController>()
        : Get.put(WordBlitzController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.restartQuiz();
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: SafeArea(
          child: Obx(() {
            if (controller.quizCompleted.value) {
              return _buildResultsPage(controller);
            } else if (controller.showResult.value) {
              return _buildAnswerReveal(controller);
            } else {
              return _buildQuizPage(controller);
            }
          }),
        ),
      ),
    );
  }

  Widget _buildQuizPage(WordBlitzController controller) {
    return AnimatedBuilder(
      animation: controller.fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: controller.fadeAnimation.value,
          child: Transform.scale(
            scale: controller.scaleAnimation.value,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildHeader(controller),
                  SizedBox(height: 40),
                  Spacer(),
                  _buildQuestionCard(controller),
                  SizedBox(height: 20),
                  Text(
                    'O\'zbek tilidagi tarjimasini tanlang:',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff666666),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildAnswerOptions(controller),
                  SizedBox(height: 30),
                  Spacer(),
                  _buildProgressBar(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(WordBlitzController controller) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showExitDialog(controller);
          },
          child: Icon(Icons.close, color: Color(0xff232323), size: 28),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Obx(() {
            double progress = controller.timeLeft.value / 30.0;
            return LinearPercentIndicator(
              percent: progress,
              lineHeight: 12.0,
              animateFromLastPercent: true,
              backgroundColor: Color(0xFFEFEFEF),
              progressColor: controller.timeLeft.value > 10
                  ? Color(0xFFCBE8BA)
                  : Color(0xFFFFC2AD),
              barRadius: Radius.circular(6),
              animation: true,
              animationDuration: 300,
            );
          }),
        ),
        SizedBox(width: 20),
        SizedBox(
          width: 55,
          child: Obx(
                () => Text(
              '${controller.timeLeft.value}s',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: controller.timeLeft.value > 10
                    ? Color(0xff232323)
                    : Color(0xFFFFC2AD),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showExitDialog(WordBlitzController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Testdan chiqasizmi?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff232323),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Sizning jarayoningiz yo\'qoladi va qaytadan boshlashingiz kerak bo\'ladi.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff232323),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              _buildDialogButton(
                controller,
                'Testdan chiqish',
                Color(0xFFEFC254),
                996,
                    () {
                  Get.back();
                  Get.back();
                },
              ),
              SizedBox(height: 12),
              _buildDialogButton(
                controller,
                'Davom etish',
                Color(0xFFFD98CD),
                995,
                    () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(
      WordBlitzController controller,
      String text,
      Color color,
      int index,
      VoidCallback onTap,
      ) {
    return Obx(() {
      final isPressed = controller.selectedOptionIndex.value == index;
      return AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 200),
        child: GestureDetector(
          onTapDown: (_) => controller.selectedOptionIndex.value = index,
          onTapUp: (_) {
            controller.selectedOptionIndex.value = -1;
            onTap();
          },
          onTapCancel: () => controller.selectedOptionIndex.value = -1,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff232323),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProgressBar(WordBlitzController controller) {
    return Obx(
          () => Text(
        'Savol ${controller.currentQuestionIndex.value + 1} / ${controller.questions.length}',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xff232323),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(WordBlitzController controller) {
    return Obx(
          () => Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFF8D91F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Center(
          child: Text(
            controller.currentQuestion.englishWord,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xff232323),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(WordBlitzController controller) {
    return Obx(
          () => Column(
        children: controller.currentOptions.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          return _buildAnswerOption(controller, option, index);
        }).toList(),
      ),
    );
  }

  Widget _buildAnswerOption(
      WordBlitzController controller,
      String option,
      int index,
      ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Obx(() {
                final isSelected = controller.selectedOptionIndex.value == index;
                return AnimatedScale(
                  scale: isSelected ? 0.95 : 1.0,
                  duration: Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTapDown: (_) {
                      HapticFeedback.lightImpact();
                      controller.selectedOptionIndex.value = index;
                    },
                    onTapUp: (_) {
                      controller.selectAnswer(option);
                      controller.selectedOptionIndex.value = -1;
                    },
                    onTapCancel: () {
                      controller.selectedOptionIndex.value = -1;
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _getOptionColor(index),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Text(
                        option,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff232323),
                        ),
                        textAlign: TextAlign.center,
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

  Color _getOptionColor(int index) {
    switch (index % 3) {
      case 0:
        return Color(0xFFEFC254);
      case 1:
        return Color(0xFFFD98CD);
      case 2:
        return Color(0xFFD292EC);
      default:
        return Color(0xFFEFC254);
    }
  }

  Widget _buildAnswerReveal(WordBlitzController controller) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Opacity(opacity: 0.3, child: _buildQuizPage(controller)),
          Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400),
              tween: Tween(begin: 1.0, end: 0.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    MediaQuery.of(context).size.height * 0.6 * value,
                  ),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: 30),
                          _buildResultIndicator(controller),
                          SizedBox(height: 20),
                          _buildResultText(controller),
                          SizedBox(height: 30),
                          _buildWordCard(controller),
                          SizedBox(height: 16),
                          _buildCorrectAnswerCard(controller),
                          SizedBox(height: 30),
                          _buildContinueButton(controller),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultIndicator(WordBlitzController controller) {
    return Obx(() {
      bool isCorrect = controller.isCorrectAnswer(controller.selectedAnswer.value);
      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, scaleValue, child) {
          return Transform.scale(
            scale: scaleValue,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isCorrect ? Color(0xFFEFC254) : Color(0xFFD292EC),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Icon(
                isCorrect ? Icons.check : Icons.close,
                color: Color(0xff232323),
                size: 40,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildResultText(WordBlitzController controller) {
    return Obx(() {
      bool isCorrect = controller.isCorrectAnswer(controller.selectedAnswer.value);
      return Text(
        isCorrect ? 'To\'g\'ri!' : 'Noto\'g\'ri',
        style: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xff232323),
        ),
      );
    });
  }

  Widget _buildWordCard(WordBlitzController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF8D91F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Text(
        controller.currentQuestion.englishWord,
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xff232323),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCorrectAnswerCard(WordBlitzController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFEFC254),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Text(
        controller.currentQuestion.correctUzbekTranslation,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xff232323),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContinueButton(WordBlitzController controller) {
    return Obx(() {
      final isPressed = controller.selectedOptionIndex.value == 999;
      return AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 200),
        child: GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            controller.selectedOptionIndex.value = 999;
          },
          onTapUp: (_) {
            controller.nextQuestion();
            controller.selectedOptionIndex.value = -1;
          },
          onTapCancel: () => controller.selectedOptionIndex.value = -1,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Color(0xFF8D91F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Center(
              child: Text(
                'Davom etish',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff232323),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildResultsPage(WordBlitzController controller) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFEFC254),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Center(child: Text('🏆', style: TextStyle(fontSize: 60))),
          ),
          SizedBox(height: 30),
          Text(
            'Test tugadi!',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xff232323),
            ),
          ),
          SizedBox(height: 20),
          Obx(
                () => Text(
              'Natija: ${controller.score.value}/${controller.questions.length}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xff232323),
              ),
            ),
          ),
          SizedBox(height: 40),
          _buildAccuracyCard(controller),
          SizedBox(height: 40),
          _buildActionButton(
            controller,
            'Qayta o\'ynash',
            Color(0xFFEFC254),
            998,
                () => controller.restartQuiz(),
          ),
          SizedBox(height: 16),
          _buildActionButton(
            controller,
            'Menyuga qaytish',
            Color(0xFFFAFAFA),
            997,
                () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyCard(WordBlitzController controller) {
    return Obx(() {
      double accuracy = (controller.score.value / controller.questions.length) * 100;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF8D91F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          children: [
            Text(
              'Aniqlik',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff232323),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${accuracy.toStringAsFixed(0)}%',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0xff232323),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton(
      WordBlitzController controller,
      String text,
      Color color,
      int index,
      VoidCallback onTap,
      ) {
    return Obx(() {
      final isPressed = controller.selectedOptionIndex.value == index;
      return AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 200),
        child: GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            controller.selectedOptionIndex.value = index;
          },
          onTapUp: (_) {
            onTap();
            controller.selectedOptionIndex.value = -1;
          },
          onTapCancel: () => controller.selectedOptionIndex.value = -1,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color == Color(0xFFFAFAFA)
                    ? Color(0xFFEFEFEF)
                    : Colors.black,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: color == Color(0xFFFAFAFA)
                      ? FontWeight.w600
                      : FontWeight.w700,
                  color: Color(0xff232323),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}