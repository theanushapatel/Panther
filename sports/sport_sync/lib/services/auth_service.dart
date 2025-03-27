import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      if (user == null) throw Exception('User not found');

      // Get user data from Firestore
      final userData = await _getUserData(user.uid);
      return userData;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required String sport,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      if (user == null) throw Exception('Failed to create user');

      // Create user model
      final UserModel userModel = UserModel(
        id: user.uid,
        name: name,
        age: age,
        gender: gender,
        sport: sport,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _saveUserData(userModel);
      
      return userModel;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile(UserModel updatedUser) async {
    try {
      await _saveUserData(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<UserModel> _getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = 
          await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        throw Exception('User data not found');
      }
      
      return UserModel.fromJson({
        'id': uid,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(
        user.toJson()..remove('id'),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  // Handle authentication errors
  Exception _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('Email is already registered.');
        case 'invalid-email':
          return Exception('Invalid email address.');
        case 'weak-password':
          return Exception('Password is too weak.');
        case 'operation-not-allowed':
          return Exception('Operation not allowed.');
        case 'user-disabled':
          return Exception('User account has been disabled.');
        default:
          return Exception('Authentication failed: ${e.message}');
      }
    }
    return Exception('Authentication failed: ${e.toString()}');
  }

  // Verify email
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Reauthenticate user before updating password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Reauthenticate user before deletion
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete user account
      await user.delete();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
}