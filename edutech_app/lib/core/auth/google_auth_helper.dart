import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleAuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      if (kIsWeb) {
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // On mobile, signInWithRedirect works with Firebase
        await _auth.setSettings(
          appVerificationDisabledForTesting: false,
        );
        await _auth.signInWithRedirect(googleProvider);
        // Return null - the caller should listen to authStateChanges instead
        return null;
      }
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Không thể đăng nhập Google: $e');
    }
  }

  static User? getCurrentUser() => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
