import 'package:flutter/material.dart';

import '../../../Domain/maker.dart';
import '../../../Core/theme/sga_theme.dart';

class MakerAvatar extends StatelessWidget {
  const MakerAvatar({required this.maker, required this.size});
  final Maker maker;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: SgaColors.of(context).avatar,
      shape: BoxShape.circle,
    ),
    child: Text(
      maker.inicial,
      style: TextStyle(
        fontSize: size * .42,
        fontWeight: FontWeight.w800,
        color: SgaColors.of(context).onPrimary,
      ),
    ),
  );
}
