import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kervia/core/l10n/kervia_l10n.dart';
import 'package:kervia/core/theme/app_theme.dart';
import 'package:kervia/features/auth/domain/entities/user_entity.dart';
import 'package:kervia/features/auth/domain/repositories/auth_repository.dart';
import 'package:kervia/features/auth/domain/usecases/auth_usecases.dart';
import 'package:kervia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kervia/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:kervia/features/auth/presentation/pages/sign_in_page.dart';
import 'package:kervia/features/job_seeker/presentation/pages/job_seeker_registration_page.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<UserEntity?> getCurrentUser() => throw UnimplementedError();

  @override
  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() => throw UnimplementedError();
}

void main() {
  const user = UserEntity(
    id: 'test_user_1',
    email: 'jane.doe@example.com',
    displayName: 'Jane Doe',
  );

  AuthBloc buildBloc() {
    final repository = _FakeAuthRepository();
    return AuthBloc(
      sendOtpUseCase: SendOtpUseCase(repository),
      verifyOtpUseCase: VerifyOtpUseCase(repository),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
      updateUserRoleUseCase: UpdateUserRoleUseCase(repository),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      signOutUseCase: SignOutUseCase(repository),
    );
  }

  Widget otpPage() => BlocProvider<AuthBloc>(
        create: (_) => buildBloc(),
        child: const OtpVerificationPage(
          verificationId: 'test-verification-id',
          phoneNumber: '+10000000000',
        ),
      );

  Widget signInPage() => BlocProvider<AuthBloc>(
        create: (_) => buildBloc(),
        child: const SignInPage(),
      );

  testWidgets('Sign-in page renders without overflow at 360 width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: signInPage(),
      ),
    );
    await tester.pump();
  });

  testWidgets('Sign-in page renders without overflow at 411 width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(411, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: signInPage(),
      ),
    );
    await tester.pump();
  });

  testWidgets('Step1 registration renders without overflow at 360 width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const JobSeekerRegistrationPage(user: user),
      ),
    );
  });

  testWidgets('Step1 registration renders without overflow at 411 width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(411, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const JobSeekerRegistrationPage(user: user),
      ),
    );
  });

  testWidgets('OTP page renders without overflow at 360 width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: otpPage(),
      ),
    );

    // Advance past the resend countdown so the periodic timer cancels itself.
    await tester.pump(const Duration(seconds: 60));
  });

  testWidgets('OTP page renders without overflow at 411 width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(411, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: otpPage(),
      ),
    );

    await tester.pump(const Duration(seconds: 60));
  });
}