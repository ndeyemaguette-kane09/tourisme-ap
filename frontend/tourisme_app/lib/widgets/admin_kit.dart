import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'net_image.dart';

void showAdminMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

double? parseNumber(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

String numberText(double? value) {
  if (value == null || value == 0) return "";
  return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
}

Future<bool> confirmDelete(BuildContext context, String name) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text("Supprimer « $name » ?", style: AppTheme.display(size: 20, weight: FontWeight.w700)),
      content: const Text("Cette action est définitive.", style: TextStyle(color: AppColors.muted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text("Annuler", style: TextStyle(color: AppColors.ink)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text("Supprimer", style: TextStyle(color: AppColors.laterite, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class AdminField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool number;
  final int maxLines;
  final int? maxLength;

  const AdminField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.number = false,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: number ? const TextInputType.numberWithOptions(decimal: true, signed: true) : null,
            inputFormatters: number ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,-]'))] : null,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

class GpsFields extends StatelessWidget {
  final TextEditingController latitude;
  final TextEditingController longitude;

  const GpsFields({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: AdminField(label: "Latitude", controller: latitude, hint: "14.6928", number: true)),
            const SizedBox(width: 12),
            Expanded(child: AdminField(label: "Longitude", controller: longitude, hint: "-17.4467", number: true)),
          ],
        ),
        const Text(
          "Sans coordonnées, le lieu n'apparaît ni sur la carte ni dans les circuits.",
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

String? checkGps(String lat, String lng) {
  if (lat.trim().isEmpty && lng.trim().isEmpty) return null;
  final la = parseNumber(lat);
  final lo = parseNumber(lng);
  if (la == null || lo == null) return "Renseigne la latitude et la longitude, ou laisse les deux vides";
  if (la < 12 || la > 17 || lo < -18 || lo > -11) return "Ces coordonnées ne tombent pas au Sénégal";
  return null;
}

class AdminSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AdminSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.display(size: 17, weight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class AdminFormPage extends StatelessWidget {
  final String title;
  final bool saving;
  final String saveLabel;
  final VoidCallback onSave;
  final List<Widget> children;

  const AdminFormPage({
    super.key,
    required this.title,
    required this.saving,
    required this.onSave,
    required this.children,
    this.saveLabel = "Enregistrer",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: children,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: saving ? null : onSave,
            child: saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(saveLabel),
          ),
        ),
      ),
    );
  }
}

class AdminRow {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool hasGps;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const AdminRow({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.hasGps,
    required this.onEdit,
    required this.onDelete,
  });
}

class AdminListPage extends StatefulWidget {
  final String title;
  final IconData icon;
  final Future<List<AdminRow>> Function(VoidCallback refresh) load;
  final Future<void> Function() onAdd;

  const AdminListPage({
    super.key,
    required this.title,
    required this.icon,
    required this.load,
    required this.onAdd,
  });

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  late Future<List<AdminRow>> _future;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _future = widget.load(_refresh);
  }

  void _refresh() {
    setState(() => _future = widget.load(_refresh));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        onPressed: () async {
          await widget.onAdd();
          _refresh();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("Ajouter"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: "Rechercher par nom ou ville",
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AdminRow>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.laterite));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: TextButton(
                      onPressed: _refresh,
                      child: const Text("Chargement impossible, réessayer", style: TextStyle(color: AppColors.ink)),
                    ),
                  );
                }
                final rows = snapshot.data!
                    .where((r) => _query.isEmpty || "${r.title} ${r.subtitle}".toLowerCase().contains(_query))
                    .toList();
                if (rows.isEmpty) {
                  return const Center(child: Text("Aucun résultat", style: TextStyle(color: AppColors.muted)));
                }
                return RefreshIndicator(
                  color: AppColors.laterite,
                  onRefresh: () async => _refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                    itemCount: rows.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Text(
                          "${rows.length} élément${rows.length > 1 ? 's' : ''}",
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        );
                      }
                      return _tile(rows[i - 1]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(AdminRow row) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: row.onEdit,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              NetImage(url: row.imageUrl, seed: row.title, icon: widget.icon, radius: BorderRadius.circular(12), width: 64, height: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(row.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                    if (!row.hasGps)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text("Pas de coordonnées GPS",
                            style: TextStyle(color: AppColors.laterite, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Supprimer",
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
                onPressed: () async {
                  if (!await confirmDelete(context, row.title)) return;
                  try {
                    await row.onDelete();
                    if (mounted) showAdminMessage(context, "« ${row.title} » supprimé");
                  } catch (_) {
                    if (mounted) showAdminMessage(context, "Suppression impossible");
                  }
                  _refresh();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
