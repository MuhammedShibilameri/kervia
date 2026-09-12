import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../applications/domain/entities/job_application_entity.dart';
import '../../domain/entities/company_profile_entity.dart';
import '../../domain/entities/job_post_entity.dart';
import '../../domain/usecases/company_job_usecases.dart';

// --- Events ---
abstract class CompanyJobEvent extends Equatable {
  const CompanyJobEvent();
  @override
  List<Object?> get props => [];
}

class LoadCompanyJobsEvent extends CompanyJobEvent {
  final String companyId;
  const LoadCompanyJobsEvent(this.companyId);
  @override
  List<Object?> get props => [companyId];
}

class SaveJobPostEvent extends CompanyJobEvent {
  final JobPostEntity job;
  final CompanyProfileEntity companyProfile;
  const SaveJobPostEvent(this.job, {required this.companyProfile});
  @override
  List<Object?> get props => [job, companyProfile];
}

class UpdateJobStatusEvent extends CompanyJobEvent {
  final String jobId;
  final String status;
  const UpdateJobStatusEvent(this.jobId, this.status);
  @override
  List<Object?> get props => [jobId, status];
}

class DeleteJobPostEvent extends CompanyJobEvent {
  final String jobId;
  const DeleteJobPostEvent(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class UpdateApplicationStatusEvent extends CompanyJobEvent {
  final String applicationId;
  final ApplicationStatus status;
  const UpdateApplicationStatusEvent(this.applicationId, this.status);
  @override
  List<Object?> get props => [applicationId, status];
}

// --- States ---
abstract class CompanyJobState extends Equatable {
  const CompanyJobState();
  @override
  List<Object?> get props => [];
}

class CompanyJobInitial extends CompanyJobState {}

class CompanyJobLoading extends CompanyJobState {
  final String message;
  const CompanyJobLoading([this.message = 'Please wait...']);
  @override
  List<Object?> get props => [message];
}

class CompanyJobLoaded extends CompanyJobState {
  final List<JobPostEntity> jobs;
  final List<JobApplicationEntity> applications;
  const CompanyJobLoaded({
    this.jobs = const [],
    this.applications = const [],
  });
  @override
  List<Object?> get props => [jobs, applications];
}

class CompanyJobSaved extends CompanyJobState {
  final JobPostEntity job;
  const CompanyJobSaved(this.job);
  @override
  List<Object?> get props => [job];
}

class CompanyJobError extends CompanyJobState {
  final String message;
  const CompanyJobError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class CompanyJobBloc extends Bloc<CompanyJobEvent, CompanyJobState> {
  final SaveJobPostUseCase saveJobPostUseCase;
  final GetCompanyJobsUseCase getCompanyJobsUseCase;
  final UpdateJobStatusUseCase updateJobStatusUseCase;
  final DeleteJobPostUseCase deleteJobPostUseCase;
  final GetCompanyApplicationsUseCase getApplicationsUseCase;
  final UpdateApplicationStatusUseCase updateApplicationStatusUseCase;

  CompanyJobBloc({
    required this.saveJobPostUseCase,
    required this.getCompanyJobsUseCase,
    required this.updateJobStatusUseCase,
    required this.deleteJobPostUseCase,
    required this.getApplicationsUseCase,
    required this.updateApplicationStatusUseCase,
  }) : super(CompanyJobInitial()) {
    on<LoadCompanyJobsEvent>(_onLoad);
    on<SaveJobPostEvent>(_onSaveJob);
    on<UpdateJobStatusEvent>(_onUpdateJobStatus);
    on<DeleteJobPostEvent>(_onDeleteJob);
    on<UpdateApplicationStatusEvent>(_onUpdateApplicationStatus);
  }

  Future<void> _onLoad(
    LoadCompanyJobsEvent event,
    Emitter<CompanyJobState> emit,
  ) async {
    emit(const CompanyJobLoading('Loading company jobs...'));
    try {
      final jobs = await getCompanyJobsUseCase(event.companyId);
      final applications =
          await getApplicationsUseCase(event.companyId);
      emit(CompanyJobLoaded(jobs: jobs, applications: applications));
    } catch (e) {
      emit(CompanyJobError(e.toString()));
    }
  }

  Future<void> _onSaveJob(
    SaveJobPostEvent event,
    Emitter<CompanyJobState> emit,
  ) async {
    emit(const CompanyJobLoading('Saving job...'));
    try {
      final companyProfile = event.companyProfile;
      final job = event.job.copyWith(
        companyName: companyProfile.companyName.isNotEmpty
            ? companyProfile.companyName
            : event.job.companyName,
        aboutCompany: companyProfile.about.isNotEmpty
            ? companyProfile.about
            : event.job.aboutCompany,
        publishedDate: event.job.publishedDate.isEmpty
            ? _formatDate(DateTime.now())
            : event.job.publishedDate,
      );
      await saveJobPostUseCase(job);
      emit(CompanyJobSaved(job));
      final stateJobs = state is CompanyJobLoaded
          ? (state as CompanyJobLoaded).jobs
          : const <JobPostEntity>[];
      final existingIndex = stateJobs.indexWhere((j) => j.id == job.id);
      final updatedJobs = existingIndex >= 0
          ? [
              ...stateJobs.sublist(0, existingIndex),
              job,
              ...stateJobs.sublist(existingIndex + 1),
            ]
          : [job, ...stateJobs];
      final applications = state is CompanyJobLoaded
          ? (state as CompanyJobLoaded).applications
          : const <JobApplicationEntity>[];
      emit(CompanyJobLoaded(jobs: updatedJobs, applications: applications));
    } catch (e) {
      emit(CompanyJobError('Failed to save job: $e'));
    }
  }

  Future<void> _onUpdateJobStatus(
    UpdateJobStatusEvent event,
    Emitter<CompanyJobState> emit,
  ) async {
    try {
      await updateJobStatusUseCase(event.jobId, event.status);
      if (state is CompanyJobLoaded) {
        final current = state as CompanyJobLoaded;
        final updatedJobs = current.jobs
            .map((j) => j.id == event.jobId
                ? j.copyWith(jobStatus: event.status)
                : j)
            .toList();
        emit(CompanyJobLoaded(
          jobs: updatedJobs,
          applications: current.applications,
        ));
      }
    } catch (e) {
      emit(CompanyJobError('Failed to update job status: $e'));
    }
  }

  Future<void> _onDeleteJob(
    DeleteJobPostEvent event,
    Emitter<CompanyJobState> emit,
  ) async {
    try {
      await deleteJobPostUseCase(event.jobId);
      if (state is CompanyJobLoaded) {
        final current = state as CompanyJobLoaded;
        emit(CompanyJobLoaded(
          jobs: current.jobs.where((j) => j.id != event.jobId).toList(),
          applications: current.applications,
        ));
      }
    } catch (e) {
      emit(CompanyJobError('Failed to delete job: $e'));
    }
  }

  Future<void> _onUpdateApplicationStatus(
    UpdateApplicationStatusEvent event,
    Emitter<CompanyJobState> emit,
  ) async {
    try {
      await updateApplicationStatusUseCase(event.applicationId, event.status);
      if (state is CompanyJobLoaded) {
        final current = state as CompanyJobLoaded;
        final updatedApps = current.applications
            .map((a) => a.id == event.applicationId
                ? a.copyWith(status: event.status)
                : a)
            .toList();
        emit(CompanyJobLoaded(
          jobs: current.jobs,
          applications: updatedApps,
        ));
      }
    } catch (e) {
      emit(CompanyJobError('Failed to update application status: $e'));
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = date.day;
    final suffix = switch (day) {
      1 || 21 || 31 => 'st',
      2 || 22 => 'nd',
      3 || 23 => 'rd',
      _ => 'th',
    };
    return '$day$suffix-${months[date.month - 1]}-${date.year}';
  }
}