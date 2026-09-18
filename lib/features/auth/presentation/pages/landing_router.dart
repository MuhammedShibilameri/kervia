import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../company/data/datasources/company_remote_data_source.dart';
import '../../../company/presentation/pages/company_home_shell_page.dart';
import '../../../company/presentation/pages/company_registration_page.dart';
import '../../../job_seeker/presentation/pages/candidate_home_shell.dart';
import '../../../job_seeker/presentation/pages/job_seeker_registration_page.dart';
import '../../domain/entities/user_entity.dart';
import 'role_selection_page.dart';

/// Routes an authenticated user straight to the right screen:
/// - job seeker  -> home shell (or registration if profile not submitted)
/// - company     -> home shell (or registration if profile incomplete)
/// - unassigned  -> role selection
Future<void> navigateToLanding(BuildContext context, UserEntity user) async {
  final navigator = Navigator.of(context);
  Widget target;
  try {
    if (user.role == UserRole.jobSeeker) {
      final doc = await FirebaseFirestore.instance
          .collection('job_seekers')
          .doc(user.id)
          .get();
      final isSubmitted = (doc.data()?['isSubmitted'] as bool?) ?? false;
      target = isSubmitted
          ? CandidateHomeShell(user: user) as Widget
          : JobSeekerRegistrationPage(user: user) as Widget;
    } else if (user.role == UserRole.company) {
      final profile = await CompanyRemoteDataSourceImpl().getProfile(user.id);
      target = (profile != null && profile.isProfileComplete)
          ? CompanyHomeShellPage(user: user, companyProfile: profile) as Widget
          : CompanyRegistrationPage(user: user) as Widget;
    } else {
      target = RoleSelectionPage(user: user);
    }
  } catch (_) {
    target = user.role == UserRole.company
        ? CompanyRegistrationPage(user: user) as Widget
        : JobSeekerRegistrationPage(user: user) as Widget;
  }
  if (!context.mounted) return;
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => target),
    (route) => false,
  );
}