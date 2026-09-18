import '../../domain/entities/job_seeker_profile_entity.dart';
import '../../domain/repositories/job_seeker_repository.dart';
import '../datasources/job_seeker_remote_data_source.dart';
import '../models/job_seeker_profile_model.dart';

class JobSeekerRepositoryImpl implements JobSeekerRepository {
  final JobSeekerRemoteDataSource remoteDataSource;

  JobSeekerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> saveDraft(JobSeekerProfileEntity profile) {
    final model = JobSeekerProfileModel.fromEntity(profile);
    return remoteDataSource.saveProfile(model);
  }

  @override
  Future<void> submitRegistration(JobSeekerProfileEntity profile) {
    final model = JobSeekerProfileModel.fromEntity(
      profile.copyWith(isSubmitted: true, stepCompleted: 3),
    );
    return remoteDataSource.saveProfile(model);
  }

  @override
  Future<JobSeekerProfileEntity?> getProfile(String userId) {
    return remoteDataSource.getProfile(userId);
  }
}
