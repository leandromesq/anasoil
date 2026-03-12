import 'package:anasoil_mobile/data/repositories/auth/auth_repository.dart';
import 'package:anasoil_mobile/data/repositories/auth/auth_repository_remote.dart';
import 'package:anasoil_mobile/data/repositories/document/document_repository.dart';
import 'package:anasoil_mobile/data/repositories/document/document_repository_remote.dart';
import 'package:anasoil_mobile/data/repositories/profile/profile_repository.dart';
import 'package:anasoil_mobile/data/repositories/profile/profile_repository_remote.dart';
import 'package:anasoil_mobile/data/repositories/soil_analysis/soil_analysis_repository.dart';
import 'package:anasoil_mobile/data/repositories/soil_analysis/soil_analysis_repository_remote.dart';
import 'package:anasoil_mobile/data/services/firebase_auth_service.dart';
import 'package:anasoil_mobile/data/services/firebase_storage_service.dart';
import 'package:anasoil_mobile/data/services/firestore_service.dart';
import 'package:anasoil_mobile/data/services/pdf_extraction_service.dart';
import 'package:anasoil_mobile/data/services/storage_service.dart';
import 'package:anasoil_mobile/ui/auth/auth_viewmodel.dart';
import 'package:anasoil_mobile/ui/home/analysis_viewmodel.dart';
import 'package:anasoil_mobile/ui/profile/profile_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instância global do GetIt para injeção de dependências
final getIt = GetIt.instance;

/// Configuração de injeção de dependências
Future<void> setupDependencyInjection() async {
  // Services
  await _setupServices();

  // Repositories
  _setupRepositories();

  // ViewModels
  _setupViewModels();
}

/// Configura os services
Future<void> _setupServices() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // StorageService
  getIt.registerSingleton<StorageService>(StorageService(prefs));

  // Firebase Services
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerSingleton<FirebaseStorageService>(FirebaseStorageService());

  // PDF Extraction Service
  getIt.registerSingleton<PdfExtractionService>(PdfExtractionService());
}

/// Configura os repositories
void _setupRepositories() {
  // AuthRepository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryRemote(
      authService: getIt<FirebaseAuthService>(),
      firestoreService: getIt<FirestoreService>(),
      storage: getIt<StorageService>(),
    ),
  );

  // ProfileRepository
  getIt.registerSingleton<ProfileRepository>(
    ProfileRepositoryRemote(
      authService: getIt<FirebaseAuthService>(),
      firestoreService: getIt<FirestoreService>(),
      storage: getIt<StorageService>(),
      storageService: getIt<FirebaseStorageService>(),
    ),
  );

  // DocumentRepository
  getIt.registerSingleton<DocumentRepository>(
    DocumentRepositoryRemote(
      authService: getIt<FirebaseAuthService>(),
      storageService: getIt<FirebaseStorageService>(),
      firestoreService: getIt<FirestoreService>(),
    ),
  );

  // SoilAnalysisRepository
  getIt.registerSingleton<SoilAnalysisRepository>(
    SoilAnalysisRepositoryRemote(
      authService: getIt<FirebaseAuthService>(),
      firestoreService: getIt<FirestoreService>(),
      pdfExtractionService: getIt<PdfExtractionService>(),
    ),
  );
}

/// Configura os ViewModels
void _setupViewModels() {
  // AuthViewModel
  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(authRepository: getIt<AuthRepository>()),
  );

  // ProfileViewModel
  getIt.registerSingleton<ProfileViewModel>(
    ProfileViewModel(profileRepository: getIt<ProfileRepository>()),
  );

  // AnalysisViewModel
  getIt.registerSingleton<AnalysisViewModel>(
    AnalysisViewModel(
      documentRepository: getIt<DocumentRepository>(),
      soilAnalysisRepository: getIt<SoilAnalysisRepository>(),
    ),
  );
}
