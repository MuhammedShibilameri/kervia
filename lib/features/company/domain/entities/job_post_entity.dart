import 'package:equatable/equatable.dart';
import '../../../applications/domain/entities/job_application_entity.dart';

class JobPostEntity extends Equatable {
  final String? id;
  final String companyId;
  final String companyName;
  final String jobTitle;
  final String occupation;
  final String employmentType; // 'Full-time', 'Part-time', etc.
  final String workMode; // 'On-site', 'Hybrid', 'Remote'
  final String salaryType; // 'Hourly', 'Monthly', 'Annual'
  final String salaryAmount;
  final String experience;
  final String vacancies;
  final String deadline;
  final String location;
  final List<JobLocationEntity> locations;
  final String jobDescription;
  final String minimumEducation;
  final List<String> requiredSkills;
  final List<String> languages;
  final String aboutCompany;
  final String jobStatus; // 'Published', 'Closed'
  final String publishedDate;
  final String updatedAt;

  const JobPostEntity({
    this.id,
    required this.companyId,
    this.companyName = '',
    this.jobTitle = '',
    this.occupation = '',
    this.employmentType = 'Full-time',
    this.workMode = 'Hybrid',
    this.salaryType = 'Monthly',
    this.salaryAmount = '',
    this.experience = '',
    this.vacancies = '1',
    this.deadline = 'No deadline',
    this.location = '',
    this.locations = const [],
    this.jobDescription = '',
    this.minimumEducation = '',
    this.requiredSkills = const [],
    this.languages = const ['English', 'Malayalam'],
    this.aboutCompany = '',
    this.jobStatus = 'Published',
    this.publishedDate = '',
    this.updatedAt = '',
  });

  String get salary =>
      salaryAmount.isEmpty ? salaryType : '$salaryAmount / $salaryType';

  JobPostEntity copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? jobTitle,
    String? occupation,
    String? employmentType,
    String? workMode,
    String? salaryType,
    String? salaryAmount,
    String? experience,
    String? vacancies,
    String? deadline,
    String? location,
    List<JobLocationEntity>? locations,
    String? jobDescription,
    String? minimumEducation,
    List<String>? requiredSkills,
    List<String>? languages,
    String? aboutCompany,
    String? jobStatus,
    String? publishedDate,
    String? updatedAt,
  }) {
    return JobPostEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      occupation: occupation ?? this.occupation,
      employmentType: employmentType ?? this.employmentType,
      workMode: workMode ?? this.workMode,
      salaryType: salaryType ?? this.salaryType,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      experience: experience ?? this.experience,
      vacancies: vacancies ?? this.vacancies,
      deadline: deadline ?? this.deadline,
      location: location ?? this.location,
      locations: locations ?? this.locations,
      jobDescription: jobDescription ?? this.jobDescription,
      minimumEducation: minimumEducation ?? this.minimumEducation,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      languages: languages ?? this.languages,
      aboutCompany: aboutCompany ?? this.aboutCompany,
      jobStatus: jobStatus ?? this.jobStatus,
      publishedDate: publishedDate ?? this.publishedDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        companyName,
        jobTitle,
        occupation,
        employmentType,
        workMode,
        salaryType,
        salaryAmount,
        experience,
        vacancies,
        deadline,
        location,
        locations,
        jobDescription,
        minimumEducation,
        requiredSkills,
        languages,
        aboutCompany,
        jobStatus,
        publishedDate,
        updatedAt,
      ];
}