import 'package:json_annotation/json_annotation.dart';

part 'quiz.g.dart';

enum QuizDifficulty { easy, medium, hard }

enum QuizType { multipleChoice, trueFalse, mixed }

@JsonSerializable()
class Quiz {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String thumbnail;
  final QuizDifficulty difficulty;
  final QuizType type;
  final int duration; // in minutes
  final int questionsCount;
  final List<Question> questions;
  final String category;
  final List<String> tags;
  final int attempts;
  final double averageScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Quiz({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.difficulty,
    required this.type,
    required this.duration,
    required this.questionsCount,
    required this.questions,
    required this.category,
    required this.tags,
    required this.attempts,
    required this.averageScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
  Map<String, dynamic> toJson() => _$QuizToJson(this);

  Quiz copyWith({
    String? id,
    String? slug,
    String? title,
    String? description,
    String? thumbnail,
    QuizDifficulty? difficulty,
    QuizType? type,
    int? duration,
    int? questionsCount,
    List<Question>? questions,
    String? category,
    List<String>? tags,
    int? attempts,
    double? averageScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      questionsCount: questionsCount ?? this.questionsCount,
      questions: questions ?? this.questions,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      attempts: attempts ?? this.attempts,
      averageScore: averageScore ?? this.averageScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quiz && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Quiz{id: $id, title: $title, slug: $slug}';
  }
}

@JsonSerializable()
class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer; // index of correct answer
  final String explanation;
  final String? imageUrl;
  final int points;
  final int timeLimit; // seconds, overrides quiz default if set

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.imageUrl,
    required this.points,
    required this.timeLimit,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  Question copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswer,
    String? explanation,
    String? imageUrl,
    int? points,
    int? timeLimit,
  }) {
    return Question(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      imageUrl: imageUrl ?? this.imageUrl,
      points: points ?? this.points,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }

  bool isCorrect(int selectedAnswer) {
    return selectedAnswer == correctAnswer;
  }

  String get correctOption {
    if (correctAnswer >= 0 && correctAnswer < options.length) {
      return options[correctAnswer];
    }
    return '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Question{id: $id, question: $question}';
  }
}

@JsonSerializable()
class QuizAttempt {
  final String id;
  final String quizId;
  final String userId;
  final int score;
  final int totalQuestions;
  final List<int> answers; // user's answers for each question
  final List<bool> correct; // whether each answer was correct
  final int duration; // time taken in seconds
  final DateTime startedAt;
  final DateTime completedAt;
  final bool completed;

  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.correct,
    required this.duration,
    required this.startedAt,
    required this.completedAt,
    required this.completed,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => _$QuizAttemptFromJson(json);
  Map<String, dynamic> toJson() => _$QuizAttemptToJson(this);

  double get percentage {
    if (totalQuestions == 0) return 0.0;
    return (score / totalQuestions) * 100;
  }

  QuizAttempt copyWith({
    String? id,
    String? quizId,
    String? userId,
    int? score,
    int? totalQuestions,
    List<int>? answers,
    List<bool>? correct,
    int? duration,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? completed,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      answers: answers ?? this.answers,
      correct: correct ?? this.correct,
      duration: duration ?? this.duration,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizAttempt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizAttempt{id: $id, quizId: $quizId, score: $score}';
  }
}

@JsonSerializable()
class QuizProgress {
  final String quizId;
  final String userId;
  final int currentQuestionIndex;
  final int score;
  final List<int> answers;
  final List<bool> correct;
  final DateTime lastActivity;
  final int timeSpent; // seconds

  const QuizProgress({
    required this.quizId,
    required this.userId,
    required this.currentQuestionIndex,
    required this.score,
    required this.answers,
    required this.correct,
    required this.lastActivity,
    required this.timeSpent,
  });

  factory QuizProgress.fromJson(Map<String, dynamic> json) => _$QuizProgressFromJson(json);
  Map<String, dynamic> toJson() => _$QuizProgressToJson(this);

  bool get isExpired {
    return DateTime.now().difference(lastActivity).inHours > 24;
  }

  QuizProgress copyWith({
    String? quizId,
    String? userId,
    int? currentQuestionIndex,
    int? score,
    List<int>? answers,
    List<bool>? correct,
    DateTime? lastActivity,
    int? timeSpent,
  }) {
    return QuizProgress(
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      answers: answers ?? this.answers,
      correct: correct ?? this.correct,
      lastActivity: lastActivity ?? this.lastActivity,
      timeSpent: timeSpent ?? this.timeSpent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizProgress && 
           other.quizId == quizId && 
           other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(quizId, userId);

  @override
  String toString() {
    return 'QuizProgress{quizId: $quizId, userId: $userId, currentQuestionIndex: $currentQuestionIndex}';
  }
}
