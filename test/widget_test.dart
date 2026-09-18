import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kervia/core/l10n/kervia_l10n.dart';
import 'package:kervia/core/theme/app_colors.dart';
import 'package:kervia/core/theme/app_theme.dart';
import 'package:kervia/features/auth/presentation/widgets/auth_brand_panel.dart';
import 'package:kervia/features/job_seeker/domain/entities/job_seeker_profile_entity.dart';
import 'package:kervia/features/job_seeker/presentation/pages/job_seeker_step2_page.dart';
import 'package:kervia/features/job_seeker/presentation/pages/job_seeker_step3_review_page.dart';
import 'package:kervia/features/applications/domain/entities/job_application_entity.dart';
import 'package:kervia/features/applications/presentation/widgets/application_card.dart';
import 'package:kervia/features/applications/presentation/widgets/application_status_filter_bar.dart';
import 'package:kervia/features/applications/presentation/pages/application_details_page.dart';
import 'package:kervia/features/auth/domain/entities/user_entity.dart';
import 'package:kervia/features/job_seeker/presentation/pages/candidate_home_shell.dart';

Widget testApp(Widget home) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  testWidgets('AuthBrandPanel renders branding and key value propositions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(
        const Scaffold(
          body: AuthBrandPanel(),
        ),
      ),
    );

    // Verify brand name & headline
    expect(find.text('Kervia'), findsOneWidget);
    expect(find.text('Elevate your career'), findsOneWidget);

    // Verify key bullet points
    expect(find.text('Verified Professional Profiles'), findsOneWidget);
    expect(find.text('Curated High-Value Job Postings'), findsOneWidget);
    expect(find.text('AI-Powered Talent Matching'), findsOneWidget);
  });

  test('AppColors Deep Teal palette integrity', () {
    expect(AppColors.primary, const Color(0xFF0F4C44));
    expect(AppColors.primarySoft, const Color(0xFFE8F5F1));
  });

  testWidgets('JobSeekerStep2Page renders professional sections and stepper',
      (WidgetTester tester) async {
    const profile = JobSeekerProfileEntity(
      userId: 'test_user_1',
      fullName: 'Jane Doe',
      email: 'jane.doe@example.com',
    );

    await tester.pumpWidget(
      testApp(const JobSeekerStep2Page(profile: profile)),
    );

    expect(find.text('Professional Details'), findsOneWidget);
    expect(find.text('Professional Summary'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Languages'), findsOneWidget);
    expect(find.text('Preferred Locations'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Resumes & Introduction Video'), findsOneWidget);
    expect(find.text('Preview Details'), findsOneWidget);
  });

  testWidgets('JobSeekerStep3ReviewPage renders review cards and declaration',
      (WidgetTester tester) async {
    const profile = JobSeekerProfileEntity(
      userId: 'test_user_1',
      fullName: 'Jane Doe',
      email: 'jane.doe@example.com',
      currentOccupation: 'Software Engineer',
    );

    await tester.pumpWidget(
      testApp(const JobSeekerStep3ReviewPage(profile: profile)),
    );

    expect(find.text('Review Your Registration Details'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Professional Summary'), findsOneWidget);
    expect(find.text('Skills & Languages'), findsOneWidget);
    expect(find.text('Job & Location Preferences'), findsOneWidget);
    expect(find.text('Applicant Declaration & Consent'), findsOneWidget);
    expect(find.text('Confirm & Submit Registration'), findsOneWidget);
  });

  testWidgets('ApplicationStatusFilterBar displays all 8 status options and handles selection',
      (WidgetTester tester) async {
    ApplicationStatus? selected;

    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: ApplicationStatusFilterBar(
            selectedStatus: ApplicationStatus.all,
            onStatusSelected: (status) => selected = status,
          ),
        ),
      ),
    );

    expect(find.text('Filter by status'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('In Review'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Hired'), 50.0);
    await tester.pumpAndSettle();

    expect(find.text('Interview Stage'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
    expect(find.text('Withdrawn'), findsOneWidget);
    expect(find.text('Hired'), findsOneWidget);

    await tester.tap(find.text('Hired'));
    expect(selected, ApplicationStatus.hired);
  });

  testWidgets('ApplicationCard renders application details matching screenshot',
      (WidgetTester tester) async {
    const app = JobApplicationEntity(
      id: 'app_test_1',
      jobTitle: 'Software tester',
      companyName: 'Test',
      location: 'Edarikode, Malappuram',
      status: ApplicationStatus.withdrawn,
      applicationType: 'Direct Application',
      appliedDate: '08-Sept-2026',
      deadline: 'No deadline',
    );

    await tester.pumpWidget(
      testApp(
        const Scaffold(
          body: ApplicationCard(application: app),
        ),
      ),
    );

    expect(find.text('Software tester'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Edarikode, Malappuram'), findsOneWidget);
    expect(find.text('Withdrawn'), findsOneWidget);
    expect(find.text('Direct Application'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('08-Sept-2026'),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('No deadline'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('ApplicationDetailsPage renders all sections, cards, and specifications from screenshot',
      (WidgetTester tester) async {
    const app = JobApplicationEntity(
      id: 'app_test_1',
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
      aboutCompany: 'Test is a specialized QA and software testing team.',
    );

    await tester.pumpWidget(
      testApp(const ApplicationDetailsPage(application: app)),
    );

    // 1. App Bar
    expect(find.text('Application details'), findsOneWidget);

    // 2. Card 1: Application status
    expect(find.text('Application status'), findsOneWidget);
    expect(find.text('Withdrawn'), findsOneWidget);
    expect(find.text('APPLIED ON'), findsOneWidget);
    expect(find.text('08-Sept-2026, 6:14 am'), findsOneWidget);
    expect(find.text('SOURCE'), findsOneWidget);
    expect(find.text('Direct Application'), findsOneWidget);
    expect(find.text('LAST UPDATED'), findsOneWidget);
    expect(find.text('08-Sept-2026, 6:15 am'), findsOneWidget);
    expect(find.text('JOB STATUS'), findsOneWidget);
    expect(find.text('Published'), findsOneWidget);

    // 3. Card 2: Job Overview & Specs
    expect(find.text('Software tester'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('OCCUPATION'), findsOneWidget);
    expect(find.text('EMPLOYMENT TYPE'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
    expect(find.text('WORK MODE'), findsOneWidget);
    expect(find.text('Hybrid'), findsOneWidget);
    expect(find.text('SALARY'), findsOneWidget);
    expect(find.text('₹25,000 / monthly'), findsOneWidget);
    expect(find.text('EXPERIENCE'), findsOneWidget);
    expect(find.text('Fresher'), findsOneWidget);
    expect(find.text('VACANCIES'), findsOneWidget);
    expect(find.text('DEADLINE'), findsOneWidget);
    expect(find.text('No deadline'), findsOneWidget);
    expect(find.text('PUBLISHED'), findsOneWidget);
    expect(find.text('06-Sept-2026'), findsOneWidget);

    // Scroll down to see remaining cards
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    // 4. Card 3: Locations
    expect(find.text('Locations'), findsOneWidget);
    expect(find.text('Edarikode'), findsOneWidget);
    expect(find.text('Tirur, Malappuram'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);

    // 5. Card 4: Job description
    expect(find.text('Job description'), findsOneWidget);
    expect(find.text('Software tester bdbbdhd'), findsOneWidget);

    // 6. Card 5: Minimum education
    expect(find.text('Minimum education'), findsOneWidget);
    expect(find.text('SSLC / Class 10'), findsOneWidget);

    // 7. Card 6: Required skills
    expect(find.text('Required skills'), findsOneWidget);
    expect(find.text('Go'), findsOneWidget);
    expect(find.text('Typing'), findsOneWidget);

    // 8. Card 7: Languages
    expect(find.text('Languages'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Malayalam'), findsOneWidget);

    // 9. Card 8: About company
    expect(find.text('About company'), findsOneWidget);
  });

  testWidgets('CandidateHomeShell renders homepage with profile strength, filters, and jobs',
      (WidgetTester tester) async {
    const user = UserEntity(
      id: 'test_candidate_1',
      email: 'shibil@example.com',
      role: UserRole.jobSeeker,
      displayName: 'Shibil',
    );

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpWidget(
      testApp(const CandidateHomeShell(user: user, initialIndex: 0)),
    );
    await tester.pumpAndSettle();

    // 1. Header and Profile strength
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Shibil'), findsOneWidget);
    expect(find.text('Profile Strength'), findsOneWidget);

    // 2. Filters & Search
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('My preferences'), findsOneWidget);
    expect(find.text('District'), findsOneWidget);
    expect(find.text('Job category'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);

    // 3. Quick Actions
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('My Applications'), findsOneWidget);
    expect(find.text('Saved Jobs'), findsOneWidget);
    expect(find.text('Resume /\nProfile'), findsOneWidget);
    expect(find.text('My Interviews'), findsOneWidget);

    // 4. Jobs for you
    expect(find.text('Jobs for you'), findsOneWidget);
    expect(find.text('Kervia Working Patner'), findsOneWidget);
    expect(find.text('Kervia Working Coordinator'), findsOneWidget);
  });
}
