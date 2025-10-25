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
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: hint),
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Color(0xFF64748B),
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


