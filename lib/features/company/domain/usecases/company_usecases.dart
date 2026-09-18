import '../entities/company_profile_entity.dart';
import '../repositories/company_repository.dart';

class SaveCompanyProfileUseCase {
  final CompanyRepository repository;
  SaveCompanyProfileUseCase(this.repository);

  Future<void> call(CompanyProfileEntity profile) {
    return repository.saveProfile(profile);
  }
}

class GetCompanyProfileUseCase {
  final CompanyRepository repository;
  GetCompanyProfileUseCase(this.repository);

  Future<CompanyProfileEntity?> call(String userId) {
    return repository.getProfile(userId);
  }
}
