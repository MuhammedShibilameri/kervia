import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_opener.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/job_seeker_profile_entity.dart';
import '../widgets/registration_stepper_header.dart';
import 'candidate_home_shell.dart';

class JobSeekerStep3ReviewPage extends StatefulWidget {
  final JobSeekerProfileEntity profile;

  const JobSeekerStep3ReviewPage({
    super.key,
    required this.profile,
  });

  @override
  State<JobSeekerStep3ReviewPage> createState() =>
      _JobSeekerStep3ReviewPageState();
}

class _JobSeekerStep3ReviewPageState extends State<JobSeekerStep3ReviewPage> {
  bool _declarationConfirmed = true;
  bool _termsAgreed = true;
  bool _isSubmitting = false;

  String _compensationOverview(JobSeekerProfileEntity profile) {
    final parts = <String>[
      if (profile.currentSalary.isNotEmpty) 'Current ₹${profile.currentSalary}',
      if (profile.expectedSalary.isNotEmpty) 'Expected ₹${profile.expectedSalary}',
    ];
    return parts.isEmpty ? '—' : parts.join(' → ');
  }

  String get _initials {
    final parts = widget.profile.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  String _orDash(String value) => value.isNotEmpty ? value : '—';

  Future<void> _openFile(String? path, {required String label, String? mime}) async {
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No $label added yet. Go back to Step 2 to upload one.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    if (isRemotePath(path)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Downloading, please wait...')),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      final localPath = await downloadRemoteFile(path, label);
      if (localPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('Could not download the file.')),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      final result = await OpenFilex.open(localPath, type: mime ?? '*/*');
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $label: ${result.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    final result = await OpenFilex.open(path, type: mime ?? '*/*');
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $label: ${result.message}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _onSubmit() async {
    if (!_declarationConfirmed || !_termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              context.tr('Please accept the declarations and terms to proceed.')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Save directly to Firestore collection 'job_seekers'
      await FirebaseFirestore.instance
          .collection('job_seekers')
          .doc(widget.profile.userId)
          .set({
        ..._profileToMap(widget.profile),
        'isSubmitted': true,
        'stepCompleted': 3,
        'submittedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Mark user profile as complete
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.profile.userId)
          .set({
        'isProfileComplete': true,
        'role': 'jobSeeker',
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${context.tr('Submission failed:')} $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Map<String, dynamic> _profileToMap(JobSeekerProfileEntity p) {
    return {
      'fullName': p.fullName,
      'email': p.email,
      'phoneNumber': p.phoneNumber,
      'dateOfBirth': p.dateOfBirth,
      'gender': p.gender,
      'currentLocation': p.currentLocation,
      'state': p.state,
      'district': p.district,
      'taluk': p.taluk,
      'panchayat': p.panchayat,
      'highestQualification': p.highestQualification,
      'currentOccupation': p.currentOccupation,
      'yearsOfExperience': p.yearsOfExperience,
      'currentSalary': p.currentSalary,
      'expectedSalary': p.expectedSalary,
      'skills': p.skills,
      'languages': p.languages,
      'preferredLocations': p.preferredLocations,
      'workMode': p.workMode,
      'salaryType': p.salaryType,
      'preferredCategories': p.preferredCategories,
      'employmentTypes': p.employmentTypes,
      'resumeName': p.resumeName,
      'resumeSize': p.resumeSize,
      'resumePath': p.resumePath,
      'videoName': p.videoName,
      'videoSize': p.videoSize,
      'videoPath': p.videoPath,
      'declarationsConfirmed': _declarationConfirmed,
      'termsAgreed': _termsAgreed,
    };
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('Registration Submitted!'),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.tr(
                    'Welcome to Kervia! Your professional profile is now verified and active. Recruiters can now discover your resume and applications.'),
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
                  Navigator.pop(context); // close dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CandidateHomeShell(
                        user: UserEntity(
                          id: widget.profile.userId,
                          displayName: widget.profile.fullName,
                          email: widget.profile.email,
                          phoneNumber: widget.profile.phoneNumber,
                          role: UserRole.jobSeeker,
                          isProfileComplete: true,
                        ),
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: Text(context.tr('Go to Home / Dashboard')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final p = widget.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepperHeader(currentStep: 3),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Page Heading
                        Text(
                          context.tr('Review Your Registration Details'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr(
                              'Please verify all your personal, professional, and preference details before final submission.'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Card 1: Personal Information
                        _buildReviewCard(
                          context,
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          onEdit: () => Navigator.pop(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _initials,
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
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
                                          _orDash(p.fullName),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            if (p.currentOccupation.isNotEmpty) p.currentOccupation,
                                            if (p.district.isNotEmpty || p.state.isNotEmpty)
                                              [p.district, p.state].where((e) => e.isNotEmpty).join(', '),
                                          ].where((e) => e.isNotEmpty).join(' • '),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Divider(color: AppColors.border),
                              const SizedBox(height: 16),
                              _buildReviewRow(
                          context,
                                'EMAIL ADDRESS',
                                _orDash(p.email),
                                'PHONE NUMBER',
                                _orDash(p.phoneNumber),
                              ),
                              const SizedBox(height: 16),
                              _buildReviewRow(
                          context,
                                'DATE OF BIRTH',
                                _orDash(p.dateOfBirth),
                                'GENDER',
                                _orDash(p.gender),
                              ),
                              const SizedBox(height: 16),
                              _buildReviewItem(
                          context,
                              'CURRENT ADDRESS', _orDash(p.currentLocation)),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final itemWidth = (constraints.maxWidth - 12) / 2;
                                  return Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      SizedBox(width: itemWidth, child: _buildMiniField(context, 'State', _orDash(p.state))),
                                      SizedBox(width: itemWidth, child: _buildMiniField(context, 'District', _orDash(p.district))),
                                      SizedBox(width: itemWidth, child: _buildMiniField(context, 'Taluk', _orDash(p.taluk))),
                                      SizedBox(width: itemWidth, child: _buildMiniField(context, 'Panchayat / Muni.', _orDash(p.panchayat))),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Card 2: Professional Summary
                        _buildReviewCard(
                          context,
                          icon: Icons.work_outline,
                          title: 'Professional Summary',
                          onEdit: () => Navigator.pop(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildReviewRow(
                          context,
                                'HIGHEST QUALIFICATION',
                                _orDash(p.highestQualification),
                                'CURRENT OCCUPATION',
                                _orDash(p.currentOccupation),
                              ),
                              const SizedBox(height: 16),
                              _buildReviewRow(
                          context,
                                'YEARS OF EXPERIENCE',
                                p.yearsOfExperience.isNotEmpty
                                    ? '${p.yearsOfExperience} Years'
                                    : '—',
                                'COMPENSATION OVERVIEW',
                                _compensationOverview(p),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Card 3: Skills & Languages
                        _buildReviewCard(
                          context,
                          icon: Icons.lightbulb_outline,
                          title: 'Skills & Languages',
                          onEdit: () => Navigator.pop(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('VALIDATED KEY SKILLS'), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                              const SizedBox(height: 8),
                              p.skills.isNotEmpty
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: p.skills.map((s) => _buildOutlinedTag(s)).toList(),
                                    )
                                  : Text('—', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(height: 20),
                              Text(context.tr('LANGUAGES KNOWN'), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                              const SizedBox(height: 8),
                              p.languages.isNotEmpty
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: p.languages.map((l) => _buildOutlinedTag(l)).toList(),
                                    )
                                  : Text('—', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Card 4: Job & Location Preferences
                        _buildReviewCard(
                          context,
                          icon: Icons.tune,
                          title: 'Job & Location Preferences',
                          onEdit: () => Navigator.pop(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('TARGET LOCATIONS'), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                              const SizedBox(height: 8),
                              p.preferredLocations.isNotEmpty
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: p.preferredLocations.map((loc) => _buildOutlinedTag(loc)).toList(),
                                    )
                                  : Text('—', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(height: 16),
                              _buildReviewRow(
                          context,
                                'WORK MODE',
                                _orDash(p.workMode),
                                'SALARY EXPECTATION TYPE',
                                _orDash(p.salaryType),
                              ),
                              const SizedBox(height: 16),
                              _buildReviewRow(
                          context,
                                'PREFERRED ROLES',
                                _orDash(p.preferredCategories),
                                'EMPLOYMENT TYPES',
                                p.employmentTypes.isNotEmpty ? p.employmentTypes.join(', ') : '—',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Card 5: Resumes & Introduction Video
                        _buildReviewCard(
                          context,
                          icon: Icons.attach_file,
                          title: 'Resumes & Introduction Video',
                          onEdit: () => Navigator.pop(context),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 580;
                              final hasResume = (p.resumeName ?? '').isNotEmpty;
                              final hasVideo = (p.videoName ?? '').isNotEmpty;
                              final resumeWidget = _buildAttachmentCard(
                                context,
                                icon: Icons.picture_as_pdf_outlined,
                                hasFile: hasResume,
                                name: hasResume ? p.resumeName! : null,
                                details: hasResume ? 'PDF • ${p.resumeSize ?? '—'}'
                                    : context.tr('No resume yet. Add it in Step 2.'),
                                onActionTap: hasResume
                                    ? () => _openFile(p.resumePath, label: 'resume', mime: 'application/pdf')
                                    : null,
                              );
                              final videoWidget = _buildAttachmentCard(
                                context,
                                icon: Icons.videocam_outlined,
                                hasFile: hasVideo,
                                name: hasVideo ? p.videoName! : null,
                                details: hasVideo ? 'MP4 • ${p.videoSize ?? '—'}'
                                    : context.tr('No intro video yet. Add it in Step 2.'),
                                onActionTap: hasVideo
                                    ? () => _openFile(p.videoPath, label: 'intro video', mime: 'video/mp4')
                                    : null,
                                isVideo: hasVideo,
                              );

                              if (isWide) {
                                return Row(
                                  children: [
                                    Expanded(child: resumeWidget),
                                    const SizedBox(width: 16),
                                    Expanded(child: videoWidget),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    resumeWidget,
                                    const SizedBox(height: 12),
                                    videoWidget,
                                  ],
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Card 6: Applicant Declaration & Consent
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_outlined, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      context.tr('Applicant Declaration & Consent'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _declarationConfirmed,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(() => _declarationConfirmed = val ?? false),
                                  ),
                                  Expanded(
                                    child: Text(
                                      context.tr(
                                          'I hereby confirm that all details provided above are true, accurate, and complete to the best of my knowledge. I understand that any false information may lead to the cancellation of my candidature.'),
                                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _termsAgreed,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(() => _termsAgreed = val ?? false),
                                  ),
                                  Expanded(
                                    child: Text(
                                      context.tr(
                                          "I agree to Kervia's Terms of Service and acknowledge the Privacy Policy regarding the handling and storage of my professional data."),
                                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Bottom Navigation Actions
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: Text(context.tr('Back to Step 2')),
                            ),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(context.tr(
                                              'Draft saved successfully.')),
                                          backgroundColor: AppColors.primary),
                                    );
                                  },
                                  icon: const Icon(Icons.save_outlined, size: 18),
                                  label: Text(context.tr('Save as Draft')),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    minimumSize: const Size(0, 48),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _isSubmitting ? null : _onSubmit,
                                  icon: _isSubmitting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.check, size: 18),
                                  label: Text(context.tr('Confirm & Submit Registration')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    minimumSize: const Size(0, 48),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // Legal Footer
                        Center(
                          child: Text(
                            context.tr(
                                '© 2026 Kervia Careers • All rights reserved. Secure encrypted transmission.'),
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr(title),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('Edit'),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildReviewRow(
      BuildContext context, String l1, String v1, String l2, String v2) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;
        final first = _buildReviewItem(context, l1, v1);
        final second = _buildReviewItem(context, l2, v2);
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              first,
              const SizedBox(height: 16),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 20),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  Widget _buildReviewItem(
      BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(label),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniField(
      BuildContext context, String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr(label), style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildOutlinedTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAttachmentCard(
    BuildContext context, {
    required IconData icon,
    required bool hasFile,
    required String? name,
    required String details,
    VoidCallback? onActionTap,
    bool isVideo = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasFile ? AppColors.primary : AppColors.border,
          width: hasFile ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? context.tr('No file added'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasFile) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onActionTap,
                icon: Icon(
                  isVideo ? Icons.play_circle_outline : Icons.file_download_outlined,
                  size: 18,
                ),
                label: Text(isVideo
                    ? context.tr('Play Video')
                    : context.tr('Preview / Download')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 44),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
