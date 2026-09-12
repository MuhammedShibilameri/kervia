import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/application_remote_data_source.dart';
import '../../data/repositories/application_repository_impl.dart';
import '../../domain/entities/job_application_entity.dart';
import '../../domain/usecases/get_applications_usecase.dart';
import '../../domain/usecases/withdraw_application_usecase.dart';
import '../bloc/application_bloc.dart';
import '../widgets/application_card.dart';
import '../widgets/application_status_filter_bar.dart';
import '../widgets/kervia_bottom_navigation_bar.dart';
import 'application_details_page.dart';

class MyApplicationsPage extends StatelessWidget {
  final bool showBottomNav;
  final Function(int)? onNavTap;

  const MyApplicationsPage({
    super.key,
    this.showBottomNav = true,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    // Provide ApplicationBloc with Clean Architecture dependencies
    final remoteDataSource = ApplicationRemoteDataSourceImpl();
    final repository = ApplicationRepositoryImpl(remoteDataSource: remoteDataSource);
    final getApplicationsUseCase = GetApplicationsUseCase(repository);
    final withdrawApplicationUseCase = WithdrawApplicationUseCase(repository);

    return BlocProvider(
      create: (_) => ApplicationBloc(
        getApplicationsUseCase: getApplicationsUseCase,
        withdrawApplicationUseCase: withdrawApplicationUseCase,
      )..add(const LoadApplicationsEvent()),
      child: _MyApplicationsView(
        showBottomNav: showBottomNav,
        onNavTap: onNavTap,
      ),
    );
  }
}

class _MyApplicationsView extends StatefulWidget {
  final bool showBottomNav;
  final Function(int)? onNavTap;

  const _MyApplicationsView({
    this.showBottomNav = true,
    this.onNavTap,
  });

  @override
  State<_MyApplicationsView> createState() => _MyApplicationsViewState();
}

class _MyApplicationsViewState extends State<_MyApplicationsView> {
  int _currentNavIndex = 1; // Applications tab

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Curved App Bar matching screenshot
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('My Applications'),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          context.tr(
                              'Track the status of every job you applied for.'),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Horizontal Filter Bar
            BlocBuilder<ApplicationBloc, ApplicationState>(
              builder: (context, state) {
                final selectedStatus = state is ApplicationLoaded
                    ? state.selectedStatus
                    : ApplicationStatus.all;

                return ApplicationStatusFilterBar(
                  selectedStatus: selectedStatus,
                  onStatusSelected: (status) {
                    context.read<ApplicationBloc>().add(FilterByStatusEvent(status));
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            // Application Cards List
            Expanded(
              child: BlocBuilder<ApplicationBloc, ApplicationState>(
                builder: (context, state) {
                  if (state is ApplicationLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is ApplicationLoaded) {
                    if (state.applications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.folder_open_outlined,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${context.tr('No')} ${context.tr(state.selectedStatus.label)} ${context.tr('Applications')}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.tr(
                                  'You have no applications under this filter status.'),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.applications.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        final app = state.applications[index];
                        return ApplicationCard(
                          application: app,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ApplicationDetailsPage(
                                  application: app,
                                  onWithdraw: () {
                                    context
                                        .read<ApplicationBloc>()
                                        .add(WithdrawApplicationEvent(app.id));
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  if (state is ApplicationError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.inter(color: AppColors.error),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? KerviaBottomNavigationBar(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
                if (widget.onNavTap != null) {
                  widget.onNavTap!(index);
                } else if (index != 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${context.tr('Switched tab to index')} $index'),
                      duration: const Duration(milliseconds: 700),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
            )
          : null,
    );
  }
}
