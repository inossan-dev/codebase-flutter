import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/user.dart';
import 'package:codebase/features/auth/domain/repositories/auth_repository.dart';
import 'package:codebase/features/auth/domain/usecases/login_usecase.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late LoginUseCase sut; // System Under Test : convention de nommage
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    sut = LoginUseCase(mockRepository);
  });

  // Fixture réutilisable
  const tUser = User(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  const tValidEmail = 'test@example.com';
  const tValidPassword = 'password123';

  group('LoginUseCase', () {
    group('validation domaine', () {
      test('retourne ValidationFailure si email invalide', () async {
        // Pas besoin de mocker le repository : l'erreur est dans le usecase
        final result = await sut(
          const LoginParams(email: 'invalid-email', password: tValidPassword),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Devrait retourner un Left'),
        );
        verifyNever(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      });

      test('retourne ValidationFailure si password < 8 chars', () async {
        final result = await sut(
          const LoginParams(email: tValidEmail, password: 'short'),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Devrait retourner un Left'),
        );
      });
    });

    group('appel repository', () {
      test('retourne User en cas de succès', () async {
        when(
          () => mockRepository.login(
            email: tValidEmail,
            password: tValidPassword,
          ),
        ).thenAnswer((_) async => const Right(tUser));

        final result = await sut(
          const LoginParams(email: tValidEmail, password: tValidPassword),
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Devrait retourner un Right'),
          (user) => expect(user, equals(tUser)),
        );

        verify(
          () => mockRepository.login(
            email: tValidEmail,
            password: tValidPassword,
          ),
        ).called(1);
      });

      test('propage le Failure du repository', () async {
        const tFailure = UnauthorizedFailure();

        when(
          () => mockRepository.login(
            email: tValidEmail,
            password: tValidPassword,
          ),
        ).thenAnswer((_) async => const Left(tFailure));

        final result = await sut(
          const LoginParams(email: tValidEmail, password: tValidPassword),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<UnauthorizedFailure>()),
          (_) => fail('Devrait retourner un Left'),
        );
      });
    });
  });
}
