import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_uploader.dart';
import '../../domain/entities/job_seeker_profile_entity.dart';
import '../data/step2_options_data.dart';
import '../widgets/chip_input_field.dart';
import '../widgets/registration_stepper_header.dart';
import '../widgets/searchable_dropdown_field.dart';
import '../widgets/upload_dropzone_card.dart';
import 'job_seeker_step3_review_page.dart';

class JobSeekerStep2Page extends StatefulWidget {
  final JobSeekerProfileEntity profile;

  const JobSeekerStep2Page({super.key, required this.profile});

  @override
  State<JobSeekerStep2Page> createState() => _JobSeekerStep2PageState();
}

class _JobSeekerStep2PageState extends State<JobSeekerStep2Page> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late String _selectedGender;
  late TextEditingController _locationController;
  late String _selectedState;
  late String _selectedDistrict;
  late String _selectedTaluk;
  late String _selectedPanchayat;

  // Photo
  Uint8List? _photoBytes;
  String? _photoName;

  // Professional Summary
  late String _selectedQualification;
  late String _selectedOccupation;
  late TextEditingController _experienceController;
  late TextEditingController _currentSalaryController;
  late TextEditingController _expectedSalaryController;

  // Skills & Languages
  late List<String> _skills;
  late List<String> _languages;
  late List<String> _preferredLocations;

  // Preferences
  late String _workMode;
  late String _salaryType;
  late TextEditingController _preferredCategoriesController;
  late List<String> _employmentTypes;

  // Attachments
  String? _resumeName;
  String? _resumeSize;
  String? _resumePath;
  String? _videoName;
  String? _videoSize;
  bool _uploadingResume = false;
  bool _uploadingVideo = false;

  Future<void> _handleResumeSelected(
    String name,
    String size,
    String path,
  ) async {
    setState(() => _uploadingResume = true);
    final url = await uploadSeekerFile(
      userId: widget.profile.userId,
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
      userId: widget.profile.userId,
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

  String? _videoPath;

  final List<String> _genderOptions = genderOptions;
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
      districtsByState[_selectedState] ?? const [];

  List<String> get _talukOptions =>
      taluksByDistrict[_selectedDistrict] ?? const [];

  List<String> get _panchayatOptions =>
      panchayatsByTaluk[_selectedTaluk] ?? const [];

  List<String> get _skillSuggestions =>
      skillsByOccupation[_selectedOccupation] ?? defaultSkillSuggestions;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;

    _fullNameController = TextEditingController(text: p.fullName);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phoneNumber);
    _dobController = TextEditingController(text: p.dateOfBirth);
    _selectedGender = p.gender;
    _locationController = TextEditingController(text: p.currentLocation);

    _selectedState = stateOptions.contains(p.state) ? p.state : '';
    _selectedDistrict = _districtOptions.contains(p.district) ? p.district : '';
    _selectedTaluk = _talukOptions.contains(p.taluk) ? p.taluk : '';
    _selectedPanchayat = _panchayatOptions.contains(p.panchayat)
        ? p.panchayat
        : '';

    _selectedQualification =
        qualificationOptions.contains(p.highestQualification)
        ? p.highestQualification
        : '';
    _selectedOccupation = occupationOptions.contains(p.currentOccupation)
        ? p.currentOccupation
        : '';
    _experienceController = TextEditingController(text: p.yearsOfExperience);
    _currentSalaryController = TextEditingController(text: p.currentSalary);
    _expectedSalaryController = TextEditingController(text: p.expectedSalary);

    _skills = List.from(p.skills);
    _languages = List.from(p.languages);
    _preferredLocations = List.from(p.preferredLocations);

    _workMode = p.workMode;
    _salaryType = p.salaryType;
    _preferredCategoriesController = TextEditingController(
      text: p.preferredCategories,
    );
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

  JobSeekerProfileEntity _buildUpdatedProfile() {
    return widget.profile.copyWith(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _selectedGender,
      currentLocation: _locationController.text.trim(),
      state: _selectedState,
      district: _selectedDistrict,
      taluk: _selectedTaluk,
      panchayat: _selectedPanchayat,
      highestQualification: _selectedQualification,
      currentOccupation: _selectedOccupation,
      yearsOfExperience: _experienceController.text.trim(),
      currentSalary: _currentSalaryController.text.trim(),
      expectedSalary: _expectedSalaryController.text.trim(),
      skills: _skills,
      languages: _languages,
      preferredLocations: _preferredLocations,
      workMode: _workMode,
      salaryType: _salaryType,
      preferredCategories: _preferredCategoriesController.text.trim(),
      employmentTypes: _employmentTypes,
      resumeName: _resumeName,
      resumeSize: _resumeSize,
      resumePath: _resumePath,
      videoName: _videoName,
      videoSize: _videoSize,
      videoPath: _videoPath,
      stepCompleted: 2,
    );
  }

  void _onPreviewDetails() {
    if (!_formKey.currentState!.validate()) return;
    final updated = _buildUpdatedProfile();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobSeekerStep3ReviewPage(profile: updated),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    final file = files.first;
    final bytes = await file.readAsBytes();
    final size = await file.length();
    if (size > 5 * 1024 * 1024) {
      if (mounted) {
        _showMessage(context.tr('Please choose an image under 5MB.'));
      }
      return;
    }
    setState(() {
      _photoBytes = bytes;
      _photoName = file.name;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
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
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepperHeader(currentStep: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Text(
                            context.tr('Professional Details'),
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
                              'Tell us about your educational background, work experience, and skills to help us match you with the best opportunities.',
                            ),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Section 1: Personal Information
                          _buildSectionCard(
                            icon: Icons.person_outline,
                            title: 'Personal Information',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Photo upload row
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _photoBytes != null
                                          ? Image.memory(
                                              _photoBytes!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                    Icons.person_outline,
                                                    color: AppColors.primary,
                                                    size: 34,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.person_outline,
                                              color: AppColors.primary,
                                              size: 34,
                                            ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _pickPhoto,
                                      icon: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 16,
                                      ),
                                      label: Text(
                                        _photoBytes != null
                                            ? context.tr('Change Photo')
                                            : context.tr('Upload Photo'),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        minimumSize: const Size(130, 38),
                                      ),
                                    ),
                                    if (_photoBytes != null)
                                      TextButton(
                                        onPressed: () => setState(() {
                                          _photoBytes = null;
                                          _photoName = null;
                                        }),
                                        child: Text(context.tr('Remove')),
                                      )
                                    else
                                      Text(
                                        context.tr('JPG, PNG max 5MB'),
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    if (_photoName != null)
                                      Text(
                                        _photoName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  controller: _fullNameController,
                                  label: 'Full Name *',
                                  hint: 'e.g. Jane Doe',
                                ),
                                const SizedBox(height: 16),
                                _responsiveRow([
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email Address *',
                                    hint: 'e.g. jane.doe@example.com',
                                  ),
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Phone Number *',
                                    hint: 'e.g. +91 98765 43210',
                                  ),
                                ]),
                                const SizedBox(height: 16),
                                _responsiveRow([
                                  _buildDobField(),
                                  _buildDropdown(
                                    label: 'Gender *',
                                    value: _selectedGender,
                                    items: _genderOptions,
                                    onChanged: (val) =>
                                        setState(() => _selectedGender = val!),
                                  ),
                                ]),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _locationController,
                                  label: 'Current Address *',
                                  hint:
                                      'Enter your full address (house no., street, city, PIN)',
                                  prefixIcon: Icons.location_on_outlined,
                                ),
                                const SizedBox(height: 16),
                                _responsiveRow([
                                  SearchableDropdownField(
                                    label: 'State *',
                                    value: _selectedState,
                                    options: stateOptions,
                                    hint: 'Select a state',
                                    prefixIcon: Icons.map_outlined,
                                    onChanged: (val) => setState(() {
                                      _selectedState = val;
                                      if (!_districtOptions.contains(
                                        _selectedDistrict,
                                      )) {
                                        _selectedDistrict = '';
                                        _selectedTaluk = '';
                                        _selectedPanchayat = '';
                                      }
                                    }),
                                  ),
                                  SearchableDropdownField(
                                    label: 'District *',
                                    value: _selectedDistrict,
                                    options: _districtOptions,
                                    hint: 'Select a district',
                                    prefixIcon: Icons.location_city_outlined,
                                    onChanged: (val) => setState(() {
                                      _selectedDistrict = val;
                                      if (!_talukOptions.contains(
                                        _selectedTaluk,
                                      )) {
                                        _selectedTaluk = '';
                                        _selectedPanchayat = '';
                                      }
                                    }),
                                  ),
                                ]),
                                const SizedBox(height: 16),
                                _responsiveRow([
                                  SearchableDropdownField(
                                    label: 'Taluk *',
                                    value: _selectedTaluk,
                                    options: _talukOptions,
                                    hint: 'Select a taluk',
                                    prefixIcon: Icons.landscape_outlined,
                                    onChanged: (val) => setState(() {
                                      _selectedTaluk = val;
                                      if (!_panchayatOptions.contains(
                                        _selectedPanchayat,
                                      )) {
                                        _selectedPanchayat = '';
                                      }
                                    }),
                                  ),
                                  SearchableDropdownField(
                                    label: 'Panchayat / Municipality *',
                                    value: _selectedPanchayat,
                                    options: _panchayatOptions,
                                    hint: 'Select panchayat',
                                    prefixIcon: Icons.location_on_outlined,
                                    onChanged: (val) => setState(
                                      () => _selectedPanchayat = val,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section 2: Professional Summary
                          _buildSectionCard(
                            icon: Icons.work_outline,
                            title: 'Professional Summary',
                            child: Column(
                              children: [
                                _responsiveRow([
                                  SearchableDropdownField(
                                    label: 'Highest Qualification *',
                                    value: _selectedQualification,
                                    options: qualificationOptions,
                                    hint: 'Select your qualification',
                                    prefixIcon: Icons.school_outlined,
                                    onChanged: (val) => setState(
                                      () => _selectedQualification = val,
                                    ),
                                  ),
                                  SearchableDropdownField(
                                    label: 'Current Occupation *',
                                    value: _selectedOccupation,
                                    options: occupationOptions,
                                    hint: 'Select your occupation',
                                    prefixIcon: Icons.work_outline,
                                    onChanged: (val) => setState(
                                      () => _selectedOccupation = val,
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 16),
                                _responsiveRow([
                                  _buildTextField(
                                    controller: _experienceController,
                                    label: 'Years of Experience',
                                    hint: 'e.g. 5',
                                  ),
                                  _buildTextField(
                                    controller: _currentSalaryController,
                                    label: 'Current Salary',
                                    hint: '0.00',
                                  ),
                                  _buildTextField(
                                    controller: _expectedSalaryController,
                                    label: 'Expected Salary',
                                    hint: '0.00',
                                  ),
                                ]),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section 3: Skills
                          _buildSectionCard(
                            icon: Icons.lightbulb_outline,
                            title: 'Skills',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('Search & Add Skills'),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ChipInputField(
                                  label: 'Skills',
                                  hint:
                                      'e.g. Flutter, Python, Project Management...',
                                  initialChips: _skills,
                                  onChanged: (chips) => _skills = chips,
                                  buttonLabel: context.tr('Add Skill'),
                                  suggestions: _skillSuggestions,
                                  suggestionsTitle: _selectedOccupation.isEmpty
                                      ? context.tr(
                                          'Tap to add a suggested skill',
                                        )
                                      : 'Tap to add suggested skills for $_selectedOccupation',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section 4: Languages
                          _buildSectionCard(
                            icon: Icons.translate,
                            title: 'Languages',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('Add Languages'),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ChipInputField(
                                  label: 'Languages',
                                  hint: 'e.g. English, Spanish',
                                  buttonLabel: context.tr('Add'),
                                  initialChips: _languages,
                                  onChanged: (chips) => _languages = chips,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section 5: Preferred Locations
                          _buildSectionCard(
                            icon: Icons.location_city_outlined,
                            title: 'Preferred Locations',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('Cities or Regions'),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ChipInputField(
                                  label: 'Locations',
                                  hint: 'e.g. New York, London, Remote',
                                  initialChips: _preferredLocations,
                                  onChanged: (chips) =>
                                      _preferredLocations = chips,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section 6: Preferences
                          _buildSectionCard(
                            icon: Icons.tune,
                            title: 'Preferences',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _responsiveRow([
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('Preferred Work Mode'),
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      RadioGroup<String>(
                                        groupValue: _workMode,
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() => _workMode = val);
                                          }
                                        },
                                        child: Wrap(
                                          spacing: 12,
                                          runSpacing: 4,
                                          children:
                                              [
                                                'On-site',
                                                'Hybrid',
                                                'Remote',
                                              ].map((mode) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Radio<String>(
                                                      value: mode,
                                                      activeColor:
                                                          AppColors.primary,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        mode,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 13,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  _buildDropdown(
                                    label: 'Preferred Salary Type',
                                    value: _salaryType,
                                    items: _salaryTypeOptions,
                                    onChanged: (val) =>
                                        setState(() => _salaryType = val!),
                                  ),
                                ]),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _preferredCategoriesController,
                                  label: 'Preferred Job Categories',
                                  hint:
                                      'e.g. Software Development, Marketing...',
                                  prefixIcon: Icons.category_outlined,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.tr('Employment Types'),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: _allEmploymentTypes.map((type) {
                                    final isChecked = _employmentTypes.contains(
                                      type,
                                    );
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
                                        Text(
                                          type,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section 7: Resumes & Introduction Video
                          _buildSectionCard(
                            icon: Icons.attach_file,
                            title: 'Resumes & Introduction Video',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth > 580;
                                    if (isWide) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ResumeUploadCard(
                                              fileName: _resumeName,
                                              fileSize: _resumeSize,
                                              onFileSelected:
                                                  (name, size, path) =>
                                                      _handleResumeSelected(
                                                        name,
                                                        size,
                                                        path,
                                                      ),
                                              onFileRemoved: () {
                                                setState(() {
                                                  _resumeName = null;
                                                  _resumeSize = null;
                                                  _resumePath = null;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: VideoUploadCard(
                                              videoName: _videoName,
                                              videoSize: _videoSize,
                                              onVideoSelected:
                                                  (name, size, path) =>
                                                      _handleVideoSelected(
                                                        name,
                                                        size,
                                                        path,
                                                      ),
                                              onVideoRemoved: () {
                                                setState(() {
                                                  _videoName = null;
                                                  _videoSize = null;
                                                  _videoPath = null;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          ResumeUploadCard(
                                            fileName: _resumeName,
                                            fileSize: _resumeSize,
                                            onFileSelected:
                                                (name, size, path) =>
                                                    _handleResumeSelected(
                                                      name,
                                                      size,
                                                      path,
                                                    ),
                                            onFileRemoved: () {
                                              setState(() {
                                                _resumeName = null;
                                                _resumeSize = null;
                                                _resumePath = null;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          VideoUploadCard(
                                            videoName: _videoName,
                                            videoSize: _videoSize,
                                            onVideoSelected:
                                                (name, size, path) =>
                                                    _handleVideoSelected(
                                                      name,
                                                      size,
                                                      path,
                                                    ),
                                            onVideoRemoved: () {
                                              setState(() {
                                                _videoName = null;
                                                _videoSize = null;
                                                _videoPath = null;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                if ((_uploadingResume || _uploadingVideo))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: LinearProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Bottom Bar
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  context.tr('Back to Step 1'),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 10,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            context.tr('Draft saved locally.'),
                                          ),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(context.tr('Save as Draft')),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _onPreviewDetails,
                                    icon: const Icon(
                                      Icons.visibility_outlined,
                                      size: 16,
                                    ),
                                    label: Text(context.tr('Preview Details')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  /// Stacks fields vertically on narrow screens so text is never squeezed.
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

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
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
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(label),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 1,
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
        Text(
          context.tr('Date of Birth *'),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(label),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
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
}
