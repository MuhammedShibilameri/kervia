import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  }) {
    return remoteDataSource.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
    );
  }

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) {
    return remoteDataSource.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  @override
  Future<UserEntity> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) {
    return remoteDataSource.updateUserRole(
      userId: userId,
      role: role,
    );
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }
}
