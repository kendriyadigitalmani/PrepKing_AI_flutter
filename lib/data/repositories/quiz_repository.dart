import '../models/quiz.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../../core/constants.dart';

class QuizRepository {
  Future<List<Quiz>> getQuizzes({
    String? category,
    String? difficulty,
    String? search,
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? token,
  }) async {
    try {
      return await ApiService.fetchQuizzes(
        category: category,
        difficulty: difficulty,
        search: search,
        page: page,
        limit: limit,
        token: token,
      );
    } on ApiException catch (e) {
      throw RepositoryException('Failed to fetch quizzes: ${e.message}', e.statusCode);
    } on NetworkException catch (e) {
      throw RepositoryException('Network error: ${e.message}');
    } catch (e) {
      throw RepositoryException('Unexpected error: $e');
    }
  }

  Future<Quiz> getQuizBySlug(String slug, {String? token}) async {
    try {
      return await ApiService.fetchQuizBySlug(slug, token: token);
    } on ApiException catch (e) {
      throw RepositoryException('Failed to fetch quiz: ${e.message}', e.statusCode);
    } on NetworkException catch (e) {
      throw RepositoryException('Network error: ${e.message}');
    } catch (e) {
      throw RepositoryException('Unexpected error: $e');
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard({
    String? category,
    String? timeFrame,
    int limit = 50,
    String? token,
  }) async {
    try {
      return await ApiService.fetchLeaderboard(
        category: category,
        timeFrame: timeFrame,
        limit: limit,
        token: token,
      );
    } on ApiException catch (e) {
      throw RepositoryException('Failed to fetch leaderboard: ${e.message}', e.statusCode);
    } on NetworkException catch (e) {
      throw RepositoryException('Network error: ${e.message}');
    } catch (e) {
      throw RepositoryException('Unexpected error: $e');
    }
  }

  Future<QuizAttempt> submitQuizAttempt({
    required String quizId,
    required List<int> answers,
    required int duration,
    required String token,
  }) async {
    try {
      return await ApiService.submitQuizAttempt(
        quizId: quizId,
        answers: answers,
        duration: duration,
        token: token,
      );
    } on ApiException catch (e) {
      throw RepositoryException('Failed to submit quiz attempt: ${e.message}', e.statusCode);
    } on NetworkException catch (e) {
      throw RepositoryException('Network error: ${e.message}');
    } catch (e) {
      throw RepositoryException('Unexpected error: $e');
    }
  }

  Future<List<QuizAttempt>> getUserAttempts({
    required String userId,
    String? quizId,
    int page = 1,
    int limit = 20,
    required String token,
  }) async {
    try {
      return await ApiService.fetchUserAttempts(
        userId: userId,
        quizId: quizId,
        page: page,
        limit: limit,
        token: token,
      );
    } on ApiException catch (e) {
      throw RepositoryException('Failed to fetch user attempts: ${e.message}', e.statusCode);
    } on NetworkException catch (e) {
      throw RepositoryException('Network error: ${e.message}');
    } catch (e) {
      throw RepositoryException('Unexpected error: $e');
    }
  }

  Future<UserStats> getUserStats({
    required String userId,
    required String token,
  }) async {
    try {
      return await ApiService.fetchUserStats(
        userId: userId,
        token: token,
      );
    } on ApiException catch (e) {
      throw RepositoryException('Failed to fetch user stats: ${e.message}', e.statusCode);
    } on NetworkException catch (e) {
      throw RepositoryException('Network error: ${e.message}');
    } catch (e) {
      throw RepositoryException('Unexpected error: $e');
    }
  }

  Future<void> saveQuizProgress({
    required String quizId,
    required QuizProgress progress,
    required String token,
  }) async {
    try {
      await ApiService.saveQuizProgress(
        quizId: quizId,
        progress: progress,
        token: token,
      );
    } on ApiException catch (e) {
      throw RepositoryException('Failed to save quiz progress: ${e.message}', e.statusCode);
    } on NetworkException catch (e) {
      throw RepositoryException('Network error: ${e.message}');
    } catch (e) {
      throw RepositoryException('Unexpected error: $e');
    }
  }

  Future<QuizProgress?> getQuizProgress({
    required String quizId,
    required String token,
  }) async {
    try {
      return await ApiService.getQuizProgress(
        quizId: quizId,
        token: token,
      );
    } on ApiException catch (e) {
      throw RepositoryException('Failed to fetch quiz progress: ${e.message}', e.statusCode);
    } on NetworkException catch (e) {
      throw RepositoryException('Network error: ${e.message}');
    } catch (e) {
      throw RepositoryException('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getCategories({String? token}) async {
    try {
      return await ApiService.getCategories(token: token);
    } on ApiException catch (e) {
      throw RepositoryException('Failed to fetch categories: ${e.message}', e.statusCode);
    } on NetworkException catch (e) {
      throw RepositoryException('Network error: ${e.message}');
    } catch (e) {
      throw RepositoryException('Unexpected error: $e');
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      return await ApiService.checkServerStatus();
    } catch (e) {
      return false;
    }
  }
}

class RepositoryException implements Exception {
  final String message;
  final int? statusCode;

  RepositoryException(this.message, [this.statusCode]);

  @override
  String toString() => 'RepositoryException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
