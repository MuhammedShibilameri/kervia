import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/job_seeker_profile_entity.dart';
import '../../domain/usecases/job_seeker_usecases.dart';

// --- Events ---
abstract class JobSeekerEvent extends Equatable {
  const JobSeekerEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobSeekerProfileEvent extends JobSeekerEvent {
  final String userId;
  const LoadJobSeekerProfileEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateJobSeekerProfileEvent extends JobSeekerEvent {
  final JobSeekerProfileEntity profile;
  const UpdateJobSeekerProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SaveJobSeekerDraftEvent extends JobSeekerEvent {
  final JobSeekerProfileEntity profile;
  const SaveJobSeekerDraftEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SubmitJobSeekerRegistrationEvent extends JobSeekerEvent {
  final JobSeekerProfileEntity profile;
  const SubmitJobSeekerRegistrationEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

// --- States ---
abstract class JobSeekerState extends Equatable {
  const JobSeekerState();

  @override
  List<Object?> get props => [];
}

class JobSeekerInitial extends JobSeekerState {}

class JobSeekerLoading extends JobSeekerState {
  final String message;
  const JobSeekerLoading([this.message = 'Please wait...']);

  @override
  List<Object?> get props => [message];
}

class JobSeekerLoaded extends JobSeekerState {
  final JobSeekerProfileEntity profile;
  const JobSeekerLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class JobSeekerDraftSaved extends JobSeekerState {
  final JobSeekerProfileEntity profile;
  const JobSeekerDraftSaved(this.profile);

  @override
  List<Object?> get props => [profile];
}

class JobSeekerSubmitted extends JobSeekerState {
  final JobSeekerProfileEntity profile;
  const JobSeekerSubmitted(this.profile);

  @override
  List<Object?> get props => [profile];
}

class JobSeekerError extends JobSeekerState {
  final String message;
  const JobSeekerError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class JobSeekerBloc extends Bloc<JobSeekerEvent, JobSeekerState> {
  final SaveJobSeekerDraftUseCase saveDraftUseCase;
  final SubmitJobSeekerRegistrationUseCase submitRegistrationUseCase;
  final GetJobSeekerProfileUseCase getProfileUseCase;

  JobSeekerBloc({
    required this.saveDraftUseCase,
    required this.submitRegistrationUseCase,
    required this.getProfileUseCase,
  }) : super(JobSeekerInitial()) {
    on<LoadJobSeekerProfileEvent>(_onLoadProfile);
    on<UpdateJobSeekerProfileEvent>(_onUpdateProfile);
    on<SaveJobSeekerDraftEvent>(_onSaveDraft);
    on<SubmitJobSeekerRegistrationEvent>(_onSubmitRegistration);
  }

  Future<void> _onLoadProfile(
    LoadJobSeekerProfileEvent event,
    Emitter<JobSeekerState> emit,
  ) async {
    emit(const JobSeekerLoading('Loading profile...'));
    try {
      final profile = await getProfileUseCase(event.userId);
      if (profile != null) {
        emit(JobSeekerLoaded(profile));
      } else {
        emit(JobSeekerLoaded(JobSeekerProfileEntity(userId: event.userId)));
      }
    } catch (e) {
      emit(JobSeekerError(e.toString()));
    }
  }

  void _onUpdateProfile(
    UpdateJobSeekerProfileEvent event,
    Emitter<JobSeekerState> emit,
  ) {
    emit(JobSeekerLoaded(event.profile));
  }

  Future<void> _onSaveDraft(
    SaveJobSeekerDraftEvent event,
    Emitter<JobSeekerState> emit,
  ) async {
    emit(const JobSeekerLoading('Saving draft...'));
    try {
      await saveDraftUseCase(event.profile);
      emit(JobSeekerDraftSaved(event.profile));
      emit(JobSeekerLoaded(event.profile));
    } catch (e) {
      emit(JobSeekerError('Failed to save draft: $e'));
    }
  }

  Future<void> _onSubmitRegistration(
    SubmitJobSeekerRegistrationEvent event,
    Emitter<JobSeekerState> emit,
  ) async {
    emit(const JobSeekerLoading('Submitting registration...'));
    try {
      await submitRegistrationUseCase(event.profile);
      emit(JobSeekerSubmitted(event.profile));
    } catch (e) {
      emit(JobSeekerError('Failed to submit registration: $e'));
    }
  }
}
