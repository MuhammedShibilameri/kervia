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
  final String? userId;
  const LoadApplicationsEvent({
    this.status = ApplicationStatus.all,
    this.userId,
  });

  @override
  List<Object?> get props => [status, userId];
}

class FilterByStatusEvent extends ApplicationEvent {
  final ApplicationStatus status;
  final String? userId;
  const FilterByStatusEvent(this.status, {this.userId});

  @override
  List<Object?> get props => [status, userId];
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
  final String? userId;

  const ApplicationLoaded({
    required this.applications,
    this.selectedStatus = ApplicationStatus.all,
    this.userId,
  });

  @override
  List<Object?> get props => [applications, selectedStatus, userId];
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
      final apps = await getApplicationsUseCase(
        status: event.status, userId: event.userId);
      emit(ApplicationLoaded(
          applications: apps,
          selectedStatus: event.status,
          userId: event.userId));
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
      final apps = await getApplicationsUseCase(
        status: event.status, userId: event.userId);
      emit(ApplicationLoaded(
          applications: apps,
          selectedStatus: event.status,
          userId: event.userId));
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
      final current = state is ApplicationLoaded
          ? (state as ApplicationLoaded)
          : null;
      final currentStatus = current?.selectedStatus ?? ApplicationStatus.all;
      final userId = current?.userId;
      final apps = await getApplicationsUseCase(
          status: currentStatus, userId: userId);
      emit(ApplicationLoaded(
          applications: apps,
          selectedStatus: currentStatus,
          userId: userId));
    } catch (e) {
      emit(ApplicationError('Failed to withdraw application: $e'));
    }
  }
}
