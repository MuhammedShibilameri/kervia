import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';

class AuthBrandPanel extends StatelessWidget {
  final String title;
  final String description;
  final List<AuthFeatureItem> features;

  const AuthBrandPanel({
    super.key,
    this.title = 'Elevate your career with Kervia',
    this.description =
        'The premier professional network connecting elite talent with top-tier companies. Whether you\'re searching for your next big role or building a world-class team, Kervia provides the tools you need to succeed.',
    this.features = const [
      AuthFeatureItem(
        icon: Icons.verified_user_outlined,
        title: 'Verified Professional Profiles',
      ),
      AuthFeatureItem(
        icon: Icons.work_outline,
        title: 'Curated High-Value Job Postings',
      ),
      AuthFeatureItem(
        icon: Icons.auto_awesome_outlined,
        title: 'AI-Powered Talent Matching',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.all_inclusive,
                  color: Colors.white,
                  size: 24,
                ),
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
          const SizedBox(height: 36),
          Text(
            context.tr(title),
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr(description),
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),
          ...features.map(
            (feat) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      feat.icon,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      context.tr(feat.title),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFeatureItem {
  final IconData icon;
  final String title;

  const AuthFeatureItem({
    required this.icon,
    required this.title,
  });
}
