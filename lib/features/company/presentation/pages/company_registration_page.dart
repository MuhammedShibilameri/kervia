import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/pages/role_selection_page.dart';
import '../../domain/entities/company_profile_entity.dart';
import '../bloc/company_bloc.dart';
import '../../data/datasources/company_remote_data_source.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/usecases/company_usecases.dart';
import 'company_home_shell_page.dart';
import '../widgets/india_location_field.dart';

class CompanyRegistrationPage extends StatefulWidget {
  final UserEntity user;

  const CompanyRegistrationPage({super.key, required this.user});

  @override
  State<CompanyRegistrationPage> createState() =>
      _CompanyRegistrationPageState();
}

class _CompanyRegistrationPageState extends State<CompanyRegistrationPage> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
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

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName ?? '');
    _industryController = TextEditingController();
    _websiteController = TextEditingController();
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _locationController = TextEditingController();
    _districtController = TextEditingController();
    _stateController = TextEditingController(text: 'Kerala');
    _employeeSizeController = TextEditingController();
    _foundedYearController = TextEditingController();
    _aboutController = TextEditingController();
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

  void _onStepContinue(BuildContext ctx) {
    final formKeys = [_formKey1, _formKey2, _formKey3];
    final form = formKeys[_currentStep].currentState;
    if (form == null || !form.validate()) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(context.tr(
              'Please fill all required fields (with the red mark) before continuing.')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _onSubmit(ctx);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _onSubmit(BuildContext ctx) {
    final profile = CompanyProfileEntity(
      userId: widget.user.id,
      companyName: _nameController.text.trim(),
      industry: _industryController.text.trim(),
      website: _websiteController.text.trim(),
      contactEmail: _emailController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
      employeeSize: _employeeSizeController.text.trim(),
      foundedYear: _foundedYearController.text.trim(),
      about: _aboutController.text.trim(),
      stepCompleted: 3,
    );

    ctx.read<CompanyBloc>().add(SubmitCompanyProfileEvent(profile));
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final remoteDataSource = CompanyRemoteDataSourceImpl();
    final repository = CompanyRepositoryImpl(remoteDataSource: remoteDataSource);
    final saveUseCase = SaveCompanyProfileUseCase(repository);
    final getUseCase = GetCompanyProfileUseCase(repository);

    return BlocProvider(
      create: (_) => CompanyBloc(
        saveProfileUseCase: saveUseCase,
        getProfileUseCase: getUseCase,
      ),
      child: BlocConsumer<CompanyBloc, CompanyState>(
        listener: (context, state) {
          if (state is CompanySubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('Profile submitted successfully!')),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => CompanyHomeShellPage(
                  user: widget.user,
                  companyProfile: state.profile,
                ),
              ),
              (route) => false,
            );
          } else if (state is CompanyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context, isDesktop),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          children: [
                            Text(
                              context.tr('Company Profile Setup'),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr(
                                  'Tell us about your company to get started.'),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),
                            if (state is CompanyLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else
                              _buildStepper(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
            child: const Icon(Icons.all_inclusive, color: Colors.white, size: 20),
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
          if (!isDesktop)
            IconButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => RoleSelectionPage(user: widget.user),
                ),
              ),
              icon: Icon(Icons.close, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Stepper(
      currentStep: _currentStep,
      onStepCancel: _onStepCancel,
      type: StepperType.vertical,
      physics: const ClampingScrollPhysics(),
      controlsBuilder: (context, details) {
        final isLast = _currentStep == 2;
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _onStepContinue(context),
                  child: Text(
                    isLast ? context.tr('Submit Profile') : context.tr('Continue'),
                  ),
                ),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: Text(context.tr('Back')),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      steps: [
        Step(
          title: Text(context.tr('Basic Information')),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          content: Form(
            key: _formKey1,
            child: Column(
              children: [
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
                  label: context.tr('Website (optional)'),
                  icon: Icons.language,
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
        ),
        Step(
          title: Text(context.tr('Contact Details')),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          content: Form(
            key: _formKey2,
            child: Column(
              children: [
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
              ],
            ),
          ),
        ),
        Step(
          title: Text(context.tr('Company Details')),
          isActive: _currentStep >= 2,
          content: Form(
            key: _formKey3,
            child: Column(
              children: [
                _buildField(
                  controller: _employeeSizeController,
                  label: context.tr('Employee Size'),
                  icon: Icons.groups_outlined,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? context.tr('Employee size is required')
                      : null,
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
                  validator: (v) => v == null || v.trim().isEmpty
                      ? context.tr('About is required')
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
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
