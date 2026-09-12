import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../company/data/models/job_post_model.dart';
import '../../data/models/job_seeker_profile_model.dart';
import '../data/demo_jobs.dart';
import '../data/step2_options_data.dart';
import 'job_detail_page.dart';
import 'job_seeker_profile_page.dart';
import 'saved_jobs_page.dart';
import '../../../applications/presentation/pages/my_applications_page.dart';
import '../../../messaging/presentation/pages/messages_page.dart';

const List<String> _kFilterSkills = [
  'All Skills',
  'Communication',
  'Teamwork',
  'Time Management',
  'Problem Solving',
  'Leadership',
  'Flutter',
  'Dart',
  'Firebase',
  'REST APIs',
  'JavaScript',
  'Python',
  'Excel',
  'MS Office',
  'Tally',
  'Digital Marketing',
  'SEO',
  'Content Writing',
  'Graphic Design',
  'Sales',
  'Customer Relations',
  'Driving',
  'Typing',
  'Teaching',
];

const List<String> _kSalaryBuckets = [
  'All Salaries',
  'Upto ₹10,000',
  '₹10,000 - ₹20,000',
  '₹20,000 - ₹40,000',
  '₹40,000 - ₹1,00,000',
  'Above ₹1,00,000',
];

(int, int?) kSalaryBucketRange(int index) {
  switch (index) {
    case 1:
      return (0, 10000);
    case 2:
      return (10000, 20000);
    case 3:
      return (20000, 40000);
    case 4:
      return (40000, 100000);
    case 5:
      return (100000, null);
    default:
      return (0, null);
  }
}

class CandidateHomeShell extends StatefulWidget {
  final UserEntity user;
  final int initialIndex;

  const CandidateHomeShell({
    super.key,
    required this.user,
    this.initialIndex = 0,
  });

  @override
  State<CandidateHomeShell> createState() => _CandidateHomeShellState();
}

class _CandidateHomeShellState extends State<CandidateHomeShell> {
  late int _index = widget.initialIndex;
  JobSeekerProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('job_seekers')
          .doc(widget.user.id)
          .get();
      if (!mounted) return;
      setState(() {
        _profile = doc.exists && doc.data() != null
            ? JobSeekerProfileModel.fromMap(doc.data()!, widget.user.id)
            : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _reloadProfile() {
    if (!mounted) return;
    _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    if (_loading && _profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    final profile = _profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: [
          _HomeTab(
            user: widget.user,
            profile: profile,
            onOpenTab: (i) => setState(() => _index = i),
          ),
          const MyApplicationsPage(showBottomNav: false),
          _PlaceholderTab(
            title: context.tr('Interviews'),
            icon: Icons.event_outlined,
            message: context.tr('Your upcoming interviews will appear here.'),
          ),
          MessagesPage(
            userId: widget.user.id,
            displayName: profile?.fullName.isNotEmpty == true
                ? profile!.fullName
                : (widget.user.displayName ?? 'Member'),
          ),
          JobSeekerProfilePage(
            user: widget.user,
            profile: profile,
            onProfileChanged: _reloadProfile,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            label: context.tr('Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.description_outlined),
            selectedIcon: const Icon(
              Icons.description,
              color: AppColors.primary,
            ),
            label: context.tr('Applications'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event, color: AppColors.primary),
            label: context.tr('Interviews'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(
              Icons.chat_bubble,
              color: AppColors.primary,
            ),
            label: context.tr('Message'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppColors.primary),
            label: context.tr('Profile'),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const _PlaceholderTab({
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr(title),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(message),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final UserEntity user;
  final JobSeekerProfileModel? profile;
  final ValueChanged<int> onOpenTab;

  const _HomeTab({
    required this.user,
    required this.profile,
    required this.onOpenTab,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  String _selectedDistrict = 'All Districts';
  String _selectedCategory = 'All Categories';
  String _selectedWorkMode = 'All Work Modes';
  String _selectedEmploymentType = 'All Employment Types';
  String _selectedSkill = 'All Skills';
  String _selectedSalary = 'All Salaries';

  List<JobPostModel> _jobs = [];
  bool _loadingJobs = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('jobStatus', isEqualTo: 'Published')
          .get();
      if (!mounted) return;
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => JobPostModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => _timestamp(b).compareTo(_timestamp(a)));
        setState(() {
          _jobs = list;
          _loadingJobs = false;
        });
        return;
      }
    } catch (_) {
      // Firestore unreachable -> fall back to demo jobs below.
    }
    if (!mounted) return;
    setState(() {
      _jobs = kDemoJobs.map(_demoToJobPost).toList();
      _loadingJobs = false;
    });
  }

  DateTime _timestamp(JobPostModel job) =>
      DateTime.tryParse(job.updatedAt) ?? DateTime.fromMillisecondsSinceEpoch(0);

  JobPostModel _demoToJobPost(DemoJob job) {
    return JobPostModel(
      id: job.id,
      companyId: 'demo',
      companyName: job.company,
      jobTitle: job.title,
      occupation: job.category,
      employmentType: 'Full-time',
      workMode: 'On-site',
      salaryType: job.salary,
      salaryAmount: '',
      experience: job.experienceLevel,
      vacancies: job.vacancies,
      deadline: job.lastDate,
      location: job.location,
      jobDescription: job.description,
      jobStatus: 'Published',
    );
  }

  JobSeekerProfileModel get _profile =>
      widget.profile ?? JobSeekerProfileModel(userId: widget.user.id);

  String get _firstName => _profile.fullName.trim().split(' ').first.isEmpty
      ? widget.user.displayName ?? 'there'
      : _profile.fullName.trim().split(' ').first;

  String get _initials {
    final name = _profile.fullName.isNotEmpty
        ? _profile.fullName
        : (widget.user.displayName ?? 'U');
    final parts = name.trim().split(' ');
    final first = parts[0].isNotEmpty ? parts[0][0] : '?';
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }

  int get _strength {
    final check = <bool>[
      _profile.fullName.isNotEmpty,
      _profile.email.isNotEmpty && _profile.email.contains('@'),
      _profile.phoneNumber.isNotEmpty,
      _profile.dateOfBirth.isNotEmpty,
      _profile.gender.isNotEmpty,
      _profile.district.isNotEmpty && _profile.taluk.isNotEmpty,
      _profile.highestQualification.isNotEmpty,
      _profile.currentOccupation.isNotEmpty,
      _profile.skills.isNotEmpty,
      _profile.preferredLocations.isNotEmpty,
    ];
    final present = check.where((e) => e).length;
    if (check.isEmpty) return 0;
    return ((present / check.length) * 100).round();
  }

  List<JobPostModel> get _filteredJobs {
    final skillFilter = _selectedSkill == 'All Skills'
        ? null
        : _selectedSkill.toLowerCase();
    return _jobs
        .where((j) => _selectedDistrict == 'All Districts' ||
            j.location.contains(_selectedDistrict))
        .where((j) => _selectedCategory == 'All Categories' ||
            j.occupation == _selectedCategory)
        .where((j) => _selectedWorkMode == 'All Work Modes' ||
            j.workMode == _selectedWorkMode)
        .where((j) => _selectedEmploymentType == 'All Employment Types' ||
            j.employmentType == _selectedEmploymentType)
        .where((j) =>
            skillFilter == null ||
            j.requiredSkills.any((s) => s.toLowerCase().contains(skillFilter)))
        .where((j) => _salaryMatches(j))
        .where((j) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return j.jobTitle.toLowerCase().contains(q) ||
          j.companyName.toLowerCase().contains(q) ||
          j.occupation.toLowerCase().contains(q) ||
          j.location.toLowerCase().contains(q);
    }).toList();
  }

  bool _salaryMatches(JobPostModel j) {
    if (_selectedSalary == 'All Salaries') return true;
    final matcher = RegExp(r'\d[\d,]*');
    final m = matcher.firstMatch(j.salaryAmount);
    if (m == null) return true;
    final amount =
        int.tryParse(m.group(0)!.replaceAll(',', '')) ?? 0;
    if (amount <= 0) return true;
    final index = _kSalaryBuckets.indexOf(_selectedSalary);
    if (index <= 0) return true;
    final (min, max) = kSalaryBucketRange(index);
    if (amount < min) return false;
    return max == null || amount <= max;
  }

  List<String> get _districtOptions =>
      ['All Districts', ...?districtsByState['Kerala']];

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildTopCurvedHeader(),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildFiltersAndSearch(),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildQuickActions(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildJobsHeading(),
            ),
            const SizedBox(height: 12),
            if (_loadingJobs)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_filteredJobs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.work_off_outlined, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('No jobs match your filters.'),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._filteredJobs.map((j) => _JobCard(
                    job: j,
                    userId: widget.user.id,
                    candidateName: _profile.fullName.isNotEmpty
                        ? _profile.fullName
                        : widget.user.displayName,
                  )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCurvedHeader() {
    final strength = _strength;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: App Logo & Right Action Icons
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'K',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Notification Bell Icon in light mint circle with green dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // User Avatar with green online dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        _initials.isNotEmpty ? _initials[0] : 'S',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Welcome back & Name
          Text(
            context.tr('Welcome back'),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _firstName.isNotEmpty ? _firstName : 'Shibil',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          // Embedded Profile Strength Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('Profile Strength'),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$strength%',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: strength / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.primaryTint,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr(
                      'Keep your profile updated for better job matches.'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.tune,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('Filters'),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => widget.onOpenTab(4),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.tr('My preferences'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              _filterChip(
                label: context.tr('District'),
                selected: _selectedDistrict != 'All Districts',
                value: _selectedDistrict,
                options: _districtOptions,
                onChanged: (v) =>
                    setState(() => _selectedDistrict = v),
              ),
              _filterChip(
                label: context.tr('Job category'),
                selected: _selectedCategory != 'All Categories',
                value: _selectedCategory,
                options: ['All Categories', ...occupationOptions],
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              _filterChip(
                label: context.tr('Work mode'),
                selected: _selectedWorkMode != 'All Work Modes',
                value: _selectedWorkMode,
                options: [
                  'All Work Modes',
                  'On-site',
                  'Hybrid',
                  'Remote',
                ],
                onChanged: (v) => setState(() => _selectedWorkMode = v),
              ),
              _filterChip(
                label: context.tr('Employment type'),
                selected: _selectedEmploymentType != 'All Employment Types',
                value: _selectedEmploymentType,
                options: [
                  'All Employment Types',
                  'Full-time',
                  'Part-time',
                  'Freelance',
                  'Contract',
                ],
                onChanged: (v) => setState(() => _selectedEmploymentType = v),
              ),
              _filterChip(
                label: context.tr('Skill'),
                selected: _selectedSkill != 'All Skills',
                value: _selectedSkill,
                options: _kFilterSkills,
                onChanged: (v) => setState(() => _selectedSkill = v),
              ),
              _filterChip(
                label: context.tr('Salary'),
                selected: _selectedSalary != 'All Salaries',
                value: _selectedSalary,
                options: _kSalaryBuckets,
                onChanged: (v) => setState(() => _selectedSalary = v),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Full width Search Input
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              hintText: context.tr('Job title or company'),
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF94A3B8),
                size: 22,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Full width Search Button
        ElevatedButton.icon(
          onPressed: () =>
              setState(() => _query = _searchController.text.trim()),
          icon: const Icon(Icons.search, size: 20, color: Colors.white),
          label: Text(
            context.tr('Search'),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final isAll = value.startsWith('All ');
    final display = isAll ? label : context.tr(value);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _showFilterPicker(context, label, options, value, onChanged),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterPicker(
    BuildContext context,
    String title,
    List<String> options,
    String current,
    ValueChanged<String> onChanged,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterPickerSheet(
        title: title,
        options: options,
        current: current,
      ),
    );
    if (selected != null) onChanged(selected);
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('Quick Actions'),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.description_outlined,
                label: context.tr('My Applications'),
                onTap: () => widget.onOpenTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                icon: Icons.bookmark_border,
                label: context.tr('Saved Jobs'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavedJobsPage(
                      userId: widget.user.id,
                      candidateName: widget.profile?.fullName,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.person_outline,
                label: context.tr('Resume /\nProfile'),
                onTap: () => widget.onOpenTab(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                icon: Icons.calendar_today_outlined,
                label: context.tr('My Interviews'),
                onTap: () => widget.onOpenTab(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr('Jobs for you'),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            Text(
              '${_filteredJobs.length} ${context.tr('jobs')}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.tr(
              'Based on your saved profile preferences and current filters.'),
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _JobCard extends StatefulWidget {
  final JobPostModel job;
  final String userId;
  final String? candidateName;

  const _JobCard({
    required this.job,
    required this.userId,
    this.candidateName,
  });

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  late bool _applied = false;
  late bool _saved = false;

  String get _docId => '${widget.userId}_${widget.job.id}';

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
    _checkApplied();
    _checkSaved();
  }

  Future<void> _checkApplied() async {
    try {
      final doc = await _db()
          ?.collection('applications')
          .doc(_docId)
          .get();
      if (!mounted) return;
      setState(() => _applied = doc?.exists ?? false);
    } catch (_) {
      // keep false when Firestore is unavailable
    }
  }

  Future<void> _checkSaved() async {
    try {
      final doc = await _db()?.collection('saved_jobs').doc(_docId).get();
      if (!mounted) return;
      setState(() => _saved = doc?.exists ?? false);
    } catch (_) {
      // ignore; bookmark stays in local state
    }
  }

  Future<void> _toggleSaved() async {
    final db = _db();
    if (db == null) {
      setState(() => _saved = !_saved);
      return;
    }
    final job = widget.job;
    final ref = db.collection('saved_jobs').doc(_docId);
    try {
      if (_saved) {
        await ref.delete();
      } else {
        await ref.set({
          'userId': widget.userId,
          'jobId': job.id,
          'companyId': job.companyId,
          'companyName': job.companyName,
          'jobTitle': job.jobTitle,
          'occupation': job.occupation,
          'location': job.location,
          'employmentType': job.employmentType,
          'workMode': job.workMode,
          'salaryType': job.salaryType,
          'salaryAmount': job.salaryAmount,
          'experience': job.experience,
          'vacancies': job.vacancies,
          'deadline': job.deadline,
          'jobDescription': job.jobDescription,
          'minimumEducation': job.minimumEducation,
          'requiredSkills': job.requiredSkills,
          'languages': job.languages,
          'aboutCompany': job.aboutCompany,
          'jobStatus': job.jobStatus,
          'publishedDate': job.publishedDate,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      if (!mounted) return;
      setState(() => _saved = !_saved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _saved
                ? context.tr('Job saved.')
                : context.tr('Job removed from saved.'),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Could not save the job.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showReportSheet() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.tr('Report this job'),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            for (final reason in const [
              'Fake job or scam',
              'Incorrect information',
              'Offensive or inappropriate',
              'Spam',
              'Other',
            ])
              ListTile(
                leading: Icon(
                  Icons.outlined_flag,
                  size: 18,
                  color: AppColors.primary,
                ),
                title: Text(
                  context.tr(reason),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, reason),
              ),
          ],
        ),
      ),
    );
    if (reason == null || !mounted) return;

    final db = _db();
    if (db == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not submit report.')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final job = widget.job;
    final ref = db.collection('reports').doc(_docId);
    DocumentSnapshot? existing;
    try {
      existing = await ref.get();
    } catch (_) {
      // treat as not reported
    }
    if (existing?.exists == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('You already reported this job.')),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    try {
      await ref.set({
        'userId': widget.userId,
        'jobId': job.id,
        'companyId': job.companyId,
        'jobTitle': job.jobTitle,
        'companyName': job.companyName,
        'reason': reason,
        'reportedAt': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Thank you. The report has been submitted.')),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Could not submit report.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openDetails() async {
    final applied = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailPage(
          job: widget.job,
          userId: widget.userId,
          candidateName: widget.candidateName,
        ),
      ),
    );
    if (applied == true && mounted) {
      setState(() => _applied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Avatar / Initials
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    job.companyName.isNotEmpty
                        ? job.companyName[0].toUpperCase()
                        : 'K',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Company & Title & Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.companyName,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.jobTitle,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.work_outline,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.occupation,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Flag and Bookmark Buttons
              InkWell(
                onTap: _showReportSheet,
                borderRadius: BorderRadius.circular(19),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.outlined_flag,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _toggleSaved,
                borderRadius: BorderRadius.circular(19),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(
                    _saved ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: _saved
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2-Column Info Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSpecRow(Icons.location_on_outlined, job.location),
                    const SizedBox(height: 8),
                    _buildSpecRow(Icons.payments_outlined, job.salary),
                    const SizedBox(height: 8),
                    _buildSpecRow(Icons.access_time, jobPostedLabel(job.updatedAt)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSpecRow(Icons.work_outline, job.experience),
                    const SizedBox(height: 8),
                    _buildSpecRow(Icons.people_outline, _vacanciesLabel(job.vacancies)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Deadline Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    text: 'Last Date to Apply: ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: job.deadline,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Button: Solid Blue "Applied" or Solid Dark Teal "Apply Now"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _applied
                ? InkWell(
                    onTap: _openDetails,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D61E7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Applied',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _openDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Now',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  String _vacanciesLabel(String vacancies) {
    final hasWord = vacancies.contains(RegExp('[a-zA-Z]'));
    return hasWord ? vacancies : '$vacancies vacancies';
  }
}

class _FilterPickerSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String current;

  const _FilterPickerSheet({
    required this.title,
    required this.options,
    required this.current,
  });

  @override
  State<_FilterPickerSheet> createState() => _FilterPickerSheetState();
}

class _FilterPickerSheetState extends State<_FilterPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<String> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options
        .where((o) => o.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final q = _query.trim();
    final showCustom = q.isNotEmpty &&
        !widget.options.any((o) => o.toLowerCase() == q.toLowerCase());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr(widget.title),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: context.tr('Search…'),
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (showCustom)
                      ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        title: Text(
                          '${context.tr('Use')} "$q"',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        onTap: () =>
                            Navigator.pop(context, q),
                      ),
                    ..._filtered.map((option) => ListTile(
                          dense: true,
                          selected: option == widget.current,
                          selectedTileColor: AppColors.primarySoft,
                          title: Text(
                            option,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight:
                                  option == widget.current
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                          ),
                          trailing:
                              option == widget.current
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                      size: 18,
                                    )
                                  : null,
                          onTap: () => Navigator.pop(context, option),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}