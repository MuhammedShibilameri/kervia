import '../../domain/entities/company_profile_entity.dart';

class CompanyProfileModel extends CompanyProfileEntity {
  const CompanyProfileModel({
    required super.userId,
    super.companyName,
    super.industry,
    super.website,
    super.contactEmail,
    super.contactPhone,
    super.location,
    super.state,
    super.district,
    super.employeeSize,
    super.foundedYear,
    super.about,
    super.logoUrl,
    super.isProfileComplete,
    super.stepCompleted,
  });

  factory CompanyProfileModel.fromEntity(CompanyProfileEntity entity) {
    return CompanyProfileModel(
      userId: entity.userId,
      companyName: entity.companyName,
      industry: entity.industry,
      website: entity.website,
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      location: entity.location,
      state: entity.state,
      district: entity.district,
      employeeSize: entity.employeeSize,
      foundedYear: entity.foundedYear,
      about: entity.about,
      logoUrl: entity.logoUrl,
      isProfileComplete: entity.isProfileComplete,
      stepCompleted: entity.stepCompleted,
    );
  }

  factory CompanyProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return CompanyProfileModel(
      userId: id,
      companyName: map['companyName'] as String? ?? '',
      industry: map['industry'] as String? ?? '',
      website: map['website'] as String? ?? '',
      contactEmail: map['contactEmail'] as String? ?? '',
      contactPhone: map['contactPhone'] as String? ?? '',
      location: map['location'] as String? ?? '',
      state: map['state'] as String? ?? 'Kerala',
      district: map['district'] as String? ?? '',
      employeeSize: map['employeeSize'] as String? ?? '',
      foundedYear: map['foundedYear'] as String? ?? '',
      about: map['about'] as String? ?? '',
      logoUrl: map['logoUrl'] as String?,
      isProfileComplete: (map['isProfileComplete'] as bool?) ?? false,
      stepCompleted: (map['stepCompleted'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'industry': industry,
      'website': website,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'location': location,
      'state': state,
      'district': district,
      'employeeSize': employeeSize,
      'foundedYear': foundedYear,
      'about': about,
      'logoUrl': logoUrl,
      'isProfileComplete': isProfileComplete,
      'stepCompleted': stepCompleted,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
