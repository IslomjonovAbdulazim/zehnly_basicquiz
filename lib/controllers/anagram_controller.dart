// controllers/anagram_controller.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AnagramQuestion {
  final String englishWord;
  final String uzbekTranslation;

  AnagramQuestion({
    required this.englishWord,
    required this.uzbekTranslation,
  });

  List<String> get shuffledLetters {
    List<String> letters = englishWord.toLowerCase().split('');
    letters.shuffle();
    return letters;
  }
}

class AnagramController extends GetxController with GetTickerProviderStateMixin {
  // Game state
  late List<AnagramQuestion> questions;
  RxInt currentQuestionIndex = 0.obs;
  RxInt score = 0.obs;
  RxInt timeLeft = 60.obs;
  RxList<String> availableLetters = <String>[].obs;
  RxList<bool> letterUsed = <bool>[].obs;
  RxList<String> selectedLetters = <String>[].obs;
  RxBool isAnswered = false.obs;
  RxInt selectedOptionIndex = (-1).obs;
  RxBool showResult = false.obs;
  RxBool gameCompleted = false.obs;
  RxString formedWord = ''.obs;

  // Timer
  Timer? _timer;

  // Audio players
  AudioPlayer? _correctPlayer;
  AudioPlayer? _wrongPlayer;
  AudioPlayer? _timePlayer;
  AudioPlayer? _completionPlayer;

  // Animation controllers
  late AnimationController fadeController;
  late AnimationController scaleController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  // Static quiz data
  final List<AnagramQuestion> anagramQuestions = [
    AnagramQuestion(englishWord: "HOUSE", uzbekTranslation: "Uy"),
    AnagramQuestion(englishWord: "WATER", uzbekTranslation: "Suv"),
    AnagramQuestion(englishWord: "FRIEND", uzbekTranslation: "Do'st"),
    AnagramQuestion(englishWord: "SCHOOL", uzbekTranslation: "Maktab"),
    AnagramQuestion(englishWord: "FAMILY", uzbekTranslation: "Oila"),
    AnagramQuestion(englishWord: "HEALTH", uzbekTranslation: "Sog'liq"),
    AnagramQuestion(englishWord: "MONEY", uzbekTranslation: "Pul"),
    AnagramQuestion(englishWord: "WORLD", uzbekTranslation: "Dunyo"),
    AnagramQuestion(englishWord: "HAPPY", uzbekTranslation: "Baxtli"),
    AnagramQuestion(englishWord: "LOVE", uzbekTranslation: "Sevgi"),
    AnagramQuestion(englishWord: "BOOK", uzbekTranslation: "Kitob"),
    AnagramQuestion(englishWord: "TIME", uzbekTranslation: "Vaqt"),
  ];

  @override
  void onInit() {
    super.onInit();
    questions = List.from(anagramQuestions);
    questions.shuffle();
    _initAudioPlayers();
    _initAnimations();
    _startGame();
  }

  void _initAudioPlayers() async {
    try {
      _correctPlayer = AudioPlayer();
      _wrongPlayer = AudioPlayer();
      _timePlayer = AudioPlayer();
      _completionPlayer = AudioPlayer();

      await _correctPlayer!.setAsset('assets/correct.mp3');
      await _wrongPlayer!.setAsset('assets/wrong.mp3');
      await _timePlayer!.setAsset('assets/time.mp3');
      await _completionPlayer!.setAsset('assets/lesson_completion.mp3');
    } catch (e) {
      print('Error initializing audio players: $e');
    }
  }

  void _initAnimations() {
    fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: fadeController, curve: Curves.easeInOut));

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: scaleController, curve: Curves.elasticOut));
  }

  void _startGame() {
    _loadCurrentQuestion();
    _startTimer();
    _playEnterAnimation();
  }

  void _loadCurrentQuestion() {
    if (currentQuestionIndex.value < questions.length) {
      availableLetters.value = questions[currentQuestionIndex.value].shuffledLetters;
      letterUsed.value = List.filled(availableLetters.length, false);
      selectedLetters.clear();
      formedWord.value = '';
      isAnswered.value = false;
      showResult.value = false;
    }
  }

  void _startTimer() {
    timeLeft.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        _timeUp();
      }
    });
  }

  void _timeUp() {
    if (!isAnswered.value) {
      _playTimeUpSound();
      _checkAnswer();
    }
  }

  void _playEnterAnimation() {
    fadeController.reset();
    scaleController.reset();
    fadeController.forward();
    scaleController.forward();
  }

  void selectLetter(int index) {
    if (isAnswered.value || index >= availableLetters.length || letterUsed[index]) return;

    String letter = availableLetters[index];
    selectedLetters.add(letter);
    letterUsed[index] = true;
    _updateFormedWord();
  }

  void removeLetter(int selectedIndex) {
    if (isAnswered.value || selectedIndex >= selectedLetters.length) return;

    String letter = selectedLetters[selectedIndex];
    selectedLetters.removeAt(selectedIndex);

    // Find the original index of this letter and mark it as unused
    for (int i = 0; i < availableLetters.length; i++) {
      if (availableLetters[i] == letter && letterUsed[i]) {
        letterUsed[i] = false;
        break;
      }
    }

    _updateFormedWord();
  }

  void _updateFormedWord() {
    formedWord.value = selectedLetters.join('').toUpperCase();
  }

  void submitAnswer() {
    if (isAnswered.value || selectedLetters.isEmpty) return;
    _checkAnswer();
  }

  void _checkAnswer() {
    isAnswered.value = true;
    _timer?.cancel();

    String currentWord = questions[currentQuestionIndex.value].englishWord;
    bool isCorrect = formedWord.value == currentWord;

    if (isCorrect) {
      score.value++;
      _playCorrectSound();
    } else {
      _playWrongSound();
    }

    showResult.value = true;
  }

  void _playCorrectSound() async {
    try {
      if (_correctPlayer != null) {
        await _correctPlayer!.seek(Duration.zero);
        await _correctPlayer!.play();
      }
    } catch (e) {
      print('Error playing correct sound: $e');
    }
  }

  void _playWrongSound() async {
    try {
      if (_wrongPlayer != null) {
        await _wrongPlayer!.seek(Duration.zero);
        await _wrongPlayer!.play();
      }
    } catch (e) {
      print('Error playing wrong sound: $e');
    }
  }

  void _playTimeUpSound() async {
    try {
      if (_timePlayer != null) {
        await _timePlayer!.seek(Duration.zero);
        await _timePlayer!.play();
      }
    } catch (e) {
      print('Error playing time up sound: $e');
    }
  }

  void nextQuestion() {
    showResult.value = false;

    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      _loadCurrentQuestion();
      _startTimer();
      _playEnterAnimation();
    } else {
      _completeGame();
    }
  }

  void _completeGame() {
    gameCompleted.value = true;
    _timer?.cancel();
    _playCompletionSound();
  }

  void _playCompletionSound() async {
    try {
      if (_completionPlayer != null) {
        await _completionPlayer!.seek(Duration.zero);
        await _completionPlayer!.play();
      }
    } catch (e) {
      print('Error playing completion sound: $e');
    }
  }

  void restartGame() {
    currentQuestionIndex.value = 0;
    score.value = 0;
    gameCompleted.value = false;
    questions.shuffle();
    _startGame();
  }

  void resetGame() {
    _timer?.cancel();
    currentQuestionIndex.value = 0;
    score.value = 0;
    timeLeft.value = 60;
    isAnswered.value = false;
    showResult.value = false;
    gameCompleted.value = false;
    selectedOptionIndex.value = -1;
    availableLetters.clear();
    selectedLetters.clear();
    formedWord.value = '';
  }

  AnagramQuestion get currentQuestion => questions[currentQuestionIndex.value];

  bool get isCorrectAnswer => formedWord.value == currentQuestion.englishWord;

  double get progress => (currentQuestionIndex.value + 1) / questions.length;

  @override
  void onClose() {
    resetGame();
    _correctPlayer?.dispose();
    _wrongPlayer?.dispose();
    _timePlayer?.dispose();
    _completionPlayer?.dispose();
    fadeController.dispose();
    scaleController.dispose();
    super.onClose();
  }
}