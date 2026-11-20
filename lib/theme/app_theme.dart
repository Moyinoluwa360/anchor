import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData dark() => _build(AnchorColors.dark, Brightness.dark);
  static ThemeData light() => _build(AnchorColors.light, Brightness.light);

  static ThemeData _build(AnchorColors c, Brightness b) {
    final scheme = ColorScheme(
      brightness: b,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.text,
      onSecondary: c.bg,
      error: c.warn,
      onError: c.onAccent,
      surface: c.surface,
      onSurface: c.text,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: c.border,
      extensions: [c],
      cupertinoOverrideTheme: CupertinoThemeData(brightness: b, primaryColor: c.accentInk),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      }),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: GoogleFonts.inter().fontFamily,
        bodyColor: c.text,
        displayColor: c.text,
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 0.5, space: 0.5),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.big))),
        showDragHandle: true,
        dragHandleColor: c.border,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface2,
        hintStyle: TextStyle(color: c.textDim),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Radii.chip), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Radii.chip),
            borderSide: BorderSide(color: c.accentInk, width: 1)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accentInk,
        selectionColor: c.accent.withValues(alpha: 0.35),
        selectionHandleColor: c.accentInk,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.onAccent : c.textDim),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.accent : c.surface2),
        trackOutlineColor: WidgetStatePropertyAll(c.border),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accent,
        inactiveTrackColor: c.surface2,
        thumbColor: c.accent,
        overlayColor: c.accent.withValues(alpha: 0.15),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.text,
        contentTextStyle: TextStyle(color: c.bg, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.chip)),
      ),
    );
  }
}
