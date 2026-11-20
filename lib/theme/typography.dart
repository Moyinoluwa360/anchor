import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The strict type scale. Fonts are bundled in assets/google_fonts and runtime
/// fetching is off (see main.dart), so the app never touches the network.
///
/// Space Grotesk: headings and big numbers. Inter: body. JetBrains Mono:
/// timers, times and small data labels.
abstract final class T {
  // Big numbers / countdowns.
  static TextStyle mega(Color c) => GoogleFonts.jetBrainsMono(
    fontSize: 84,
    fontWeight: FontWeight.w700,
    letterSpacing: -4,
    height: 1,
    color: c,
  );
  static TextStyle display(Color c) => GoogleFonts.spaceGrotesk(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.8,
    height: 1.02,
    color: c,
  );
  static TextStyle h1(Color c) => GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    height: 1.08,
    color: c,
  );
  static TextStyle h2(Color c) => GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    height: 1.15,
    color: c,
  );
  static TextStyle h3(Color c) => GoogleFonts.spaceGrotesk(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
    color: c,
  );
  static TextStyle number(Color c, {double size = 40}) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: -size * 0.04,
    height: 1,
    color: c,
  );

  static TextStyle body(Color c) =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.45, color: c);
  static TextStyle bodyStrong(Color c) =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4, color: c);
  static TextStyle small(Color c) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, height: 1.35, color: c);
  static TextStyle button(Color c) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: c);

  static TextStyle mono(Color c, {double size = 13, FontWeight w = FontWeight.w500}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: w, letterSpacing: -0.2, color: c);

  /// Tiny uppercase data label: "FOCUS · 25 MIN".
  static TextStyle label(Color c) =>
      GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.1, color: c);
}
