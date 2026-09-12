import '../entities/company_profile_entity.dart';

abstract class CompanyRepository {
  Future<void> saveProfile(CompanyProfileEntity profile);
  Future<CompanyProfileEntity?> getProfile(String userId);
}
