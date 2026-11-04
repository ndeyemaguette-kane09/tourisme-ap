import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NetImage extends StatelessWidget {
  final String? url;
  final Object? seed;
  final IconData icon;
  final BorderRadius radius;
  final double? width;
  final double? height;

  const NetImage({
    super.key,
    required this.url,
    this.seed,
    this.icon = Icons.landscape_rounded,
    this.radius = BorderRadius.zero,
    this.width,
    this.height,
  });

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.placeholderFor(seed ?? url),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white.withOpacity(0.85), size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: radius,
      child: hasUrl
          ? Image.network(
              url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _placeholder(),
            )
          : _placeholder(),
    );
  }
}
