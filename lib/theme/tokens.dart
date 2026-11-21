import 'package:flutter/material.dart';

import '../models/enums.dart';

/// Raw palette. Screens never use these directly: they read [ExeColors]
/// from the theme so dark and light both work.
abstract final class Palette {
  static const black = Color(0xFF0A0A0A);
  static const surfaceDark = Color(0xFF141414);
  static const surfaceDark2 = Color(0xFF1B1B1B);
  static const borderDark = Color(0xFF262626);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFF8A8A8A);
  static const lemon = Color(0xFFD4FF3A);

  static const offWhite = Color(0xFFF3F3EF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceLight2 = Color(0xFFEAEAE4);
  static const borderLight = Color(0xFFDDDDD6);
  static const greyLight = Color(0xFF6B6B66);

  /// Deeper lemon for thin strokes and accent text on the light theme, where
  /// pure lemon on off-white would be too faint to read.
  static const lemonInk = Color(0xFF5C7400); // 4.8:1 on off-white (WCAG AA)

  /// Gentle "getting full" warning. Never red anywhere in the app.
  static const amber = Color(0xFFFFB547);
}

/// Semantic colours, available as `context.c`.
@immutable
class ExeColors extends ThemeExtension<ExeColors> {
  const ExeColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.textDim,
    required this.accent,
    required this.onAccent,
    required this.accentInk,
    required this.warn,
    required this.glassTint,
    required this.glassBorder,
    required this.grain,
    required this.isDark,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color text;
  final Color textDim;

  /// Lemon: active task, progress fills, primary button, timer ring, wins.
  final Color accent;
  final Color onAccent;

  /// Accent used for thin lines and small text (readable on both themes).
  final Color accentInk;
  final Color warn;
  final Color glassTint;
  final Color glassBorder;
  final Color grain;
  final bool isDark;

  static const dark = ExeColors(
    bg: Palette.black,
    surface: Palette.surfaceDark,
    surface2: Palette.surfaceDark2,
    border: Palette.borderDark,
    text: Palette.white,
    textDim: Palette.grey,
    accent: Palette.lemon,
    onAccent: Palette.black,
    accentInk: Palette.lemon,
    warn: Palette.amber,
    glassTint: Color(0x1AFFFFFF), // white @ 10 %
    glassBorder: Color(0x33FFFFFF),
    grain: Color(0x0DFFFFFF),
    isDark: true,
  );

  static const light = ExeColors(
    bg: Palette.offWhite,
    surface: Palette.surfaceLight,
    surface2: Palette.surfaceLight2,
    border: Palette.borderLight,
    text: Palette.black,
    textDim: Palette.greyLight,
    accent: Palette.lemon,
    onAccent: Palette.black,
    accentInk: Palette.lemonInk,
    warn: Color(0xFF995900), // 5:1 on off-white
    glassTint: Color(0x99FFFFFF),
    glassBorder: Color(0x1F000000),
    grain: Color(0x0F000000),
    isDark: false,
  );

  /// Subtle per-area tint: shades of grey and green only, so the app stays
  /// black, white and lemon.
  Color areaTint(LifeArea a) => switch (a) {
    LifeArea.startup => accentInk,
    LifeArea.cloud => Color.lerp(text, accentInk, 0.55)!,
    LifeArea.sideGigs => Color.lerp(text, accentInk, 0.3)!,
    LifeArea.health => text,
    LifeArea.personal => textDim,
  };

  @override
  ExeColors copyWith() => this;

  @override
  ExeColors lerp(ThemeExtension<ExeColors>? other, double t) {
    if (other is! ExeColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ExeColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      border: l(border, other.border),
      text: l(text, other.text),
      textDim: l(textDim, other.textDim),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentInk: l(accentInk, other.accentInk),
      warn: l(warn, other.warn),
      glassTint: l(glassTint, other.glassTint),
      glassBorder: l(glassBorder, other.glassBorder),
      grain: l(grain, other.grain),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Spacing, radii and motion constants used everywhere.
abstract final class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const gutter = 20.0;
}

abstract final class Radii {
  static const chip = 14.0;
  static const card = 24.0;
  static const big = 28.0;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 180);
  static const med = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 380); // ceiling per spec (≈400 ms)
  static const curve = Curves.easeOutCubic;
  static const spring = Curves.easeOutBack;
}

extension ExeThemeX on BuildContext {
  ExeColors get c => Theme.of(this).extension<ExeColors>()!;

  /// True when the user asked iOS to reduce motion.
  bool get reduceMotion => MediaQuery.of(this).disableAnimations;

  /// [d] or zero when reduced motion is on.
  Duration motion(Duration d) => reduceMotion ? Duration.zero : d;
}
