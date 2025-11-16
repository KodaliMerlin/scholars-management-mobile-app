import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  // Instance of FirebaseAuth to communicate with Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This creates a stream that will notify the app whenever the user's
  // login state changes (e.g., when they sign in or sign out).
  // The AuthWrapper in your main.dart file listens to this stream.
  Stream<User?> get user => _auth.authStateChanges();

  // Method to sign in with an email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Use the signInWithEmailAndPassword method from the FirebaseAuth package
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // If successful, return the user object
      return result.user;
    } on FirebaseAuthException catch (e) {
      // If there's an error (like a wrong password), print it for debugging
      // and return null to indicate failure.
      debugPrint('Firebase Auth Exception: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      return null;
    }
  }

  // Method to sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
