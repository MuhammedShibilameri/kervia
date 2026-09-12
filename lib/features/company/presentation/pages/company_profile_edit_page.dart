import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/datasources/company_remote_data_source.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/entities/company_profile_entity.dart';
import '../../domain/usecases/company_usecases.dart';
import '../bloc/company_bloc.dart';
import '../widgets/india_location_field.dart';

class CompanyProfileEditPage extends StatefulWidget {
  final UserEntity user;
  final CompanyProfileEntity profile;

  const CompanyProfileEditPage({
    super.key,
    required this.user,
    required this.profile,
  });

  @override
  State<CompanyProfileEditPage> createState() =>
      _CompanyProfileEditPageState();
}

class _CompanyProfileEditPageState extends State<CompanyProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _industryController;
  late final TextEditingController _websiteController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _districtController;
  late final TextEditingController _stateController;
  late final TextEditingController _employeeSizeController;
  late final TextEditingController _foundedYearController;
  late final TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.companyName);
    _industryController = TextEditingController(text: p.industry);
    _websiteController = TextEditingController(text: p.website);
    _emailController = TextEditingController(text: p.contactEmail);
    _phoneController = TextEditingController(text: p.contactPhone);
    _locationController = TextEditingController(text: p.location);
    _districtController = TextEditingController(text: p.district);
    _stateController = TextEditingController(text: p.state);
    _employeeSizeController = TextEditingController(text: p.employeeSize);
    _foundedYearController = TextEditingController(text: p.foundedYear);
    _aboutController = TextEditingController(text: p.about);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _employeeSizeController.dispose();
    _foundedYearController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.profile.copyWith(
      companyName: _nameController.text.trim(),
      industry: _industryController.text.trim(),
      website: _websiteController.text.trim(),
      contactEmail: _emailController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      employeeSize: _employeeSizeController.text.trim(),
      foundedYear: _foundedYearController.text.trim(),
      about: _aboutController.text.trim(),
    );

    final remoteDataSource = CompanyRemoteDataSourceImpl();
    final repository =
        CompanyRepositoryImpl(remoteDataSource: remoteDataSource);
    final saveUseCase = SaveCompanyProfileUseCase(repository);
    final getUseCase = GetCompanyProfileUseCase(repository);

    final bloc = CompanyBloc(
      saveProfileUseCase: saveUseCase,
      getProfileUseCase: getUseCase,
    );
    bloc.add(SaveCompanyProfileEvent(updated));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('Profile saved successfully.')),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pop(context);
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('Edit Company Profile'),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          controller: _nameController,
                          label: context.tr('Company Name'),
                          icon: Icons.business_outlined,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('Company name is required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _industryController,
                          label: context.tr('Industry / Category'),
                          icon: Icons.category_outlined,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('Industry is required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _websiteController,
                          label: context.tr('Website'),
                          icon: Icons.language,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _emailController,
                          label: context.tr('Contact Email'),
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('Email is required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _phoneController,
                          label: context.tr('Phone Number'),
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('Phone is required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        IndiaLocationField(
                          controller: _locationController,
                          label: context.tr('Location / Address'),
                          icon: Icons.location_on_outlined,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('Location is required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _districtController,
                          label: context.tr('District'),
                          icon: Icons.map_outlined,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('District is required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _stateController,
                          label: context.tr('State'),
                          icon: Icons.flag_outlined,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('State is required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _employeeSizeController,
                          label: context.tr('Employee Size'),
                          icon: Icons.groups_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _foundedYearController,
                          label: context.tr('Founded Year'),
                          icon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _aboutController,
                          label: context.tr('About Your Company'),
                          icon: Icons.info_outline,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onSave,
                            child: Text(context.tr('Save Changes')),
                          ),
                        ),
                        const SizedBox(height: 32),
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

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.all_inclusive, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Kervia',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Text(
            context.tr('Edit Profile'),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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
}
