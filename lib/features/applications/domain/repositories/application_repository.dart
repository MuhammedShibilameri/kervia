import '../entities/job_application_entity.dart';

abstract class ApplicationRepository {
  Future<List<JobApplicationEntity>> getApplications({
    ApplicationStatus? status,
    String? userId,
  });
  Future<void> withdrawApplication(String applicationId);
}
