# Codebase — Architecture Flutter de référence

Architecture **Clean Architecture par feature**, pensée pour scaler.

## Stack technique

| Couche | Package |
|---|---|
| State management | `flutter_riverpod` + `riverpod_annotation` (code gen) |
| Navigation | `go_router` (guards auth, routes typées) |
| Network | `dio` (interceptors auth, logging, retry) |
| Serialisation | `freezed` + `json_serializable` |
| Secure storage | `flutter_secure_storage` |
| Error handling | `dartz` (`Either<Failure, T>`) |
| Logging | `logger` (wrapper `AppLogger`) |
| Tests | `mocktail` + `fake_async` |

---

## Architecture

```
lib/
├── core/
│   ├── config/            # AppConfig (dart-define, flavors)
│   ├── di/                # Barrel des providers + infrastructure_providers
│   ├── error/             # Hiérarchie sealed Failure
│   ├── extensions/        # Either extensions, etc.
│   ├── network/           # DioClient + interceptors (auth, log)
│   ├── router/
│   │   ├── app_router.dart    # GoRouter + guards
│   │   └── screens/           # Placeholders (404, shell, detail)
│   ├── theme/
│   │   ├── app_theme.dart     # Material 3 centralisé
│   │   └── app_dimens.dart    # Spacing, radius, paddings
│   ├── usecase/           # Classe abstraite UseCase<T, Params>
│   └── utils/             # AppLogger, safeCall()
│
└── features/
    └── <feature>/
        ├── di/                    # <feature>_providers.dart
        ├── data/
        │   ├── datasources/       # Remote (API) + Local (cache)
        │   ├── models/            # DTOs + toDomain() + fromJson()
        │   └── repositories/      # Implémentations concrètes
        ├── domain/
        │   ├── entities/          # Entités métier pures (immutables)
        │   ├── repositories/      # Interfaces (contrats)
        │   └── usecases/          # 1 classe = 1 cas d'usage
        └── presentation/
            ├── providers/         # Notifiers + sealed states
            ├── screens/           # Pages complètes
            └── widgets/           # Composants réutilisables
```

### Règle de dépendance

```
presentation → domain ← data
```

- **domain** : pur Dart, aucune dépendance framework/infra
- **data** : implémente les interfaces du domaine, gère JSON/Dio/cache
- **presentation** : appelle les UseCases via providers, affiche les états

---

## Démarrage rapide

```bash
# 1. Installer les dépendances
flutter pub get

# 2. Générer le code (riverpod, freezed, json)
dart run build_runner build --delete-conflicting-outputs

# 3. Lancer en dev
flutter run --dart-define=FLAVOR=dev --dart-define=API_URL=https://api.dev.example.com

# 4. Lancer en staging / prod
flutter run --dart-define=FLAVOR=staging --dart-define=API_URL=https://api.staging.example.com
flutter run --dart-define=FLAVOR=prod --dart-define=API_URL=https://api.example.com
```

---

## Ajouter une nouvelle fonctionnalité — Guide pas à pas

Exemple : ajouter une feature **`product`**.

### Étape 1 — Créer la structure de dossiers

```
lib/features/product/
├── di/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

### Étape 2 — Définir l'entité domaine

Créer `lib/features/product/domain/entities/product.dart` :

```dart
import 'package:equatable/equatable.dart';

final class Product extends Equatable {
  const Product({required this.id, required this.name, required this.price});

  final String id;
  final String name;
  final double price;

  @override
  List<Object?> get props => [id, name, price];
}
```

> **Règle** : aucun import de package externe (pas de json, pas de flutter).

### Étape 3 — Définir le contrat du repository (interface)

Créer `lib/features/product/domain/repositories/product_repository.dart` :

```dart
import 'package:dartz/dartz.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/product/domain/entities/product.dart';

abstract interface class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(String id);
}
```

### Étape 4 — Créer le UseCase

Créer `lib/features/product/domain/usecases/get_products_usecase.dart` :

```dart
import 'package:dartz/dartz.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/usecase/usecase.dart';
import 'package:codebase/features/product/domain/entities/product.dart';
import 'package:codebase/features/product/domain/repositories/product_repository.dart';

final class GetProductsUseCase extends UseCase<List<Product>, NoParams> {
  const GetProductsUseCase(this._repository);
  final ProductRepository _repository;

  @override
  Future<Either<Failure, List<Product>>> call(NoParams _) {
    return _repository.getProducts();
  }
}
```

### Étape 5 — Créer le modèle data (DTO)

Créer `lib/features/product/data/models/product_model.dart` :

```dart
import 'package:codebase/features/product/domain/entities/product.dart';

final class ProductModel {
  const ProductModel({required this.id, required this.name, required this.price});

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
      );

  final String id;
  final String name;
  final double price;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};

  Product toDomain() => Product(id: id, name: name, price: price);
}
```

### Étape 6 — Créer le datasource remote

Créer `lib/features/product/data/datasources/product_remote_datasource.dart` :

```dart
import 'package:dio/dio.dart';
import 'package:codebase/features/product/data/models/product_model.dart';

final class ProductRemoteDatasource {
  const ProductRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<ProductModel>> getProducts() async {
    final response = await _dio.get<List<dynamic>>('/products');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    return ProductModel.fromJson(response.data!);
  }
}
```

### Étape 7 — Implémenter le repository

Créer `lib/features/product/data/repositories/product_repository_impl.dart` :

```dart
import 'package:dartz/dartz.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/utils/safe_call.dart';
import 'package:codebase/features/product/data/datasources/product_remote_datasource.dart';
import 'package:codebase/features/product/domain/entities/product.dart';
import 'package:codebase/features/product/domain/repositories/product_repository.dart';

final class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({required ProductRemoteDatasource remote})
      : _remote = remote;
  final ProductRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<Product>>> getProducts() {
    return safeCall(
      tag: 'getProducts',
      action: () async {
        final models = await _remote.getProducts();
        return models.map((m) => m.toDomain()).toList();
      },
    );
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) {
    return safeCall(
      tag: 'getProductById',
      action: () async => (await _remote.getProductById(id)).toDomain(),
    );
  }
}
```

> **Note** : `safeCall()` gère automatiquement le try/catch DioException → Failure.

### Étape 8 — Enregistrer les providers (DI)

Créer `lib/features/product/di/product_providers.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:codebase/core/di/infrastructure_providers.dart';
import 'package:codebase/features/product/data/datasources/product_remote_datasource.dart';
import 'package:codebase/features/product/data/repositories/product_repository_impl.dart';
import 'package:codebase/features/product/domain/repositories/product_repository.dart';
import 'package:codebase/features/product/domain/usecases/get_products_usecase.dart';

part 'product_providers.g.dart';

@Riverpod(keepAlive: true)
ProductRemoteDatasource productRemoteDatasource(Ref ref) {
  return ProductRemoteDatasource(ref.watch(dioClientProvider).instance);
}

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) {
  return ProductRepositoryImpl(remote: ref.watch(productRemoteDatasourceProvider));
}

@Riverpod(keepAlive: true)
GetProductsUseCase getProductsUseCase(Ref ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
}
```

Puis **ajouter l'export** dans `lib/core/di/providers.dart` :

```dart
export 'package:codebase/features/product/di/product_providers.dart';
```

### Étape 9 — Créer le provider de présentation

Créer `lib/features/product/presentation/providers/product_list_provider.dart` :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:codebase/core/usecase/usecase.dart';
import 'package:codebase/features/product/di/product_providers.dart';
import 'package:codebase/features/product/domain/entities/product.dart';

part 'product_list_provider.g.dart';

@riverpod
Future<List<Product>> productList(Ref ref) async {
  final useCase = ref.watch(getProductsUseCaseProvider);
  final result = await useCase(const NoParams());
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
}
```

### Étape 10 — Créer l'écran

Créer `lib/features/product/presentation/screens/product_list_screen.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codebase/features/product/presentation/providers/product_list_provider.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Produits')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('${product.price} €'),
            );
          },
        ),
      ),
    );
  }
}
```

### Étape 11 — Ajouter la route

Dans `lib/core/router/app_router.dart`, ajouter la constante et la route :

```dart
// Dans AppRoutes
static const products = '/products';

// Dans les routes du GoRouter
GoRoute(
  path: AppRoutes.products,
  name: 'products',
  builder: (context, state) => const ProductListScreen(),
),
```

### Étape 12 — Générer le code et vérifier

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

---

## Checklist nouvelle feature

- [ ] Entité domaine créée (immutable, Equatable, aucun import infra)
- [ ] Interface repository dans `domain/repositories/`
- [ ] UseCase(s) étendant `UseCase<T, Params>`
- [ ] Modèle data avec `fromJson()`, `toJson()`, `toDomain()`
- [ ] Datasource(s) remote/local
- [ ] Repository impl utilisant `safeCall()` pour le error handling
- [ ] Providers DI dans `<feature>/di/` + export dans `core/di/providers.dart`
- [ ] Provider de présentation (AsyncNotifier ou simple provider)
- [ ] Écran avec gestion des 3 états (loading / error / data)
- [ ] Route ajoutée dans `AppRoutes` + `GoRouter`
- [ ] `build_runner` exécuté
- [ ] `flutter analyze` — 0 issues
- [ ] Tests unitaires pour le UseCase
- [ ] Tests widget pour l'écran

---

## Conventions

### Nommage
- **Fichiers** : `snake_case.dart`
- **Classes** : `PascalCase`
- **Providers** : `camelCaseProvider`
- **Tests** : `*_test.dart`, variable SUT nommée `sut`

### Imports
- Toujours des **package imports** (`package:codebase/...`)
- Jamais de chemins relatifs (`../../../`)
- Tri : dart → flutter → packages tiers → packages internes

### Gestion d'erreur
- **Jamais** de `throw` dans les repositories → retourner `Left(Failure)`
- Utiliser `safeCall()` pour le boilerplate try/catch des repositories
- **Toujours** logger avec `AppLogger.e()` avant de wrapper en `Failure`
- Catch spécifique (`on DioException`) avant catch générique

### Widgets
- `ConsumerWidget` par défaut (stateless)
- `ConsumerStatefulWidget` **uniquement** si `TextEditingController` ou animation
- `dispose()` de tous les controllers sans exception
- Utiliser `theme.colorScheme.xxx` — jamais de `Colors.blue` en dur
- Utiliser `AppDimens` — jamais de magic numbers (`SizedBox(height: 16)`)

### Performance
- `const` partout où possible
- `ref.watch(provider.select((s) => s.field))` pour les rebuilds ciblés
- Éviter les providers trop larges qui causent des rebuilds en cascade

---

## Commandes utiles

```bash
# Générer le code
dart run build_runner build --delete-conflicting-outputs

# Watch mode (regénère à chaque save)
dart run build_runner watch --delete-conflicting-outputs

# Analyse statique
flutter analyze

# Tests unitaires + widget
flutter test

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```
