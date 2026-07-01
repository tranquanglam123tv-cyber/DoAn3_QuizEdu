import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthHelper {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Future<GoogleSignInAccount?> _ensureWebSignIn() async {
    if (kIsWeb) {
      try {
        return await _googleSignIn.signInSilently();
      } catch (_) {
        return await _googleSignIn.signIn();
      }
    }
    return _googleSignIn.signIn();
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final account = await _ensureWebSignIn();
      if (account == null) return null;

      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Không thể đăng nhập Google: $e');
    }
  }

  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb && Platform.isAndroid) {
      await _googleSignIn.signOut();
    }
  }
}
