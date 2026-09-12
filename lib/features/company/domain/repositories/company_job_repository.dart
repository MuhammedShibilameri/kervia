import '../../../applications/domain/entities/job_application_entity.dart';
import '../entities/job_post_entity.dart';

abstract class CompanyJobRepository {
  Future<String> saveJobPost(JobPostEntity job);
  Future<List<JobPostEntity>> getCompanyJobs(String companyId);
  Future<void> updateJobStatus(String jobId, String status);
  Future<void> deleteJobPost(String jobId);
  Future<List<JobApplicationEntity>> getApplicationsForCompany(
      String companyId);
  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus status);
}