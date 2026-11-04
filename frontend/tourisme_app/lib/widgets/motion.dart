import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

bool reduceMotion(BuildContext context) => MediaQuery.maybeOf(context)?.disableAnimations ?? false;

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration step;
  final Duration delay;
  final double offset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.step = const Duration(milliseconds: 70),
    this.delay = Duration.zero,
    this.offset = 18,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.status != AnimationStatus.dismissed) return;
    if (reduceMotion(context)) {
      _c.value = 1;
      return;
    }
    final wait = widget.delay + widget.step * math.min(widget.index, 10);
    Future.delayed(wait, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(offset: Offset(0, widget.offset * (1 - _t.value)), child: child),
      ),
    );
  }
}

class Shake extends StatefulWidget {
  final Widget child;

  const Shake({super.key, required this.child});

  @override
  State<Shake> createState() => ShakeState();
}

class ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  void shake() {
    if (reduceMotion(context)) return;
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final dx = math.sin(_c.value * math.pi * 5) * 10 * (1 - _c.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

enum ButtonPhase { idle, loading, done }

class MorphButton extends StatelessWidget {
  final String label;
  final ButtonPhase phase;
  final VoidCallback onPressed;

  const MorphButton({super.key, required this.label, required this.phase, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final busy = phase != ButtonPhase.idle;
    return LayoutBuilder(
      builder: (context, box) => Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          width: busy ? 56 : box.maxWidth,
          height: 56,
          decoration: BoxDecoration(
            color: phase == ButtonPhase.done ? AppColors.laterite : AppColors.ink,
            borderRadius: BorderRadius.circular(busy ? 28 : 18),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: busy ? null : onPressed,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                  child: switch (phase) {
                    ButtonPhase.idle => Text(
                        label,
                        key: const ValueKey("label"),
                        maxLines: 1,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ButtonPhase.loading => const SizedBox(
                        key: ValueKey("loading"),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      ),
                    ButtonPhase.done => const Icon(Icons.check_rounded, key: ValueKey("done"), color: Colors.white, size: 28),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordStrength extends StatelessWidget {
  final TextEditingController controller;

  const PasswordStrength({super.key, required this.controller});

  static int score(String p) {
    if (p.isEmpty) return 0;
    var s = 0;
    if (p.length >= 8) s++;
    if (p.length >= 12) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s <= 1 ? 1 : (s <= 3 ? 2 : 3);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final s = score(value.text);
        const labels = ["", "Faible", "Correct", "Solide"];
        const colors = [AppColors.line, Color(0xFFB9502B), Color(0xFFA86A24), Color(0xFF5E7D5A)];
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              for (var i = 1; i <= 3; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: s >= i ? colors[s] : AppColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              SizedBox(
                width: 56,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    labels[s],
                    key: ValueKey(s),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors[s]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PiroguePainter extends CustomPainter {
  final double sail;
  final double sun;
  final double time;

  PiroguePainter({required this.sail, required this.sun, required this.time});

  static const sceneTop = 200.0;
  static const sceneHeight = 140.0;
  static const _blue = Color(0xFF1F5C78);
  static const _horizon = 296.0;

  Path _hull() {
    return Path()
      ..moveTo(-64, -22)
      ..cubicTo(-56, -8, -40, 6, -20, 8)
      ..lineTo(20, 8)
      ..cubicTo(40, 6, 56, -8, 64, -22)
      ..cubicTo(50, -10, 30, -6, 0, -6)
      ..cubicTo(-30, -6, -50, -10, -64, -22)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 240);
    canvas.translate(0, -sceneTop);
    const w = 240.0;

    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, 0, w, _horizon - 4));
    canvas.drawCircle(Offset(168, 262 + 46 * (1 - sun)), 34, Paint()..color = AppColors.laterite);
    canvas.restore();

    const waves = [(_horizon, 6.0, 2.5, 1.0, 16.0), (310.0, 5.0, 2.0, 0.55, 11.4), (324.0, 4.0, 2.0, 0.3, 8.7)];
    for (final (y, amp, stroke, alpha, speed) in waves) {
      final off = (time * speed) % 24;
      final path = Path()..moveTo(-24 - off, y);
      for (var x = -24 - off; x < w + 24; x += 24) {
        path.quadraticBezierTo(x + 12, y - amp, x + 24, y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.ink.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    final bob = math.sin(time * 2.6);
    final bx = -90 + 210 * sail;
    final by = 286 - 2 * bob;

    final stern = bx - 58;
    final appear = (time * 2).clamp(0.0, 1.0);
    for (var d = 0.0; stern - d > -10; d += 11) {
      final a = (1 - d / 200).clamp(0.0, 1.0) * appear;
      if (a <= 0) break;
      final px = stern - d;
      canvas.drawCircle(
        Offset(px, _horizon + 4 + math.sin(px / 14) * 1.2),
        2.2,
        Paint()..color = AppColors.laterite.withValues(alpha: a * 0.85),
      );
    }

    canvas.save();
    canvas.translate(bx, by);
    canvas.rotate(bob * 0.035);

    final ink = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(34, -6), const Offset(34, -40), ink);
    final flap = math.sin(time * 7) * 3;
    canvas.drawPath(
      Path()
        ..moveTo(34, -40)
        ..lineTo(52, -34 + flap)
        ..lineTo(34, -28)
        ..close(),
      Paint()..color = AppColors.laterite,
    );

    final hull = _hull();
    canvas.save();
    canvas.clipPath(hull);
    canvas.drawRect(const Rect.fromLTWH(-70, -30, 140, 26), Paint()..color = _blue);
    final soft = Paint()..color = AppColors.lateriteSoft;
    final lat = Paint()..color = AppColors.laterite;
    for (var i = -70.0; i < 70; i += 10) {
      canvas.drawPath(Path()..moveTo(i, -6)..lineTo(i + 5, -14)..lineTo(i + 10, -6)..close(), soft);
    }
    for (var i = -66.0; i < 70; i += 10) {
      canvas.drawPath(Path()..moveTo(i, -14)..lineTo(i + 4, -20)..lineTo(i + 8, -14)..close(), lat);
    }
    canvas.drawRect(const Rect.fromLTWH(-70, -4, 140, 3), soft);
    canvas.drawRect(const Rect.fromLTWH(-70, -1, 140, 3), lat);
    canvas.drawRect(const Rect.fromLTWH(-70, 2, 140, 9), Paint()..color = AppColors.ink);
    for (final c in const [-30.0, -18.0, -6.0, 6.0, 18.0, 30.0]) {
      canvas.drawCircle(Offset(c, 5.5), 1.4, soft);
    }
    canvas.restore();
    canvas.drawPath(hull, ink);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(PiroguePainter old) => old.sail != sail || old.sun != sun || old.time != time;
}

class AuthBackdrop extends StatefulWidget {
  const AuthBackdrop({super.key});

  @override
  State<AuthBackdrop> createState() => _AuthBackdropState();
}

class _AuthBackdropState extends State<AuthBackdrop> with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(seconds: 40));
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _spin.stop();
      _float.stop();
    } else if (!_spin.isAnimating) {
      _spin.repeat();
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -110,
            child: RotationTransition(
              turns: _spin,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lateriteSoft, width: 34),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(top: 9),
                    decoration: const BoxDecoration(color: AppColors.laterite, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: 50,
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, Curves.easeInOut.transform(_float.value) * 10),
                child: child,
              ),
              child: Container(
              width: 46,
              height: 46,
                decoration: const BoxDecoration(color: AppColors.laterite, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Skeleton extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;

  const Skeleton({super.key, required this.height, this.width, this.radius = 16});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!reduceMotion(context) && !_c.isAnimating) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final x = _c.value * 3 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: const [AppColors.chip, Color(0xFFF7F7F3), AppColors.chip],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;
  final EdgeInsets padding;

  const SkeletonList({super.key, this.count = 5, this.itemHeight = 84, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Skeleton(height: itemHeight),
    );
  }
}

class PopOnChange extends StatefulWidget {
  final bool active;
  final Widget child;

  const PopOnChange({super.key, required this.active, required this.child});

  @override
  State<PopOnChange> createState() => _PopOnChangeState();
}

class _PopOnChangeState extends State<PopOnChange> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

  @override
  void didUpdateWidget(PopOnChange old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active && !reduceMotion(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        final scale = t == 0 ? 1.0 : 1 + 0.35 * math.sin(t * math.pi) * (1 - t * 0.4);
        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}

class SoftPageTransitionsBuilder extends PageTransitionsBuilder {
  const SoftPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion(context)) return child;
    final enter = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    final leave = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: enter,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(enter),
        child: FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.6).animate(leave),
          child: child,
        ),
      ),
    );
  }
}
