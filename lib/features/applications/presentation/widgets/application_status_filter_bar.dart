import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/job_application_entity.dart';

class ApplicationStatusFilterBar extends StatelessWidget {
  final ApplicationStatus selectedStatus;
  final Function(ApplicationStatus) onStatusSelected;

  const ApplicationStatusFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  static const List<ApplicationStatus> statuses = [
    ApplicationStatus.all,
    ApplicationStatus.submitted,
    ApplicationStatus.inReview,
    ApplicationStatus.shortlisted,
    ApplicationStatus.interviewStage,
    ApplicationStatus.rejected,
    ApplicationStatus.withdrawn,
    ApplicationStatus.hired,
  ];

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Filter by status" label with icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.tune,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('Filter by status'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrolling filter pills
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: statuses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final status = statuses[index];
              final isSelected = selectedStatus == status;

              return InkWell(
                onTap: () => onStatusSelected(status),
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        context.tr(status.label),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
