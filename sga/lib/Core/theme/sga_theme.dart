import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/widgets.dart' show Brightness, BuildContext, Color;

/// Azul da identidade do SGA (#1E90FF).
const Color sgaPrimary = Color(0xFF1E90FF);

/// Preferência temporária da sessão. Persistência entra junto com a API.
final ValueNotifier<AppThemeMode> sgaThemeMode = ValueNotifier(
  AppThemeMode.light,
);

/// Papéis semânticos da interface. Nenhuma tela deve conhecer códigos de cor:
/// ela pede o papel visual de que precisa a esta única fonte de verdade.
class SgaColors {
  const SgaColors._(this._tokens, this.dark);

  final ThemeTokens _tokens;
  final bool dark;

  static SgaColors of(BuildContext context) => SgaColors._(
    AppThemeScope.tokensOf(context),
    AppThemeScope.brightnessOf(context) == Brightness.dark,
  );

  Color get background => _tokens.backgroundColor;
  Color get surface => _tokens.surfaceColor;
  Color get panel => dark ? const Color(0xFF132434) : const Color(0xFFFFFFFF);
  Color get panelBorder =>
      dark ? const Color(0xFF31526B) : const Color(0xFFFFFFFF);
  Color get text => _tokens.textColor;
  Color get heading => dark ? const Color(0xFFF4F8FC) : const Color(0xFF09243A);
  Color get muted => _tokens.mutedTextColor;
  Color get border => _tokens.borderColor;
  Color get primary => _tokens.primaryColor;
  Color get onPrimary => _tokens.onPrimaryColor;
  Color get success => _tokens.successColor;
  Color get error => _tokens.errorColor;
  Color get input => dark ? const Color(0xFF1B3347) : const Color(0xFFF7FBFE);
  Color get disabled =>
      dark ? const Color(0xFF6E8292) : const Color(0xFF627D92);
  Color get icon => dark ? const Color(0xFF73C6FF) : const Color(0xFF17659A);
  Color get avatar => const Color(0xFF168DEE);
  Color get negative =>
      dark ? const Color(0xFFFF8A80) : const Color(0xFFC45A40);
  Color get selectedNavigation =>
      dark ? const Color(0xFF21415A) : const Color(0xFFFFFFFF);
  Color get chartPrimary => const Color(0xFF168BF1);
  Color get chartSecondary => const Color(0xFF55B6FA);
  Color get chartTertiary => const Color(0xFF8BCBFA);
  Color get chartQuaternary => const Color(0xFFCEECFF);
}

/// Compatibilidade temporária para widgets ainda em migração. Novos widgets
/// devem usar [SgaColors.of] com o BuildContext.
@Deprecated('Use SgaColors.of(context).text')
Color get sgaOnSurface => sgaThemeMode.value == AppThemeMode.dark
    ? const Color(0xFFEAF2FA)
    : const Color(0xFF16354C);

@Deprecated('Use SgaColors.of(context).muted')
Color get sgaMuted => sgaThemeMode.value == AppThemeMode.dark
    ? const Color(0xFFB5C5D4)
    : const Color(0xFF456078);

@Deprecated('Use SgaColors.of(context).heading')
Color get sgaHeading => sgaThemeMode.value == AppThemeMode.dark
    ? const Color(0xFFF4F8FC)
    : const Color(0xFF09243A);

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
