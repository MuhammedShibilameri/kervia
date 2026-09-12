import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kervia/core/l10n/kervia_l10n.dart';
import 'package:kervia/core/theme/app_theme.dart';
import 'package:kervia/features/job_seeker/domain/entities/job_seeker_profile_entity.dart';
import 'package:kervia/features/job_seeker/presentation/pages/job_seeker_step2_page.dart';

Widget testApp(Widget home) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  testWidgets('Step2 renders without overflow at 360 width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const profile = JobSeekerProfileEntity(
      userId: 'test_user_1',
      fullName: 'Jane Doe',
      email: 'jane.doe@example.com',
    );

    await tester.pumpWidget(
      testApp(const JobSeekerStep2Page(profile: profile)),
    );
  });

  testWidgets('Step2 renders without overflow at 600 width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const profile = JobSeekerProfileEntity(
      userId: 'test_user_1',
      fullName: 'Jane Doe',
      email: 'jane.doe@example.com',
    );

    await tester.pumpWidget(
      testApp(const JobSeekerStep2Page(profile: profile)),
    );
  });
}