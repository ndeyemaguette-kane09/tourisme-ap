import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/restaurant.dart';
import '../../services/restaurant_service.dart';

class EditRestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;
  final String token;

  const EditRestaurantScreen({
    super.key,
    required this.restaurant,
    required this.token,
  });

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ── LOGIQUE INCHANGÉE ──
  late TextEditingController nameController;
  late TextEditingController cityController;
  late TextEditingController imageController;
  late TextEditingController ratingController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;

  bool isLoading = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // ── Palette Teranga ──
  static const Color _orange = Color(0xFFE64A19);
  static const Color _orangeDark = Color(0xFFBF360C);
  static const Color _orangeLight = Color(0xFFF57C00);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _amber = Color(0xFFFFF3E0);

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.restaurant.name);
    cityController = TextEditingController(text: widget.restaurant.city ?? "");
    imageController = TextEditingController(text: widget.restaurant.imageUrl ?? '');
    ratingController = TextEditingController(text: widget.restaurant.rating?.toString() ?? "0");
    descriptionController = TextEditingController(text: widget.restaurant.description ?? "");
    addressController = TextEditingController(text: widget.restaurant.address ?? "");

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    imageController.dispose();
    ratingController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── LOGIQUE INCHANGÉE ──
  Future<void> _updateRestaurant() async {
    setState(() => isLoading = true);

    try {
      await RestaurantService().updateRestaurant(
        widget.restaurant.id,
        {
          "name": nameController.text,
          "city": cityController.text,
          "cityName": cityController.text,
          "imageUrl": imageController.text,
          "description": descriptionController.text,
          "address": addressController.text,
          "rating": double.tryParse(ratingController.text.replaceAll(',', '.')) ?? 0,
        },
        widget.token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Restaurant modifié avec succès"),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Erreur lors de la modification"),
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _cream,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── HEADER GRADIENT ──
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: size.height * 0.22,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_orangeDark, _orange, _orangeLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // ── CERCLES DÉCORATIFS ──
            Positioned(
              top: -30, right: -40,
              child: Container(width: 160, height: 160,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07))),
            ),
            Positioned(
              top: 30, right: 40,
              child: Container(width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07))),
            ),

            // ── ARRONDI CRÈME ──
            Positioned(
              top: size.height * 0.19, left: 0, right: 0,
              child: Container(height: 36,
                decoration: const BoxDecoration(color: _cream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)))),
            ),

            // ── CONTENU ──
            SafeArea(
              child: Column(
                children: [
                  // ── TITRE HEADER ──
                  SizedBox(
                    height: size.height * 0.14,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Modifier", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5)),
                                Text("le restaurant", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5)),
                                SizedBox(height: 5),
                                Text("Mettez à jour les informations", style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                            ),
                            child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── FORMULAIRE ──
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                        children: [
                          _buildImagePreview(),
                          const SizedBox(height: 24),

                          _buildSectionTitle(Icons.info_outline_rounded, "Informations"),
                          const SizedBox(height: 14),

                          _buildField(
                            label: "Nom du restaurant",
                            controller: nameController,
                            icon: Icons.restaurant_rounded,
                            hint: "Ex: Chez Loutcha",
                          ),

                          _buildDropdownCity(),
                          const SizedBox(height: 12),

                          _buildField(
                            label: "Adresse",
                            controller: addressController,
                            icon: Icons.location_on_rounded,
                            hint: "Ex: Corniche des Almadies",
                          ),
                          const SizedBox(height: 12),

                          _buildSectionTitle(Icons.description_rounded, "Description"),
                          const SizedBox(height: 14),

                          _buildField(
                            label: "Description",
                            controller: descriptionController,
                            icon: Icons.edit_note_rounded,
                            hint: "Décrivez ce restaurant...",
                            maxLines: 4,
                          ),

                          const SizedBox(height: 24),
                          _buildSectionTitle(Icons.star_rounded, "Note"),
                          const SizedBox(height: 14),

                          _buildField(
                            label: "Note (ex: 4.5)",
                            controller: ratingController,
                            icon: Icons.star_half_rounded,
                            hint: "Entre 0 et 5",
                            isNumber: true,
                          ),

                          const SizedBox(height: 24),
                          _buildSectionTitle(Icons.image_rounded, "Média"),
                          const SizedBox(height: 14),

                          _buildField(
                            label: "URL de l'image",
                            controller: imageController,
                            icon: Icons.link_rounded,
                            hint: "https://...",
                            onChanged: (_) => setState(() {}),
                          ),

                          const SizedBox(height: 28),
                          Row(children: [
                            Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.restaurant_rounded, color: Colors.grey.shade300, size: 16),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                          ]),
                          const SizedBox(height: 20),
                          const Center(
                            child: Text("Teranga • Culture • Découverte",
                              style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── BOUTON CTA FIXE ──
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: _cream,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -6))],
                ),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_orangeDark, _orange, _orangeLight], begin: Alignment.centerLeft, end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: _orange.withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: isLoading ? null : _updateRestaurant,
                      child: Center(
                        child: isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text("Enregistrer les modifications",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final url = imageController.text.trim();
    if (url.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 160, width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _amber,
                child: const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 40)))),
            DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter))),
            Positioned(bottom: 12, left: 14,
              child: Text(nameController.text.isNotEmpty ? nameController.text : "Aperçu",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(width: 3, height: 18, decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Icon(icon, color: _orange, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A), letterSpacing: 0.1)),
      ],
    );
  }

  Widget _buildDropdownCity() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: cityController.text.isNotEmpty ? cityController.text : null,
        items: const [
          DropdownMenuItem(value: "Dakar", child: Text("Dakar")),
          DropdownMenuItem(value: "Thiès", child: Text("Thiès")),
          DropdownMenuItem(value: "Saint-Louis", child: Text("Saint-Louis")),
          DropdownMenuItem(value: "Diourbel", child: Text("Diourbel")),
          DropdownMenuItem(value: "Fatick", child: Text("Fatick")),
          DropdownMenuItem(value: "Kaolack", child: Text("Kaolack")),
          DropdownMenuItem(value: "Kaffrine", child: Text("Kaffrine")),
          DropdownMenuItem(value: "Kolda", child: Text("Kolda")),
          DropdownMenuItem(value: "Louga", child: Text("Louga")),
          DropdownMenuItem(value: "Matam", child: Text("Matam")),
          DropdownMenuItem(value: "Sédhiou", child: Text("Sédhiou")),
          DropdownMenuItem(value: "Tambacounda", child: Text("Tambacounda")),
          DropdownMenuItem(value: "Kédougou", child: Text("Kédougou")),
          DropdownMenuItem(value: "Ziguinchor", child: Text("Ziguinchor")),
        ],
        onChanged: (value) {
          if (value != null) setState(() => cityController.text = value);
        },
        decoration: InputDecoration(
          labelText: "Ville",
          prefixIcon: Icon(Icons.location_city_rounded, color: _orange, size: 20),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _orange, width: 1.8)),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool isNumber = false,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        maxLines: maxLines,
        onChanged: onChanged,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))] : null,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: _orange, size: 20),
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.5),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _orange, width: 1.8)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade300, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade400, width: 1.8)),
        ),
      ),
    );
  }
}