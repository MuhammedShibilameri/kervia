import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  all('All'),
  submitted('Submitted'),
  inReview('In Review'),
  shortlisted('Shortlisted'),
  interviewStage('Interview Stage'),
  rejected('Rejected'),
  withdrawn('Withdrawn'),
  hired('Hired');

  final String label;
  const ApplicationStatus(this.label);
}

class JobLocationEntity extends Equatable {
  final String name;
  final String subLocation;
  final bool isPrimary;

  const JobLocationEntity({
    required this.name,
    required this.subLocation,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [name, subLocation, isPrimary];
}

class JobApplicationEntity extends Equatable {
  final String id;
  final String? userId;
  final String? candidateName;
  final String jobTitle;
  final String companyName;
  final String? companyLogoUrl;
  final String location;
  final ApplicationStatus status;
  final String applicationType;
  final String appliedDate;
  final String appliedTime;
  final String lastUpdated;
  final String jobStatus;
  final String occupation;
  final String employmentType;
  final String workMode;
  final String salary;
  final String experience;
  final String vacancies;
  final String deadline;
  final String publishedDate;
  final List<JobLocationEntity> locations;
  final String jobDescription;
  final String minimumEducation;
  final List<String> requiredSkills;
  final List<String> languages;
  final String aboutCompany;

  const JobApplicationEntity({
    required this.id,
    this.userId,
    this.candidateName,
    required this.jobTitle,
    required this.companyName,
    this.companyLogoUrl,
    required this.location,
    required this.status,
    this.applicationType = 'Direct Application',
    required this.appliedDate,
    this.appliedTime = '6:14 am',
    this.lastUpdated = '08-Sept-2026, 6:15 am',
    this.jobStatus = 'Published',
    this.occupation = 'Software Tester',
    this.employmentType = 'Freelance',
    this.workMode = 'Hybrid',
    this.salary = '₹25,000 / monthly',
    this.experience = 'Fresher',
    this.vacancies = '1',
    this.deadline = 'No deadline',
    this.publishedDate = '06-Sept-2026',
    this.locations = const [
      JobLocationEntity(
        name: 'Edarikode',
        subLocation: 'Tirur, Malappuram',
        isPrimary: true,
      ),
    ],
    this.jobDescription = 'Software tester bdbbdhd',
    this.minimumEducation = 'SSLC / Class 10',
    this.requiredSkills = const ['Go', 'Typing'],
    this.languages = const ['English', 'Malayalam'],
    this.aboutCompany = 'A forward-thinking organization committed to quality and excellence in software solutions.',
  });

  JobApplicationEntity copyWith({
    String? id,
    String? userId,
    String? candidateName,
    String? jobTitle,
    String? companyName,
    String? companyLogoUrl,
    String? location,
    ApplicationStatus? status,
    String? applicationType,
    String? appliedDate,
    String? appliedTime,
    String? lastUpdated,
    String? jobStatus,
    String? occupation,
    String? employmentType,
    String? workMode,
    String? salary,
    String? experience,
    String? vacancies,
    String? deadline,
    String? publishedDate,
    List<JobLocationEntity>? locations,
    String? jobDescription,
    String? minimumEducation,
    List<String>? requiredSkills,
    List<String>? languages,
    String? aboutCompany,
  }) {
    return JobApplicationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      candidateName: candidateName ?? this.candidateName,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      location: location ?? this.location,
      status: status ?? this.status,
      applicationType: applicationType ?? this.applicationType,
      appliedDate: appliedDate ?? this.appliedDate,
      appliedTime: appliedTime ?? this.appliedTime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      jobStatus: jobStatus ?? this.jobStatus,
      occupation: occupation ?? this.occupation,
      employmentType: employmentType ?? this.employmentType,
      workMode: workMode ?? this.workMode,
      salary: salary ?? this.salary,
      experience: experience ?? this.experience,
      vacancies: vacancies ?? this.vacancies,
      deadline: deadline ?? this.deadline,
      publishedDate: publishedDate ?? this.publishedDate,
      locations: locations ?? this.locations,
      jobDescription: jobDescription ?? this.jobDescription,
      minimumEducation: minimumEducation ?? this.minimumEducation,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      languages: languages ?? this.languages,
      aboutCompany: aboutCompany ?? this.aboutCompany,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        candidateName,
        jobTitle,
        companyName,
        companyLogoUrl,
        location,
        status,
        applicationType,
        appliedDate,
        appliedTime,
        lastUpdated,
        jobStatus,
        occupation,
        employmentType,
        workMode,
        salary,
        experience,
        vacancies,
        deadline,
        publishedDate,
        locations,
        jobDescription,
        minimumEducation,
        requiredSkills,
        languages,
        aboutCompany,
      ];
}
