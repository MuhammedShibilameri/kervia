import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../applications/domain/entities/job_application_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../bloc/company_job_bloc.dart';
import 'applicant_detail_page.dart';

class CompanyApplicantsPage extends StatelessWidget {
  final UserEntity user;
  final String companyName;

  const CompanyApplicantsPage({
    super.key,
    required this.user,
    this.companyName = '',
  });

  @override
  Widget build(BuildContext context) {
    context.adaptive();
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

        final applications =
            state is CompanyJobLoaded ? state.applications : const <JobApplicationEntity>[];

        if (applications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('No applications received yet.'),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                        'Applications from candidates will appear here.'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  ...applications.map((app) => _buildApplicantCard(context, app)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicantCard(BuildContext context, JobApplicationEntity app) {
    final name = (app.candidateName ?? '').isNotEmpty
        ? app.candidateName!
        : 'Candidate';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  name.substring(0, 1),
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
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.jobTitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(app.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.tr(app.status.label),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(app.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildMeta(
                  context, Icons.calendar_today_outlined, app.appliedDate),
              _buildMeta(context, Icons.location_on_outlined, app.location),
              app.experience.isNotEmpty
                  ? _buildMeta(
                      context, Icons.work_history_outlined, app.experience)
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplicantDetailPage(application: app),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: Text(context.tr('View Profile')),
              ),
              if (app.userId != null && app.userId!.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          userId: user.id,
                          displayName: companyName.isNotEmpty
                              ? companyName
                              : (user.displayName ?? 'Company'),
                          otherUserId: app.userId,
                          otherName: (app.candidateName ?? '').isNotEmpty
                              ? app.candidateName!
                              : 'Candidate',
                          canInitiate: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: Text(context.tr('Message')),
                ),
              TextButton.icon(
                onPressed: () => _showStatusDialog(context, app),
                icon: const Icon(Icons.track_changes_outlined, size: 16),
                label: Text(context.tr('Update Status')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return const Color(0xFF607D8B);
      case ApplicationStatus.inReview:
        return const Color(0xFF7B61FF);
      case ApplicationStatus.shortlisted:
        return const Color(0xFF0F4C44);
      case ApplicationStatus.interviewStage:
        return const Color(0xFF1565C0);
      case ApplicationStatus.hired:
        return const Color(0xFF2E7D32);
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return const Color(0xFFC62828);
      case ApplicationStatus.all:
        return AppColors.textMuted;
    }
  }

  Widget _buildMeta(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _showStatusDialog(
      BuildContext context, JobApplicationEntity app) async {
    final availableStatuses = [
      ApplicationStatus.submitted,
      ApplicationStatus.inReview,
      ApplicationStatus.shortlisted,
      ApplicationStatus.interviewStage,
      ApplicationStatus.hired,
      ApplicationStatus.rejected,
    ];

    final selected = await showDialog<ApplicationStatus>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          context.tr('Update Application Status'),
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: RadioGroup<ApplicationStatus>(
            groupValue: app.status,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableStatuses.map((status) {
                final isCurrent = app.status == status;
                return RadioListTile<ApplicationStatus>(
                  value: status,
                  title: Text(
                    context.tr(status.label),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  secondary: isCurrent
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Cancel')),
          ),
        ],
      ),
    );

    if (selected != null && selected != app.status && context.mounted) {
      context
          .read<CompanyJobBloc>()
          .add(UpdateApplicationStatusEvent(app.id, selected));
    }
  }
}