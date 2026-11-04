import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_kit.dart';

class AccountInfoScreen extends StatefulWidget {
  final int userId;
  const AccountInfoScreen({super.key, required this.userId});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await AccountService.profile(widget.userId);
    if (!mounted) return;
    if (data != null) {
      _name.text = data["name"] ?? "";
      _email.text = data["email"] ?? "";
      _phone.text = data["phone"] ?? "";
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final email = _email.text.trim();
    if (_name.text.trim().isEmpty || !email.contains("@")) {
      showAdminMessage(context, "Nom et e-mail valides obligatoires");
      return;
    }
    setState(() => _saving = true);
    final ok = await AccountService.update(
      widget.userId,
      name: _name.text.trim(),
      email: email,
      phone: _phone.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      showAdminMessage(context, "Impossible d'enregistrer, réessaie plus tard");
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.laterite)),
      );
    }
    return AdminFormPage(
      title: "Informations personnelles",
      saving: _saving,
      onSave: _save,
      children: [
        AdminField(label: "Nom complet", controller: _name),
        AdminField(label: "E-mail", controller: _email),
        AdminField(label: "Téléphone", controller: _phone, hint: "77 000 00 00"),
        const Text(
          "Si tu changes ton e-mail, reconnecte-toi avec le nouveau.",
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      ],
    );
  }
}

class PasswordScreen extends StatefulWidget {
  final int userId;
  const PasswordScreen({super.key, required this.userId});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (_new.text.length < 6) {
      showAdminMessage(context, "Au moins 6 caractères");
      return;
    }
    if (_new.text != _confirm.text) {
      showAdminMessage(context, "Les deux mots de passe ne correspondent pas");
      return;
    }
    setState(() => _saving = true);
    final ok = await AccountService.changePassword(widget.userId, _old.text, _new.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      showAdminMessage(context, "Mot de passe actuel incorrect");
    }
  }

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(controller: c, obscureText: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormPage(
      title: "Mot de passe",
      saving: _saving,
      onSave: _save,
      saveLabel: "Mettre à jour",
      children: [
        _field("Mot de passe actuel", _old),
        _field("Nouveau mot de passe", _new),
        _field("Confirmer", _confirm),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(fontSize: 15, height: 1.5, color: AppColors.ink);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("À propos")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text("Cap Teranga", style: AppTheme.display(size: 34)),
          const SizedBox(height: 4),
          const Text("Version 1.0", style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          const Text(
            "Cap Teranga aide à préparer un voyage au Sénégal : plages, hôtels, restaurants, sites historiques, "
            "circuits sur plusieurs jours et calendrier des grands rendez-vous religieux.",
            style: body,
          ),
          const SizedBox(height: 16),
          const Text(
            "Les paiements affichés dans l'application sont fictifs : aucune somme n'est débitée.",
            style: body,
          ),
          const SizedBox(height: 28),
          Text("Photos", style: AppTheme.display(size: 18, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            "Les photos des sites proviennent de Wikimedia Commons, sous licences libres "
            "(CC BY, CC BY-SA). Les auteurs sont crédités dans le README du projet.",
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Text("Dates des fêtes", style: AppTheme.display(size: 18, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            "Les dates religieuses suivent le calendrier lunaire. Celles marquées « estimée » "
            "peuvent bouger d'un ou deux jours selon l'observation du croissant.",
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
