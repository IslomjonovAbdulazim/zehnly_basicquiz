// controllers/word_blitz_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class Question {
  final String word;
  final String correctDefinition;
  final List<String> wrongOptions;

  Question({
    required this.word,
    required this.correctDefinition,
    required this.wrongOptions,
  });

  List<String> get allOptions {
    List<String> options = [correctDefinition, ...wrongOptions];
    options.shuffle();
    return options;
  }
}

class WordBlitzController extends GetxController
    with GetTickerProviderStateMixin {
  // Quiz state
  late List<Question> questions;
  RxInt currentQuestionIndex = 0.obs;
  RxInt score = 0.obs;
  RxInt timeLeft = 60.obs;
  RxString selectedAnswer = ''.obs;
  RxBool isAnswered = false.obs;
  RxInt selectedOptionIndex = (-1).obs;
  RxBool showResult = false.obs;
  RxBool quizCompleted = false.obs;

  // Timer
  Timer? _timer;

  // Audio players
  AudioPlayer? _correctPlayer;
  AudioPlayer? _wrongPlayer;
  AudioPlayer? _timePlayer;

  // Animation controllers
  late AnimationController fadeController;
  late AnimationController scaleController;
  late AnimationController slideController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<Offset> slideAnimation;

  // Current question options (shuffled)
  RxList<String> currentOptions = <String>[].obs;

  // Static quiz data
  final List<Question> quizQuestions = [
    Question(
      word: "Integrity",
      correctDefinition:
          "the quality of being honest and having strong moral principles",
      wrongOptions: [
        "relating to money or currency",
        "a piece of land surrounded by water",
      ],
    ),
    Question(
      word: "Ambiguous",
      correctDefinition:
          "open to more than one interpretation; not having one obvious meaning",
      wrongOptions: [
        "extremely angry or furious",
        "relating to ancient history",
      ],
    ),
    Question(
      word: "Catalyst",
      correctDefinition:
          "a person or thing that precipitates an event or change",
      wrongOptions: ["a type of building material", "a musical instrument"],
    ),
    Question(
      word: "Eloquent",
      correctDefinition: "fluent or persuasive in speaking or writing",
      wrongOptions: ["related to electricity", "extremely loud or noisy"],
    ),
    Question(
      word: "Resilient",
      correctDefinition:
          "able to withstand or recover quickly from difficult conditions",
      wrongOptions: ["relating to real estate", "having a bad smell"],
    ),
    Question(
      word: "Paradigm",
      correctDefinition: "a typical example or pattern of something; a model",
      wrongOptions: ["a type of bird", "a mathematical equation"],
    ),
    Question(
      word: "Meticulous",
      correctDefinition:
          "showing great attention to detail; very careful and precise",
      wrongOptions: [
        "relating to weather conditions",
        "extremely fast or quick",
      ],
    ),
    Question(
      word: "Pragmatic",
      correctDefinition: "dealing with things sensibly and realistically",
      wrongOptions: ["relating to ancient Greece", "extremely dramatic"],
    ),
    Question(
      word: "Ephemeral",
      correctDefinition: "lasting for a very short time",
      wrongOptions: ["relating to elephants", "extremely expensive"],
    ),
    Question(
      word: "Ubiquitous",
      correctDefinition: "present, appearing, or found everywhere",
      wrongOptions: ["relating to computers", "extremely unique or rare"],
    ),
    Question(
      word: "Tenacious",
      correctDefinition: "tending to keep a firm hold; persistent",
      wrongOptions: ["relating to tennis", "extremely fragile"],
    ),
    Question(
      word: "Verbose",
      correctDefinition: "using or expressed in more words than are needed",
      wrongOptions: [
        "relating to plants and nature",
        "extremely quiet or silent",
      ],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    questions = List.from(quizQuestions);
    _initAudioPlayers();
    _initAnimations();
    _startQuiz();
  }

  void _initAudioPlayers() async {
    try {
      _correctPlayer = AudioPlayer();
      _wrongPlayer = AudioPlayer();
      _timePlayer = AudioPlayer();

      await _correctPlayer!.setAsset('assets/correct.mp3');
      await _wrongPlayer!.setAsset('assets/wrong.mp3');
      await _timePlayer!.setAsset('assets/time.mp3');

      print('Audio players initialized successfully');
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

    slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: fadeController, curve: Curves.easeInOut));

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.elasticOut),
    );

    slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: slideController, curve: Curves.easeOutCubic),
        );
  }

  void _startQuiz() {
    _loadCurrentQuestion();
    _startTimer();
    _playEnterAnimation();
  }

  void _loadCurrentQuestion() {
    if (currentQuestionIndex.value < questions.length) {
      currentOptions.value = questions[currentQuestionIndex.value].allOptions;
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
      selectAnswer(''); // Empty string means no answer
    }
  }

  void _playEnterAnimation() {
    fadeController.reset();
    scaleController.reset();
    slideController.reset();

    fadeController.forward();
    scaleController.forward();
    slideController.forward();
  }

  void selectAnswer(String answer) {
    if (isAnswered.value) return;

    selectedAnswer.value = answer;
    isAnswered.value = true;
    _timer?.cancel();

    // Play sound immediately when answer is selected
    if (answer.isEmpty) {
      // Time ran out
      print('Playing time up sound');
      _playTimeUpSound();
    } else if (answer ==
        questions[currentQuestionIndex.value].correctDefinition) {
      score.value++;
      print('Playing correct sound');
      _playCorrectSound();
    } else {
      print('Playing wrong sound');
      _playWrongSound();
    }

    // Show result after a delay
    showResult.value = true;
  }

  void _playCorrectSound() async {
    try {
      if (_correctPlayer != null) {
        await _correctPlayer!.seek(Duration.zero);
        await _correctPlayer!.play();
        print('Correct sound played');
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
        print('Wrong sound played');
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
        print('Time up sound played');
      }
    } catch (e) {
      print('Error playing time up sound: $e');
    }
  }

  void nextQuestion() {
    showResult.value = false;
    isAnswered.value = false;
    selectedAnswer.value = '';
    selectedOptionIndex.value = -1;

    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      _loadCurrentQuestion();
      _startTimer();
      _playEnterAnimation();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    quizCompleted.value = true;
    _timer?.cancel();
  }

  void restartQuiz() {
    currentQuestionIndex.value = 0;
    score.value = 0;
    quizCompleted.value = false;
    showResult.value = false;
    isAnswered.value = false;
    selectedAnswer.value = '';
    selectedOptionIndex.value = -1;
    _startQuiz();
  }

  void resetQuiz() {
    _timer?.cancel();
    currentQuestionIndex.value = 0;
    score.value = 0;
    timeLeft.value = 60;
    selectedAnswer.value = '';
    isAnswered.value = false;
    showResult.value = false;
    quizCompleted.value = false;
    selectedOptionIndex.value = -1;
    currentOptions.clear();
  }

  double get progress => (currentQuestionIndex.value + 1) / questions.length;

  Question get currentQuestion => questions[currentQuestionIndex.value];

  bool isCorrectAnswer(String answer) {
    return answer == currentQuestion.correctDefinition;
  }

  @override
  void onClose() {
    resetQuiz();
    _correctPlayer?.dispose();
    _wrongPlayer?.dispose();
    _timePlayer?.dispose();
    fadeController.dispose();
    scaleController.dispose();
    slideController.dispose();
    super.onClose();
  }
}
