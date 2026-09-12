import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../company/data/datasources/company_remote_data_source.dart';
import '../../../company/presentation/pages/company_home_shell_page.dart';
import '../../../company/presentation/pages/company_registration_page.dart';
import '../../../job_seeker/presentation/pages/candidate_home_shell.dart';
import '../../../job_seeker/presentation/pages/job_seeker_registration_page.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_brand_panel.dart';
import 'otp_verification_page.dart';
import 'role_selection_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+1';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSendOtpPressed() {
    final rawNumber = _phoneController.text.trim();
    if (rawNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Please enter your phone number'))),
      );
      return;
    }
    final fullNumber = '$_selectedCountryCode$rawNumber';
    context.read<AuthBloc>().add(SendOtpEvent(fullNumber));
  }

  void _onGoogleSignInPressed() {
    context.read<AuthBloc>().add(SignInWithGoogleEvent());
  }

  Future<void> _openJobSeekerLanding(UserEntity user) async {
    final navigator = Navigator.of(context);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('job_seekers')
          .doc(user.id)
          .get();
      final isSubmitted =
          (doc.data()?['isSubmitted'] as bool?) ?? false;
      final target = isSubmitted
          ? CandidateHomeShell(user: user) as Widget
          : JobSeekerRegistrationPage(user: user) as Widget;
      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => target),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => JobSeekerRegistrationPage(user: user),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _openCompanyLanding(UserEntity user) async {
    final navigator = Navigator.of(context);
    Widget target;
    try {
      final profile = await CompanyRemoteDataSourceImpl().getProfile(user.id);
      target = (profile != null && profile.isProfileComplete)
          ? CompanyHomeShellPage(user: user, companyProfile: profile)
          : CompanyRegistrationPage(user: user) as Widget;
    } catch (_) {
      target = CompanyRegistrationPage(user: user);
    }
    if (!mounted) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => target),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationPage(
                verificationId: state.verificationId,
                phoneNumber: state.phoneNumber,
              ),
            ),
          );
        } else if (state is NeedsRoleSelectionState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RoleSelectionPage(user: state.user),
            ),
          );
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is AuthenticatedState) {
          if (state.user.role == UserRole.jobSeeker) {
            _openJobSeekerLanding(state.user);
          } else if (state.user.role == UserRole.company) {
            _openCompanyLanding(state.user);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => RoleSelectionPage(user: state.user),
              ),
              (route) => false,
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1080 : 480,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              flex: 5,
                              child: AuthBrandPanel(),
                            ),
                            Container(
                              width: 1,
                              height: 520,
                              color: AppColors.border,
                            ),
                            Expanded(
                              flex: 5,
                              child: _buildSignInCard(isLoading),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const AuthBrandPanel(),
                            Divider(color: AppColors.border),
                            _buildSignInCard(isLoading),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignInCard(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/branding/kervia_logo.png',
                    height: 72,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.work_outline,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kervia',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('Enter your credentials to continue'),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Text(
            context.tr('Phone Number'),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      items: const [
                        DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                        DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                        DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                        DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCountryCode = val);
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: AppColors.border,
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '(555) 000-0000',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _onSendOtpPressed,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('Send OTP')),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  context.tr('or'),
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: isLoading ? null : _onGoogleSignInPressed,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/branding/google_logo.png',
                    height: 20,
                    width: 20,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(context.tr('Continue with Google')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            context.tr(
                "By continuing, you agree to Kervia's Terms of Service and Privacy Policy"),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
