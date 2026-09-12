import '../../../applications/domain/entities/job_application_entity.dart';
import '../../domain/entities/job_post_entity.dart';
import '../../domain/repositories/company_job_repository.dart';
import '../datasources/company_job_remote_data_source.dart';
import '../models/job_post_model.dart';

class CompanyJobRepositoryImpl implements CompanyJobRepository {
  final CompanyJobRemoteDataSource remoteDataSource;

  CompanyJobRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> saveJobPost(JobPostEntity job) {
    return remoteDataSource.saveJobPost(JobPostModel.fromEntity(job));
  }

  @override
  Future<List<JobPostEntity>> getCompanyJobs(String companyId) {
    return remoteDataSource.getCompanyJobs(companyId);
  }

  @override
  Future<void> updateJobStatus(String jobId, String status) {
    return remoteDataSource.updateJobStatus(jobId, status);
  }

  @override
  Future<void> deleteJobPost(String jobId) {
    return remoteDataSource.deleteJobPost(jobId);
  }

  @override
  Future<List<JobApplicationEntity>> getApplicationsForCompany(
      String companyId) {
    return remoteDataSource.getApplicationsForCompany(companyId);
  }

  @override
  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus status) {
    return remoteDataSource.updateApplicationStatus(applicationId, status);
  }
}