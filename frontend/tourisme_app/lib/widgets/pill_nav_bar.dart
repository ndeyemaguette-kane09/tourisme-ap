import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PillNavItem {
  final IconData icon;
  final String label;

  const PillNavItem(this.icon, this.label);
}

class PillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PillNavItem> items;

  const PillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final active = i == currentIndex;
          return Semantics(
            button: true,
            selected: active,
            label: item.label,
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12),
                decoration: BoxDecoration(
                  color: active ? AppColors.background : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 22, color: active ? AppColors.ink : Colors.white),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: active
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.ink,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
