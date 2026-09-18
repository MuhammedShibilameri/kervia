import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../company/data/models/job_post_model.dart';
import '../data/demo_jobs.dart';

class JobDetailPage extends StatefulWidget {
  final JobPostModel job;
  final String userId;
  final String? candidateName;

  const JobDetailPage({
    super.key,
    required this.job,
    required this.userId,
    this.candidateName,
  });

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  bool _applying = false;
  bool? _alreadyApplied;

  String get _docId => '${widget.userId}_${widget.job.id}';

  @override
  void initState() {
    super.initState();
    _checkApplied();
  }

  Future<void> _checkApplied() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('applications')
          .doc(_docId)
          .get();
      if (!mounted) return;
      setState(() => _alreadyApplied = doc.exists);
    } catch (_) {
      if (!mounted) return;
      setState(() => _alreadyApplied = false);
    }
  }

  Future<void> _apply() async {
    setState(() => _applying = true);
    final job = widget.job;
    final now = DateTime.now();
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(_docId)
          .set({
        'userId': widget.userId,
        'jobId': job.id,
        'companyId': job.companyId,
        'candidateName': widget.candidateName,
        'jobTitle': job.jobTitle,
        'companyName': job.companyName,
        'occupation': job.occupation,
        'employmentType': job.employmentType,
        'workMode': job.workMode,
        'salary': job.salary,
        'experience': job.experience,
        'vacancies': job.vacancies,
        'deadline': job.deadline,
        'location': job.location,
        'locations': job.locations
            .map((l) => {
                  'name': l.name,
                  'subLocation': l.subLocation,
                  'isPrimary': l.isPrimary,
                })
            .toList(),
        'jobDescription': job.jobDescription,
        'minimumEducation': job.minimumEducation,
        'requiredSkills': job.requiredSkills,
        'languages': job.languages,
        'aboutCompany': job.aboutCompany,
        'jobStatus': job.jobStatus,
        'publishedDate': job.publishedDate.isEmpty
            ? jobPostedLabel(job.updatedAt)
            : job.publishedDate,
        'status': 'submitted',
        'applicationType': 'Direct Application',
        'appliedDate': _formatDate(now),
        'appliedTime': _formatTime(now),
        'lastUpdated': '${_formatDate(now)}, ${_formatTime(now)}',
        'updatedAt': now.toIso8601String(),
      });
      if (!mounted) return;
      setState(() {
        _applying = false;
        _alreadyApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Application submitted successfully!')),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _applying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not apply. $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')}-${months[d.month - 1]}-${d.year}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'am' : 'pm';
    return '$h:$m $ampm';
  }

  String _vacanciesLabel(String vacancies) {
    final hasWord = vacancies.contains(RegExp('[a-zA-Z]'));
    return hasWord ? vacancies : '$vacancies vacancies';
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final job = widget.job;
    final applied = _alreadyApplied ?? false;

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
          context.tr('Job Details'),
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.bookmark_outline, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                job.companyName,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.work_outline,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          job.jobTitle,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.occupation,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _detailChip(Icons.location_on_outlined, job.location),
                            _detailChip(Icons.work_outline, job.experience),
                            _detailChip(Icons.currency_rupee, job.salary),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: AppColors.border),
                        const SizedBox(height: 8),
                        _detailRow(context.tr('Posted'), jobPostedLabel(job.updatedAt)),
                        _detailRow(
                            context.tr('Vacancies'), _vacanciesLabel(job.vacancies)),
                        _detailRow(context.tr('Last date to apply'), job.deadline),
                        _detailRow(context.tr('Employment type'), job.employmentType),
                        _detailRow(context.tr('Work mode'), job.workMode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('About this job'),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          job.jobDescription.isNotEmpty
                              ? job.jobDescription
                              : context.tr(
                                  'This is a demo job listed to showcase the Kervia job feed. Full descriptions, screening questions and recruiter contact details will appear here once real jobs are added by employers.'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        if (job.minimumEducation.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _detailRow(context.tr('Education'),
                              job.minimumEducation),
                        ],
                        if (job.requiredSkills.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            context.tr('Skills required'),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: job.requiredSkills
                                .map((s) => _detailChip(Icons.check_circle_outline, s))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: applied
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon:
                                const Icon(Icons.check_circle_outline, size: 20),
                            label: Text(context.tr('Already Applied')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              disabledForegroundColor: AppColors.textMuted,
                              side: BorderSide(color: AppColors.border),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _applying ? null : _apply,
                            icon: _applying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_outlined, size: 18),
                            label: Text(_applying
                                ? context.tr('Applying…')
                                : context.tr('Apply Now')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size(0, 52),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
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
}