import 'package:equatable/equatable.dart';

class JobSeekerProfileEntity extends Equatable {
  final String userId;

  // Personal Information
  final String fullName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String gender;
  final String currentLocation;
  final String state;
  final String district;
  final String taluk;
  final String panchayat;
  final String? photoUrl;

  // Professional Summary
  final String highestQualification;
  final String currentOccupation;
  final String yearsOfExperience;
  final String currentSalary;
  final String expectedSalary;

  // Skills & Languages
  final List<String> skills;
  final List<String> languages;

  // Preferences
  final List<String> preferredLocations;
  final String workMode; // 'On-site', 'Hybrid', 'Remote'
  final String salaryType; // 'Hourly', 'Monthly', 'Annual'
  final String preferredCategories;
  final List<String> employmentTypes; // 'Full-time', 'Part-time', etc.

  // Media & Attachments
  final String? resumeName;
  final String? resumeSize;
  final String? resumePath;
  final String? videoName;
  final String? videoSize;
  final String? videoPath;

  // Consent
  final bool declarationsConfirmed;
  final bool termsAgreed;

  // Progress
  final int stepCompleted;
  final bool isSubmitted;

  // Settings
  final bool notificationsEnabled;

  const JobSeekerProfileEntity({
    required this.userId,
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.currentLocation = '',
    this.state = 'Kerala',
    this.district = '',
    this.taluk = '',
    this.panchayat = '',
    this.photoUrl,
    this.highestQualification = '',
    this.currentOccupation = '',
    this.yearsOfExperience = '',
this.currentSalary = '',
    this.expectedSalary = '',
    this.skills = const [],
    this.languages = const [],
    this.preferredLocations = const [],
    this.workMode = '',
    this.salaryType = '',
    this.preferredCategories = '',
    this.employmentTypes = const [],
    this.resumeName,
    this.resumeSize,
    this.resumePath,
    this.videoName,
    this.videoSize,
    this.videoPath,
    this.declarationsConfirmed = false,
    this.termsAgreed = false,
    this.stepCompleted = 1,
    this.isSubmitted = false,
    this.notificationsEnabled = true,
  });

  JobSeekerProfileEntity copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? currentLocation,
    String? state,
    String? district,
    String? taluk,
    String? panchayat,
    String? photoUrl,
    String? highestQualification,
    String? currentOccupation,
    String? yearsOfExperience,
    String? currentSalary,
    String? expectedSalary,
    List<String>? skills,
    List<String>? languages,
    List<String>? preferredLocations,
    String? workMode,
    String? salaryType,
    String? preferredCategories,
    List<String>? employmentTypes,
    String? resumeName,
    String? resumeSize,
    String? resumePath,
    String? videoName,
    String? videoSize,
    String? videoPath,
    bool? declarationsConfirmed,
    bool? termsAgreed,
    int? stepCompleted,
    bool? isSubmitted,
    bool? notificationsEnabled,
  }) {
    return JobSeekerProfileEntity(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      currentLocation: currentLocation ?? this.currentLocation,
      state: state ?? this.state,
      district: district ?? this.district,
      taluk: taluk ?? this.taluk,
      panchayat: panchayat ?? this.panchayat,
      photoUrl: photoUrl ?? this.photoUrl,
      highestQualification:
          highestQualification ?? this.highestQualification,
      currentOccupation: currentOccupation ?? this.currentOccupation,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      currentSalary: currentSalary ?? this.currentSalary,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      workMode: workMode ?? this.workMode,
      salaryType: salaryType ?? this.salaryType,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      employmentTypes: employmentTypes ?? this.employmentTypes,
      resumeName: resumeName ?? this.resumeName,
      resumeSize: resumeSize ?? this.resumeSize,
      resumePath: resumePath ?? this.resumePath,
      videoName: videoName ?? this.videoName,
      videoSize: videoSize ?? this.videoSize,
      videoPath: videoPath ?? this.videoPath,
      declarationsConfirmed:
          declarationsConfirmed ?? this.declarationsConfirmed,
      termsAgreed: termsAgreed ?? this.termsAgreed,
      stepCompleted: stepCompleted ?? this.stepCompleted,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        phoneNumber,
        dateOfBirth,
        gender,
        currentLocation,
        state,
        district,
        taluk,
        panchayat,
        photoUrl,
        highestQualification,
        currentOccupation,
        yearsOfExperience,
        currentSalary,
        expectedSalary,
        skills,
        languages,
        preferredLocations,
        workMode,
        salaryType,
        preferredCategories,
        employmentTypes,
        resumeName,
        resumeSize,
        resumePath,
        videoName,
        videoSize,
        videoPath,
        declarationsConfirmed,
        termsAgreed,
        stepCompleted,
        isSubmitted,
        notificationsEnabled,
      ];
}
