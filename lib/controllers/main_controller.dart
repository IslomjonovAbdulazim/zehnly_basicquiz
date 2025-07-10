import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Game {
  final String title;
  final String description;
  final String color;
  final String icon;
  final bool isRecentlyPlayed;

  Game({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    this.isRecentlyPlayed = false,
  });
}

class MainController extends GetxController with GetTickerProviderStateMixin {
  // Observable variables
  var selectedGameIndex = (-1).obs;
  var isLoading = false.obs;
  var recentlyPlayedGames = <Game>[].obs;
  var allGames = <Game>[].obs;

  // Animation controllers
  late AnimationController fadeController;
  late AnimationController scaleController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  @override
  void onInit() {
    super.onInit();
    initializeAnimations();
    loadGames();
    loadRecentlyPlayed();
  }

  void initializeAnimations() {
    fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: fadeController, curve: Curves.easeInOut),
    );

    scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    fadeController.forward();
    scaleController.forward();
  }

  void loadGames() {
    allGames.value = [
      Game(
        title: 'Anagram Attack',
        description: '',
        color: 'anagram',
        icon: '',
      ),
      Game(
        title: 'Word Blitz',
        description: '',
        color: 'blitz',
        icon: '',
      ),
      Game(
        title: 'Guess the Definition Blitz',
        description: '',
        color: 'definition',
        icon: '',
      ),
    ];
  }

  void loadRecentlyPlayed() {
    // Fixed recently played - no longer data driven
    recentlyPlayedGames.value = [];
  }

  void selectGame(int index) {
    selectedGameIndex.value = index;

    // Add haptic feedback
    Get.defaultDialog(
      title: 'Coming Soon!',
      middleText: 'This game will be available soon.',
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );

    // Reset selection after a delay
    Future.delayed(Duration(milliseconds: 200), () {
      selectedGameIndex.value = -1;
    });
  }

  void playRecentGame(Game game) {
    Get.snackbar(
      'Loading ${game.title}',
      'Preparing your game...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    fadeController.dispose();
    scaleController.dispose();
    super.onClose();
  }
}