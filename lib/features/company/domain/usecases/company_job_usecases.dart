import '../../../applications/domain/entities/job_application_entity.dart';
import '../entities/job_post_entity.dart';
import '../repositories/company_job_repository.dart';

class SaveJobPostUseCase {
  final CompanyJobRepository repository;
  SaveJobPostUseCase(this.repository);

  Future<String> call(JobPostEntity job) {
    return repository.saveJobPost(job);
  }
}

class GetCompanyJobsUseCase {
  final CompanyJobRepository repository;
  GetCompanyJobsUseCase(this.repository);

  Future<List<JobPostEntity>> call(String companyId) {
    return repository.getCompanyJobs(companyId);
  }
}

class UpdateJobStatusUseCase {
  final CompanyJobRepository repository;
  UpdateJobStatusUseCase(this.repository);

  Future<void> call(String jobId, String status) {
    return repository.updateJobStatus(jobId, status);
  }
}

class DeleteJobPostUseCase {
  final CompanyJobRepository repository;
  DeleteJobPostUseCase(this.repository);

  Future<void> call(String jobId) {
    return repository.deleteJobPost(jobId);
  }
}

class GetCompanyApplicationsUseCase {
  final CompanyJobRepository repository;
  GetCompanyApplicationsUseCase(this.repository);

  Future<List<JobApplicationEntity>> call(String companyId) {
    return repository.getApplicationsForCompany(companyId);
  }
}

class UpdateApplicationStatusUseCase {
  final CompanyJobRepository repository;
  UpdateApplicationStatusUseCase(this.repository);

  Future<void> call(String applicationId, ApplicationStatus status) {
    return repository.updateApplicationStatus(applicationId, status);
  }
}