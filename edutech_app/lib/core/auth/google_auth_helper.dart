import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Use Firebase Auth Google provider directly
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Sign in and get UserCredential
      return await _auth.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Không thể đăng nhập Google: $e');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
