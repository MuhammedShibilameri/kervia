import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import 'landing_router.dart';
import 'role_selection_page.dart';
import 'sign_in_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _minDisplayTimer;
  Timer? _fallbackTimer;
  bool _ready = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Enforce a short branded splash even when auth resolves instantly.
    _minDisplayTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _ready = true);
      _routeFor(context.read<AuthBloc>().state);
    });
    // Safety fallback: never block on a hung auth check.
    _fallbackTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _navigated) return;
      _navigated = true;
      _goSignIn();
    });
  }

  @override
  void dispose() {
    _minDisplayTimer?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _routeFor(AuthState state) {
    if (_navigated || !_ready) return;
    if (state is AuthLoading) return; // still checking - keep waiting
    _navigated = true;
    _fallbackTimer?.cancel();
    if (state is AuthenticatedState) {
      navigateToLanding(context, state.user);
    } else if (state is NeedsRoleSelectionState) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => RoleSelectionPage(user: state.user)),
        (route) => false,
      );
    } else {
      _goSignIn();
    }
  }

  void _goSignIn() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignInPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _routeFor(state),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/branding/kervia_logo.png',
                    width: 200,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.work_outline,
                      size: 120,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Text(
                  'Kervia',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}