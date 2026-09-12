import '../entities/job_application_entity.dart';

abstract class ApplicationRepository {
  Future<List<JobApplicationEntity>> getApplications({ApplicationStatus? status});
  Future<void> withdrawApplication(String applicationId);
}
