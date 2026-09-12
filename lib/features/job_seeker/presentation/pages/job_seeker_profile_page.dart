import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import '../../data/models/job_seeker_profile_model.dart';
import 'job_seeker_registration_page.dart';
import 'profile_detail_page.dart';

class JobSeekerProfilePage extends StatelessWidget {
  final UserEntity user;
  final JobSeekerProfileModel? profile;
  final VoidCallback? onProfileChanged;

  const JobSeekerProfilePage({
    super.key,
    required this.user,
    this.profile,
    this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    if (profile == null) {
      return _ProfileIncompleteBody(user: user);
    }
    return _ProfileMenu(
      user: user,
      profile: profile,
      onProfileChanged: onProfileChanged,
    );
  }
}

class _ProfileMenu extends StatefulWidget {
  final UserEntity user;
  final JobSeekerProfileModel profile;
  final VoidCallback? onProfileChanged;

  const _ProfileMenu({
    required this.user,
    required this.profile,
    this.onProfileChanged,
  });

  @override
  State<_ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<_ProfileMenu> {
  String _notifications = 'Enabled';

  void _signOut(BuildContext context) {
    context.read<AuthBloc>().add(SignOutEvent());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (route) => false,
    );
  }

  String get _initials {
    final parts = widget.profile.fullName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    final first = parts[0][0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }

  String get _role => widget.profile.currentOccupation.isNotEmpty
      ? widget.profile.currentOccupation
      : 'Job Seeker';

  String get _location {
    final district = widget.profile.district;
    final panchayat = widget.profile.panchayat
        .replaceAll(RegExp(r'\s*\((Municipality|Corporation)\)$'), '')
        .trim();
    final place = panchayat.isNotEmpty ? panchayat : widget.profile.taluk;
    if (place.isNotEmpty && district.isNotEmpty) return '$place, $district';
    if (place.isNotEmpty) return place;
    if (district.isNotEmpty) return district;
    return 'Location not set';
  }

  int _profileStrength() {
    final check = <bool>[
      widget.profile.fullName.isNotEmpty,
      widget.profile.email.isNotEmpty && widget.profile.email.contains('@'),
      widget.profile.phoneNumber.isNotEmpty,
      widget.profile.dateOfBirth.isNotEmpty,
      widget.profile.gender.isNotEmpty,
      widget.profile.district.isNotEmpty && widget.profile.taluk.isNotEmpty,
      widget.profile.highestQualification.isNotEmpty,
      widget.profile.currentOccupation.isNotEmpty,
      widget.profile.skills.isNotEmpty,
      widget.profile.preferredLocations.isNotEmpty,
    ];
    final present = check.where((e) => e).length;
    if (check.isEmpty) return 0;
    return ((present / check.length) * 100).round();
  }

  void _openDetail(ProfileDetailSection section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileDetailPage(
          profile: widget.profile,
          section: section,
          onProfileChanged: widget.onProfileChanged,
        ),
      ),
    );
  }

  void _showAbout(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Close')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final strength = _profileStrength();
    final languageSelected = AppLanguage.isMalayalam ? 'ML' : 'EN';
    final themeSelected = AppThemeMode.isDark ? 'Dark' : 'Light';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHeader(strength),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: context.tr('ACCOUNT'),
              children: [
                _menuItem(
                  icon: Icons.person_outline,
                  title: context.tr('Personal Details'),
                  subtitle: context.tr('Name, contact, location'),
                  onTap: () => _openDetail(ProfileDetailSection.personal),
                ),
                _menuItem(
                  icon: Icons.work_outline,
                  title: context.tr('Professional Details'),
                  subtitle: context.tr('Qualification, experience, salary'),
                  onTap: () => _openDetail(ProfileDetailSection.professional),
                ),
                _menuItem(
                  icon: Icons.tune,
                  title: context.tr('Skills & Preferences'),
                  subtitle: context.tr('Skills, languages, job preferences'),
                  onTap: () => _openDetail(ProfileDetailSection.skills),
                ),
                _menuItem(
                  icon: Icons.description_outlined,
                  title: context.tr('Resume & Video'),
                  subtitle: context.tr('Resume, introduction video'),
                  onTap: () => _openDetail(ProfileDetailSection.media),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: context.tr('SETTINGS'),
              children: [
                _menuItem(
                  icon: Icons.translate,
                  title: context.tr('Language'),
                  subtitle: context.tr('English'),
                  trailing: _segmentedControl(
                    options: const ['EN', 'ML'],
                    selected: languageSelected,
                    onChanged: (v) =>
                        AppLanguage.set(v == 'ML' ? 'ml' : 'en'),
                  ),
                ),
                _menuItem(
                  icon: Icons.light_mode_outlined,
                  title: context.tr('Theme'),
                  subtitle: context.tr(themeSelected),
                  trailing: _segmentedControl(
                    options: const ['Light', 'Dark'],
                    selected: themeSelected,
                    onChanged: (v) => AppThemeMode.set(
                        v == 'Dark' ? ThemeMode.dark : ThemeMode.light),
                  ),
                ),
                _menuItem(
                  icon: Icons.notifications_outlined,
                  title: context.tr('Notifications'),
                  subtitle: context.tr(_notifications),
                  trailing: _segmentedControl(
                    options: const ['Enabled', 'Disabled'],
                    selected: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: context.tr('ABOUT'),
              children: [
                _menuItem(
                  icon: Icons.verified_user_outlined,
                  title: context.tr('Privacy Policy'),
                  subtitle: null,
                  onTap: () => _showAbout(
                    context,
                    context.tr('Privacy Policy'),
                    context.tr(
                        'Kervia is committed to protecting your privacy.\n\n'
                        'We collect only the information necessary to connect job seekers with employers in your local area.\n\n'
                        'Your personal data - including your name, contact details, resume, and profile information - is stored securely and shared only with employers you choose to apply to.\n\n'
                        'We do not sell your data to third parties.\n\n'
                        'Location data is used solely to match you with nearby job opportunities.\n\n'
                        'For questions about our privacy practices, contact us at privacy@kervia.in.'),
                  ),
                ),
                _menuItem(
                  icon: Icons.description_outlined,
                  title: context.tr('Terms & Conditions'),
                  subtitle: null,
                  onTap: () => _showAbout(
                    context,
                    context.tr('Terms & Conditions'),
                    context.tr(
                        'By using Kervia, you agree to the following terms:\n'
                        '1. You must provide accurate information in your profile and job listings.\n'
                        '2. Employers must have valid business credentials to post jobs.\n'
                        '3. Job seekers must not misrepresent their qualifications.\n'
                        '4. Kervia reserves the right to suspend accounts that violate community guidelines.\n'
                        '5. All interview scheduling and payment features are subject to applicable service fees.\n'
                        '6. Content you upload (resumes, videos, company logos) must not contain inappropriate material.\n'
                        'For the full terms of service, visit kervia.in/ terms.'),
                  ),
                ),
                _menuItem(
                  icon: Icons.info_outline,
                  title: context.tr('About Kervia'),
                  subtitle: null,
                  onTap: () => _showAbout(
                    context,
                    context.tr('About Kervia'),
                    context.tr(
                        'Kervia is a local job matching platform built to connect job seekers and employers in Kerala.\n\n'
                        'Our mission is to make local employment accessible to everyone - from skilled tradespeople to office professionals - by bridging the gap between talent and opportunity in your community.\n\n'
                        'Kervia provides verified employer profiles, protected resumes, video introductions, and a streamlined interview scheduling system to make hiring faster and more personal.\n\n'
                        'Built with care in Kerala'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: null,
              children: [
                _menuItem(
                  icon: Icons.logout,
                  title: context.tr('Logout'),
                  subtitle: null,
                  destructive: true,
                  onTap: () => _signOut(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                context.tr('© 2026 Kervia • Candidate Portal'),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int strength) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.fullName.isNotEmpty
                          ? widget.profile.fullName
                          : context.tr('User'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(_role),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            context.tr(_location),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.tr('Profile Strength'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$strength%',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: strength >= 100
                      ? Colors.white
                      : const Color(0xFFFFD54F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: strength / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String? title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            Divider(color: AppColors.border, height: 1),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool destructive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: destructive
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: destructive ? AppColors.error : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: destructive
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: trailing,
              ),
            ] else ...[
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: destructive
                    ? AppColors.error.withValues(alpha: 0.6)
                    : AppColors.textMuted,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _segmentedControl({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Flexible(
            fit: FlexFit.loose,
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    context.tr(opt),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileIncompleteBody extends StatelessWidget {
  final UserEntity user;

  const _ProfileIncompleteBody({required this.user});

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_search_outlined,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.tr('Complete Your Profile'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr(
                          'Finish your registration so recruiters can discover your profile, resume and preferences.'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                JobSeekerRegistrationPage(user: user),
                          ),
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.tr('Complete Registration')),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}