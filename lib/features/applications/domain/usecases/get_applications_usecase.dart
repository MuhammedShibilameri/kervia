import '../entities/job_application_entity.dart';
import '../repositories/application_repository.dart';

class GetApplicationsUseCase {
  final ApplicationRepository repository;
  GetApplicationsUseCase(this.repository);

  Future<List<JobApplicationEntity>> call({
    ApplicationStatus status = ApplicationStatus.all,
    String? userId,
  }) {
    return repository.getApplications(status: status, userId: userId);
  }
}
