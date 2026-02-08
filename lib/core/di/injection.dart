import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Data Sources
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/health_brief/data/datasources/gemini_datasource.dart';
import '../../features/health_brief/data/datasources/health_brief_remote_datasource.dart';
import '../../features/health_brief/data/datasources/local_report_storage.dart';

// Repositories
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/health_brief/data/repositories/health_brief_repository_impl.dart';
import '../../features/health_brief/domain/repositories/health_brief_repository.dart';

// Use Cases
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/health_brief/domain/usecases/analyze_document.dart';
import '../../features/health_brief/domain/usecases/get_health_briefs.dart';
import '../../features/health_brief/domain/usecases/get_health_brief_by_id.dart';

// Blocs
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/health_brief/presentation/bloc/health_brief_bloc.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies({required String geminiApiKey}) async {
  // External
  _initExternal(geminiApiKey);

  // Data Sources
  _initDataSources();

  // Repositories
  _initRepositories();

  // Use Cases
  _initUseCases();

  // Blocs
  _initBlocs();
}

void _initExternal(String geminiApiKey) {
  // Firebase (Auth + Firestore only; reports stored locally, not in Storage)
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Google Sign In
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // Gemini (use a current model; gemini-1.5-flash is no longer available for v1beta)
  sl.registerLazySingleton<GenerativeModel>(
    () => GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: geminiApiKey,
    ),
  );
}

void _initDataSources() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<GeminiDataSource>(
    () => GeminiDataSourceImpl(generativeModel: sl()),
  );

  sl.registerLazySingleton<LocalReportStorage>(
    () => LocalReportStorageImpl(),
  );

  sl.registerLazySingleton<HealthBriefRemoteDataSource>(
    () => HealthBriefRemoteDataSourceImpl(firestore: sl()),
  );
}

void _initRepositories() {
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<HealthBriefRepository>(
    () => HealthBriefRepositoryImpl(
      geminiDataSource: sl(),
      localReportStorage: sl(),
      remoteDataSource: sl(),
    ),
  );
}

void _initUseCases() {
  // Auth
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));

  // Health Brief
  sl.registerLazySingleton(() => AnalyzeDocument(sl()));
  sl.registerLazySingleton(() => GetHealthBriefs(sl()));
  sl.registerLazySingleton(() => GetHealthBriefById(sl()));
}

void _initBlocs() {
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      deleteAccount: sl(),
    ),
  );

  sl.registerFactory(
    () => HealthBriefBloc(
      analyzeDocument: sl(),
      getHealthBriefs: sl(),
      getHealthBriefById: sl(),
    ),
  );
}
