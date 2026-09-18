import '../entities/job_seeker_profile_entity.dart';

abstract class JobSeekerRepository {
  Future<void> saveDraft(JobSeekerProfileEntity profile);
  Future<void> submitRegistration(JobSeekerProfileEntity profile);
  Future<JobSeekerProfileEntity?> getProfile(String userId);
}
