import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Auth remote data source interface
abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges;

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Delete account and all user data (Firestore user doc + health briefs, then Firebase Auth user)
  Future<void> deleteAccount();
}

/// Auth remote data source implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'User not found');
      }

      return UserModel.fromFirebaseUser(
        user.uid,
        user.email,
        user.displayName,
        user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed', code: e.code);
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'Failed to create user');
      }

      // Update display name
      await user.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Registration failed', code: e.code);
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Google sign in was cancelled', code: 'cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(message: 'Failed to sign in with Google');
      }

      final userModel = UserModel.fromFirebaseUser(
        user.uid,
        user.email,
        user.displayName,
        user.photoURL,
      );

      // Fire-and-forget: write user doc so sign-in is not blocked by Firestore
      firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore(), SetOptions(merge: true))
          .catchError((_) {});

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Google sign in failed', code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(message: 'Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    return UserModel.fromFirebaseUser(
      user.uid,
      user.email,
      user.displayName,
      user.photoURL,
    );
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(
        user.uid,
        user.email,
        user.displayName,
        user.photoURL,
      );
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Failed to send reset email', code: e.code);
    }
  }

  static const int _batchSize = 500;

  @override
  Future<void> deleteAccount() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'No user signed in', code: 'no-user');
    }
    final uid = user.uid;

    try {
      // 1. Delete all health briefs for this user (batched)
      final briefsRef = firestore.collection(AppConstants.healthBriefsCollection);
      Query<Map<String, dynamic>> query = briefsRef.where('userId', isEqualTo: uid);
      while (true) {
        final snapshot = await query.limit(_batchSize).get();
        if (snapshot.docs.isEmpty) break;
        final batch = firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (snapshot.docs.length < _batchSize) break;
      }

      // 2. Delete user document
      await firestore.collection(AppConstants.usersCollection).doc(uid).delete();

      // 3. Delete Firebase Auth user (may throw requires-recent-login)
      await user.delete();

      // 4. Sign out (e.g. clear Google Sign-In)
      await signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Failed to delete account', code: e.code);
    } on FirebaseException catch (e) {
      throw AuthException(message: e.message ?? 'Failed to delete your data', code: e.code);
    }
  }
}
