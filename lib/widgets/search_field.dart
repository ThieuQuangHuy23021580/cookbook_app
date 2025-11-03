import 'package:flutter/material.dart';
class SearchField extends StatelessWidget {

  final String hint;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterPressed;
  const SearchField({
    super.key,
    this.hint = 'Tìm món, nguyên liệu...',
    this.onSubmitted,
    this.onFilterPressed,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.15), width: 2.0) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
            ),
          ),
          if (onFilterPressed != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onFilterPressed,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.tune,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
