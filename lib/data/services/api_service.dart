import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import '../models/user.dart';
import '../../core/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<List<Quiz>> fetchQuizzes({
    String? category,
    String? difficulty,
    String? search,
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? token,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (search != null) queryParams['search'] = search;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.quizzesEndpoint}').replace(queryParameters: queryParams),
        headers: await _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Quiz.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to fetch quizzes', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<Quiz> fetchQuizBySlug(String slug, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.quizEndpoint}?slug=$slug'),
        headers: await _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Quiz.fromJson(data);
      } else if (response.statusCode == 404) {
        throw ApiException('Quiz not found', 404);
      } else {
        throw ApiException('Failed to fetch quiz', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<List<LeaderboardEntry>> fetchLeaderboard({
    String? category,
    String? timeFrame, // 'daily', 'weekly', 'monthly', 'all'
    int limit = 50,
    String? token,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (timeFrame != null) queryParams['time_frame'] = timeFrame;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.leaderboardEndpoint}').replace(queryParameters: queryParams),
        headers: await _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaderboardEntry.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to fetch leaderboard', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<QuizAttempt> submitQuizAttempt({
    required String quizId,
    required List<int> answers,
    required int duration,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/attempts'),
        headers: await _getHeaders(token: token),
        body: jsonEncode({
          'quiz_id': quizId,
          'answers': answers,
          'duration': duration,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return QuizAttempt.fromJson(data);
      } else {
        throw ApiException('Failed to submit quiz attempt', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<List<QuizAttempt>> fetchUserAttempts({
    required String userId,
    String? quizId,
    int page = 1,
    int limit = 20,
    required String token,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (quizId != null) queryParams['quiz_id'] = quizId;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/attempts').replace(queryParameters: queryParams),
        headers: await _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => QuizAttempt.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to fetch user attempts', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<UserStats> fetchUserStats({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.userProgressEndpoint}/$userId/stats'),
        headers: await _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserStats.fromJson(data);
      } else {
        throw ApiException('Failed to fetch user stats', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<void> saveQuizProgress({
    required String quizId,
    required QuizProgress progress,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.userProgressEndpoint}'),
        headers: await _getHeaders(token: token),
        body: jsonEncode({
          'quiz_id': quizId,
          'progress': progress.toJson(),
        }),
      );

      if (response.statusCode != 200) {
        throw ApiException('Failed to save quiz progress', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<QuizProgress?> getQuizProgress({
    required String quizId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.userProgressEndpoint}/$quizId'),
        headers: await _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return QuizProgress.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ApiException('Failed to fetch quiz progress', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<Map<String, dynamic>> getCategories({String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/categories'),
        headers: await _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Failed to fetch categories', response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  static Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/health'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
