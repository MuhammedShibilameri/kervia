import 'package:equatable/equatable.dart';

class CompanyProfileEntity extends Equatable {
  final String userId;
  final String companyName;
  final String industry;
  final String website;
  final String contactEmail;
  final String contactPhone;
  final String location;
  final String state;
  final String district;
  final String employeeSize;
  final String foundedYear;
  final String about;
  final String? logoUrl;
  final bool isProfileComplete;
  final int stepCompleted;

  const CompanyProfileEntity({
    required this.userId,
    this.companyName = '',
    this.industry = '',
    this.website = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.location = '',
    this.state = 'Kerala',
    this.district = '',
    this.employeeSize = '',
    this.foundedYear = '',
    this.about = '',
    this.logoUrl,
    this.isProfileComplete = false,
    this.stepCompleted = 1,
  });

  CompanyProfileEntity copyWith({
    String? userId,
    String? companyName,
    String? industry,
    String? website,
    String? contactEmail,
    String? contactPhone,
    String? location,
    String? state,
    String? district,
    String? employeeSize,
    String? foundedYear,
    String? about,
    String? logoUrl,
    bool? isProfileComplete,
    int? stepCompleted,
  }) {
    return CompanyProfileEntity(
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      location: location ?? this.location,
      state: state ?? this.state,
      district: district ?? this.district,
      employeeSize: employeeSize ?? this.employeeSize,
      foundedYear: foundedYear ?? this.foundedYear,
      about: about ?? this.about,
      logoUrl: logoUrl ?? this.logoUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      stepCompleted: stepCompleted ?? this.stepCompleted,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        companyName,
        industry,
        website,
        contactEmail,
        contactPhone,
        location,
        state,
        district,
        employeeSize,
        foundedYear,
        about,
        logoUrl,
        isProfileComplete,
        stepCompleted,
      ];
}
