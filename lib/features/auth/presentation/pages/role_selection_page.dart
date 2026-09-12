import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../../../job_seeker/presentation/pages/job_seeker_registration_page.dart';
import '../../../company/presentation/pages/company_registration_page.dart';

class RoleSelectionPage extends StatelessWidget {
  final UserEntity user;

  const RoleSelectionPage({
    super.key,
    required this.user,
  });

  void _onSelectJobSeeker(BuildContext context) {
    context.read<AuthBloc>().add(const SelectUserRoleEvent(UserRole.jobSeeker));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => JobSeekerRegistrationPage(user: user),
      ),
    );
  }

  void _onSelectCompany(BuildContext context) {
    context.read<AuthBloc>().add(const SelectUserRoleEvent(UserRole.company));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyRegistrationPage(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav / Branding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.all_inclusive, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Kervia',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('Choose Your Path'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Text(
                            context.tr(
                                "Join Kervia's professional network today. Select how you'd like to use our platform to get started."),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Two Cards
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildJobSeekerCard(context)),
                              const SizedBox(width: 28),
                              Expanded(child: _buildCompanyCard(context)),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildJobSeekerCard(context),
                              const SizedBox(height: 24),
                              _buildCompanyCard(context),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr(
                              'Kervia © 2026 Kervia Professional. All rights reserved.'),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Row(
                          children: [
                            _footerLink(context, context.tr('Privacy Policy')),
                            _footerDot(context),
                            _footerLink(context, context.tr('Terms of Service')),
                            _footerDot(context),
                            _footerLink(context, context.tr('Help Center')),
                            _footerDot(context),
                            _footerLink(context, context.tr('Contact')),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                          context.tr(
                              'Kervia © 2026 Kervia Professional. All rights reserved.'),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _footerLink(context, context.tr('Privacy Policy')),
                            _footerLink(context, context.tr('Terms of Service')),
                            _footerLink(context, context.tr('Help Center')),
                            _footerLink(context, context.tr('Contact')),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSeekerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('Job Seeker'),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
                'Find your dream job and grow your career. Access exclusive opportunities, build your professional profile, and connect with top recruiters.'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _onSelectJobSeeker(context),
            child: Text(context.tr('Register as Job Seeker')),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business_outlined,
              size: 36,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('Company'),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
                'Hire top talent and build your winning team. Post jobs, search our extensive candidate database, and manage your recruitment pipeline efficiently.'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => _onSelectCompany(context),
            child: Text(context.tr('Register as Company')),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(BuildContext context, String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _footerDot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '·',
        style: GoogleFonts.inter(color: AppColors.textMuted),
      ),
    );
  }
}
