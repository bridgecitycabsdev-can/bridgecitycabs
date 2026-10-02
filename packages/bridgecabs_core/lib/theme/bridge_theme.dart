import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

ThemeData bridgeTheme(Brightness brightness) {
  if (!kIsWeb && Platform.environment['FLUTTER_TEST'] == 'true') {
    GoogleFonts.config.allowRuntimeFetching = false;
  }
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: BridgeTokens.brand,
    brightness: brightness,
  ).copyWith(surface: dark ? BridgeTokens.surfaceDark : BridgeTokens.surface);
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? BridgeTokens.bgDark : BridgeTokens.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    primaryTextTheme: GoogleFonts.interTextTheme(base.primaryTextTheme),
  );
}
