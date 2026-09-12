import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../company/data/models/job_post_model.dart';
import 'job_detail_page.dart';

class SavedJobsPage extends StatefulWidget {
  final String userId;
  final String? candidateName;

  const SavedJobsPage({super.key, required this.userId, this.candidateName});

  @override
  State<SavedJobsPage> createState() => _SavedJobsPageState();
}

class _SavedJobsPageState extends State<SavedJobsPage> {
  List<JobPostModel> _jobs = [];
  bool _loading = true;

  static FirebaseFirestore? _db() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snapshot = await _db()
          ?.collection('saved_jobs')
          .where('userId', isEqualTo: widget.userId)
          .get();
      final jobs = (snapshot?.docs ?? const [])
          .map((doc) {
            final data = doc.data();
            return JobPostModel.fromMap(data, data['jobId'] as String? ?? '');
          })
          .toList();
      jobs.sort((a, b) {
        final ta = DateTime.tryParse(a.updatedAt);
        final tb = DateTime.tryParse(b.updatedAt);
        return (tb ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(ta ?? DateTime.fromMillisecondsSinceEpoch(0));
      });
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unsave(JobPostModel job) async {
    final db = _db();
    if (db == null) return;
    try {
      await db
          .collection('saved_jobs')
          .doc('${widget.userId}_${job.id}')
          .delete();
      if (!mounted) return;
      setState(() => _jobs = _jobs.where((j) => j.id != job.id).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Job removed from saved.')),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (_) {
      // ignore
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
          context.tr('Saved Jobs'),
          style: GoogleFonts.inter(
            fontSize: 17,
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
            : _jobs.isEmpty
                ? _buildEmpty(context)
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _jobs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final job = _jobs[index];
                        return _SavedJobCard(
                          job: job,
                          onOpen: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailPage(
                                  job: job,
                                  userId: widget.userId,
                                  candidateName: widget.candidateName,
                                ),
                              ),
                            );
                          },
                          onUnsave: () => _unsave(job),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              context.tr('No saved jobs yet.'),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('Tap the bookmark on a job to save it here.'),
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
}

class _SavedJobCard extends StatelessWidget {
  final JobPostModel job;
  final VoidCallback onOpen;
  final VoidCallback onUnsave;

  const _SavedJobCard({
    required this.job,
    required this.onOpen,
    required this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.companyName.isNotEmpty
                      ? job.companyName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      job.companyName,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            job.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr('Remove'),
                onPressed: onUnsave,
                icon: Icon(
                  Icons.bookmark,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}