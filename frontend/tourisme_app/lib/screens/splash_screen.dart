import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/motion.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _word = "Cap Teranga";

  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
  late final Animation<double> _sail = CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.71, curve: Curves.easeOutCubic));
  late final Animation<double> _sun = CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.79, curve: Curves.easeOutCubic));
  late final Animation<double> _tagline = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.85, 0.98, curve: Curves.easeOut),
  );
  final _time = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker((elapsed) => _time.value = elapsed.inMicroseconds / 1e6);
  late final List<Animation<double>> _letters = List.generate(_word.length + 1, _letter);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotion(context)) {
      _c.value = 1;
      _time.value = 2;
      Future.delayed(const Duration(milliseconds: 800), _goNext);
    } else {
      _ticker.start();
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
    _ticker.dispose();
    _time.dispose();
    _c.dispose();
    super.dispose();
  }

  Animation<double> _letter(int i) {
    final start = 0.6 + i * 0.02;
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
            ClipRect(
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).width * PiroguePainter.sceneHeight / 240,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_c, _time]),
                  builder: (context, _) => CustomPaint(
                    painter: PiroguePainter(sail: _sail.value, sun: _sun.value, time: _time.value),
                  ),
                ),
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
