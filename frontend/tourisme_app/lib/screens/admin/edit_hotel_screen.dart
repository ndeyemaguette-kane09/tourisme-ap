import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/hotel.dart';
import '../../services/hotel_service.dart';

class EditHotelScreen extends StatefulWidget {
  final Hotel hotel;
  final String token;

  const EditHotelScreen({
    super.key,
    required this.hotel,
    required this.token,
  });

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ── LOGIQUE INCHANGÉE ──
  late TextEditingController nameController;
  late TextEditingController cityController;
  late TextEditingController priceController;
  late TextEditingController imageController;
  late TextEditingController ratingController;
  late TextEditingController descriptionController;

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

    nameController = TextEditingController(text: widget.hotel.name);
    cityController = TextEditingController(text: widget.hotel.city ?? "");
    priceController =
        TextEditingController(text: widget.hotel.price.toString());
    imageController =
        TextEditingController(text: widget.hotel.imageUrl ?? '');
    ratingController = TextEditingController(
      text: widget.hotel.rating != null ? widget.hotel.rating.toString() : "0",
    );
    descriptionController =
        TextEditingController(text: widget.hotel.description ?? "");

    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    priceController.dispose();
    imageController.dispose();
    ratingController.dispose();
    descriptionController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── LOGIQUE INCHANGÉE ──
  Future<void> _updateHotel() async {
    // if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await HotelService().updateHotel(
        widget.hotel.id,
        {
          "name": nameController.text,
          "city": cityController.text,
          "cityName": cityController.text,
          "imageUrl": imageController.text,
          "description": descriptionController.text,
          "price": double.tryParse(

          priceController.text.replaceAll(',', '.'),

        ) ??
        0,
        "rating": double.tryParse(

          ratingController.text.replaceAll(',', '.'),

        ) ??
        0,
        },
        widget.token,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Hôtel modifié avec succès"),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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
              top: 0,
              left: 0,
              right: 0,
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
              top: -30,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // ── ARRONDI CRÈME ──
            Positioned(
              top: size.height * 0.19,
              left: 0,
              right: 0,
              child: Container(
                height: 36,
                decoration: const BoxDecoration(
                  color: _cream,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(36)),
                ),
              ),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Modifier",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  "l'hôtel",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Mettez à jour les informations",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1),
                            ),
                            child: const Icon(Icons.hotel_rounded,
                                color: Colors.white, size: 20),
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
                        padding:
                            const EdgeInsets.fromLTRB(24, 8, 24, 120),
                        children: [
                          // Aperçu image si URL renseignée
                          _buildImagePreview(),
                          const SizedBox(height: 24),

                          _buildSectionTitle(
                              Icons.info_outline_rounded, "Informations"),
                          const SizedBox(height: 14),

                          _buildField(
                            label: "Nom de l'hôtel",
                            controller: nameController,
                            icon: Icons.hotel_rounded,
                            hint: "Ex: Hôtel Terrou-Bi",
                          ),
                          Padding(
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
      if (value != null) {
        setState(() {
          cityController.text = value;
        });
      }
    },
    decoration: InputDecoration(
      labelText: "Ville",
      prefixIcon: Icon(Icons.location_city_rounded, color: _orange),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _orange, width: 1.8),
      ),
    ),
  ),
),
                          _buildField(
                            label: "Description",
                            controller: descriptionController,
                            icon: Icons.description_rounded,
                            hint: "Décrivez l'hôtel...",
                            maxLines: 4,
                          ),
                          

                          const SizedBox(height: 24),

                          _buildSectionTitle(
                              Icons.payments_rounded, "Tarification"),
                          const SizedBox(height: 14),

                          _buildField(
                            label: "Rating",
                            controller: ratingController,
                            icon: Icons.star,
                            hint: "Ex: 4.5",
                            isNumber: true,
                          ),

                          _buildField(
                            label: "Prix par nuit (FCFA)",
                            controller: priceController,
                            icon: Icons.paid_rounded,
                            hint: "Ex: 25000",
                            isNumber: true,
                          ),

                          const SizedBox(height: 24),

                          _buildSectionTitle(
                              Icons.image_rounded, "Média"),
                          const SizedBox(height: 14),

                          _buildField(
                            label: "URL de l'image",
                            controller: imageController,
                            icon: Icons.link_rounded,
                            hint: "https://...",
                            onChanged: (_) => setState(() {}),
                          ),

                          const SizedBox(height: 28),

                          // Divider déco
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      color: Colors.grey.shade200,
                                      thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Icon(Icons.hotel_rounded,
                                    color: Colors.grey.shade300,
                                    size: 16),
                              ),
                              Expanded(
                                  child: Divider(
                                      color: Colors.grey.shade200,
                                      thickness: 1)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Center(
                            child: Text(
                              "Teranga • Culture • Découverte",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: _cream,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: isLoading
                ? null
                : () {
                    _updateHotel();
                  },
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Enregistrer les modifications",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── APERÇU IMAGE ──
  Widget _buildImagePreview() {
    final url = imageController.text.trim();
    if (url.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _amber,
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.grey, size: 40),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 14,
              child: Text(
                nameController.text.isNotEmpty
                    ? nameController.text
                    : "Aperçu",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TITRE DE SECTION ──
  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _orange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: _orange, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  // ── CHAMP DE SAISIE ──
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
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
            maxLines: maxLines,
        onChanged: onChanged,
        inputFormatters: isNumber
    ? [
        FilteringTextInputFormatter.allow(
          RegExp(r'[0-9\.,]'),
        ),
      ]
    : null,
        validator: (value) {
          // 🔥 allow empty image URL
          if (label == "URL de l'image") return null;
          return value == null || value.isEmpty
              ? "Ce champ est requis"
              : null;
        },
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: _orange, size: 20),
          labelStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13.5,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13.5,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _orange, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: Colors.red.shade300, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Colors.red.shade400, width: 1.8),
          ),
        ),
      ),
    );
  }
}