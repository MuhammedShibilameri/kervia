import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/l10n/kervia_l10n.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Dependency Setup (Clean Architecture)
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  final sendOtpUseCase = SendOtpUseCase(authRepository);
  final verifyOtpUseCase = VerifyOtpUseCase(authRepository);
  final signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository);
  final updateUserRoleUseCase = UpdateUserRoleUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);

  runApp(
    MyApp(
      authBloc: AuthBloc(
        sendOtpUseCase: sendOtpUseCase,
        verifyOtpUseCase: verifyOtpUseCase,
        signInWithGoogleUseCase: signInWithGoogleUseCase,
        updateUserRoleUseCase: updateUserRoleUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        signOutUseCase: signOutUseCase,
      )..add(CheckAuthStatusEvent()),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;

  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: ListenableBuilder(
        listenable: Listenable.merge([
          AppLanguage.rebuildListenable,
          AppThemeMode.rebuildListenable,
        ]),
        builder: (context, _) {
          AppColors.dark = AppThemeMode.isDark;
          return MaterialApp(
            title: 'Kervia',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: AppThemeMode.mode,
            locale: AppLanguage.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: appLocalizationsDelegates,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
} 