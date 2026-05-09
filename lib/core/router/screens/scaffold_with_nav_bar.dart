import 'package:flutter/material.dart';

/// Shell commun pour les routes authentifiées (BottomNavigationBar, etc.).
///
/// À personnaliser avec votre navigation principale.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(body: child);
}
