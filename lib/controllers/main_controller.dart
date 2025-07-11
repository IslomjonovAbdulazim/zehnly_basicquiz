import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  var selectedRecentGame = false.obs;
  var isLoading = false.obs;
  var recentlyPlayedGame = Rxn<Game>();
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
        description: 'Solve word puzzles by rearranging letters',
        color: 'anagram',
        icon: '🔤',
      ),
      Game(
        title: 'Word Blitz',
        description: 'Find words as fast as you can',
        color: 'blitz',
        icon: '⚡',
      ),
      Game(
        title: 'Guess the Definition Blitz',
        description: 'Match words with their meanings',
        color: 'definition',
        icon: '📖',
      ),
    ];
  }

  Future<void> loadRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameTitle = prefs.getString('last_game_title');
      final gameColor = prefs.getString('last_game_color');

      if (gameTitle != null && gameColor != null) {
        recentlyPlayedGame.value = Game(
          title: gameTitle,
          description: 'Last played recently',
          color: gameColor,
          icon: _getIconForColor(gameColor),
          isRecentlyPlayed: true,
        );
      }
    } catch (e) {
      print('Error loading recently played: $e');
    }
  }

  String _getIconForColor(String color) {
    switch (color.toLowerCase()) {
      case 'anagram':
        return '🔤';
      case 'blitz':
        return '⚡';
      case 'definition':
        return '📖';
      default:
        return '🎮';
    }
  }

  Future<void> saveLastPlayedGame(Game game) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_game_title', game.title);
      await prefs.setString('last_game_color', game.color);

      // Update the reactive variable
      recentlyPlayedGame.value = Game(
        title: game.title,
        description: 'Last played recently',
        color: game.color,
        icon: game.icon,
        isRecentlyPlayed: true,
      );
    } catch (e) {
      print('Error saving last played game: $e');
    }
  }

  void selectGame(int index) {
    selectedGameIndex.value = index;

    // Save the selected game as last played
    final selectedGame = allGames[index];
    saveLastPlayedGame(selectedGame);

    // Reset selection after a delay
    Future.delayed(Duration(milliseconds: 200), () {
      selectedGameIndex.value = -1;
    });
  }

  void selectRecentGame() {
    selectedRecentGame.value = true;
  }

  @override
  void onClose() {
    fadeController.dispose();
    scaleController.dispose();
    super.onClose();
  }
}