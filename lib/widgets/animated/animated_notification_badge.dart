import 'package:flutter/material.dart';
class SmoothNotificationBadge extends StatelessWidget {

  final int count;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? icon;
  const SmoothNotificationBadge({
    super.key,
    required this.count,
    this.backgroundColor = const Color(0xFFEF3A16),
    this.foregroundColor = Colors.white,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _buildBadge(key: ValueKey<int>(count)),
    );
  }
  Widget _buildBadge({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: 14, color: foregroundColor),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '$count',
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
