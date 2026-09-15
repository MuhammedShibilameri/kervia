import '../../domain/entities/job_application_entity.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_remote_data_source.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;

  ApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<JobApplicationEntity>> getApplications({
    ApplicationStatus? status,
    String? userId,
  }) {
    return remoteDataSource.getApplications(status: status, userId: userId);
  }

  @override
  Future<void> withdrawApplication(String applicationId) {
    return remoteDataSource.withdrawApplication(applicationId);
  }
}
