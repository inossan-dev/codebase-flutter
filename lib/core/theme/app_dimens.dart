import 'package:flutter/material.dart';

/// Constantes de spacing et de dimensions.
///
/// Élimine les magic numbers dans les widgets.
/// Utilisation : `SizedBox(height: AppDimens.sm)` ou `AppDimens.paddingH`
abstract final class AppDimens {
  // ─── Spacing scale (multiples de 4) ─────────────────────────────────────
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // ─── Border radius ──────────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // ─── Paddings courants ──────────────────────────────────────────────────
  static const EdgeInsets paddingH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingAll = EdgeInsets.all(md);
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // ─── Tailles composants ─────────────────────────────────────────────────
  static const double buttonHeight = 52;
  static const double iconSizeSm = 20;
  static const double iconSizeMd = 24;
  static const double iconSizeLg = 32;
}
