import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_uploader.dart';
import '../../data/models/job_seeker_profile_model.dart';
import '../../domain/entities/job_seeker_profile_entity.dart';
import '../data/step2_options_data.dart';
import '../widgets/chip_input_field.dart';
import '../widgets/searchable_dropdown_field.dart';
import '../widgets/upload_dropzone_card.dart';
import 'profile_detail_page.dart';

class ProfileEditPage extends StatefulWidget {
  final String userId;
  final JobSeekerProfileEntity profile;
  final ProfileDetailSection section;

  const ProfileEditPage({
    super.key,
    required this.userId,
    required this.profile,
    required this.section,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _locationController;
  late String _gender;
  late String _state;
  late String _district;
  late String _taluk;
  late String _panchayat;

  late String _qualification;
  late String _occupation;
  late TextEditingController _experienceController;
  late TextEditingController _currentSalaryController;
  late TextEditingController _expectedSalaryController;
  late String _salaryType;

  late List<String> _skills;
  late List<String> _languages;
  late TextEditingController _preferredCategoriesController;
  late List<String> _preferredLocations;
  late String _workMode;
  late List<String> _employmentTypes;

  String? _resumeName;
  String? _resumeSize;
  String? _resumePath;
  String? _videoName;
  String? _videoSize;
  String? _videoPath;
  bool _uploadingResume = false;
  bool _uploadingVideo = false;

  Future<void> _handleResumeSelected(
    String name,
    String size,
    String path,
  ) async {
    setState(() => _uploadingResume = true);
    final url = await uploadSeekerFile(
      userId: widget.userId,
      localPath: path,
      kind: 'resume',
    );
    if (!mounted) return;
    setState(() => _uploadingResume = false);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not upload resume. Try again.')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() {
      _resumeName = name;
      _resumeSize = size;
      _resumePath = url;
    });
  }

  Future<void> _handleVideoSelected(
    String name,
    String size,
    String path,
  ) async {
    setState(() => _uploadingVideo = true);
    final url = await uploadSeekerFile(
      userId: widget.userId,
      localPath: path,
      kind: 'video',
    );
    if (!mounted) return;
    setState(() => _uploadingVideo = false);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not upload video. Try again.')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() {
      _videoName = name;
      _videoSize = size;
      _videoPath = url;
    });
  }

  final List<String> _salaryTypeOptions = [
    'Hourly',
    'Monthly',
    'Annual',
    'Annual (Fixed + Variable)',
  ];
  final List<String> _allEmploymentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Freelance',
    'Internship',
  ];

  List<String> get _districtOptions =>
      districtsByState[_state] ?? const <String>[];
  List<String> get _talukOptions =>
      taluksByDistrict[_district] ?? const <String>[];
  List<String> get _panchayatOptions =>
      panchayatsByTaluk[_taluk] ?? const <String>[];
  List<String> get _skillSuggestions =>
      skillsByOccupation[_occupation] ?? defaultSkillSuggestions;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;

    _fullNameController = TextEditingController(text: p.fullName);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phoneNumber);
    _dobController = TextEditingController(text: p.dateOfBirth);
    _gender = p.gender;
    _locationController = TextEditingController(text: p.currentLocation);

    _state = stateOptions.contains(p.state) ? p.state : '';
    _district = _districtOptions.contains(p.district) ? p.district : '';
    _taluk = _talukOptions.contains(p.taluk) ? p.taluk : '';
    _panchayat = _panchayatOptions.contains(p.panchayat) ? p.panchayat : '';

    _qualification = qualificationOptions.contains(p.highestQualification)
        ? p.highestQualification
        : '';
    _occupation = occupationOptions.contains(p.currentOccupation)
        ? p.currentOccupation
        : '';
    _experienceController = TextEditingController(text: p.yearsOfExperience);
    _currentSalaryController = TextEditingController(text: p.currentSalary);
    _expectedSalaryController = TextEditingController(text: p.expectedSalary);
    _salaryType = _salaryTypeOptions.contains(p.salaryType) ? p.salaryType : '';

    _skills = List.from(p.skills);
    _languages = List.from(p.languages);
    _preferredCategoriesController = TextEditingController(
      text: p.preferredCategories,
    );
    _preferredLocations = List.from(p.preferredLocations);
    _workMode = p.workMode;
    _employmentTypes = List.from(p.employmentTypes);

    _resumeName = p.resumeName;
    _resumeSize = p.resumeSize;
    _resumePath = p.resumePath;
    _videoName = p.videoName;
    _videoSize = p.videoSize;
    _videoPath = p.videoPath;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _currentSalaryController.dispose();
    _expectedSalaryController.dispose();
    _preferredCategoriesController.dispose();
    super.dispose();
  }

  ({String title, IconData icon}) get _config => switch (widget.section) {
    ProfileDetailSection.personal => (
      title: 'Edit Personal Details',
      icon: Icons.person_outline,
    ),
    ProfileDetailSection.professional => (
      title: 'Edit Professional Details',
      icon: Icons.work_outline,
    ),
    ProfileDetailSection.skills => (
      title: 'Edit Skills & Preferences',
      icon: Icons.tune,
    ),
    ProfileDetailSection.media => (
      title: 'Edit Resume & Video',
      icon: Icons.description_outlined,
    ),
  };

  JobSeekerProfileEntity _buildUpdated() {
    return widget.profile.copyWith(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _gender,
      currentLocation: _locationController.text.trim(),
      state: _state,
      district: _district,
      taluk: _taluk,
      panchayat: _panchayat,
      highestQualification: _qualification,
      currentOccupation: _occupation,
      yearsOfExperience: _experienceController.text.trim(),
      currentSalary: _currentSalaryController.text.trim(),
      expectedSalary: _expectedSalaryController.text.trim(),
      salaryType: _salaryType,
      skills: _skills,
      languages: _languages,
      preferredLocations: _preferredLocations,
      workMode: _workMode,
      preferredCategories: _preferredCategoriesController.text.trim(),
      employmentTypes: _employmentTypes,
      resumeName: _resumeName,
      resumeSize: _resumeSize,
      resumePath: _resumePath,
      videoName: _videoName,
      videoSize: _videoSize,
      videoPath: _videoPath,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updated = _buildUpdated();
      await FirebaseFirestore.instance
          .collection('job_seekers')
          .doc(widget.userId)
          .set(
            JobSeekerProfileModel.fromEntity(updated).toMap(),
            SetOptions(merge: true),
          );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
            'role': 'jobSeeker',
            'isProfileComplete': updated.isSubmitted,
            'updatedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr('Could not save changes.')} $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickDob() async {
    final parsed = _parseDob(_dobController.text);
    final now = DateTime.now();
    final latest = DateTime(now.year - 16, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: parsed.isBefore(latest) && parsed.isAfter(DateTime(1940))
          ? parsed
          : latest,
      firstDate: DateTime(1940),
      lastDate: latest,
      helpText: context.tr('Select Date of Birth'),
      fieldLabelText: context.tr('Date of Birth'),
      fieldHintText: 'dd/MM/yyyy',
    );
    if (selected != null) {
      setState(() {
        _dobController.text =
            '${selected.day.toString().padLeft(2, '0')}/${selected.month.toString().padLeft(2, '0')}/${selected.year}';
      });
    }
  }

  DateTime _parseDob(String text) {
    final parts = text.trim().split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null && m >= 1 && m <= 12) {
        return DateTime(y, m, d);
      }
    }
    return DateTime(1998, 5, 15);
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
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(_saving ? context.tr('Saving…') : context.tr('Save')),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: _buildForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return switch (widget.section) {
      ProfileDetailSection.personal => _personalForm(),
      ProfileDetailSection.professional => _professionalForm(),
      ProfileDetailSection.skills => _skillsForm(),
      ProfileDetailSection.media => _mediaForm(),
    };
  }

  Widget _personalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(_fullNameController, 'Full Name *', 'e.g. Jane Doe'),
        const SizedBox(height: 16),
        _responsiveRow([
          _buildTextField(
            _emailController,
            'Email Address *',
            'e.g. jane.doe@example.com',
          ),
          _buildTextField(
            _phoneController,
            'Phone Number *',
            'e.g. +91 98765 43210',
          ),
        ]),
        const SizedBox(height: 16),
        _responsiveRow([
          _buildDobField(),
          _buildDropdown('Gender *', _gender, genderOptions, (val) {
            if (val != null) setState(() => _gender = val);
          }),
        ]),
        const SizedBox(height: 16),
        _buildTextField(
          _locationController,
          'Current Address',
          'House no., street, city, PIN',
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        _responsiveRow([
          SearchableDropdownField(
            label: 'State *',
            value: _state,
            options: stateOptions,
            hint: 'Select a state',
            prefixIcon: Icons.map_outlined,
            onChanged: (val) => setState(() {
              _state = val;
              if (!_districtOptions.contains(_district)) {
                _district = '';
                _taluk = '';
                _panchayat = '';
              }
            }),
          ),
          SearchableDropdownField(
            label: 'District *',
            value: _district,
            options: _districtOptions,
            hint: 'Select a district',
            prefixIcon: Icons.location_city_outlined,
            onChanged: (val) => setState(() {
              _district = val;
              if (!_talukOptions.contains(_taluk)) {
                _taluk = '';
                _panchayat = '';
              }
            }),
          ),
        ]),
        const SizedBox(height: 16),
        _responsiveRow([
          SearchableDropdownField(
            label: 'Taluk *',
            value: _taluk,
            options: _talukOptions,
            hint: 'Select a taluk',
            prefixIcon: Icons.landscape_outlined,
            onChanged: (val) => setState(() {
              _taluk = val;
              if (!_panchayatOptions.contains(_panchayat)) {
                _panchayat = '';
              }
            }),
          ),
          SearchableDropdownField(
            label: 'Panchayat / Municipality *',
            value: _panchayat,
            options: _panchayatOptions,
            hint: 'Select panchayat',
            prefixIcon: Icons.location_on_outlined,
            onChanged: (val) => setState(() => _panchayat = val),
          ),
        ]),
      ],
    );
  }

  Widget _professionalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchableDropdownField(
          label: 'Highest Qualification *',
          value: _qualification,
          options: qualificationOptions,
          hint: 'Select your qualification',
          prefixIcon: Icons.school_outlined,
          onChanged: (val) => setState(() => _qualification = val),
        ),
        const SizedBox(height: 16),
        SearchableDropdownField(
          label: 'Current Occupation *',
          value: _occupation,
          options: occupationOptions,
          hint: 'Select your occupation',
          prefixIcon: Icons.work_outline,
          onChanged: (val) => setState(() => _occupation = val),
        ),
        const SizedBox(height: 16),
        _responsiveRow([
          _buildTextField(
            _experienceController,
            'Years of Experience',
            'e.g. 5',
            prefixIcon: Icons.timeline_outlined,
          ),
          _buildTextField(
            _currentSalaryController,
            'Current Salary',
            '0.00',
            prefixIcon: Icons.currency_rupee,
          ),
          _buildTextField(
            _expectedSalaryController,
            'Expected Salary',
            '0.00',
            prefixIcon: Icons.trending_up,
          ),
        ]),
        const SizedBox(height: 16),
        _buildDropdown('Salary Period', _salaryType, _salaryTypeOptions, (val) {
          if (val != null) setState(() => _salaryType = val);
        }),
      ],
    );
  }

  Widget _skillsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChipInputField(
          label: 'Key Skills',
          hint: 'e.g. Flutter, Python, Project Management...',
          initialChips: _skills,
          onChanged: (chips) => _skills = chips,
          buttonLabel: context.tr('Add Skill'),
          suggestions: _skillSuggestions,
          suggestionsTitle: _occupation.isEmpty
              ? context.tr('Tap to add a suggested skill')
              : 'Tap to add suggested skills for $_occupation',
        ),
        const SizedBox(height: 20),
        ChipInputField(
          label: 'Languages Spoken',
          hint: 'e.g. English, Malayalam',
          initialChips: _languages,
          onChanged: (chips) => _languages = chips,
          buttonLabel: context.tr('Add'),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Preferred Work Mode'),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _workMode,
              onChanged: (val) {
                if (val != null) setState(() => _workMode = val);
              },
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: ['On-site', 'Hybrid', 'Remote'].map((mode) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: mode,
                        activeColor: AppColors.primary,
                      ),
                      Text(mode, style: GoogleFonts.inter(fontSize: 13)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          _preferredCategoriesController,
          'Preferred Job Roles',
          'e.g. Software Development, Marketing... (comma separated)',
          prefixIcon: Icons.category_outlined,
        ),
        const SizedBox(height: 20),
        ChipInputField(
          label: 'Target Locations',
          hint: 'e.g. Kochi, Calicut, Remote',
          initialChips: _preferredLocations,
          onChanged: (chips) => _preferredLocations = chips,
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Employment Types'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: _allEmploymentTypes.map((type) {
                final isChecked = _employmentTypes.contains(type);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _employmentTypes.add(type);
                          } else {
                            _employmentTypes.remove(type);
                          }
                        });
                      },
                    ),
                    Text(type, style: GoogleFonts.inter(fontSize: 13)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _withSpinner(bool busy, Widget card) {
    if (!busy) return card;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        const SizedBox(height: 8),
        const LinearProgressIndicator(color: AppColors.primary),
      ],
    );
  }

  Widget _mediaForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 580;
        final resumeCard = ResumeUploadCard(
          fileName: _resumeName,
          fileSize: _resumeSize,
          onFileSelected: (name, size, path) =>
              _handleResumeSelected(name, size, path),
          onFileRemoved: () => setState(() {
            _resumeName = null;
            _resumeSize = null;
            _resumePath = null;
          }),
        );
        final videoCard = VideoUploadCard(
          videoName: _videoName,
          videoSize: _videoSize,
          onVideoSelected: (name, size, path) =>
              _handleVideoSelected(name, size, path),
          onVideoRemoved: () => setState(() {
            _videoName = null;
            _videoSize = null;
            _videoPath = null;
          }),
        );
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _withSpinner(_uploadingResume, resumeCard)),
              const SizedBox(width: 20),
              Expanded(child: _withSpinner(_uploadingVideo, videoCard)),
            ],
          );
        }
        return Column(
          children: [
            _withSpinner(_uploadingResume, resumeCard),
            const SizedBox(height: 16),
            _withSpinner(_uploadingVideo, videoCard),
          ],
        );
      },
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      context.tr(text),
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: context.tr(hint),
            isDense: true,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.textMuted)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Date of Birth'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          onTap: _pickDob,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            isDense: true,
            prefixIcon: Icon(
              Icons.cake_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
            suffixIcon: Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value.isEmpty ? null : value,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
          hint: Text(
            context.tr('Select'),
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textMuted),
          ),
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }

  Widget _responsiveRow(List<Widget> children, {double spacing = 16}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                children[i],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}
