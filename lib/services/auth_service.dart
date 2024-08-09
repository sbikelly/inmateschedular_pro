import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inmateschedular_pro/util/toast.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? user;

  AuthService() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      this.user = user;
      notifyListeners();
    });
  }

  bool get isAuthenticated {
    try {
      // Check if user is not null and has a valid email
      return user != null && user!.email != null && user!.email!.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking authentication status: $e');
      return false;
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address already exists', err: true);
      } else {
        debugPrint('Firebase error during sign up: $e');
      }
    }
    return null;
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Invalid email or password.', err: true);
      } else {
        showToast(message: 'An error occurred: ${e.code}', err: true);
        debugPrint('Firebase error during sign in: $e');
      }
    }
    return null;
  }

  Future<void> checkAuthState() async {
    user = _firebaseAuth.currentUser;
    if (user == null) {
      await signOut();
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }

  Future<void> deleteUser(String email) async {
    try {
      if (user != null && user!.email == email) {
        await user!.delete();
        user = null;
        showToast(message: 'User deleted successfully.', err: false);
      } else {
        showToast(message: 'No user found with the provided email.', err: true);
      }
    } on FirebaseAuthException catch (e) {
      showToast(message: 'An error occurred: ${e.code}', err: true);
      debugPrint('Firebase error during user deletion: $e');
    }
    notifyListeners();
  }

  Future<void> updateUserCredentials({
    required String currentPassword,
    String? newEmail,
    String? newPassword,
    String? newName,
  }) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        if (newEmail != null && newEmail.isNotEmpty) {
          await user.verifyBeforeUpdateEmail(newEmail);
          showToast(message: 'Email updated successfully.', err: false);
        }

        if (newPassword != null && newPassword.isNotEmpty) {
          await user.updatePassword(newPassword);
          showToast(message: 'Password updated successfully.', err: false);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          showToast(message: 'The current password is incorrect.', err: true);
        } else {
          showToast(message: 'An error occurred: ${e.code}', err: true);
        }
        debugPrint('Firebase error during credentials update: $e');
      }
    }
  }
}
