import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codebase/core/network/network_info.dart';

/// Bannière affichée en haut de l'écran quand la connexion est perdue.
///
/// À placer dans le Shell ou au-dessus du router :
/// ```dart
/// Column(
///   children: [
///     const ConnectivityBanner(),
///     Expanded(child: child),
///   ],
/// )
/// ```
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);

    return isOnlineAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (isConnected) {
        if (isConnected) return const SizedBox.shrink();

        return MaterialBanner(
          content: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, size: 18),
              SizedBox(width: 8),
              Text('Aucune connexion internet'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          actions: const [SizedBox.shrink()],
        );
      },
    );
  }
}
