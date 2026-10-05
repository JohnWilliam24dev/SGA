import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

/// Faz o filho aparecer subindo suavemente. Use [delay] para escalonar
/// vários elementos da mesma tela. Anima uma única vez.
class FadeIn extends StatelessWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.offset = 16,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Quantos pixels o filho percorre, de baixo para cima, ao aparecer.
  final double offset;

  @override
  Widget build(BuildContext context) {
    final total = delay + duration;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: total,
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * offset),
            child: child,
          ),
        );
      },
    );
  }
}
