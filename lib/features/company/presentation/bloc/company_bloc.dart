import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/company_profile_entity.dart';
import '../../domain/usecases/company_usecases.dart';

// --- Events ---
abstract class CompanyEvent extends Equatable {
  const CompanyEvent();
  @override
  List<Object?> get props => [];
}

class LoadCompanyProfileEvent extends CompanyEvent {
  final String userId;
  const LoadCompanyProfileEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class UpdateCompanyProfileEvent extends CompanyEvent {
  final CompanyProfileEntity profile;
  const UpdateCompanyProfileEvent(this.profile);
  @override
  List<Object?> get props => [profile];
}

class SaveCompanyProfileEvent extends CompanyEvent {
  final CompanyProfileEntity profile;
  const SaveCompanyProfileEvent(this.profile);
  @override
  List<Object?> get props => [profile];
}

class SubmitCompanyProfileEvent extends CompanyEvent {
  final CompanyProfileEntity profile;
  const SubmitCompanyProfileEvent(this.profile);
  @override
  List<Object?> get props => [profile];
}

// --- States ---
abstract class CompanyState extends Equatable {
  const CompanyState();
  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {
  final String message;
  const CompanyLoading([this.message = 'Please wait...']);
  @override
  List<Object?> get props => [message];
}

class CompanyLoaded extends CompanyState {
  final CompanyProfileEntity profile;
  const CompanyLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class CompanySaved extends CompanyState {
  final CompanyProfileEntity profile;
  const CompanySaved(this.profile);
  @override
  List<Object?> get props => [profile];
}

class CompanySubmitted extends CompanyState {
  final CompanyProfileEntity profile;
  const CompanySubmitted(this.profile);
  @override
  List<Object?> get props => [profile];
}

class CompanyError extends CompanyState {
  final String message;
  const CompanyError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final SaveCompanyProfileUseCase saveProfileUseCase;
  final GetCompanyProfileUseCase getProfileUseCase;

  CompanyBloc({
    required this.saveProfileUseCase,
    required this.getProfileUseCase,
  }) : super(CompanyInitial()) {
    on<LoadCompanyProfileEvent>(_onLoadProfile);
    on<UpdateCompanyProfileEvent>(_onUpdateProfile);
    on<SaveCompanyProfileEvent>(_onSaveProfile);
    on<SubmitCompanyProfileEvent>(_onSubmitProfile);
  }

  Future<void> _onLoadProfile(
    LoadCompanyProfileEvent event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading('Loading profile...'));
    try {
      final profile = await getProfileUseCase(event.userId);
      if (profile != null) {
        emit(CompanyLoaded(profile));
      } else {
        emit(CompanyLoaded(CompanyProfileEntity(userId: event.userId)));
      }
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  void _onUpdateProfile(
    UpdateCompanyProfileEvent event,
    Emitter<CompanyState> emit,
  ) {
    emit(CompanyLoaded(event.profile));
  }

  Future<void> _onSaveProfile(
    SaveCompanyProfileEvent event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading('Saving profile...'));
    try {
      await saveProfileUseCase(event.profile);
      emit(CompanySaved(event.profile));
      emit(CompanyLoaded(event.profile));
    } catch (e) {
      emit(CompanyError('Failed to save profile: $e'));
    }
  }

  Future<void> _onSubmitProfile(
    SubmitCompanyProfileEvent event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading('Submitting profile...'));
    try {
      final completedProfile = event.profile.copyWith(
        isProfileComplete: true,
        stepCompleted: 3,
      );
      await saveProfileUseCase(completedProfile);
      emit(CompanySubmitted(completedProfile));
    } catch (e) {
      emit(CompanyError('Failed to submit profile: $e'));
    }
  }
}
