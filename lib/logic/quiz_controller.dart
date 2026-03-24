import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/quiz.dart';
import '../data/repositories/quiz_repository.dart';
import '../core/constants.dart';
import '../core/utils.dart';

enum QuizStatus {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

class QuizController extends ChangeNotifier {
  final QuizRepository _repository = QuizRepository();

  // State
  QuizStatus _status = QuizStatus.idle;
  String? _errorMessage;
  
  // Quiz Data
  List<Quiz> _quizzes = [];
  Quiz? _currentQuiz;
  List<Question> _questions = [];
  
  // Game State
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = AppConstants.questionTimeSeconds;
  Timer? _timer;
  bool _answered = false;
  List<int> _userAnswers = [];
  List<bool> _isCorrect = [];
  int _quizStartTime = 0;
  int _totalTimeSpent = 0;
  
  // Progress
  QuizProgress? _progress;
  bool _hasResumableQuiz = false;

  // Getters
  QuizStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  int get timeLeft => _timeLeft;
  bool get answered => _answered;
  List<int> get userAnswers => _userAnswers;
  List<bool> get isCorrect => _isCorrect;
  QuizProgress? get progress => _progress;
  bool get hasResumableQuiz => _hasResumableQuiz;
  
  // Computed Properties
  Question? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }
  
  bool get isLastQuestion {
    return _currentQuestionIndex >= _questions.length - 1;
  }
  
  bool get isQuizCompleted {
    return _currentQuestionIndex >= _questions.length;
  }
  
  int get totalQuestions => _questions.length;
  
  double get progressPercentage {
    if (_questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / _questions.length;
  }
  
  String get progressText {
    return '${_currentQuestionIndex + 1}/${_questions.length}';
  }
  
  double get scorePercentage {
    if (_questions.isEmpty) return 0.0;
    return (_score / _questions.length) * 100;
  }

  // Initialize
  Future<void> initialize() async {
    await _loadQuizzes();
    await _checkForResumableQuiz();
  }

  // Load Quizzes
  Future<void> _loadQuizzes({String? category, String? difficulty, String? search}) async {
    _setStatus(QuizStatus.loading);
    
    try {
      _quizzes = await _repository.getQuizzes(
        category: category,
        difficulty: difficulty,
        search: search,
      );
      _setStatus(QuizStatus.idle);
    } catch (e) {
      _setError('Failed to load quizzes: $e');
    }
  }

  // Refresh Quizzes
  Future<void> refreshQuizzes() async {
    await _loadQuizzes();
  }

  // Filter Quizzes
  void filterQuizzes({String? category, String? difficulty, String? search}) {
    _loadQuizzes(category: category, difficulty: difficulty, search: search);
  }

  // Start Quiz
  Future<void> startQuiz(Quiz quiz, {bool resume = false}) async {
    _setStatus(QuizStatus.loading);
    
    try {
      _currentQuiz = quiz;
      
      if (resume && _progress != null) {
        // Resume from progress
        _questions = quiz.questions;
        _currentQuestionIndex = _progress!.currentQuestionIndex;
        _score = _progress!.score;
        _userAnswers = List.from(_progress!.answers);
        _isCorrect = List.from(_progress!.correct);
        _quizStartTime = DateTime.now().millisecondsSinceEpoch - _progress!.timeSpent * 1000;
      } else {
        // Start fresh
        final quizWithQuestions = await _repository.getQuizBySlug(quiz.slug);
        _questions = quizWithQuestions.questions;
        _currentQuestionIndex = 0;
        _score = 0;
        _userAnswers = [];
        _isCorrect = [];
        _quizStartTime = DateTime.now().millisecondsSinceEpoch;
      }
      
      _timeLeft = _getCurrentQuestionTimeLimit();
      _answered = false;
      _totalTimeSpent = 0;
      
      _setStatus(QuizStatus.playing);
      _startTimer();
      
      // Clear any existing progress
      await _clearProgress();
    } catch (e) {
      _setError('Failed to start quiz: $e');
    }
  }

  // Select Answer
  void selectAnswer(int answerIndex) {
    if (_answered || _status != QuizStatus.playing) return;
    
    _answered = true;
    _userAnswers.add(answerIndex);
    
    final question = currentQuestion!;
    final correct = question.isCorrect(answerIndex);
    _isCorrect.add(correct);
    
    if (correct) {
      _score++;
      AppUtils.hapticFeedbackSuccess();
    } else {
      AppUtils.hapticFeedbackError();
    }
    
    _saveProgress();
    notifyListeners();
    
    // Auto advance after delay
    Timer(const Duration(seconds: 2), () {
      if (!isLastQuestion) {
        nextQuestion();
      } else {
        completeQuiz();
      }
    });
  }

  // Next Question
  void nextQuestion() {
    if (_status != QuizStatus.playing) return;
    
    _currentQuestionIndex++;
    _answered = false;
    _timeLeft = _getCurrentQuestionTimeLimit();
    
    notifyListeners();
    
    if (isQuizCompleted) {
      completeQuiz();
    }
  }

  // Previous Question (for review)
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Pause Quiz
  void pauseQuiz() {
    if (_status != QuizStatus.playing) return;
    
    _timer?.cancel();
    _setStatus(QuizStatus.paused);
    _saveProgress();
  }

  // Resume Quiz
  void resumeQuiz() {
    if (_status != QuizStatus.paused) return;
    
    _setStatus(QuizStatus.playing);
    _startTimer();
  }

  // Complete Quiz
  Future<void> completeQuiz() async {
    _timer?.cancel();
    _totalTimeSpent = (DateTime.now().millisecondsSinceEpoch - _quizStartTime) ~/ 1000;
    
    _setStatus(QuizStatus.completed);
    await _clearProgress();
    
    // Submit attempt (if user is logged in)
    // This would be handled by AuthController
  }

  // Restart Quiz
  void restartQuiz() {
    if (_currentQuiz == null) return;
    
    _currentQuestionIndex = 0;
    _score = 0;
    _timeLeft = AppConstants.questionTimeSeconds;
    _answered = false;
    _userAnswers = [];
    _isCorrect = [];
    _quizStartTime = DateTime.now().millisecondsSinceEpoch;
    _totalTimeSpent = 0;
    
    _setStatus(QuizStatus.playing);
    _startTimer();
  }

  // Quit Quiz
  void quitQuiz() {
    _timer?.cancel();
    _setStatus(QuizStatus.idle);
    _clearProgress();
  }

  // Timer Management
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeLeft--;
      
      if (_timeLeft <= 0) {
        _timeLeft = 0;
        _answered = true;
        _userAnswers.add(-1); // -1 indicates timeout
        _isCorrect.add(false);
        
        AppUtils.hapticFeedbackError();
        
        notifyListeners();
        
        Timer(const Duration(seconds: 1), () {
          if (!isLastQuestion) {
            nextQuestion();
          } else {
            completeQuiz();
          }
        });
      } else {
        notifyListeners();
      }
    });
  }

  int _getCurrentQuestionTimeLimit() {
    final question = currentQuestion;
    if (question?.timeLimit != null && question!.timeLimit! > 0) {
      return question!.timeLimit!;
    }
    return AppConstants.questionTimeSeconds;
  }

  // Progress Management
  Future<void> _checkForResumableQuiz() async {
    // This would check local storage for any saved progress
    // For now, we'll set it to false
    _hasResumableQuiz = false;
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    if (_currentQuiz == null || _status != QuizStatus.playing) return;
    
    final progress = QuizProgress(
      quizId: _currentQuiz!.id,
      userId: '', // Would come from AuthController
      currentQuestionIndex: _currentQuestionIndex,
      score: _score,
      answers: _userAnswers,
      correct: _isCorrect,
      lastActivity: DateTime.now(),
      timeSpent: (DateTime.now().millisecondsSinceEpoch - _quizStartTime) ~/ 1000,
    );
    
    // Save to local storage
    // This would use LocalStorage service
  }

  Future<void> _clearProgress() async {
    _progress = null;
    _hasResumableQuiz = false;
    // Clear from local storage
  }

  // State Management
  void _setStatus(QuizStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _status = QuizStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == QuizStatus.error) {
      _status = QuizStatus.idle;
    }
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
