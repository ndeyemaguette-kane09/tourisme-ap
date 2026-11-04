import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NetImage extends StatelessWidget {
  final String? url;
  final Object? seed;
  final IconData icon;
  final BorderRadius radius;
  final double? width;
  final double? height;
  final Object? heroTag;

  const NetImage({
    super.key,
    required this.url,
    this.seed,
    this.icon = Icons.landscape_rounded,
    this.radius = BorderRadius.zero,
    this.width,
    this.height,
    this.heroTag,
  });

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.placeholderFor(seed ?? url),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;
    final image = ClipRRect(
      borderRadius: radius,
      child: hasUrl
          ? Image.network(
              url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
              frameBuilder: (context, child, frame, sync) {
                if (sync) return child;
                return Stack(
                  fit: StackFit.passthrough,
                  children: [
                    _placeholder(),
                    AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      child: child,
                    ),
                  ],
                );
              },
            )
          : _placeholder(),
    );
    if (heroTag == null) return image;
    return Hero(tag: heroTag!, child: image);
  }
}
