import '../../../applications/domain/entities/job_application_entity.dart';
import '../../domain/entities/job_post_entity.dart';

class JobPostModel extends JobPostEntity {
  const JobPostModel({
    super.id,
    required super.companyId,
    super.companyName,
    super.jobTitle,
    super.occupation,
    super.employmentType,
    super.workMode,
    super.salaryType,
    super.salaryAmount,
    super.experience,
    super.vacancies,
    super.deadline,
    super.location,
    super.locations,
    super.jobDescription,
    super.minimumEducation,
    super.requiredSkills,
    super.languages,
    super.aboutCompany,
    super.jobStatus,
    super.publishedDate,
    super.updatedAt,
  });

  factory JobPostModel.fromEntity(JobPostEntity entity) {
    return JobPostModel(
      id: entity.id,
      companyId: entity.companyId,
      companyName: entity.companyName,
      jobTitle: entity.jobTitle,
      occupation: entity.occupation,
      employmentType: entity.employmentType,
      workMode: entity.workMode,
      salaryType: entity.salaryType,
      salaryAmount: entity.salaryAmount,
      experience: entity.experience,
      vacancies: entity.vacancies,
      deadline: entity.deadline,
      location: entity.location,
      locations: entity.locations,
      jobDescription: entity.jobDescription,
      minimumEducation: entity.minimumEducation,
      requiredSkills: entity.requiredSkills,
      languages: entity.languages,
      aboutCompany: entity.aboutCompany,
      jobStatus: entity.jobStatus,
      publishedDate: entity.publishedDate,
      updatedAt: entity.updatedAt,
    );
  }

  factory JobPostModel.fromMap(Map<String, dynamic> map, String id) {
    return JobPostModel(
      id: id,
      companyId: map['companyId'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      occupation: map['occupation'] as String? ?? '',
      employmentType: map['employmentType'] as String? ?? 'Full-time',
      workMode: map['workMode'] as String? ?? 'Hybrid',
      salaryType: map['salaryType'] as String? ?? 'Monthly',
      salaryAmount: map['salaryAmount'] as String? ?? '',
      experience: map['experience'] as String? ?? '',
      vacancies: map['vacancies'] as String? ?? '1',
      deadline: map['deadline'] as String? ?? 'No deadline',
      location: map['location'] as String? ?? '',
      locations: (map['locations'] as List<dynamic>?)
              ?.map((l) => JobLocationEntity(
                    name: l['name'] as String? ?? '',
                    subLocation: l['subLocation'] as String? ?? '',
                    isPrimary: l['isPrimary'] as bool? ?? false,
                  ))
              .toList() ??
          const [],
      jobDescription: map['jobDescription'] as String? ?? '',
      minimumEducation: map['minimumEducation'] as String? ?? '',
      requiredSkills: List<String>.from(map['requiredSkills'] ?? const []),
      languages: List<String>.from(map['languages'] ?? const ['English', 'Malayalam']),
      aboutCompany: map['aboutCompany'] as String? ?? '',
      jobStatus: map['jobStatus'] as String? ?? 'Published',
      publishedDate: map['publishedDate'] as String? ?? '',
      updatedAt: map['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'occupation': occupation,
      'employmentType': employmentType,
      'workMode': workMode,
      'salaryType': salaryType,
      'salaryAmount': salaryAmount,
      'experience': experience,
      'vacancies': vacancies,
      'deadline': deadline,
      'location': location,
      'locations': locations
          .map((l) => {
                'name': l.name,
                'subLocation': l.subLocation,
                'isPrimary': l.isPrimary,
              })
          .toList(),
      'jobDescription': jobDescription,
      'minimumEducation': minimumEducation,
      'requiredSkills': requiredSkills,
      'languages': languages,
      'aboutCompany': aboutCompany,
      'jobStatus': jobStatus,
      'publishedDate': publishedDate,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}