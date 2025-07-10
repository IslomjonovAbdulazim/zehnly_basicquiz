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
    // Get existing controller or create new one, then reset
    final WordBlitzController controller =
        Get.isRegistered<WordBlitzController>()
        ? Get.find<WordBlitzController>()
        : Get.put(WordBlitzController());

    // Reset everything when page loads
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
                  // Header with close button and timer
                  _buildHeader(controller),

                  SizedBox(height: 40),

                  // Question card
                  Spacer(),
                  _buildQuestionCard(controller),
                  SizedBox(height: 40),

                  // Answer options
                  _buildAnswerOptions(controller),

                  SizedBox(height: 30),

                  // Progress bar at bottom
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
                        'Exit Quiz?',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff232323),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your progress will be lost and you\'ll need to start over.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff232323),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),

                      // Exit button
                      Obx(() {
                        final isPressed =
                            controller.selectedOptionIndex.value == 996;
                        return AnimatedScale(
                          scale: isPressed ? 0.95 : 1.0,
                          duration: Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTapDown: (_) =>
                                controller.selectedOptionIndex.value = 996,
                            onTapUp: (_) {
                              controller.selectedOptionIndex.value = -1;
                              Get.back(); // Close dialog
                              Get.back(); // Close quiz
                            },
                            onTapCancel: () =>
                                controller.selectedOptionIndex.value = -1,
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFC2AD),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Exit Quiz',
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
                      }),

                      SizedBox(height: 12),

                      // Stay button
                      Obx(() {
                        final isPressed =
                            controller.selectedOptionIndex.value == 995;
                        return AnimatedScale(
                          scale: isPressed ? 0.95 : 1.0,
                          duration: Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTapDown: (_) =>
                                controller.selectedOptionIndex.value = 995,
                            onTapUp: (_) {
                              controller.selectedOptionIndex.value = -1;
                              Get.back();
                            },
                            onTapCancel: () =>
                                controller.selectedOptionIndex.value = -1,
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFFCBE8BA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Continue Quiz',
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
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
          child: Icon(Icons.close, color: Color(0xff232323), size: 28),
        ),

        SizedBox(width: 20),

        // Animated progress bar
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

        // Timer
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

  Widget _buildProgressBar(WordBlitzController controller) {
    return Obx(
      () => Text(
        'Question ${controller.currentQuestionIndex.value + 1} of ${controller.questions.length}',
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
          color: Color(0xFFD9CAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Center(
          child: Text(
            controller.currentQuestion.word,
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
                final isSelected =
                    controller.selectedOptionIndex.value == index;
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
                          fontSize: 16,
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
        return Color(0xFFDFEDD6); // Anagram green
      case 1:
        return Color(0xFFC9F1FC); // Definition blue
      case 2:
        return Color(0xFFFFF0D7); // Blitz cream
      default:
        return Color(0xFFDFEDD6);
    }
  }

  Widget _buildAnswerReveal(WordBlitzController controller) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background quiz page (dimmed)
          Opacity(opacity: 0.3, child: _buildQuizPage(controller)),

          // Bottom sheet that slides up
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
                      // border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag indicator
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          SizedBox(height: 30),

                          // Result indicator with scale animation
                          Obx(() {
                            bool isCorrect = controller.isCorrectAnswer(
                              controller.selectedAnswer.value,
                            );
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
                                      color: isCorrect
                                          ? Color(0xFFCBE8BA)
                                          : Color(0xFFFFC2AD),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
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
                          }),

                          SizedBox(height: 20),

                          Obx(() {
                            bool isCorrect = controller.isCorrectAnswer(
                              controller.selectedAnswer.value,
                            );
                            return Text(
                              isCorrect ? 'Correct!' : 'Incorrect',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff232323),
                              ),
                            );
                          }),

                          SizedBox(height: 30),

                          // Word card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFFD9CAFA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Text(
                              controller.currentQuestion.word,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff232323),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 16),

                          // Correct definition
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFFCBE8BA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Text(
                              controller.currentQuestion.correctDefinition,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff232323),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 30),

                          // Continue button
                          Obx(() {
                            final isPressed =
                                controller.selectedOptionIndex.value == 999;
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
                                onTapCancel: () {
                                  controller.selectedOptionIndex.value = -1;
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD9CAFA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Continue',
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
                          }),
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

  Widget _buildResultsPage(WordBlitzController controller) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Trophy/Score
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFCBE8BA),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Center(child: Text('🏆', style: TextStyle(fontSize: 60))),
          ),

          SizedBox(height: 30),

          Text(
            'Quiz Complete!',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xff232323),
            ),
          ),

          SizedBox(height: 20),

          Obx(
            () => Text(
              'Your Score: ${controller.score.value}/${controller.questions.length}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xff232323),
              ),
            ),
          ),

          SizedBox(height: 40),

          // Accuracy percentage
          Obx(() {
            double accuracy =
                (controller.score.value / controller.questions.length) * 100;
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFD9CAFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    'Accuracy',
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
          }),

          SizedBox(height: 40),

          // Restart button
          Obx(() {
            final isPressed = controller.selectedOptionIndex.value == 998;
            return AnimatedScale(
              scale: isPressed ? 0.95 : 1.0,
              duration: Duration(milliseconds: 200),
              child: GestureDetector(
                onTapDown: (_) {
                  HapticFeedback.lightImpact();
                  controller.selectedOptionIndex.value = 998;
                },
                onTapUp: (_) {
                  controller.restartQuiz();
                  controller.selectedOptionIndex.value = -1;
                },
                onTapCancel: () {
                  controller.selectedOptionIndex.value = -1;
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFFCBE8BA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      'Play Again',
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
          }),

          SizedBox(height: 16),

          // Back to menu button
          Obx(() {
            final isPressed = controller.selectedOptionIndex.value == 997;
            return AnimatedScale(
              scale: isPressed ? 0.95 : 1.0,
              duration: Duration(milliseconds: 200),
              child: GestureDetector(
                onTapDown: (_) {
                  HapticFeedback.lightImpact();
                  controller.selectedOptionIndex.value = 997;
                },
                onTapUp: (_) {
                  Get.back();
                  controller.selectedOptionIndex.value = -1;
                },
                onTapCancel: () {
                  controller.selectedOptionIndex.value = -1;
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFEFEFEF), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      'Back to Menu',
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
          }),
        ],
      ),
    );
  }
}
