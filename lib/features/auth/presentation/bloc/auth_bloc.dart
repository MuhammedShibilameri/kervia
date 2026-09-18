import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;
  const SendOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class OtpCodeSentEvent extends AuthEvent {
  final String verificationId;
  final String phoneNumber;
  const OtpCodeSentEvent({required this.verificationId, required this.phoneNumber});

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String smsCode;
  const VerifyOtpEvent({required this.verificationId, required this.smsCode});

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class SignInWithGoogleEvent extends AuthEvent {}

class SelectUserRoleEvent extends AuthEvent {
  final UserRole role;
  const SelectUserRoleEvent(this.role);

  @override
  List<Object?> get props => [role];
}

class SignOutEvent extends AuthEvent {}

class AuthErrorOccurredEvent extends AuthEvent {
  final String message;
  const AuthErrorOccurredEvent(this.message);

  @override
  List<Object?> get props => [message];
}

// --- States ---
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

class OtpSentState extends AuthState {
  final String verificationId;
  final String phoneNumber;
  const OtpSentState({required this.verificationId, required this.phoneNumber});

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

class AuthenticatedState extends AuthState {
  final UserEntity user;
  const AuthenticatedState(this.user);

  @override
  List<Object?> get props => [user];
}

class NeedsRoleSelectionState extends AuthState {
  final UserEntity user;
  const NeedsRoleSelectionState(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignOutUseCase signOutUseCase;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.signInWithGoogleUseCase,
    required this.updateUserRoleUseCase,
    required this.getCurrentUserUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpEvent>(_onSendOtp);
    on<OtpCodeSentEvent>(_onOtpCodeSent);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SelectUserRoleEvent>(_onSelectUserRole);
    on<SignOutEvent>(_onSignOut);
    on<AuthErrorOccurredEvent>(_onAuthErrorOccurred);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading('Checking authentication...'));
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        if (user.role == UserRole.unassigned) {
          emit(NeedsRoleSelectionState(user));
        } else {
          emit(AuthenticatedState(user));
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading('Sending verification code...'));
    try {
      await sendOtpUseCase(SendOtpParams(
        phoneNumber: event.phoneNumber,
        onCodeSent: (verificationId) {
          add(OtpCodeSentEvent(verificationId: verificationId, phoneNumber: event.phoneNumber));
        },
        onVerificationFailed: (error) {
          add(AuthErrorOccurredEvent(error));
        },
      ));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void _onOtpCodeSent(OtpCodeSentEvent event, Emitter<AuthState> emit) {
    emit(OtpSentState(
      verificationId: event.verificationId,
      phoneNumber: event.phoneNumber,
    ));
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading('Verifying OTP...'));
    try {
      final user = await verifyOtpUseCase(VerifyOtpParams(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      ));

      if (user.role == UserRole.unassigned) {
        emit(NeedsRoleSelectionState(user));
      } else {
        emit(AuthenticatedState(user));
      }
    } catch (e) {
      emit(AuthErrorState('Verification failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading('Signing in with Google...'));
    try {
      final user = await signInWithGoogleUseCase();
      if (user.role == UserRole.unassigned) {
        emit(NeedsRoleSelectionState(user));
      } else {
        emit(AuthenticatedState(user));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onSelectUserRole(SelectUserRoleEvent event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is NeedsRoleSelectionState) {
      emit(const AuthLoading('Updating your profile role...'));
      try {
        await updateUserRoleUseCase(UpdateUserRoleParams(
          userId: currentState.user.id,
          role: event.role,
        ));
        final updatedUser = UserEntity(
          id: currentState.user.id,
          phoneNumber: currentState.user.phoneNumber,
          email: currentState.user.email,
          displayName: currentState.user.displayName,
          photoUrl: currentState.user.photoUrl,
          role: event.role,
          isProfileComplete: currentState.user.isProfileComplete,
        );
        emit(AuthenticatedState(updatedUser));
      } catch (e) {
        emit(AuthErrorState('Failed to update role: $e'));
      }
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading('Signing out...'));
    await signOutUseCase();
    emit(AuthInitial());
  }

  void _onAuthErrorOccurred(AuthErrorOccurredEvent event, Emitter<AuthState> emit) {
    emit(AuthErrorState(event.message));
  }
}
