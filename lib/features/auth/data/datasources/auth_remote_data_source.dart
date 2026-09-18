import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  });

  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<UserModel> signInWithGoogle();

  Future<UserModel?> getCurrentUser();

  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  });

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (fb.FirebaseAuthException e) {
        onVerificationFailed(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = fb.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final fbUser = userCredential.user;

    if (fbUser == null) {
      throw Exception('Failed to sign in. User is null.');
    }

    // Check if user exists in Firestore
    final userDoc = await _firestore.collection('users').doc(fbUser.uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      return UserModel.fromMap(userDoc.data()!, fbUser.uid);
    } else {
      final newUser = UserModel.fromFirebaseUser(fbUser);
      await _firestore.collection('users').doc(fbUser.uid).set(newUser.toMap());
      return newUser;
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final fb.UserCredential userCredential;
    if (kIsWeb) {
      final googleProvider = fb.GoogleAuthProvider();
      userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled by the user.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _firebaseAuth.signInWithCredential(credential);
    }

    final fbUser = userCredential.user;

    if (fbUser == null) {
      throw Exception('Google Sign-In failed: User is null.');
    }

    final userDoc = await _firestore.collection('users').doc(fbUser.uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      return UserModel.fromMap(userDoc.data()!, fbUser.uid);
    } else {
      final newUser = UserModel.fromFirebaseUser(fbUser);
      await _firestore.collection('users').doc(fbUser.uid).set(newUser.toMap());
      return newUser;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentFbUser = _firebaseAuth.currentUser;
    if (currentFbUser == null) return null;

    final userDoc = await _firestore.collection('users').doc(currentFbUser.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      return UserModel.fromMap(userDoc.data()!, currentFbUser.uid);
    }

    return UserModel.fromFirebaseUser(currentFbUser);
  }

  @override
  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    await _firestore.collection('users').doc(userId).set(
      {
        'role': role.name,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
