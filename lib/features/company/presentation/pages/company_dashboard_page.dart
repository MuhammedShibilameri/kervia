import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/company_profile_entity.dart';
import '../bloc/company_job_bloc.dart';
import 'applicant_detail_page.dart';
import 'post_job_page.dart';

class CompanyDashboardPage extends StatelessWidget {
  final UserEntity user;
  final CompanyProfileEntity companyProfile;
  final void Function(int)? onOpenTab;

  const CompanyDashboardPage({
    super.key,
    required this.user,
    required this.companyProfile,
    this.onOpenTab,
  });

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return BlocBuilder<CompanyJobBloc, CompanyJobState>(
      builder: (context, state) {
        if (state is CompanyJobLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CompanyJobError) {
          return Center(
            child: Text(
              state.message,
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          );
        }

        final jobs = state is CompanyJobLoaded ? state.jobs : const <dynamic>[];
        final applications =
            state is CompanyJobLoaded ? state.applications : const <dynamic>[];
        final publishedJobs =
            jobs.where((j) => j.jobStatus == 'Published').toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('Company Dashboard'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('Manage your jobs and applicants from one place.'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats row
                  isDesktop
                      ? Row(
                          children: [
                            Expanded(
                                child: _buildStatCard(
                                    context,
                                    context.tr('Total Jobs'),
                                    jobs.length,
                                    Icons.work_outline,
                                    () => _openTab(1))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildStatCard(
                                    context,
                                    context.tr('Published'),
                                    publishedJobs.length,
                                    Icons.check_circle_outline,
                                    () => _openTab(1))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildStatCard(
                                    context,
                                    context.tr('Applicants'),
                                    applications.length,
                                    Icons.people_outline,
                                    () => _openTab(2))),
                          ],
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: _buildStatCard(
                                        context,
                                        context.tr('Total Jobs'),
                                        jobs.length,
                                        Icons.work_outline,
                                        () => _openTab(1))),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _buildStatCard(
                                        context,
                                        context.tr('Published'),
                                        publishedJobs.length,
                                        Icons.check_circle_outline,
                                        () => _openTab(1))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildStatCard(
                                        context,
                                        context.tr('Applicants'),
                                        applications.length,
                                        Icons.people_outline,
                                        () => _openTab(2))),
                              ],
                            ),
                          ],
                        ),
                  const SizedBox(height: 28),

                  // Quick actions
                  Text(
                    context.tr('Quick Actions'),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<CompanyJobBloc>(),
                                  child: PostJobPage(
                                    user: user,
                                    companyProfile: companyProfile,
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: Text(context.tr('Post a Job')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Recent applications
                  Text(
                    context.tr('Recent Applications'),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (applications.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        context.tr(
                            'No applications yet. Share your job links to start receiving applications.'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  else
                    ...applications.take(3).map((app) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ApplicantDetailPage(application: app),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primarySoft,
                                child: Text(
                                  (app.candidateName ?? '?')
                                          .isNotEmpty
                                      ? app.candidateName!.substring(0, 1)
                                      : '?',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.candidateName ?? 'Candidate',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      app.jobTitle,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                context.tr(app.status.label),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openTab(int index) {
    onOpenTab?.call(index);
  }

  Widget _buildStatCard(BuildContext context, String label, int value,
      IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 22, color: AppColors.primary),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}