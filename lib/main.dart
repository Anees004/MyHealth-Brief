import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Gemini API key: pass at run time to avoid committing secrets.
  // Run: flutter run --dart-define=GEMINI_API_KEY=your_key_here
  const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY',
  );
  await initializeDependencies(geminiApiKey: geminiApiKey);

  runApp(const MyHealthBriefApp());
}

class MyHealthBriefApp extends StatefulWidget {
  const MyHealthBriefApp({super.key});

  @override
  State<MyHealthBriefApp> createState() => _MyHealthBriefAppState();
}

class _MyHealthBriefAppState extends State<MyHealthBriefApp> {
  late final ValueNotifier<bool> _authNotifier;
  late final GoRouter _goRouter;

  @override
  void initState() {
    super.initState();
    _authNotifier = ValueNotifier<bool>(false);
    _goRouter = AppRouter.router(
      authListenable: _authNotifier,
      isAuthenticated: () => _authNotifier.value,
    );
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final isAuth = state is AuthAuthenticated;
          if (state is AuthLoading) return; // keep previous value while loading
          if (_authNotifier.value != isAuth) {
            _authNotifier.value = isAuth;
          }
        },
        child: MaterialApp.router(
          title: 'MyHealth Brief',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _goRouter,
        ),
      ),
    );
  }
}
