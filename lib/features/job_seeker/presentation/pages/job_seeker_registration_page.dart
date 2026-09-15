import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/pages/role_selection_page.dart';
import '../../domain/entities/job_seeker_profile_entity.dart';
import 'job_seeker_step2_page.dart';

class JobSeekerRegistrationPage extends StatefulWidget {
  final UserEntity user;

  const JobSeekerRegistrationPage({
    super.key,
    required this.user,
  });

  @override
  State<JobSeekerRegistrationPage> createState() =>
      _JobSeekerRegistrationPageState();
}

class _JobSeekerRegistrationPageState extends State<JobSeekerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Split display name if present
    final parts = (widget.user.displayName ?? '').split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onContinueToStep2() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
    final profile = JobSeekerProfileEntity(
      userId: widget.user.id,
      fullName: fullName,
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      stepCompleted: 1,
    );

    // Navigate immediately; persist in the background so a slow/failed
    // Firestore write never blocks the user from reaching step 2.
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobSeekerStep2Page(profile: profile),
        ),
      );
    }

    try {
      await FirebaseFirestore.instance
          .collection('job_seekers')
          .doc(widget.user.id)
          .set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'stepCompleted': 1,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${context.tr('Failed to save details:')} $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person_add_alt_outlined,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            context.tr('Registration'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        context.tr('Step 1 of 3'),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stepper bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Row(
                  children: [
                    Expanded(child: _buildStepNode(1, context.tr('Personal Info'), isActive: true)),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: AppColors.border,
                      ),
                    ),
                    Expanded(child: _buildStepNode(2, context.tr('Experience'), isActive: false)),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: AppColors.border,
                      ),
                    ),
                    Expanded(child: _buildStepNode(3, context.tr('Preferences'), isActive: false)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Form Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              context.tr('Personal Information'),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr(
                                  'Please provide your basic details to complete your profile.'),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Photo upload avatar
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    context.tr('Upload Photo'),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Form Fields
                            if (isDesktop) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _firstNameController,
                                      label: 'First Name',
                                      hint: 'John',
                                      validator: (v) => v == null || v.isEmpty
                                          ? context.tr('Required')
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _lastNameController,
                                      label: 'Last Name',
                                      hint: 'Doe',
                                      validator: (v) => v == null || v.isEmpty
                                          ? context.tr('Required')
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _emailController,
                                      label: 'Email Address',
                                      hint: 'john@example.com',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) => v == null || !v.contains('@')
                                          ? context.tr('Valid email required')
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _phoneController,
                                      label: 'Phone Number',
                                      hint: '+1 (555) 000-0000',
                                      keyboardType: TextInputType.phone,
                                      validator: (v) => v == null || v.isEmpty
                                          ? context.tr('Required')
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                hint: 'John',
                                validator: (v) =>
                                    v == null || v.isEmpty ? context.tr('Required') : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                hint: 'Doe',
                                validator: (v) =>
                                    v == null || v.isEmpty ? context.tr('Required') : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                hint: 'john@example.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v == null || !v.contains('@')
                                    ? context.tr('Valid email required')
                                    : null,
                              ),
                              const SizedBox(height: 16),
_buildTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                hint: '+1 (555) 000-0000',
                                keyboardType: TextInputType.phone,
                                validator: (v) =>
                                    v == null || v.isEmpty ? context.tr('Required') : null,
                              ),
                            ],

                            const SizedBox(height: 40),

                            // Actions
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RoleSelectionPage(user: widget.user),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_back, size: 16),
                                  label: Text(context.tr('Back to Roles')),
                                ),
                                ElevatedButton(
                                  onPressed: _onContinueToStep2,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(context.tr('Continue to Step 2')),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                        ],
                      ),
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

  Widget _buildStepNode(int step, String title, {required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.tr(title),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: context.tr(hint),
          ),
        ),
      ],
    );
  }
}
