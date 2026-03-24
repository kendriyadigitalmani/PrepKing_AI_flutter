import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../data/models/user.dart';
import '../data/repositories/quiz_repository.dart';
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
  final QuizRepository _repository = QuizRepository();

  // State
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;
  
  // User Data
  User? _currentUser;
  User? _userProfile;
  
  // Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

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
      // Check for existing Firebase session
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        await _loadUserProfile(user.uid);
        _setStatus(AuthStatus.authenticated);
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setError('Authentication initialization failed: $e');
    }
  }

  // Google Sign-In
  Future<void> signInWithGoogle() async {
    _setStatus(AuthStatus.loading);
    
    try {
      // Trigger Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _setStatus(AuthStatus.unauthenticated);
        return;
      }

      // Get authentication details
      final googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
        await _syncUserData(firebaseUser);
        _setStatus(AuthStatus.authenticated);
        AppUtils.hapticFeedbackSuccess();
      } else {
        _setError('Failed to sign in with Google');
      }
    } catch (e) {
      _setError('Google sign-in failed: $e');
      AppUtils.hapticFeedbackError();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setStatus(AuthStatus.loading);
    
    try {
      // Sign out from Firebase
      await firebase_auth.FirebaseAuth.instance.signOut();
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Clear local data
      _currentUser = null;
      _userProfile = null;
      
      _setStatus(AuthStatus.unauthenticated);
      AppUtils.hapticFeedback();
    } catch (e) {
      _setError('Sign out failed: $e');
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    _setStatus(AuthStatus.loading);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Delete user data from backend
        await _deleteUserData(user.uid);
        
        // Delete Firebase account
        await user.delete();
        
        // Sign out from Google
        await _googleSignIn.signOut();
        
        // Clear local data
        _currentUser = null;
        _userProfile = null;
        
        _setStatus(AuthStatus.unauthenticated);
        AppUtils.hapticFeedbackSuccess();
      } else {
        _setError('No user to delete');
      }
    } catch (e) {
      _setError('Account deletion failed: $e');
      AppUtils.hapticFeedbackError();
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
      // Update in backend
      final updatedProfile = await _repository.updateUserProfile(
        userId: _currentUser!.id,
        name: name,
        avatar: avatar,
        preferences: preferences,
      );
      
      if (updatedProfile != null) {
        _userProfile = updatedProfile;
        _currentUser = _currentUser!.copyWith(
          name: name ?? _currentUser!.name,
          avatar: avatar ?? _currentUser!.avatar,
          preferences: preferences ?? _currentUser!.preferences,
        );
      }
      
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
      await _loadUserProfile(_currentUser!.id);
      _setStatus(AuthStatus.authenticated);
    } catch (e) {
      _setError('Failed to refresh user data: $e');
    }
  }

  // Load User Profile
  Future<void> _loadUserProfile(String userId) async {
    try {
      // Try to get user profile from backend
      final userProfile = await _repository.getUserProfile(userId);
      
      if (userProfile != null) {
        _userProfile = userProfile;
        _currentUser = userProfile;
      } else {
        // Create new user profile if doesn't exist
        final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          await _createUserProfile(firebaseUser);
        }
      }
    } catch (e) {
      // If backend fails, create basic user from Firebase data
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await _createUserProfile(firebaseUser);
      }
    }
  }

  // Create User Profile
  Future<void> _createUserProfile(User firebaseUser) async {
    final newUser = User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'User',
      avatar: firebaseUser.photoURL,
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

    try {
      final createdProfile = await _repository.createUserProfile(newUser);
      if (createdProfile != null) {
        _userProfile = createdProfile;
        _currentUser = createdProfile;
      } else {
        // Fallback to local user
        _userProfile = newUser;
        _currentUser = newUser;
      }
    } catch (e) {
      // Fallback to local user if backend fails
      _userProfile = newUser;
      _currentUser = newUser;
    }
  }

  // Sync User Data
  Future<void> _syncUserData(User firebaseUser) async {
    try {
      // Sync user stats and achievements
      await _repository.syncUserStats(firebaseUser.uid);
    } catch (e) {
      // Non-critical, continue
    }
  }

  // Delete User Data
  Future<void> _deleteUserData(String userId) async {
    try {
      await _repository.deleteUserData(userId);
    } catch (e) {
      // Non-critical if backend fails
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
      final updatedProfile = await _repository.addAchievement(
        userId: _currentUser!.id,
        achievementId: achievementId,
      );
      
      if (updatedProfile != null) {
        _userProfile = updatedProfile;
        _currentUser = _currentUser!.copyWith(achievements: updatedProfile.achievements);
        AppUtils.hapticFeedbackSuccess();
      }
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
