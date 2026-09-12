import '../../domain/entities/company_profile_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_data_source.dart';
import '../models/company_profile_model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> saveProfile(CompanyProfileEntity profile) {
    final model = CompanyProfileModel.fromEntity(profile);
    return remoteDataSource.saveProfile(model);
  }

  @override
  Future<CompanyProfileEntity?> getProfile(String userId) {
    return remoteDataSource.getProfile(userId);
  }
}
