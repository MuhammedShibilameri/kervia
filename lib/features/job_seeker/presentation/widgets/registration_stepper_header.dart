import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';

class RegistrationStepperHeader extends StatelessWidget {
  final int currentStep; // 1, 2, or 3
  final String stepSubtitle;

  const RegistrationStepperHeader({
    super.key,
    required this.currentStep,
    this.stepSubtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    String stepLabel;
    if (currentStep == 1) {
      stepLabel = context.tr('Step 1 of 3');
    } else if (currentStep == 2) {
      stepLabel = context.tr('Step 2 of 3');
    } else {
      stepLabel = context.tr('Step 3 of 3: Review & Submit Registration');
    }

    return Column(
      children: [
        // Top App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_add_alt_outlined,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        context.tr('Registration'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Text(
                  stepLabel,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stepper Progress Track
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Row(
              children: [
                Expanded(child: _buildStepNode(context, 1, context.tr('Basic Info'))),
                Expanded(
                  child: Container(
                    height: 2,
                    color: currentStep > 1 ? AppColors.primary : AppColors.border,
                  ),
                ),
                Expanded(child: _buildStepNode(context, 2, context.tr('Professional'))),
                Expanded(
                  child: Container(
                    height: 2,
                    color: currentStep > 2 ? AppColors.primary : AppColors.border,
                  ),
                ),
                Expanded(child: _buildStepNode(context, 3, context.tr('Review & Submit'))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepNode(
      BuildContext context, int step, String label) {
    final isCompleted = currentStep > step;
    final isActive = currentStep == step;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isActive ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text(
                    step.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppColors.textMuted,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.tr(label),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
            color: isActive || isCompleted ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
