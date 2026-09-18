import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SendOtpParams {
  final String phoneNumber;
  final Function(String verificationId) onCodeSent;
  final Function(String error) onVerificationFailed;

  const SendOtpParams({
    required this.phoneNumber,
    required this.onCodeSent,
    required this.onVerificationFailed,
  });
}

class SendOtpUseCase {
  final AuthRepository repository;
  SendOtpUseCase(this.repository);

  Future<void> call(SendOtpParams params) {
    return repository.sendOtp(
      phoneNumber: params.phoneNumber,
      onCodeSent: params.onCodeSent,
      onVerificationFailed: params.onVerificationFailed,
    );
  }
}

class VerifyOtpParams {
  final String verificationId;
  final String smsCode;

  const VerifyOtpParams({
    required this.verificationId,
    required this.smsCode,
  });
}

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<UserEntity> call(VerifyOtpParams params) {
    return repository.verifyOtp(
      verificationId: params.verificationId,
      smsCode: params.smsCode,
    );
  }
}

class SignInWithGoogleUseCase {
  final AuthRepository repository;
  SignInWithGoogleUseCase(this.repository);

  Future<UserEntity> call() {
    return repository.signInWithGoogle();
  }
}

class UpdateUserRoleParams {
  final String userId;
  final UserRole role;

  const UpdateUserRoleParams({
    required this.userId,
    required this.role,
  });
}

class UpdateUserRoleUseCase {
  final AuthRepository repository;
  UpdateUserRoleUseCase(this.repository);

  Future<void> call(UpdateUserRoleParams params) {
    return repository.updateUserRole(
      userId: params.userId,
      role: params.role,
    );
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}
