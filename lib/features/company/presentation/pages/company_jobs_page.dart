import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/job_post_entity.dart';
import '../bloc/company_job_bloc.dart';
import 'post_job_page.dart';

class CompanyJobsPage extends StatelessWidget {
  final UserEntity user;

  const CompanyJobsPage({super.key, required this.user});

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

        final jobs = state is CompanyJobLoaded ? state.jobs : const <JobPostEntity>[];

        if (jobs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_off_outlined,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('No jobs posted yet.'),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                        'Post your first job to start receiving applications.'),
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
                  Text(
                    context.tr('Your Jobs'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...jobs.map((job) => _buildJobCard(context, job)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobCard(BuildContext context, JobPostEntity job) {
    final isPublished = job.jobStatus == 'Published';
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.occupation,
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
                  color: isPublished
                      ? AppColors.primarySoft
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPublished ? context.tr('Published') : context.tr('Closed'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPublished
                        ? AppColors.primary
                        : AppColors.textMuted,
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
              _buildMeta(context, Icons.currency_rupee_outlined, job.salary),
              _buildMeta(context, Icons.work_outline, job.workMode),
              _buildMeta(context, Icons.location_on_outlined, job.location),
              _buildMeta(context, Icons.calendar_today_outlined, job.publishedDate),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _actionButton(
                context: context,
                icon: Icons.edit_outlined,
                label: context.tr('Edit'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CompanyJobBloc>(),
                        child: PostJobPage(
                          user: user,
                          existing: job,
                        ),
                      ),
                    ),
                  );
                },
              ),
              _actionButton(
                context: context,
                icon: isPublished
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                label: isPublished
                    ? context.tr('Close Job')
                    : context.tr('Reopen Job'),
                onPressed: () {
                  context
                      .read<CompanyJobBloc>()
                      .add(UpdateJobStatusEvent(
                        job.id ?? '',
                        isPublished ? 'Closed' : 'Published',
                      ));
                },
              ),
              _actionButton(
                context: context,
                icon: Icons.delete_outline,
                label: context.tr('Delete'),
                danger: true,
                onPressed: () => _confirmDelete(context, job),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool danger = false,
  }) {
    final color = danger ? AppColors.error : AppColors.primary;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
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

  Future<void> _confirmDelete(BuildContext context, JobPostEntity job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          context.tr('Delete this job?'),
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          context.tr(
              'This will permanently remove the job posting. This action cannot be undone.'),
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.tr('Delete'),
              style: GoogleFonts.inter(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && job.id != null && context.mounted) {
      context.read<CompanyJobBloc>().add(DeleteJobPostEvent(job.id!));
    }
  }
}