import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kervia/core/l10n/kervia_l10n.dart';
import 'package:kervia/core/theme/app_theme.dart';
import 'package:kervia/features/job_seeker/domain/entities/job_seeker_profile_entity.dart';
import 'package:kervia/features/job_seeker/presentation/pages/job_seeker_step3_review_page.dart';

Widget testApp(Widget home) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  const longProfile = JobSeekerProfileEntity(
    userId: 'test_user_1',
    fullName: 'Muhammed Shibil K Abdulrahimanckandy',
    email: 'mhdshibil9562@gmail.com',
    phoneNumber: '+91 98765 43210',
    dateOfBirth: '15/05/1998',
    gender: 'Male',
    currentLocation: 'KAVANNUR HOUSE, NEAR MASJID, P.O. ATHAVANAD VIA TIRUR, MALAPPURAM DISTRICT, PIN 676301, KERALA',
    state: 'Kerala',
    district: 'Malappuram',
    taluk: 'Tirur',
    panchayat: 'Kuttippuram Municipality',
    highestQualification: 'Master of Computer Applications (MCA), Computer Science',
    currentOccupation: 'Flutter & Node.js Full Stack Software Engineer',
    yearsOfExperience: '7',
    currentSalary: '8,50,000',
    expectedSalary: '15,00,000',
    skills: ['Flutter', 'Dart', 'Firebase', 'Node.js', 'MongoDB', 'REST APIs', 'Clean Architecture', 'CI/CD'],
    languages: ['Malayalam (Native)', 'English (Full Professional)', 'Hindi (Working)', 'Arabic (Basic)'],
    preferredLocations: ['Kochi', 'Bengaluru', 'Remote', 'Doha', 'Dubai', 'Calicut'],
    workMode: 'Hybrid',
    salaryType: 'Annual',
    preferredCategories: 'Software Development, Mobile App Development, Product Engineering',
    employmentTypes: ['Full-time', 'Contract', 'Remote'],
    resumeName: 'Shibil_Resume_2026_Final_Updated.pdf',
    resumeSize: '2.4 MB',
    videoName: 'Intro_Video_Muhammed_Shibil.mp4',
    videoSize: '18.5 MB',
  );

  testWidgets('Step3 renders without overflow at 360 width with long data',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      testApp(const JobSeekerStep3ReviewPage(profile: longProfile)),
    );

    await tester.scrollUntilVisible(
      find.textContaining('Confirm & Submit Registration'),
      400,
    );
  });

  testWidgets('Step3 renders without overflow at 600 width with long data',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      testApp(const JobSeekerStep3ReviewPage(profile: longProfile)),
    );

    await tester.scrollUntilVisible(
      find.textContaining('Confirm & Submit Registration'),
      400,
    );
  });
}