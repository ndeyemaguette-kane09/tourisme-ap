import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/motion.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _done = false;
  final _shakeKey = GlobalKey<ShakeState>();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    setState(() => _isLoading = true);

    String? token = await authService.login(
      emailController.text,
      passwordController.text,
    );

    setState(() => _isLoading = false);

    if (token != null && mounted) {
      setState(() => _done = true);
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      // Si ADMIN → dashboard admin
      if (authService.role == "ADMIN") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(
              token: authService.token!,
            ),
          ),
        );
      } else {
        // Utilisateur normal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              token: authService.token!,
              userId: authService.userId!,
              userName: authService.userName ?? "",
            ),
          ),
        );
      }
    } else if (mounted) {
      _shakeKey.currentState?.shake();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Email ou mot de passe incorrect"),
          backgroundColor: const Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      const Text("E-mail", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 6),
      TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: const InputDecoration(hintText: "awa@exemple.sn"),
      ),
      const SizedBox(height: 16),
      const Text("Mot de passe", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 6),
      TextField(
        controller: passwordController,
        obscureText: _obscurePassword,
        autofillHints: const [AutofillHints.password],
        onSubmitted: (_) => login(),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            tooltip: _obscurePassword ? "Afficher le mot de passe" : "Masquer le mot de passe",
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                key: ValueKey(_obscurePassword),
                color: AppColors.muted,
              ),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackdrop()),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 190, 24, 24),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Hero(
                        tag: "brand-wordmark",
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text.rich(
                            TextSpan(
                              text: "Cap Teranga",
                              style: AppTheme.display(size: 40),
                              children: [TextSpan(text: ".", style: AppTheme.display(size: 40, color: AppColors.laterite))],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 250),
                      child: Text(
                        "Dalal ak jàmm. Ton carnet de route pour découvrir le Sénégal.",
                        style: AppTheme.display(size: 19, weight: FontWeight.w500, color: const Color(0xFF3A3F48)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Shake(
                      key: _shakeKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < fields.length; i++)
                            FadeSlideIn(index: i, delay: const Duration(milliseconds: 350), child: fields[i]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 750),
                      child: MorphButton(
                        label: "Se connecter",
                        phase: _done ? ButtonPhase.done : (_isLoading ? ButtonPhase.loading : ButtonPhase.idle),
                        onPressed: login,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 850),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Pas encore de compte ?"),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupScreen()),
                            ),
                            child: const Text(
                              "Créer un compte",
                              style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
