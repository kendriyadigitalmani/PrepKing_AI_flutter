class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://yourdomain.com/api';
  static const String quizzesEndpoint = '/quizzes';
  static const String quizEndpoint = '/quiz';
  static const String leaderboardEndpoint = '/leaderboard';
  static const String userProgressEndpoint = '/progress';
  
  // Time Constants
  static const int questionTimeSeconds = 30;
  static const int resumeTimeHours = 24;
  static const int resumeTimeMillis = 24 * 60 * 60 * 1000;
  
  // Animation Durations
  static const int cardFlipDurationMs = 500;
  static const int buttonAnimationMs = 200;
  static const int confettiDurationSeconds = 2;
  
  // Local Storage Keys
  static const String userKey = 'user_data';
  static const String progressKey = 'quiz_progress';
  static const String settingsKey = 'app_settings';
  static const String cacheKey = 'quiz_cache';
  
  // Deep Link Patterns
  static const String quizLinkPattern = '/quiz';
  static const String slugQueryParam = 'slug';
  
  // Sound Assets
  static const String correctSound = 'sounds/correct.mp3';
  static const String wrongSound = 'sounds/wrong.mp3';
  static const String clickSound = 'sounds/click.mp3';
  static const String timerSound = 'sounds/timer.mp3';
  
  // Image Assets
  static const String placeholderImage = 'images/placeholder.png';
  static const String logoImage = 'images/logo.png';
  
  // UI Constants
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Grid Configuration
  static const int homeGridCrossAxisCount = 2;
  static const double homeGridChildAspectRatio = 0.75;
  static const double homeGridSpacing = 12.0;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Cache Duration (in minutes)
  static const int cacheDurationMinutes = 30;
  
  // Max Attempts for Resume
  static const int maxResumeAttempts = 3;
}

class AppStrings {
  // App
  static const String appName = 'Prepking AI';
  static const String tagline = 'Learn. Practice. Excel.';
  
  // Navigation
  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String leaderboard = 'Leaderboard';
  static const String settings = 'Settings';
  
  // Quiz
  static const String startQuiz = 'Start Quiz';
  static const String resumeQuiz = 'Resume Quiz';
  static const String nextQuestion = 'Next Question';
  static const String question = 'Question';
  static const String of = 'of';
  static const String score = 'Score';
  static const String time = 'Time';
  static const String seconds = 'seconds';
  
  // Actions
  static const String share = 'Share';
  static const String attempt = 'Attempt';
  static const String playAgain = 'Play Again';
  static const String review = 'Review';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  
  // Feedback
  static const String correct = 'Correct!';
  static const String wrong = 'Wrong!';
  static const String excellent = 'Excellent!';
  static const String goodJob = 'Good Job!';
  static const String tryAgain = 'Try Again!';
  
  // Results
  static const String quizComplete = 'Quiz Complete!';
  static const String yourScore = 'Your Score';
  static const String shareResult = 'Share Result';
  
  // Auth
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String welcomeBack = 'Welcome Back!';
  
  // Filters
  static const String all = 'All';
  static const String easy = 'Easy';
  static const String medium = 'Medium';
  static const String hard = 'Hard';
  static const String searchQuizzes = 'Search quizzes...';
  
  // Errors
  static const String somethingWentWrong = 'Something went wrong';
  static const String noInternet = 'No internet connection';
  static const String tryAgainLater = 'Please try again later';
  static const String quizNotFound = 'Quiz not found';
  
  // Empty States
  static const String noQuizzesFound = 'No quizzes found';
  static const String noProgress = 'No progress yet';
  static const String startFirstQuiz = 'Start your first quiz!';
}
