// Barrel file — regroupe tous les providers pour un import unique.
//
// Organisation : chaque concern a son propre fichier de providers.
// Ce barrel permet de conserver `import 'package:codebase/core/di/providers.dart'`
// comme point d'entrée unique.
//
// Pour ajouter une feature :
// 1. Créer `lib/features/<feature>/di/<feature>_providers.dart`
// 2. Ajouter l'export ci-dessous

export 'package:codebase/core/di/infrastructure_providers.dart';
export 'package:codebase/features/auth/di/auth_providers.dart';

// Alias pratique pour les consommateurs
// ignore: unused_import
import 'package:codebase/core/di/infrastructure_providers.dart';

final themeModeProvider = themeModeNotifierProvider;
