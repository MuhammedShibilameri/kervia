import '../../domain/entities/job_application_entity.dart';

class JobApplicationModel extends JobApplicationEntity {
  const JobApplicationModel({
    required super.id,
    super.userId,
    super.candidateName,
    required super.jobTitle,
    required super.companyName,
    super.companyLogoUrl,
    required super.location,
    required super.status,
    super.applicationType = 'Direct Application',
    required super.appliedDate,
    super.appliedTime = '6:14 am',
    super.lastUpdated = '08-Sept-2026, 6:15 am',
    super.jobStatus = 'Published',
    super.occupation = 'Software Tester',
    super.employmentType = 'Freelance',
    super.workMode = 'Hybrid',
    super.salary = '₹25,000 / monthly',
    super.experience = 'Fresher',
    super.vacancies = '1',
    super.deadline = 'No deadline',
    super.publishedDate = '06-Sept-2026',
    super.locations = const [
      JobLocationEntity(
        name: 'Edarikode',
        subLocation: 'Tirur, Malappuram',
        isPrimary: true,
      ),
    ],
    super.jobDescription = 'Software tester bdbbdhd',
    super.minimumEducation = 'SSLC / Class 10',
    super.requiredSkills = const ['Go', 'Typing'],
    super.languages = const ['English', 'Malayalam'],
    super.aboutCompany = 'A forward-thinking organization committed to quality and excellence in software solutions.',
  });

  factory JobApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return JobApplicationModel(
      id: id,
      userId: map['userId'] as String?,
      candidateName: map['candidateName'] as String?,
      jobTitle: map['jobTitle'] as String? ?? 'Untitled Role',
      companyName: map['companyName'] as String? ?? 'Company',
      companyLogoUrl: map['companyLogoUrl'] as String?,
      location: map['location'] as String? ?? 'Remote',
      status: _parseStatus(map['status'] as String?),
      applicationType: map['applicationType'] as String? ?? 'Direct Application',
      appliedDate: map['appliedDate'] as String? ?? '',
      appliedTime: map['appliedTime'] as String? ?? '6:14 am',
      lastUpdated: map['lastUpdated'] as String? ?? '08-Sept-2026, 6:15 am',
      jobStatus: map['jobStatus'] as String? ?? 'Published',
      occupation: map['occupation'] as String? ?? 'Software Tester',
      employmentType: map['employmentType'] as String? ?? 'Freelance',
      workMode: map['workMode'] as String? ?? 'Hybrid',
      salary: map['salary'] as String? ?? '₹25,000 / monthly',
      experience: map['experience'] as String? ?? 'Fresher',
      vacancies: map['vacancies'] as String? ?? '1',
      deadline: map['deadline'] as String? ?? 'No deadline',
      publishedDate: map['publishedDate'] as String? ?? '06-Sept-2026',
      locations: (map['locations'] as List<dynamic>?)
              ?.map((l) => JobLocationEntity(
                    name: l['name'] as String? ?? '',
                    subLocation: l['subLocation'] as String? ?? '',
                    isPrimary: l['isPrimary'] as bool? ?? false,
                  ))
              .toList() ??
          const [
            JobLocationEntity(
              name: 'Edarikode',
              subLocation: 'Tirur, Malappuram',
              isPrimary: true,
            ),
          ],
      jobDescription: map['jobDescription'] as String? ?? 'Software tester bdbbdhd',
      minimumEducation: map['minimumEducation'] as String? ?? 'SSLC / Class 10',
      requiredSkills: (map['requiredSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Go', 'Typing'],
      languages: (map['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['English', 'Malayalam'],
      aboutCompany: map['aboutCompany'] as String? ??
          'A forward-thinking organization committed to quality and excellence in software solutions.',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'candidateName': candidateName,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
      'location': location,
      'status': status.name,
      'applicationType': applicationType,
      'appliedDate': appliedDate,
      'appliedTime': appliedTime,
      'lastUpdated': lastUpdated,
      'jobStatus': jobStatus,
      'occupation': occupation,
      'employmentType': employmentType,
      'workMode': workMode,
      'salary': salary,
      'experience': experience,
      'vacancies': vacancies,
      'deadline': deadline,
      'publishedDate': publishedDate,
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
    };
  }

  static ApplicationStatus _parseStatus(String? status) {
    switch (status) {
      case 'submitted':
        return ApplicationStatus.submitted;
      case 'inReview':
        return ApplicationStatus.inReview;
      case 'shortlisted':
        return ApplicationStatus.shortlisted;
      case 'interviewStage':
        return ApplicationStatus.interviewStage;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      case 'hired':
        return ApplicationStatus.hired;
      default:
        return ApplicationStatus.submitted;
    }
  }
}
