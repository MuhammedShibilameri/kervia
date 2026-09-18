import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../company/data/models/company_profile_model.dart';
import '../../../job_seeker/data/models/job_seeker_profile_model.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String otherUserId;
  final String? otherName;

  const OtherUserProfilePage({
    super.key,
    required this.otherUserId,
    this.otherName,
  });

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

enum _ProfileKind { company, jobSeeker }

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  bool _loading = true;
  String? _error;
  _ProfileKind? _kind;
  CompanyProfileModel? _company;
  JobSeekerProfileModel? _seeker;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = FirebaseFirestore.instance;
      final otherId = widget.otherUserId;

      final companyDoc = await db.collection('companies').doc(otherId).get();
      if (companyDoc.exists && companyDoc.data() != null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _kind = _ProfileKind.company;
          _company = CompanyProfileModel.fromMap(companyDoc.data()!, otherId);
        });
        return;
      }

      final seekerDoc = await db.collection('job_seekers').doc(otherId).get();
      if (seekerDoc.exists && seekerDoc.data() != null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _kind = _ProfileKind.jobSeeker;
          _seeker = JobSeekerProfileModel.fromMap(seekerDoc.data()!, otherId);
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.tr('Profile not found.');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.tr('Could not load profile.');
      });
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
          widget.otherName?.isNotEmpty == true
              ? widget.otherName!
              : context.tr('Profile'),
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
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: GoogleFonts.inter(color: AppColors.textMuted),
                    ),
                  )
                : _kind == _ProfileKind.company
                    ? _buildCompany(_company)
                    : _buildSeeker(_seeker),
      ),
    );
  }

  Widget _buildCompany(CompanyProfileModel? profile) {
    final p = profile!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              p.companyName.isNotEmpty ? p.companyName : context.tr('Company'),
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (p.industry.isNotEmpty) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(
                p.industry,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildSection(
            context.tr('Company Details'),
            [
              _buildRow(context.tr('Email'), p.contactEmail),
              _buildRow(context.tr('Phone'), p.contactPhone),
              _buildRow(context.tr('Location'), p.location),
              _buildRow(context.tr('District'), p.district),
              _buildRow(context.tr('State'), p.state),
              _buildRow(context.tr('Website'), p.website),
              _buildRow(context.tr('Employee Size'), p.employeeSize),
              _buildRow(context.tr('Founded Year'), p.foundedYear),
            ],
          ),
          if (p.about.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              context.tr('About'),
              [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    p.about,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSeeker(JobSeekerProfileModel? profile) {
    final p = profile!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              p.fullName.isNotEmpty ? p.fullName : context.tr('Job Seeker'),
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (p.currentOccupation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(
                p.currentOccupation,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildSection(
            context.tr('Personal Details'),
            [
              _buildRow(context.tr('Email'), p.email),
              _buildRow(context.tr('Phone'), p.phoneNumber),
              _buildRow(context.tr('Location'), p.currentLocation),
              _buildRow(context.tr('District'), p.district),
              _buildRow(context.tr('Highest Qualification'), p.highestQualification),
              _buildRow(context.tr('Years of Experience'), p.yearsOfExperience),
              _buildRow(context.tr('Work Mode'), p.workMode),
              _buildRow(context.tr('Expected Salary'), p.expectedSalary),
            ],
          ),
          if (p.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              context.tr('Skills'),
              [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.skills
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}