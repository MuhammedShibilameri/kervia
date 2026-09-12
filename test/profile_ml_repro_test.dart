import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kervia/core/l10n/kervia_l10n.dart';
import 'package:kervia/core/theme/app_theme.dart';
import 'package:kervia/features/auth/domain/entities/user_entity.dart';
import 'package:kervia/features/job_seeker/data/models/job_seeker_profile_model.dart';
import 'package:kervia/features/job_seeker/presentation/pages/job_seeker_profile_page.dart';

Widget testApp(Widget home) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  testWidgets('Profile page ML notifications no overflow 360',
      (WidgetTester tester) async {
    AppLanguage.set('ml');
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(() => AppLanguage.set('en'));

    const user = UserEntity(
      id: 'test_user_1',
      email: 'jane.doe@example.com',
      displayName: 'Jane Doe',
    );

    const profile = JobSeekerProfileModel(
      userId: 'test_user_1',
      fullName: 'Jane Doe',
      email: 'jane.doe@example.com',
      currentOccupation: 'Software Engineer',
      district: 'Malappuram',
      taluk: 'Tirur',
    );

    await tester.pumpWidget(
      testApp(const JobSeekerProfilePage(user: user, profile: profile)),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile page ML notifications no overflow 320',
      (WidgetTester tester) async {
    AppLanguage.set('ml');
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(() => AppLanguage.set('en'));

    const user = UserEntity(
      id: 'test_user_1',
      email: 'jane.doe@example.com',
      displayName: 'Jane Doe',
    );

    const profile = JobSeekerProfileModel(
      userId: 'test_user_1',
      fullName: 'Jane Doe',
      email: 'jane.doe@example.com',
      currentOccupation: 'Software Engineer',
      district: 'Malappuram',
      taluk: 'Tirur',
    );

    await tester.pumpWidget(
      testApp(const JobSeekerProfilePage(user: user, profile: profile)),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile page ML legal dialogs no overflow 320',
      (WidgetTester tester) async {
    AppLanguage.set('ml');
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(() => AppLanguage.set('en'));

    const user = UserEntity(
      id: 'test_user_1',
      email: 'jane.doe@example.com',
      displayName: 'Jane Doe',
    );

    const profile = JobSeekerProfileModel(
      userId: 'test_user_1',
      fullName: 'Jane Doe',
      email: 'jane.doe@example.com',
      currentOccupation: 'Software Engineer',
      district: 'Malappuram',
      taluk: 'Tirur',
    );

    final overflowErrors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      overflowErrors.add(details);
    };

    await tester.pumpWidget(
      testApp(const JobSeekerProfilePage(user: user, profile: profile)),
    );
    await tester.pump();

    for (final label in [
      'സ്വകാര്യതാ നയം',
      'നിയമങ്ങളും വ്യവസ്ഥകളും',
      'കേർവിയയെ കുറിച്ച്',
    ]) {
      final finder = find.text(label);
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder);
        await tester.pumpAndSettle();
        await tester.tap(find.text('അടയ്ക്കുക'));
        await tester.pumpAndSettle();
      }
    }

    FlutterError.onError = previousOnError;

    final overflows = overflowErrors
        .where((d) => d.toString().contains('overflowed'))
        .toList();
    expect(overflows, isEmpty);
  });
}
