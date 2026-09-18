import '../entities/job_seeker_profile_entity.dart';
import '../repositories/job_seeker_repository.dart';

class SaveJobSeekerDraftUseCase {
  final JobSeekerRepository repository;
  SaveJobSeekerDraftUseCase(this.repository);

  Future<void> call(JobSeekerProfileEntity profile) {
    return repository.saveDraft(profile);
  }
}

class SubmitJobSeekerRegistrationUseCase {
  final JobSeekerRepository repository;
  SubmitJobSeekerRegistrationUseCase(this.repository);

  Future<void> call(JobSeekerProfileEntity profile) {
    return repository.submitRegistration(profile);
  }
}

class GetJobSeekerProfileUseCase {
  final JobSeekerRepository repository;
  GetJobSeekerProfileUseCase(this.repository);

  Future<JobSeekerProfileEntity?> call(String userId) {
    return repository.getProfile(userId);
  }
}
