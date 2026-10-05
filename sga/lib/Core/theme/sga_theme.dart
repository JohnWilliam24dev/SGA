import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show Color;

/// Azul da identidade do SGA (#1E90FF).
const Color sgaPrimary = Color(0xFF1E90FF);

/// Paleta do SGA, explícita (o framework não infere nada do Material).
///
/// Visual limpo, de sistema de saúde: azul da marca, fundo levemente azulado,
/// superfícies brancas e texto em azul-marinho. O modo fica fixo em claro
/// para a identidade não variar com a preferência do aparelho.
const AppTheme sgaTheme = AppTheme(
  mode: AppThemeMode.light,
  light: ThemeTokens(
    primaryColor: sgaPrimary,
    secondaryColor: Color(0xFF00B8A9),
    backgroundColor: Color(0xFFF4F9FF),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF0F2A43),
    mutedTextColor: Color(0xFF5B7089),
    borderColor: Color(0xFFD3E3F5),
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
  inputText: const InputStyleSpec.rounded(radius: 12),
  button: const ButtonStyleSpec(radius: 12, minHeight: 50, horizontalPadding: 24),
  card: const CardStyleSpec(
    radius: 20,
    elevation: ElevationLevel.subtle,
    paddingSteps: 3,
  ),
  spacingScale: 1.1,
);
