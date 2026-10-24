import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';

/// Rota de página do app (uma tela empilhada no Navigator).
Route<void> appRoute(WidgetBuilder builder) {
  return MaterialPageRoute<void>(builder: builder);
}
