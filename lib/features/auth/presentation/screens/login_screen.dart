import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:codebase/core/router/app_router.dart';
import 'package:codebase/features/auth/presentation/providers/auth_provider.dart';
import 'package:codebase/features/auth/presentation/widgets/app_text_field.dart';

/// Règles d'un écran bien fait :
/// - ConsumerStatefulWidget si on a besoin d'un controller/formkey local
/// - Jamais de logique métier dans le widget (tout va dans le Notifier)
/// - Gestion explicite de chaque état (idle/loading/error/success)
/// - dispose() de TOUS les controllers
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    // TOUJOURS disposer les controllers pour éviter les memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Valider le formulaire avant d'appeler le provider
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Fermer le clavier
    FocusScope.of(context).unfocus();

    await ref
        .read(loginNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les changements d'état pour les side effects (navigation, snackbar)
    ref.listen<LoginState>(loginNotifierProvider, (previous, next) {
      if (next is LoginSuccess) {
        context.go(AppRoutes.home);
      } else if (next is LoginError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        // Reset pour permettre un nouvel essai
        ref.read(loginNotifierProvider.notifier).resetState();
      }
    });

    final loginState = ref.watch(loginNotifierProvider);
    final isLoading = loginState is LoginLoading;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),

                  // ─── Header ─────────────────────────────────────────────
                  Text(
                    'Connexion',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bienvenue ! Entrez vos identifiants.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ─── Email ───────────────────────────────────────────────
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'vous@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'L\'email est requis.';
                      }
                      if (!RegExp(
                        r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(value.trim())) {
                        return 'Format d\'email invalide.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ─── Password ────────────────────────────────────────────
                  AppTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    enabled: !isLoading,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le mot de passe est requis.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // ─── Submit ──────────────────────────────────────────────
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Text('Se connecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
