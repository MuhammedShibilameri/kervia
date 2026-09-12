import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/job_application_entity.dart';
import '../../domain/usecases/get_applications_usecase.dart';
import '../../domain/usecases/withdraw_application_usecase.dart';

// --- Events ---
abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];
}

class LoadApplicationsEvent extends ApplicationEvent {
  final ApplicationStatus status;
  const LoadApplicationsEvent({this.status = ApplicationStatus.all});

  @override
  List<Object?> get props => [status];
}

class FilterByStatusEvent extends ApplicationEvent {
  final ApplicationStatus status;
  const FilterByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class WithdrawApplicationEvent extends ApplicationEvent {
  final String applicationId;
  const WithdrawApplicationEvent(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

// --- States ---
abstract class ApplicationState extends Equatable {
  const ApplicationState();

  @override
  List<Object?> get props => [];
}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationLoaded extends ApplicationState {
  final List<JobApplicationEntity> applications;
  final ApplicationStatus selectedStatus;

  const ApplicationLoaded({
    required this.applications,
    this.selectedStatus = ApplicationStatus.all,
  });

  @override
  List<Object?> get props => [applications, selectedStatus];
}

class ApplicationError extends ApplicationState {
  final String message;
  const ApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final GetApplicationsUseCase getApplicationsUseCase;
  final WithdrawApplicationUseCase? withdrawApplicationUseCase;

  ApplicationBloc({
    required this.getApplicationsUseCase,
    this.withdrawApplicationUseCase,
  }) : super(ApplicationInitial()) {
    on<LoadApplicationsEvent>(_onLoadApplications);
    on<FilterByStatusEvent>(_onFilterByStatus);
    on<WithdrawApplicationEvent>(_onWithdrawApplication);
  }

  Future<void> _onLoadApplications(
    LoadApplicationsEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    try {
      final apps = await getApplicationsUseCase(status: event.status);
      emit(ApplicationLoaded(applications: apps, selectedStatus: event.status));
    } catch (e) {
      emit(ApplicationError('Failed to load applications: $e'));
    }
  }

  Future<void> _onFilterByStatus(
    FilterByStatusEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    try {
      final apps = await getApplicationsUseCase(status: event.status);
      emit(ApplicationLoaded(applications: apps, selectedStatus: event.status));
    } catch (e) {
      emit(ApplicationError('Failed to filter applications: $e'));
    }
  }

  Future<void> _onWithdrawApplication(
    WithdrawApplicationEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    try {
      if (withdrawApplicationUseCase != null) {
        await withdrawApplicationUseCase!(event.applicationId);
      }
      final currentStatus = state is ApplicationLoaded
          ? (state as ApplicationLoaded).selectedStatus
          : ApplicationStatus.all;
      final apps = await getApplicationsUseCase(status: currentStatus);
      emit(ApplicationLoaded(applications: apps, selectedStatus: currentStatus));
    } catch (e) {
      emit(ApplicationError('Failed to withdraw application: $e'));
    }
  }
}
