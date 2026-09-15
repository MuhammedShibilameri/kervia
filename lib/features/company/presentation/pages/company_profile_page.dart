import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import '../../data/datasources/company_remote_data_source.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/entities/company_profile_entity.dart';
import '../../domain/usecases/company_usecases.dart';
import '../bloc/company_bloc.dart';
import 'company_profile_edit_page.dart';

class CompanyProfilePage extends StatelessWidget {
  final UserEntity user;

  const CompanyProfilePage({super.key, required this.user});

  void _signOut(BuildContext context) {
    context.read<AuthBloc>().add(SignOutEvent());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final remoteDataSource = CompanyRemoteDataSourceImpl();
    final repository = CompanyRepositoryImpl(remoteDataSource: remoteDataSource);
    final getUseCase = GetCompanyProfileUseCase(repository);
    final saveUseCase = SaveCompanyProfileUseCase(repository);

    return BlocProvider(
      create: (_) => CompanyBloc(
        saveProfileUseCase: saveUseCase,
        getProfileUseCase: getUseCase,
      )..add(LoadCompanyProfileEvent(user.id)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<CompanyBloc, CompanyState>(
            builder: (context, state) {
              if (state is CompanyLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CompanyError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                );
              }
              if (state is CompanyLoaded) {
                return _buildProfile(context, state.profile, isDesktop);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(
      BuildContext context, CompanyProfileEntity profile, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
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
                profile.companyName.isNotEmpty
                    ? profile.companyName
                    : context.tr('Your Company'),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (profile.industry.isNotEmpty) ...[
              const SizedBox(height: 6),
              Center(
                child: Text(
                  profile.industry,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompanyProfileEditPage(
                            user: user,
                            profile: profile,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(context.tr('Edit Profile')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Details card
            _buildSection(
              context,
              context.tr('Company Details'),
              [
                _buildRow(context.tr('Email'), profile.contactEmail),
                _buildRow(context.tr('Phone'), profile.contactPhone),
                _buildRow(context.tr('Location'), profile.location),
                _buildRow(context.tr('District'), profile.district),
                _buildRow(context.tr('State'), profile.state),
                _buildRow(context.tr('Website'), profile.website),
                _buildRow(context.tr('Employee Size'), profile.employeeSize),
                _buildRow(context.tr('Founded Year'), profile.foundedYear),
              ],
            ),
            const SizedBox(height: 16),

            // About card
            if (profile.about.isNotEmpty)
              _buildSection(
                context,
                context.tr('About'),
                [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      profile.about,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _signOut(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: Text(
                  context.tr('Logout'),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
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
