import 'package:flutter/material.dart';
class FilterBottomSheet extends StatefulWidget {

  final String initialQuery;
  final Function(String? titleQuery, List<String>? includeIngredients, List<String>? excludeIngredients) onApplyFilter;
  const FilterBottomSheet({
    super.key,
    required this.initialQuery,
    required this.onApplyFilter,
  });
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {

  final TextEditingController _includeController = TextEditingController();
  final TextEditingController _excludeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _includeController.text = widget.initialQuery;
  }

  @override
  void dispose() {
    _includeController.dispose();
    _excludeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: isDark ? Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 2.0,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.tune,
                  color: Color(0xFFEF3A16),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Bộ lọc tìm kiếm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: isDark ? Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 2.0,
                      ) : null,
                      boxShadow: isDark ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      Icons.close,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    title: 'Hiển thị các món với:',
                    controller: _includeController,
                    icon: Icons.add_circle_outline,
                    hintText: 'Ví dụ: thịt bò, hành tây, rau cải',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'Hiển thị các món không có:',
                    controller: _excludeController,
                    icon: Icons.remove_circle_outline,
                    hintText: 'Ví dụ: tôm, cua, hải sản',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Bộ lọc nhanh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickFilterChip('Món chay', Icons.eco, isDark),
                      _buildQuickFilterChip('Món cay', Icons.local_fire_department, isDark),
                      _buildQuickFilterChip('Món ngọt', Icons.cake, isDark),
                      _buildQuickFilterChip('Món mặn', Icons.restaurant, isDark),
                      _buildQuickFilterChip('Dễ làm', Icons.speed, isDark),
                      _buildQuickFilterChip('Nhanh gọn', Icons.timer, isDark),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[200]!,
                  width: isDark ? 2.0 : 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _includeController.clear();
                      _excludeController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
                          width: isDark ? 2.0 : 1,
                        ),
                        boxShadow: isDark ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: Text(
                          'Đặt lại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      List<String>? includeIngredients;
                      final includeText = _includeController.text.trim();
                      if (includeText.isNotEmpty) {
                        includeIngredients = includeText
                            .split(RegExp(r'[,，\n]'))
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                      }
                      List<String>? excludeIngredients;
                      final excludeText = _excludeController.text.trim();
                      if (excludeText.isNotEmpty) {
                        excludeIngredients = excludeText
                            .split(RegExp(r'[,，\n]'))
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                      }
                      print(' [FILTER] Parsed ingredients:');
                      print('   Include (${includeIngredients?.length ?? 0}): $includeIngredients');
                      print('   Exclude (${excludeIngredients?.length ?? 0}): $excludeIngredients');
                      final hasTitleQuery = widget.initialQuery.trim().isNotEmpty;
                      final hasIncludeFilters = includeIngredients != null && includeIngredients.isNotEmpty;
                      final hasExcludeFilters = excludeIngredients != null && excludeIngredients.isNotEmpty;
                      final hasAnyFilter = hasTitleQuery || hasIncludeFilters || hasExcludeFilters;
                      if (!hasAnyFilter) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập từ khóa hoặc nguyên liệu để tìm kiếm'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      print(' [FILTER] Applying filter:');
                      print('   Title: ${widget.initialQuery.trim().isNotEmpty ? widget.initialQuery.trim() : "None"}');
                      print('   Include: $includeIngredients');
                      print('   Exclude: $excludeIngredients');
                      Navigator.pop(context);
                      Future.microtask(() {
                        widget.onApplyFilter(
                          widget.initialQuery.trim().isNotEmpty ? widget.initialQuery.trim() : null,
                          includeIngredients?.isNotEmpty == true ? includeIngredients : null,
                          excludeIngredients?.isNotEmpty == true ? excludeIngredients : null,
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFEF3A16),
                            Color(0xFFFF5A00),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF3A16).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Áp dụng bộ lọc',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterSection({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFEF3A16),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
              width: isDark ? 2.0 : 1,
            ),
            boxShadow: isDark ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ] : null,
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[600] : const Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        controller.clear();
                        setState(() {});
                      },
                      child: Icon(
                        Icons.clear,
                        color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                    )
                  : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }
  Widget _buildQuickFilterChip(String label, IconData icon, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (_includeController.text.isEmpty) {
          _includeController.text = label;
        } else {
          _includeController.text = '${_includeController.text}, $label';
        }
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
            width: isDark ? 2.0 : 1,
          ),
          boxShadow: isDark ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 0),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
