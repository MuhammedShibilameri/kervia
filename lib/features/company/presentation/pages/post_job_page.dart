import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/company_profile_entity.dart';
import '../../domain/entities/job_post_entity.dart';
import '../bloc/company_job_bloc.dart';
import '../widgets/india_location_field.dart';

const Map<String, List<String>> _kOccupationSkills = {
  'software': [
    'Flutter',
    'Dart',
    'Firebase',
    'REST APIs',
    'SQL',
    'Git',
  ],
  'developer': [
    'Flutter',
    'Dart',
    'Firebase',
    'REST APIs',
    'SQL',
    'Git',
  ],
  'web': ['HTML', 'CSS', 'JavaScript', 'React', 'Node.js'],
  'teacher': [
    'Lesson Planning',
    'Classroom Management',
    'Online Teaching',
    'Subject Expertise',
  ],
  'accountant': ['Tally', 'GST', 'Excel', 'Bookkeeping', 'Tax Filing'],
  'sales': ['Sales', 'Customer Relations', 'Negotiation', 'CRM'],
  'marketing': ['Digital Marketing', 'SEO', 'Social Media', 'Content Writing'],
  'nurse': ['Patient Care', 'First Aid', 'Nursing Documentation'],
  'driver': ['Safe Driving', 'Route Knowledge', 'Vehicle Maintenance'],
  'electrician': ['Wiring', 'Maintenance', 'Safety Standards'],
  'plumber': ['Repair', 'Installation', 'Safety Standards'],
  'carpenter': ['Woodworking', 'Furniture Making', 'Measurement'],
  'mechanic': ['Engine Repair', 'Diagnostics', 'Tools'],
  'designer': ['Graphic Design', 'UI/UX', 'Figma', 'Adobe Suite'],
  'data': ['Data Analysis', 'Excel', 'SQL', 'Python', 'Power BI'],
  'admin': ['MS Office', 'Scheduling', 'Data Entry', 'Communication'],
  'customer': ['Communication', 'Problem Solving', 'CRM'],
  'manager': ['Leadership', 'Planning', 'Communication', 'Budgeting'],
  'photographer': ['Photography', 'Editing', 'Lighting'],
  'cook': ['Cooking', 'Kitchen Hygiene', 'Recipe Knowledge'],
  'security': ['Surveillance', 'Patrolling', 'Reporting'],
  'watchman': ['Patrolling', 'Communication', 'Alertness'],
};

const List<String> _kCommonSkills = [
  'Communication',
  'Teamwork',
  'Time Management',
  'Problem Solving',
  'Leadership',
];

class PostJobPage extends StatefulWidget {
  final UserEntity user;
  final CompanyProfileEntity? companyProfile;
  final JobPostEntity? existing;

  const PostJobPage({
    super.key,
    required this.user,
    this.companyProfile,
    this.existing,
  });

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _occupationController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryMinController;
  late final TextEditingController _salaryMaxController;
  late final TextEditingController _experienceController;
  late final TextEditingController _vacanciesController;
  late final TextEditingController _deadlineController;
  late final TextEditingController _educationController;
  late final TextEditingController _skillsController;
  late final TextEditingController _newSkillController;
  List<String> _skills = const [];
  late final TextEditingController _descriptionController;
  late final TextEditingController _aboutCompanyController;

  String _employmentType = 'Full-time';
  String _workMode = 'Hybrid';
  String _salaryType = 'Monthly';
  List<String> _languages = const ['English', 'Malayalam'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.jobTitle ?? '');
    _occupationController = TextEditingController(text: e?.occupation ?? '');
    _locationController = TextEditingController(text: e?.location ?? '');
    _salaryMinController = TextEditingController();
    _salaryMaxController = TextEditingController();
    if (e != null) {
      final parts = e.salaryAmount.replaceAll('₹', '').split('-');
      _salaryMinController.text = parts.isNotEmpty ? parts[0].trim() : '';
      _salaryMaxController.text =
          parts.length > 1 ? parts[1].trim() : '';
    }
    _experienceController = TextEditingController(text: e?.experience ?? '');
    _vacanciesController = TextEditingController(text: e?.vacancies ?? '1');
    _deadlineController = TextEditingController(text: e?.deadline ?? 'No deadline');
    _educationController = TextEditingController(text: e?.minimumEducation ?? '');
    _skillsController = TextEditingController();
    _newSkillController = TextEditingController();
    _skills = e?.requiredSkills ?? const [];
    _descriptionController = TextEditingController(text: e?.jobDescription ?? '');
    _aboutCompanyController = TextEditingController(
      text: (e != null && e.aboutCompany.isNotEmpty)
          ? e.aboutCompany
          : (widget.companyProfile?.about ?? ''),
    );
    if (e != null) {
      _employmentType = e.employmentType;
      _workMode = e.workMode;
      _salaryType = e.salaryType;
      _languages = e.languages;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _occupationController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _experienceController.dispose();
    _vacanciesController.dispose();
    _deadlineController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _newSkillController.dispose();
    _descriptionController.dispose();
    _aboutCompanyController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final skills = List<String>.from(_skills);
    final customSkill = _newSkillController.text.trim();
    if (customSkill.isNotEmpty) skills.add(customSkill);

    final minText = _salaryMinController.text.trim();
    final maxText = _salaryMaxController.text.trim();
    final salaryAmount = (minText.isNotEmpty && maxText.isNotEmpty)
        ? '₹$minText - ₹$maxText'
        : (minText.isNotEmpty ? '₹$minText+' : maxText);

    final job = JobPostEntity(
      id: widget.existing?.id,
      companyId: widget.user.id,
      jobTitle: _titleController.text.trim(),
      occupation: _occupationController.text.trim(),
      location: _locationController.text.trim(),
      salaryType: _salaryType,
      salaryAmount: salaryAmount,
      experience: _experienceController.text.trim(),
      vacancies: _vacanciesController.text.trim(),
      deadline: _deadlineController.text.trim(),
      jobDescription: _descriptionController.text.trim(),
      minimumEducation: _educationController.text.trim(),
      requiredSkills: skills,
      languages: _languages,
      employmentType: _employmentType,
      workMode: _workMode,
      aboutCompany: _aboutCompanyController.text.trim(),
      jobStatus: widget.existing?.jobStatus ?? 'Published',
      publishedDate: widget.existing?.publishedDate ?? '',
    );

    context
        .read<CompanyJobBloc>()
        .add(SaveJobPostEvent(job,
            companyProfile: widget.companyProfile ??
                CompanyProfileEntity(userId: widget.user.id)));

    if (!mounted) return;
    Navigator.pop(context, job);
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, isDesktop),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existing == null
                                ? context.tr('Post a Job')
                                : context.tr('Edit Job'),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildField(
                            controller: _titleController,
                            label: context.tr('Job Title'),
                            icon: Icons.title,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? context.tr('Job title is required')
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _occupationController,
                            label: context.tr('Occupation / Category'),
                            icon: Icons.category_outlined,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? context.tr('Occupation is required')
                                : null,
                          ),
                          const SizedBox(height: 16),
                  IndiaLocationField(
                    controller: _locationController,
                    label: context.tr('Location'),
                    icon: Icons.location_on_outlined,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? context.tr('Location is required')
                        : null,
                  ),
                          const SizedBox(height: 20),
                          _buildChipSelector(
                            context.tr('Employment Type'),
                            ['Full-time', 'Part-time', 'Freelance', 'Contract'],
                            _employmentType,
                            (value) => setState(() => _employmentType = value),
                          ),
                          const SizedBox(height: 20),
                          _buildChipSelector(
                            context.tr('Work Mode'),
                            ['On-site', 'Hybrid', 'Remote'],
                            _workMode,
                            (value) => setState(() => _workMode = value),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _salaryMinController,
                                  label: context.tr('Salary From'),
                                  icon: Icons.currency_rupee_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? context.tr(
                                              'Minimum salary is required')
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _salaryMaxController,
                                  label: context.tr('Salary To'),
                                  icon: Icons.currency_rupee_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSalaryTypeDropdown(),
                          const SizedBox(height: 8),
                          Text(
                            _salaryType == 'Annual'
                                ? context.tr(
                                    'Example: from 2 to 3 LPA (or 200000 to 300000)')
                                : context.tr(
                                    'Example: from 10000 to 20000 monthly'),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _experienceController,
                                  label: context.tr('Experience Required'),
                                  icon: Icons.work_history_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _vacanciesController,
                                  label: context.tr('Vacancies'),
                                  icon: Icons.groups_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _deadlineController,
                            label: context.tr('Application Deadline'),
                            icon: Icons.event_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _educationController,
                            label: context.tr('Minimum Education'),
                            icon: Icons.school_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildSkillsSelector(),
                          const SizedBox(height: 20),
                          _buildLanguageSelector(),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: _descriptionController,
                            label: context.tr('Job Description'),
                            icon: Icons.description_outlined,
                            maxLines: 5,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? context.tr('Description is required')
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _aboutCompanyController,
                            label: context.tr('About Company'),
                            icon: Icons.business_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onSave,
                              child: Text(
                                widget.existing == null
                                    ? context.tr('Publish Job')
                                    : context.tr('Save Changes'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
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

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.existing == null
                  ? context.tr('Post a Job')
                  : context.tr('Edit Job'),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildChipSelector(
    String label,
    List<String> options,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              label: Text(
                context.tr(option),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addSkill(String skill) {
    final s = skill.trim();
    if (s.isEmpty || _skills.contains(s)) return;
    setState(() => _skills = [..._skills, s]);
  }

  void _removeSkill(String skill) {
    setState(() => _skills = _skills.where((s) => s != skill).toList());
  }

  List<String> get _skillSuggestions {
    final occ = _occupationController.text.trim().toLowerCase();
    final matched = <String>[];
    for (final entry in _kOccupationSkills.entries) {
      if (occ.contains(entry.key)) {
        for (final s in entry.value) {
          if (!matched.contains(s)) matched.add(s);
        }
      }
    }
    for (final s in _kCommonSkills) {
      if (!matched.contains(s)) matched.add(s);
    }
    return matched;
  }

  Widget _buildSkillsSelector() {
    final suggestions = _skillSuggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('Required Skills'),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newSkillController,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (v) {
                  _addSkill(v);
                  _newSkillController.clear();
                },
                decoration: InputDecoration(
                  hintText: context.tr('Type a skill and add it'),
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  isDense: true,
                  prefixIcon: Icon(Icons.add, color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                _addSkill(_newSkillController.text);
                _newSkillController.clear();
              },
              child: Text(context.tr('Add')),
            ),
          ],
        ),
        if (_skills.isEmpty) ...[
          const SizedBox(height: 10),
          Text(
            context.tr('No skills added yet.'),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _skills
                .map(
                  (s) => InputChip(
                    label: Text(s),
                    onDeleted: () => _removeSkill(s),
                    backgroundColor: AppColors.primarySoft,
                    side: BorderSide.none,
                    deleteIconColor: AppColors.textMuted,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          context.tr('Suggested skills'),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: suggestions
              .where((s) => !_skills.contains(s))
              .map(
                (s) => ActionChip(
                  avatar: const Icon(Icons.add, size: 14, color: AppColors.primary),
                  label: Text(s),
                  onPressed: () => _addSkill(s),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: AppColors.border),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    const popular = ['English', 'Malayalam', 'Hindi', 'Tamil', 'Kannada'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('Languages'),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...popular.map((lang) {
              final isSelected = _languages.contains(lang);
              return FilterChip(
                label: Text(
                  lang,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _languages = [..._languages, lang];
                    } else {
                      _languages =
                          _languages.where((l) => l != lang).toList();
                    }
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
            FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 15, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('Add more'),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              selected: false,
              onSelected: (_) => _openLanguageSheet(),
              backgroundColor: AppColors.primarySoft.withValues(alpha: 0.4),
              side: BorderSide(color: AppColors.primarySoft),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            for (final lang in _languages)
              if (!popular.contains(lang))
                InputChip(
                  label: Text(lang),
                  onDeleted: () => _removeLanguage(lang),
                  backgroundColor: AppColors.primarySoft,
                  side: BorderSide.none,
                  deleteIconColor: AppColors.textMuted,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
          ],
        ),
      ],
    );
  }

  void _removeLanguage(String lang) {
    setState(() => _languages = _languages.where((l) => l != lang).toList());
  }

  Future<void> _openLanguageSheet() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LanguageSearchSheet(selected: _languages),
    );
    if (result != null && mounted) {
      setState(() => _languages = result);
    }
  }

  Widget _buildSalaryTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _salaryType,
      decoration: InputDecoration(
        labelText: context.tr('Salary Type'),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        prefixIcon: Icon(Icons.trending_up, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      style: GoogleFonts.inter(color: AppColors.textPrimary),
      items: ['Hourly', 'Monthly', 'Annual']
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(context.tr(type)),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _salaryType = value);
      },
    );
  }
}

const List<String> _kAllLanguages = [
  'Arabic',
  'Assamese',
  'Bengali',
  'Bhojpuri',
  'Chinese',
  'Dogri',
  'English',
  'French',
  'German',
  'Gujarati',
  'Hindi',
  'Italian',
  'Japanese',
  'Kannada',
  'Kashmiri',
  'Konkani',
  'Korean',
  'Maithili',
  'Malayalam',
  'Manipuri',
  'Marathi',
  'Nepali',
  'Odia',
  'Persian',
  'Portuguese',
  'Punjabi',
  'Russian',
  'Sanskrit',
  'Santali',
  'Sindhi',
  'Spanish',
  'Tamil',
  'Telugu',
  'Urdu',
];

class _LanguageSearchSheet extends StatefulWidget {
  final List<String> selected;

  const _LanguageSearchSheet({required this.selected});

  @override
  State<_LanguageSearchSheet> createState() => _LanguageSearchSheetState();
}

class _LanguageSearchSheetState extends State<_LanguageSearchSheet> {
  late final List<String> _selected;
  String _query = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selected);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _kAllLanguages;
    return _kAllLanguages.where((l) => l.toLowerCase().contains(q)).toList();
  }

  void _toggle(String lang) {
    setState(() {
      if (_selected.contains(lang)) {
        _selected.remove(lang);
      } else {
        _selected.add(lang);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final filtered = _filtered;
    final trimmed = _query.trim();
    final canAdd = trimmed.isNotEmpty &&
        !_kAllLanguages.any(
            (l) => l.toLowerCase() == trimmed.toLowerCase());
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: context.tr('Search languages'),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (canAdd)
                    ListTile(
                      leading: const Icon(Icons.add, color: AppColors.primary),
                      title: Text(
                        context.tr("Add '{value}'").replaceFirst(
                            '{value}', trimmed),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      trailing: _selected.contains(trimmed)
                          ? const Icon(Icons.check,
                              size: 18, color: AppColors.primary)
                          : null,
                      onTap: () => _toggle(trimmed),
                    ),
                  ...filtered.map(
                    (lang) => ListTile(
                      title: Text(
                        lang,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: _selected.contains(lang)
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: _selected.contains(lang)
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: _selected.contains(lang)
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () => _toggle(lang),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  context.tr('Done ({count})').replaceFirst(
                      '{count}', _selected.length.toString()),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}