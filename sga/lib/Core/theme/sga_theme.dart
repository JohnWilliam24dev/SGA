import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show Color;

/// Azul da identidade do SGA (#1E90FF).
const Color sgaPrimary = Color(0xFF1E90FF);

/// Paleta do SGA. O azul vivo e as superfícies claras translúcidas seguem a
/// nova identidade visual do produto.
const AppTheme sgaTheme = AppTheme(
  mode: AppThemeMode.light,
  light: ThemeTokens(
    primaryColor: sgaPrimary,
    secondaryColor: Color(0xFF76C7FF),
    backgroundColor: Color(0xFF1E95F3),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF0F2A43),
    mutedTextColor: Color(0xFF456078),
    borderColor: Color(0x99FFFFFF),
    onPrimaryColor: Color(0xFFFFFFFF),
  ),
  dark: ThemeTokens(
    primaryColor: sgaPrimary,
    secondaryColor: Color(0xFF2DD4C4),
    backgroundColor: Color(0xFF0B1620),
    surfaceColor: Color(0xFF132434),
    textColor: Color(0xFFEAF2FA),
    onPrimaryColor: Color(0xFFFFFFFF),
  ),
);

/// "Pele" do SGA: cantos suaves, botões altos e bastante respiro.
final StylePack sgaPack = StylePack.define(
  name: 'sga',
  inputText: const InputStyleSpec.rounded(radius: 11),
  button: const ButtonStyleSpec(
    radius: 11,
    minHeight: 46,
    horizontalPadding: 20,
  ),
  card: const CardStyleSpec(
    radius: 16,
    elevation: ElevationLevel.subtle,
    paddingSteps: 3,
  ),
  spacingScale: 1.1,
);
