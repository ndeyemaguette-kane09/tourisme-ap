import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/motion.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const _word = "Cap Teranga";

  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  late final Animation<double> _route = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic),
  );
  late final Animation<double> _tagline = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.78, 0.95, curve: Curves.easeOut),
  );
  late final List<Animation<double>> _letters = List.generate(_word.length + 1, _letter);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotion(context)) {
      _c.value = 1;
      Future.delayed(const Duration(milliseconds: 800), _goNext);
    } else {
      _c.forward().whenComplete(() => Future.delayed(const Duration(milliseconds: 250), _goNext));
    }
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _letter(int i) {
    final start = 0.5 + i * 0.022;
    return CurvedAnimation(
      parent: _c,
      curve: Interval(start.clamp(0.0, 0.9), (start + 0.16).clamp(0.0, 1.0), curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    final letters = [..._word.split(''), '.'];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            SizedBox(
              width: 240,
              height: 300,
              child: AnimatedBuilder(
                animation: _route,
                builder: (context, _) => CustomPaint(painter: RoutePainter(progress: _route.value * 1.15, stroke: 3.5)),
              ),
            ),
            const SizedBox(height: 28),
            Hero(
              tag: "brand-wordmark",
              child: Material(
                type: MaterialType.transparency,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < letters.length; i++)
                      AnimatedBuilder(
                        animation: _letters[i],
                        builder: (context, child) {
                          final t = _letters[i].value;
                          return Opacity(
                            opacity: t.clamp(0.0, 1.0),
                            child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
                          );
                        },
                        child: Text(
                          letters[i],
                          style: AppTheme.display(
                            size: 40,
                            color: i == letters.length - 1 ? AppColors.laterite : AppColors.ink,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _tagline,
              child: const Text(
                "Dalal ak jàmm",
                style: TextStyle(color: AppColors.muted, fontSize: 15, letterSpacing: 0.4),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
