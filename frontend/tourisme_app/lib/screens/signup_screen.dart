import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/motion.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  bool _done = false;
  final _shakeKey = GlobalKey<ShakeState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signup() async {
    if (passwordController.text != confirmPasswordController.text) {
      _shakeKey.currentState?.shake();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Les mots de passe ne correspondent pas"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    bool success = await authService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (success && mounted) {
      setState(() => _done = true);
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Compte créé avec succès. Bienvenue !"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      _shakeKey.currentState?.shake();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Erreur lors de l'inscription"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      _label("Nom complet"),
      TextField(
        controller: nameController,
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.name],
        decoration: const InputDecoration(hintText: "Awa Diop"),
      ),
      const SizedBox(height: 16),
      _label("E-mail"),
      TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: const InputDecoration(hintText: "awa@exemple.sn"),
      ),
      const SizedBox(height: 16),
      _label("Mot de passe"),
      TextField(
        controller: passwordController,
        obscureText: _obscurePassword,
        autofillHints: const [AutofillHints.newPassword],
        decoration: InputDecoration(
          suffixIcon: _eye(_obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
        ),
      ),
      PasswordStrength(controller: passwordController),
      const SizedBox(height: 16),
      _label("Confirme le mot de passe"),
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: confirmPasswordController,
        builder: (context, value, _) {
          final matches = value.text.isNotEmpty && value.text == passwordController.text;
          return TextField(
            controller: confirmPasswordController,
            obscureText: _obscureConfirm,
            onSubmitted: (_) => signup(),
            decoration: InputDecoration(
              prefixIcon: AnimatedScale(
                scale: matches ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF5E7D5A)),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: matches ? 44 : 12),
              suffixIcon: _eye(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackdrop()),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 120, 24, 32),
                  children: [
                    FadeSlideIn(child: Text("Crée ton compte", style: AppTheme.display(size: 34))),
                    const SizedBox(height: 8),
                    const FadeSlideIn(
                      index: 1,
                      child: Text(
                        "Garde tes favoris, prépare tes circuits et réserve tes nuits au même endroit.",
                        style: TextStyle(color: AppColors.muted, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Shake(
                      key: _shakeKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < fields.length; i++)
                            FadeSlideIn(index: i, step: const Duration(milliseconds: 45), delay: const Duration(milliseconds: 200), child: fields[i]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 700),
                      child: MorphButton(
                        label: "Créer mon compte",
                        phase: _done ? ButtonPhase.done : (isLoading ? ButtonPhase.loading : ButtonPhase.idle),
                        onPressed: signup,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 800),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Déjà inscrit ?"),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Se connecter",
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }

  Widget _eye(bool hidden, VoidCallback onTap) {
    return IconButton(
      tooltip: hidden ? "Afficher le mot de passe" : "Masquer le mot de passe",
      icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.muted),
      onPressed: onTap,
    );
  }
}
