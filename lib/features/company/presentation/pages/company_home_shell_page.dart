import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/datasources/company_job_remote_data_source.dart';
import '../../data/repositories/company_job_repository_impl.dart';
import '../../domain/entities/company_profile_entity.dart';
import '../../domain/usecases/company_job_usecases.dart';
import '../bloc/company_job_bloc.dart';
import 'company_applicants_page.dart';
import 'company_dashboard_page.dart';
import 'company_jobs_page.dart';
import 'company_profile_page.dart';
import '../../../messaging/presentation/pages/messages_page.dart';

class CompanyHomeShellPage extends StatelessWidget {
  final UserEntity user;
  final CompanyProfileEntity companyProfile;

  const CompanyHomeShellPage({
    super.key,
    required this.user,
    required this.companyProfile,
  });

  @override
  Widget build(BuildContext context) {
    context.adaptive();

    final remoteDataSource = CompanyJobRemoteDataSourceImpl();
    final repository = CompanyJobRepositoryImpl(remoteDataSource: remoteDataSource);
    final saveJobUseCase = SaveJobPostUseCase(repository);
    final getJobsUseCase = GetCompanyJobsUseCase(repository);
    final updateStatusUseCase = UpdateJobStatusUseCase(repository);
    final deleteJobUseCase = DeleteJobPostUseCase(repository);
    final getApplicationsUseCase = GetCompanyApplicationsUseCase(repository);
    final updateApplicationStatusUseCase =
        UpdateApplicationStatusUseCase(repository);

    return BlocProvider<CompanyJobBloc>(
      create: (_) => CompanyJobBloc(
        saveJobPostUseCase: saveJobUseCase,
        getCompanyJobsUseCase: getJobsUseCase,
        updateJobStatusUseCase: updateStatusUseCase,
        deleteJobPostUseCase: deleteJobUseCase,
        getApplicationsUseCase: getApplicationsUseCase,
        updateApplicationStatusUseCase: updateApplicationStatusUseCase,
      )..add(LoadCompanyJobsEvent(user.id)),
      child: _CompanyHomeShellView(user: user, companyProfile: companyProfile),
    );
  }
}

class _CompanyHomeShellView extends StatefulWidget {
  final UserEntity user;
  final CompanyProfileEntity companyProfile;

  const _CompanyHomeShellView({
    required this.user,
    required this.companyProfile,
  });

  @override
  State<_CompanyHomeShellView> createState() => _CompanyHomeShellViewState();
}

class _CompanyHomeShellViewState extends State<_CompanyHomeShellView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final pages = [
      CompanyDashboardPage(
        user: widget.user,
        companyProfile: widget.companyProfile,
        onOpenTab: (index) => setState(() => _currentIndex = index),
      ),
      CompanyJobsPage(user: widget.user),
      CompanyApplicantsPage(
          user: widget.user, companyName: widget.companyProfile.companyName),
      MessagesPage(
        userId: widget.user.id,
        displayName: widget.companyProfile.companyName.isNotEmpty
            ? widget.companyProfile.companyName
            : (widget.user.displayName ?? 'Company'),
        canInitiate: true,
      ),
      CompanyProfilePage(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context, isDesktop),
          Expanded(child: IndexedStack(index: _currentIndex, children: pages)),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _CompanyBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          Text(
            widget.companyProfile.companyName.isNotEmpty
                ? widget.companyProfile.companyName
                : context.tr('Company'),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CompanyBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child:
                      _buildNavItem(context, 0, 'Home', Icons.home_outlined, Icons.home)),
              Expanded(
                  child: _buildNavItem(
                      context, 1, 'Jobs', Icons.work_outline, Icons.work)),
              Expanded(
                  child: _buildNavItem(context, 2, 'Applicants', Icons.people_outline,
                      Icons.people)),
              Expanded(
                  child: _buildNavItem(context, 3, 'Message',
                      Icons.chat_bubble_outline, Icons.chat_bubble)),
              Expanded(
                  child: _buildNavItem(
                      context, 4, 'Profile', Icons.person_outline, Icons.person)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String label,
      IconData icon, IconData activeIcon) {
    final isActive = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 21,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(label),
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}