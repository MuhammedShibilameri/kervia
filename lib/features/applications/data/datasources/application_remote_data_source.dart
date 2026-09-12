import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/job_application_entity.dart';
import '../models/job_application_model.dart';

abstract class ApplicationRemoteDataSource {
  Future<List<JobApplicationModel>> getApplications({ApplicationStatus? status});
  Future<void> withdrawApplication(String applicationId);
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final FirebaseFirestore? _firestore;

  ApplicationRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _safeFirestore;

  static FirebaseFirestore? get _safeFirestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  static final List<JobApplicationModel> _mockApplications = [
    const JobApplicationModel(
      id: 'app_1',
      jobTitle: 'Software tester',
      companyName: 'Test',
      location: 'Edarikode, Malappuram',
      status: ApplicationStatus.withdrawn,
      applicationType: 'Direct Application',
      appliedDate: '08-Sept-2026',
      appliedTime: '6:14 am',
      lastUpdated: '08-Sept-2026, 6:15 am',
      jobStatus: 'Published',
      occupation: 'Software Tester',
      employmentType: 'Freelance',
      workMode: 'Hybrid',
      salary: '₹25,000 / monthly',
      experience: 'Fresher',
      vacancies: '1',
      deadline: 'No deadline',
      publishedDate: '06-Sept-2026',
      locations: [
        JobLocationEntity(
          name: 'Edarikode',
          subLocation: 'Tirur, Malappuram',
          isPrimary: true,
        ),
      ],
      jobDescription: 'Software tester bdbbdhd',
      minimumEducation: 'SSLC / Class 10',
      requiredSkills: ['Go', 'Typing'],
      languages: ['English', 'Malayalam'],
      aboutCompany: 'Test is a premier quality assurance and software evaluation lab, providing automated testing, user acceptance verification, and bug triage.',
    ),
    const JobApplicationModel(
      id: 'app_2',
      jobTitle: 'Senior Flutter Engineer',
      companyName: 'TechCorp Solutions',
      location: 'Bangalore, Karnataka',
      status: ApplicationStatus.interviewStage,
      applicationType: 'Direct Application',
      appliedDate: '05-Sept-2026',
      appliedTime: '10:30 am',
      lastUpdated: '07-Sept-2026, 2:00 pm',
      jobStatus: 'Published',
      occupation: 'Mobile Developer',
      employmentType: 'Full-time',
      workMode: 'Hybrid',
      salary: '₹1,20,000 / monthly',
      experience: '4-6 years',
      vacancies: '2',
      deadline: '15-Sept-2026',
      publishedDate: '01-Sept-2026',
      locations: [
        JobLocationEntity(
          name: 'Koramangala',
          subLocation: 'Bangalore South, Karnataka',
          isPrimary: true,
        ),
      ],
      jobDescription: 'Seeking an experienced Flutter engineer to lead architecture, performance tuning, and multi-platform mobile application development.',
      minimumEducation: 'Bachelor of Technology / B.E.',
      requiredSkills: ['Flutter', 'Dart', 'BLoC', 'Firebase'],
      languages: ['English', 'Hindi'],
      aboutCompany: 'TechCorp Solutions powers enterprise mobility for Fortune 500 companies with cutting edge cloud and mobile engineering.',
    ),
    const JobApplicationModel(
      id: 'app_3',
      jobTitle: 'Product Designer',
      companyName: 'PixelStudio',
      location: 'Kochi, Kerala',
      status: ApplicationStatus.inReview,
      applicationType: 'Direct Application',
      appliedDate: '06-Sept-2026',
      appliedTime: '3:45 pm',
      lastUpdated: '07-Sept-2026, 11:15 am',
      jobStatus: 'Published',
      occupation: 'UI/UX Designer',
      employmentType: 'Full-time',
      workMode: 'On-site',
      salary: '₹45,000 / monthly',
      experience: '2-3 years',
      vacancies: '1',
      deadline: '18-Sept-2026',
      publishedDate: '02-Sept-2026',
      locations: [
        JobLocationEntity(
          name: 'Infopark',
          subLocation: 'Kakkanad, Kochi',
          isPrimary: true,
        ),
      ],
      jobDescription: 'Create modern, human-centric interface designs, prototypes, design systems, and mobile wireframes.',
      minimumEducation: 'Diploma / Degree in Design',
      requiredSkills: ['Figma', 'Prototyping', 'Design Systems'],
      languages: ['English', 'Malayalam'],
      aboutCompany: 'PixelStudio is an award-winning creative studio crafting memorable brands and digital products.',
    ),
    const JobApplicationModel(
      id: 'app_4',
      jobTitle: 'Backend Developer (Node.js)',
      companyName: 'CloudScale Inc',
      location: 'Remote',
      status: ApplicationStatus.shortlisted,
      applicationType: 'Direct Application',
      appliedDate: '03-Sept-2026',
      appliedTime: '9:00 am',
      lastUpdated: '06-Sept-2026, 4:20 pm',
      jobStatus: 'Published',
      occupation: 'Backend Developer',
      employmentType: 'Full-time',
      workMode: 'Remote',
      salary: '₹60,000 / monthly',
      experience: '2-4 years',
      vacancies: '3',
      deadline: '20-Sept-2026',
      publishedDate: '28-Aug-2026',
      locations: [
        JobLocationEntity(
          name: 'Remote Workstation',
          subLocation: 'All India',
          isPrimary: true,
        ),
      ],
      jobDescription: 'Design scalable microservices, REST APIs, and database migrations with Node.js, TypeScript, and PostgreSQL.',
      minimumEducation: 'B.Sc Computer Science / BCA / B.Tech',
      requiredSkills: ['Node.js', 'PostgreSQL', 'Docker', 'Redis'],
      languages: ['English'],
      aboutCompany: 'CloudScale delivers robust backend infrastructure for high-growth SaaS applications.',
    ),
    const JobApplicationModel(
      id: 'app_5',
      jobTitle: 'Full Stack Engineer',
      companyName: 'NextGen Innovations',
      location: 'Calicut, Kerala',
      status: ApplicationStatus.hired,
      applicationType: 'Direct Application',
      appliedDate: '25-Aug-2026',
      appliedTime: '11:00 am',
      lastUpdated: '01-Sept-2026, 5:00 pm',
      jobStatus: 'Closed',
      occupation: 'Full Stack Engineer',
      employmentType: 'Full-time',
      workMode: 'On-site',
      salary: '₹55,000 / monthly',
      experience: '2-4 years',
      vacancies: '1',
      deadline: 'Completed',
      publishedDate: '20-Aug-2026',
      locations: [
        JobLocationEntity(
          name: 'Cyberpark',
          subLocation: 'Pantheeramkavu, Calicut',
          isPrimary: true,
        ),
      ],
      jobDescription: 'Develop web and mobile applications from end to end using modern JavaScript and cloud infrastructure.',
      minimumEducation: 'Bachelor Degree',
      requiredSkills: ['React', 'Node.js', 'MongoDB'],
      languages: ['English', 'Malayalam'],
      aboutCompany: 'NextGen Innovations builds technology solutions empowering modern healthcare and retail enterprises.',
    ),
    const JobApplicationModel(
      id: 'app_6',
      jobTitle: 'QA Automation Engineer',
      companyName: 'GlobalSoft',
      location: 'Trivandrum, Kerala',
      status: ApplicationStatus.rejected,
      applicationType: 'Direct Application',
      appliedDate: '15-Aug-2026',
      appliedTime: '2:15 pm',
      lastUpdated: '22-Aug-2026, 10:00 am',
      jobStatus: 'Closed',
      occupation: 'QA Engineer',
      employmentType: 'Full-time',
      workMode: 'On-site',
      salary: '₹35,000 / monthly',
      experience: '1-2 years',
      vacancies: '2',
      deadline: 'Closed',
      publishedDate: '10-Aug-2026',
      locations: [
        JobLocationEntity(
          name: 'Technopark Phase 3',
          subLocation: 'Kazhakkoottam, Trivandrum',
          isPrimary: true,
        ),
      ],
      jobDescription: 'Create automated test scripts using Selenium and Cypress for enterprise web portals.',
      minimumEducation: 'Diploma / Degree in Engineering',
      requiredSkills: ['Selenium', 'Java', 'Postman'],
      languages: ['English', 'Malayalam'],
      aboutCompany: 'GlobalSoft is an IT services and consulting company serving clients across Europe and North America.',
    ),
    const JobApplicationModel(
      id: 'app_7',
      jobTitle: 'Mobile App Developer',
      companyName: 'AppSphere Labs',
      location: 'Remote, India',
      status: ApplicationStatus.submitted,
      applicationType: 'Direct Application',
      appliedDate: '07-Sept-2026',
      appliedTime: '8:45 pm',
      lastUpdated: '07-Sept-2026, 8:45 pm',
      jobStatus: 'Published',
      occupation: 'Mobile Developer',
      employmentType: 'Full-time',
      workMode: 'Remote',
      salary: '₹40,000 / monthly',
      experience: '1-3 years',
      vacancies: '2',
      deadline: '25-Sept-2026',
      publishedDate: '05-Sept-2026',
      locations: [
        JobLocationEntity(
          name: 'Remote Work',
          subLocation: 'Kerala / Karnataka',
          isPrimary: true,
        ),
      ],
      jobDescription: 'Build intuitive Android and iOS experiences using Flutter with Clean Architecture.',
      minimumEducation: 'B.Tech / BCA / B.Sc',
      requiredSkills: ['Flutter', 'REST API', 'Git'],
      languages: ['English', 'Malayalam'],
      aboutCompany: 'AppSphere Labs creates next-generation consumer apps with over 5 million downloads.',
    ),
  ];

  @override
  Future<List<JobApplicationModel>> getApplications({ApplicationStatus? status}) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final snapshot = await firestore.collection('applications').get();
        if (snapshot.docs.isNotEmpty) {
          final apps = snapshot.docs
              .map((doc) => JobApplicationModel.fromMap(doc.data(), doc.id))
              .toList();

          if (status == null || status == ApplicationStatus.all) {
            return apps;
          }
          return apps.where((a) => a.status == status).toList();
        }
      }
    } catch (_) {
      // Fallback gracefully to mock data
    }

    if (status == null || status == ApplicationStatus.all) {
      return _mockApplications;
    }
    return _mockApplications.where((a) => a.status == status).toList();
  }

  @override
  Future<void> withdrawApplication(String applicationId) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore.collection('applications').doc(applicationId).update({
          'status': ApplicationStatus.withdrawn.name,
        });
      }
    } catch (_) {
      // Handle local state in repository
    }
  }
}
