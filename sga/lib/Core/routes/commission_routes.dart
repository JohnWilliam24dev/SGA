import 'package:flutter/material.dart' show Dialog, showDialog;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../View/commissions/commission_detail_page.dart';
import 'app_route.dart';

/// No desktop o pedido é uma nota sobre o quadro; no celular, onde não há
/// espaço para as duas coisas, continua sendo uma página própria.
void openCommissionDetail(
  BuildContext context, {
  required CommissionResumoModel commission,
  required String statusNome,
}) {
  final mobile = MediaQuery.sizeOf(context).width < 760;
  if (mobile) {
    Navigator.of(context).push(
      appRoute(
        (_) => buildCommissionDetailScreen(
          commission: commission,
          statusNome: statusNome,
        ),
      ),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: const Color(0x00000000),
      insetPadding: const EdgeInsets.all(24),
      // A nota de vidro tem o tamanho do conteúdo, até este limite; passando
      // dele, o corpo rola dentro da própria nota.
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: buildCommissionDetailScreen(
          commission: commission,
          statusNome: statusNome,
          compact: true,
          onBack: () => Navigator.of(dialogContext).pop(),
        ),
      ),
    ),
  );
}

Widget buildCommissionDetailScreen({
  required CommissionResumoModel commission,
  required String statusNome,
  bool compact = false,
  VoidCallback? onBack,
}) {
  return Builder(
    builder: (context) => CommissionDetailPage(
      repository: commissionRepository,
      commission: commission,
      statusNome: statusNome,
      compact: compact,
      onBack: onBack ?? () => Navigator.of(context).pop(),
    ),
  );
}
