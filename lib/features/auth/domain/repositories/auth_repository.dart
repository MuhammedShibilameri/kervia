import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  });

  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<UserEntity> signInWithGoogle();

  Future<UserEntity?> getCurrentUser();

  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  });

  Future<void> signOut();
}
