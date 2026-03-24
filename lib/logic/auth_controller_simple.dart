import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../core/constants.dart';
import '../core/utils.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthController extends ChangeNotifier {
  // State
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;
  
  // User Data
  User? _currentUser;
  User? _userProfile;
  
  // Getters
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  User? get userProfile => _userProfile;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;

  // Initialize
  Future<void> initialize() async {
    _setStatus(AuthStatus.loading);
    
    try {
      // Check for existing session (simplified)
      // This would integrate with Firebase/Google Sign-In
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _setError('Authentication initialization failed: $e');
    }
  }

  // Mock Google Sign-In for now
  Future<void> signInWithGoogle() async {
    _setStatus(AuthStatus.loading);
    
    try {
      // Mock user for testing
      final mockUser = User(
        id: 'mock_user_id',
        email: 'user@example.com',
        name: 'Test User',
        role: UserRole.student,
        totalQuizzesTaken: 0,
        totalScore: 0,
        averageScore: 0.0,
        streak: 0,
        longestStreak: 0,
        joinedAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        preferences: {
          'sound_enabled': true,
          'vibration_enabled': true,
          'dark_mode': true,
          'notifications_enabled': true,
        },
        achievements: [],
        level: 1,
        experiencePoints: 0,
      );
      
      _currentUser = mockUser;
      _userProfile = mockUser;
      _setStatus(AuthStatus.authenticated);
      AppUtils.hapticFeedbackSuccess();
    } catch (e) {
      _setError('Google sign-in failed: $e');
      AppUtils.hapticFeedbackError();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setStatus(AuthStatus.loading);
    
    try {
      // Clear local data
      _currentUser = null;
      _userProfile = null;
      
      _setStatus(AuthStatus.unauthenticated);
      AppUtils.hapticFeedback();
    } catch (e) {
      _setError('Sign out failed: $e');
    }
  }

  // Update User Profile
  Future<void> updateProfile({
    String? name,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) async {
    if (!isAuthenticated || _currentUser == null) return;
    
    _setStatus(AuthStatus.loading);
    
    try {
      // Update local user data
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        avatar: avatar ?? _currentUser!.avatar,
        preferences: preferences ?? _currentUser!.preferences,
      );
      
      _userProfile = _userProfile!.copyWith(
        name: name ?? _userProfile!.name,
        avatar: avatar ?? _userProfile!.avatar,
        preferences: preferences ?? _userProfile!.preferences,
      );
      
      _setStatus(AuthStatus.authenticated);
      AppUtils.hapticFeedbackSuccess();
    } catch (e) {
      _setError('Profile update failed: $e');
      AppUtils.hapticFeedbackError();
    }
  }

  // Refresh User Data
  Future<void> refreshUserData() async {
    if (!isAuthenticated || _currentUser == null) return;
    
    _setStatus(AuthStatus.loading);
    
    try {
      // Mock refresh - would fetch from backend
      _setStatus(AuthStatus.authenticated);
    } catch (e) {
      _setError('Failed to refresh user data: $e');
    }
  }

  // State Management
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Get User Initials
  String getUserInitials() {
    if (_currentUser == null) return '';
    return _currentUser!.initials;
  }

  // Get Display Name
  String getDisplayName() {
    if (_currentUser == null) return 'Guest';
    return _currentUser!.name;
  }

  // Get User Level Info
  Map<String, dynamic> getLevelInfo() {
    if (_userProfile == null) {
      return {'level': 1, 'currentXP': 0, 'nextLevelXP': 100, 'progress': 0.0};
    }

    final level = _userProfile!.level;
    final currentXP = _userProfile!.experiencePoints;
    final nextLevelXP = level * 100; // Simple progression
    final progress = currentXP / nextLevelXP;

    return {
      'level': level,
      'currentXP': currentXP,
      'nextLevelXP': nextLevelXP,
      'progress': progress,
    };
  }

  // Check Achievement
  bool hasAchievement(String achievementId) {
    if (_userProfile == null) return false;
    return _userProfile!.achievements.contains(achievementId);
  }

  // Add Achievement
  Future<void> addAchievement(String achievementId) async {
    if (!isAuthenticated || _userProfile == null) return;
    
    if (hasAchievement(achievementId)) return;
    
    try {
      final updatedAchievements = List<String>.from(_userProfile!.achievements)..add(achievementId);
      
      _userProfile = _userProfile!.copyWith(achievements: updatedAchievements);
      _currentUser = _currentUser!.copyWith(achievements: updatedAchievements);
      
      AppUtils.hapticFeedbackSuccess();
    } catch (e) {
      // Non-critical if backend fails
    }
  }

  // Update Preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await updateProfile(preferences: preferences);
  }

  // Get Preference
  T? getPreference<T>(String key, [T? defaultValue]) {
    if (_userProfile == null) return defaultValue;
    return _userProfile!.preferences[key] as T? ?? defaultValue;
  }

  // Dispose
  @override
  void dispose() {
    super.dispose();
  }
}
