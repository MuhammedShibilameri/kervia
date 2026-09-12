import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_opener.dart';
import '../../../applications/domain/entities/job_application_entity.dart';
import '../../../job_seeker/data/models/job_seeker_profile_model.dart';

class ApplicantDetailPage extends StatefulWidget {
  final JobApplicationEntity application;

  const ApplicantDetailPage({super.key, required this.application});

  @override
  State<ApplicantDetailPage> createState() => _ApplicantDetailPageState();
}

class _ApplicantDetailPageState extends State<ApplicantDetailPage> {
  JobSeekerProfileModel? _profile;
  bool _loading = true;

  static FirebaseFirestore? _db() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> get _app => {
    'job': widget.application.jobTitle,
    'status': widget.application.status.label,
    'appliedDate': widget.application.appliedDate,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = widget.application.userId;
    final db = _db();
    if (userId == null || userId.isEmpty || db == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final doc = await db.collection('job_seekers').doc(userId).get();
      if (!mounted) return;
      setState(() {
        _profile = doc.exists && doc.data() != null
            ? JobSeekerProfileModel.fromMap(doc.data()!, userId)
            : null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isHttp(String? path) => isRemotePath(path);

  Future<void> _openFile(String? path, String name) async {
    if (path == null || path.isEmpty) return;
    if (_isHttp(path)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Downloading, please wait...')),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      final localPath = await downloadRemoteFile(path, name);
      if (localPath == null) {
        await Clipboard.setData(ClipboardData(text: path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr('Download failed. Link copied to clipboard.'),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      try {
        await OpenFilex.open(localPath);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('Could not open the file.')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
      return;
    }
    final file = File(path);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('File is not available on this device.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    try {
      await OpenFilex.open(path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Could not open the file.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_app['job']} - ${context.tr('Applicant')}',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _profile == null
            ? _buildMissing(context)
            : _buildProfile(context, _profile!),
      ),
    );
  }

  Widget _buildMissing(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('Candidate profile could not be loaded.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, JobSeekerProfileModel p) {
    final name = p.fullName.isNotEmpty
        ? p.fullName
        : (widget.application.candidateName ?? 'Candidate');
    final expected = double.tryParse(p.expectedSalary);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primarySoft,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (p.currentOccupation.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  p.currentOccupation,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              if (expected != null && expected > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${context.tr('Expected')}: \u20B9${expected.round()} ${p.salaryType}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (p.yearsOfExperience.isNotEmpty)
                          _chip(
                            Icons.work_history_outlined,
                            p.yearsOfExperience,
                          ),
                        if (p.workMode.isNotEmpty)
                          _chip(Icons.business_center_outlined, p.workMode),
                        _chip(
                          Icons.calendar_today_outlined,
                          _app['appliedDate'] ?? '',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _card(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      context,
                      Icons.contact_page_outlined,
                      context.tr('Contact'),
                    ),
                    _row(context, Icons.email_outlined, p.email),
                    _row(context, Icons.phone_outlined, p.phoneNumber),
                    _row(
                      context,
                      Icons.location_on_outlined,
                      [
                        p.currentLocation,
                        p.district,
                        p.state,
                      ].where((s) => s.isNotEmpty).join(', '),
                    ),
                    if (p.gender.isNotEmpty)
                      _row(context, Icons.person_outline, p.gender),
                    if (p.dateOfBirth.isNotEmpty)
                      _row(context, Icons.cake_outlined, p.dateOfBirth),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _card(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      context,
                      Icons.school_outlined,
                      context.tr('Education'),
                    ),
                    _row(
                      context,
                      Icons.menu_book_outlined,
                      p.highestQualification,
                    ),
                    _row(context, Icons.badge_outlined, p.currentOccupation),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _card(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      context,
                      Icons.handyman_outlined,
                      context.tr('Skills'),
                    ),
                    const SizedBox(height: 10),
                    p.skills.isEmpty
                        ? Text(
                            context.tr('No skills listed.'),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: p.skills.map((s) => _tag(s)).toList(),
                          ),
                    const SizedBox(height: 14),
                    _sectionTitle(
                      context,
                      Icons.translate,
                      context.tr('Languages'),
                    ),
                    const SizedBox(height: 10),
                    p.languages.isEmpty
                        ? Text(
                            context.tr('No languages listed.'),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: p.languages.map((l) => _tag(l)).toList(),
                          ),
                    if (p.preferredLocations.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _sectionTitle(
                        context,
                        Icons.place_outlined,
                        context.tr('Preferred Locations'),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: p.preferredLocations
                            .map((l) => _tag(l))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (p.resumeName != null ||
                  p.videoName != null ||
                  p.resumePath != null ||
                  p.videoPath != null) ...[
                const SizedBox(height: 14),
                _card(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        context,
                        Icons.attach_file_outlined,
                        context.tr('Documents'),
                      ),
                      const SizedBox(height: 10),
                      _fileTile(
                        context,
                        Icons.description_outlined,
                        p.resumeName,
                        p.resumeSize,
                        p.resumePath,
                      ),
                      if (p.videoName != null || p.videoPath != null) ...[
                        const SizedBox(height: 8),
                        _fileTile(
                          context,
                          Icons.videocam_outlined,
                          p.videoName,
                          p.videoSize,
                          p.videoPath,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        context.tr(
                          'Resume and video are downloaded securely when you tap them.',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, IconData icon, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _fileTile(
    BuildContext context,
    IconData icon,
    String? name,
    String? size,
    String? path,
  ) {
    final hasPath = path != null && path.isNotEmpty;
    String? label = name;
    if ((label == null || label.isEmpty) && hasPath) label = path;
    final fileLabel = (label != null && label.isNotEmpty)
        ? label
        : context.tr('Attached file');
    final sizeLabel = size != null && size.isNotEmpty ? '  \u00B7  $size' : '';
    return InkWell(
      onTap: hasPath ? () => _openFile(path, name ?? 'file') : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$fileLabel$sizeLabel',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (hasPath)
              Icon(Icons.launch, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
