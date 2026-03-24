import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppUtils {
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String formatScore(int score, int total) {
    return '$score/$total';
  }

  static double calculatePercentage(int score, int total) {
    if (total == 0) return 0.0;
    return (score / total) * 100;
  }

  static String getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '#22C55E';
      case 'medium':
        return '#FACC15';
      case 'hard':
        return '#EF4444';
      default:
        return '#3B82F6';
    }
  }

  static Future<void> hapticFeedback() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore haptic feedback errors
    }
  }

  static Future<void> hapticFeedbackError() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignore haptic feedback errors
    }
  }

  static Future<void> hapticFeedbackSuccess() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignore haptic feedback errors
    }
  }

  static String generateShareLink(String slug) {
    return 'https://quizking.ai/quiz?slug=$slug';
  }

  static String generateResultShareText(String quizTitle, int score, int total) {
    final percentage = calculatePercentage(score, total);
    return '🎯 I scored $score/$total ($percentage.toStringAsFixed(0)}%) in "$quizTitle" on Prepking AI! Can you beat my score?';
  }

  static bool isExpired(int timestamp, int durationMillis) {
    return DateTime.now().millisecondsSinceEpoch - timestamp > durationMillis;
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static Color getColorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  static String getRelativeTime(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  static int calculateStreak(List<int> attemptDays) {
    if (attemptDays.isEmpty) return 0;
    
    final sortedDays = List<int>.from(attemptDays)..sort();
    final today = DateTime.now();
    int streak = 0;
    
    for (int i = sortedDays.length - 1; i >= 0; i--) {
      final attemptDate = DateTime.fromMillisecondsSinceEpoch(sortedDays[i]);
      final daysDiff = today.difference(DateTime(attemptDate.year, attemptDate.month, attemptDate.day)).inDays;
      
      if (daysDiff == streak) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  static List<T> shuffleList<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    final random = Random();
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String camelCaseToTitle(String text) {
    return text
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .replaceAll(RegExp(r'^\s+'), '')
        .capitalize();
  }
}
