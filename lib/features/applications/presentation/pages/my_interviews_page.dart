import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/application_remote_data_source.dart';
import '../../data/repositories/application_repository_impl.dart';
import '../../domain/entities/job_application_entity.dart';
import '../../domain/usecases/get_applications_usecase.dart';
import '../bloc/application_bloc.dart';
import '../widgets/application_card.dart';
import '../widgets/kervia_bottom_navigation_bar.dart';
import 'application_details_page.dart';

class MyInterviewsPage extends StatelessWidget {
  final String? userId;
  final bool showBottomNav;
  final Function(int)? onNavTap;

  const MyInterviewsPage({
    super.key,
    this.userId,
    this.showBottomNav = true,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = ApplicationRemoteDataSourceImpl();
    final repository =
        ApplicationRepositoryImpl(remoteDataSource: remoteDataSource);
    final getApplicationsUseCase = GetApplicationsUseCase(repository);

    return BlocProvider(
      create: (_) => ApplicationBloc(getApplicationsUseCase: getApplicationsUseCase)
        ..add(LoadApplicationsEvent(
          status: ApplicationStatus.interviewStage,
          userId: userId,
        )),
      child: _MyInterviewsView(
        showBottomNav: showBottomNav,
        onNavTap: onNavTap,
      ),
    );
  }
}

class _MyInterviewsView extends StatefulWidget {
  final bool showBottomNav;
  final Function(int)? onNavTap;

  const _MyInterviewsView({
    this.showBottomNav = true,
    this.onNavTap,
  });

  @override
  State<_MyInterviewsView> createState() => _MyInterviewsViewState();
}

class _MyInterviewsViewState extends State<_MyInterviewsView> {
  int _currentNavIndex = 2; // Interviews tab

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Curved App Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_available_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('My Interviews'),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          context.tr(
                              'Companies that invite you to an interview appear here.'),
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

            // Interview Applications List
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
                                Icons.event_busy_outlined,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.tr('No interviews yet.'),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32),
                              child: Text(
                                context.tr(
                                    'When a company moves your application to the interview stage, it will appear here.'),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.applications.length,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                } else if (index != 2) {
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