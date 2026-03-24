import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole { student, teacher, admin }

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final UserRole role;
  final int totalQuizzesTaken;
  final int totalScore;
  final double averageScore;
  final int streak;
  final int longestStreak;
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> preferences;
  final List<String> achievements;
  final int level;
  final int experiencePoints;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.role,
    required this.totalQuizzesTaken,
    required this.totalScore,
    required this.averageScore,
    required this.streak,
    required this.longestStreak,
    required this.joinedAt,
    required this.lastActiveAt,
    required this.preferences,
    required this.achievements,
    required this.level,
    required this.experiencePoints,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    UserRole? role,
    int? totalQuizzesTaken,
    int? totalScore,
    double? averageScore,
    int? streak,
    int? longestStreak,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
    List<String>? achievements,
    int? level,
    int? experiencePoints,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      totalScore: totalScore ?? this.totalScore,
      averageScore: averageScore ?? this.averageScore,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferences: preferences ?? this.preferences,
      achievements: achievements ?? this.achievements,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  bool get hasStreak => streak > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email}';
  }
}

@JsonSerializable()
class UserStats {
  final String userId;
  final int totalQuizzesTaken;
  final int totalScore;
  final double averageScore;
  final int streak;
  final int longestStreak;
  final Map<String, int> categoryStats; // category -> attempts
  final Map<String, double> categoryScores; // category -> average score
  final List<int> recentActivity; // timestamps of recent quiz attempts
  final DateTime lastActiveAt;

  const UserStats({
    required this.userId,
    required this.totalQuizzesTaken,
    required this.totalScore,
    required this.averageScore,
    required this.streak,
    required this.longestStreak,
    required this.categoryStats,
    required this.categoryScores,
    required this.recentActivity,
    required this.lastActiveAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  UserStats copyWith({
    String? userId,
    int? totalQuizzesTaken,
    int? totalScore,
    double? averageScore,
    int? streak,
    int? longestStreak,
    Map<String, int>? categoryStats,
    Map<String, double>? categoryScores,
    List<int>? recentActivity,
    DateTime? lastActiveAt,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      totalScore: totalScore ?? this.totalScore,
      averageScore: averageScore ?? this.averageScore,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      categoryStats: categoryStats ?? this.categoryStats,
      categoryScores: categoryScores ?? this.categoryScores,
      recentActivity: recentActivity ?? this.recentActivity,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserStats{userId: $userId, totalQuizzesTaken: $totalQuizzesTaken, averageScore: $averageScore}';
  }
}

@JsonSerializable()
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rank;
  final int totalScore;
  final int quizzesTaken;
  final double averageScore;
  final int streak;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rank,
    required this.totalScore,
    required this.quizzesTaken,
    required this.averageScore,
    required this.streak,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntry && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'LeaderboardEntry{userId: $userId, userName: $userName, rank: $rank}';
  }
}
