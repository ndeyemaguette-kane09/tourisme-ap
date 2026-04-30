import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddHotelScreen extends StatefulWidget {
  final String token;
  const AddHotelScreen({super.key, required this.token});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final ratingController = TextEditingController();
  final imageController = TextEditingController();
  final descriptionController = TextEditingController();

  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    cityController.dispose();
    addressController.dispose();
    priceController.dispose();
    ratingController.dispose();
    imageController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void addHotel() async {
    if (nameController.text.isEmpty ||
        cityController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Veuillez remplir les champs obligatoires"),
          backgroundColor: const Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.addHotel(widget.token, {
        "name": nameController.text,
        "city": cityController.text,
        "address": addressController.text,
        "price": double.parse(priceController.text),
        "rating": double.tryParse(ratingController.text.replaceAll(',', '.')) ?? 0.0,
        "imageUrl": imageController.text,
        "description": descriptionController.text.length > 200
            ? descriptionController.text.substring(0, 200)
            : descriptionController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("🏨 Hôtel ajouté avec succès !"),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Erreur lors de l'ajout de l'hôtel"),
            backgroundColor: const Color(0xFFB71C1C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Stack(
        children: [
          // ── Cercles déco ──
          Positioned(
            top: -50,
            right: -50,
            child: _decorCircle(180, Colors.orange.withOpacity(0.06)),
          ),
          Positioned(
            bottom: 100,
            left: -40,
            child: _decorCircle(140, Colors.deepOrange.withOpacity(0.05)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Header ──
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFBF360C),
                            Color(0xFFE64A19),
                            Color(0xFFF57C00),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                                painter: _AfricanPatternPainter()),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Ajouter un hôtel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Text(
                                    "Remplissez les informations",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Formulaire ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section : Informations générales
                          _sectionTitle("Informations générales"),
                          const SizedBox(height: 14),

                          _buildCard(children: [
                            _buildField(
                              controller: nameController,
                              label: "Nom de l'hôtel *",
                              hint: "Ex: Hôtel Terrou-Bi",
                              icon: Icons.hotel,
                            ),
                            _divider(),
                            _buildField(
                              controller: cityController,
                              label: "Ville *",
                              hint: "Ex: Dakar",
                              icon: Icons.location_city,
                            ),
                            _divider(),
                            _buildField(
                              controller: addressController,
                              label: "Adresse",
                              hint: "Ex: Boulevard de la Corniche",
                              icon: Icons.place_outlined,
                            ),
                          ]),

                          const SizedBox(height: 24),

                          // Section : Tarif & Note
                          _sectionTitle("Tarif & Évaluation"),
                          const SizedBox(height: 14),

                          _buildCard(children: [
                            _buildField(
                              controller: priceController,
                              label: "Prix par nuit (FCFA) *",
                              hint: "Ex: 45000",
                              icon: Icons.payments_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            _divider(),
                            _buildField(
                              controller: ratingController,
                              label: "Note (0 - 5)",
                              hint: "Ex: 4.5",
                              icon: Icons.star_outline,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ]),

                          const SizedBox(height: 24),

                          // Section : Médias
                          _sectionTitle("Image & Description"),
                          const SizedBox(height: 14),

                          _buildCard(children: [
                            _buildField(
                              controller: imageController,
                              label: "URL de l'image",
                              hint: "https://...",
                              icon: Icons.image_outlined,
                              keyboardType: TextInputType.url,
                            ),
                            _divider(),
                            _buildField(
                              controller: descriptionController,
                              label: "Description",
                              hint: "Décrivez cet hôtel...",
                              icon: Icons.description_outlined,
                              maxLines: 4,
                            ),
                          ]),

                          const SizedBox(height: 32),

                          // ── Bouton ajouter ──
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : addHotel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFBF360C),
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shadowColor:
                                    const Color(0xFFBF360C).withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_circle_outline,
                                            size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          "Ajouter l'hôtel",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Center(
                            child: Text(
                              "🇸🇳  Teranga • Culture • Découverte",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
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

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFE64A19),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4E1B00),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, color: Color(0xFF2D1200)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4E1B00),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon:
              Icon(icon, color: const Color(0xFFE64A19), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xFFFFCCBC).withOpacity(0.5),
      indent: 52,
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _AfricanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const spacing = 55.0;
    const diagSize = 14.0;
    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = 0; x < size.width + spacing; x += spacing) {
        final path = Path();
        path.moveTo(x, y - diagSize);
        path.lineTo(x + diagSize, y);
        path.lineTo(x, y + diagSize);
        path.lineTo(x - diagSize, y);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_AfricanPatternPainter old) => false;
}