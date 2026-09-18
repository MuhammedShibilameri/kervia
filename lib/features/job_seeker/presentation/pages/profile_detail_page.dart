import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_opener.dart';
import '../../domain/entities/job_seeker_profile_entity.dart';
import 'profile_edit_page.dart';

enum ProfileDetailSection { personal, professional, skills, media }

class ProfileDetailPage extends StatefulWidget {
  final JobSeekerProfileEntity profile;
  final ProfileDetailSection section;
  final VoidCallback? onProfileChanged;

  const ProfileDetailPage({
    super.key,
    required this.profile,
    required this.section,
    this.onProfileChanged,
  });

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late JobSeekerProfileEntity _profile = widget.profile;

  ({String title, IconData icon}) get _config => switch (widget.section) {
        ProfileDetailSection.personal => (
            title: 'Personal Details',
            icon: Icons.person_outline,
          ),
        ProfileDetailSection.professional => (
            title: 'Professional Details',
            icon: Icons.work_outline,
          ),
        ProfileDetailSection.skills => (
            title: 'Skills & Preferences',
            icon: Icons.tune,
          ),
        ProfileDetailSection.media => (
            title: 'Resume & Video',
            icon: Icons.description_outlined,
          ),
      };

  Future<void> _openEdit() async {
    final updated = await Navigator.push<JobSeekerProfileEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditPage(
          userId: _profile.userId,
          profile: _profile,
          section: widget.section,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
      widget.onProfileChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr(_config.title)} ${context.tr('updated.')}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr(_config.title),
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _openEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(context.tr('Edit')),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  switch (widget.section) {
                    ProfileDetailSection.personal => _personalContent(),
                    ProfileDetailSection.professional => _professionalContent(),
                    ProfileDetailSection.skills => _skillsContent(),
                    ProfileDetailSection.media => _mediaContent(),
                  },
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _orDash(String v) => v.isNotEmpty ? v : '—';

  String get _initials {
    final parts = _profile.fullName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    final first = parts[0][0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }

  String _formatSalary(String amount) {
    if (amount.isEmpty || amount == '0' || amount == '0.00') return '—';
    final period = switch (_profile.salaryType) {
      'Hourly' => '/ hour',
      'Annual' => '/ year',
      _ => '/ month',
    };
    return '₹$amount $period';
  }

  List<String> _splitRoles() {
    return _profile.preferredCategories
        .split(RegExp(r'[\n,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Widget _simpleCard({required Widget child, Widget? header}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: header == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 16),
                child,
              ],
            ),
    );
  }

  Widget _simpleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: AppColors.border, height: 1);

  Widget _chipBlock(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        items.isNotEmpty
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((s) => _chip(s)).toList(),
              )
            : Text(
                '—',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
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

  Widget _personalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _simpleCard(
          header: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _orDash(_profile.fullName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _orDash(_profile.currentOccupation),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _openEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
          child: Column(
            children: [
              _simpleRow(context.tr('Date of Birth'), _orDash(_profile.dateOfBirth)),
              _divider(),
              _simpleRow(context.tr('Gender'), _orDash(_profile.gender)),
              _divider(),
              _simpleRow(context.tr('Phone Number'), _orDash(_profile.phoneNumber)),
              _divider(),
              _simpleRow(context.tr('Email Address'), _orDash(_profile.email)),
              _divider(),
              _simpleRow(
                  context.tr('Current Address'), _orDash(_profile.currentLocation)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _simpleCard(
          header: Row(
            children: [
              const Icon(Icons.location_city_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                context.tr('Regional Details'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          child: Column(
            children: [
              _simpleRow(context.tr('State'), _orDash(_profile.state)),
              _divider(),
              _simpleRow(context.tr('District'), _orDash(_profile.district)),
              _divider(),
              _simpleRow(context.tr('Taluk'), _orDash(_profile.taluk)),
              _divider(),
              _simpleRow(
                  context.tr('Local Body'), _orDash(_profile.panchayat)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _professionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _simpleCard(
          child: Column(
            children: [
              _simpleRow(
                context.tr('Current Occupation'),
                _orDash(_profile.currentOccupation),
              ),
              _divider(),
              _simpleRow(
                context.tr('Highest Qualification'),
                _orDash(_profile.highestQualification),
              ),
              _divider(),
              _simpleRow(
                context.tr('Years of Experience'),
                _profile.yearsOfExperience.isNotEmpty
                    ? '${_profile.yearsOfExperience} Years'
                    : '—',
              ),
              _divider(),
              _simpleRow(context.tr('Current Salary'),
                  _formatSalary(_profile.currentSalary)),
              _divider(),
              _simpleRow(context.tr('Expected Salary'),
                  _formatSalary(_profile.expectedSalary)),
              _divider(),
              _simpleRow(
                  context.tr('Salary Period'), _orDash(_profile.salaryType)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skillsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _simpleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _chipBlock(context.tr('Key Skills'), _profile.skills),
              const SizedBox(height: 20),
              _divider(),
              const SizedBox(height: 20),
              _chipBlock(context.tr('Languages Spoken'), _profile.languages),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _simpleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _simpleRow(context.tr('Preferred Work Mode'), _orDash(_profile.workMode)),
              _divider(),
              _simpleRow(
                context.tr('Employment Types'),
                _profile.employmentTypes.isNotEmpty
                    ? _profile.employmentTypes.join(', ')
                    : '—',
              ),
              _divider(),
              _chipBlock(context.tr('Preferred Job Roles'), _splitRoles()),
              const SizedBox(height: 20),
              _divider(),
              const SizedBox(height: 20),
              _chipBlock(context.tr('Target Locations'), _profile.preferredLocations),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mediaContent() {
    final hasResume = (_profile.resumeName ?? '').isNotEmpty;
    final hasVideo = (_profile.videoName ?? '').isNotEmpty;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 580;
        final resumeWidget = _attachmentTile(
          icon: Icons.picture_as_pdf_outlined,
          hasFile: hasResume,
          name: hasResume ? _profile.resumeName : null,
          details: hasResume
              ? 'PDF • ${_profile.resumeSize ?? '—'}'
              : context.tr('No resume added yet.'),
          actionLabel: context.tr('Preview / Download'),
          onTap: hasResume
              ? () => _openFile(
                    context,
                    _profile.resumePath,
                    label: 'resume',
                    mime: 'application/pdf',
                  )
              : null,
        );
        final videoWidget = _attachmentTile(
          icon: Icons.videocam_outlined,
          hasFile: hasVideo,
          name: hasVideo ? _profile.videoName : null,
          details: hasVideo
              ? 'MP4 • ${_profile.videoSize ?? '—'}'
              : context.tr('No intro video added yet.'),
          actionLabel: context.tr('Play Video'),
          onTap: hasVideo
              ? () => _openFile(
                    context,
                    _profile.videoPath,
                    label: 'intro video',
                    mime: 'video/mp4',
                  )
              : null,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              onPressed: _openEdit,
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: Text(context.tr('Add / Change Resume or Video')),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: resumeWidget),
                  const SizedBox(width: 16),
                  Expanded(child: videoWidget),
                ],
              )
            else ...[
              resumeWidget,
              const SizedBox(height: 12),
              videoWidget,
            ],
          ],
        );
      },
    );
  }

  Widget _attachmentTile({
    required IconData icon,
    required bool hasFile,
    required String? name,
    required String details,
    required String actionLabel,
    VoidCallback? onTap,
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
              TextButton(
                onPressed: _openEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
                child: Text(context.tr('Edit')),
              ),
            ],
          ),
          if (hasFile) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.play_circle_outline, size: 18),
                label: Text(actionLabel),
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

  Future<void> _openFile(
    BuildContext context,
    String? path, {
    required String label,
    String? mime,
  }) async {
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No $label available to open.'),
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('Could not download the file.')),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      final result = await OpenFilex.open(localPath,
          type: mime ?? '*/*');
      if (result.type != ResultType.done && context.mounted) {
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
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $label: ${result.message}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}