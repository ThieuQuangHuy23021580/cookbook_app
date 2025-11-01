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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
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
                const Text(
                  'Bộ lọc tìm kiếm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Include section
                  _buildFilterSection(
                    title: 'Hiển thị các món với:',
                    subtitle: 'Tìm kiếm các món có chứa từ khóa này',
                    controller: _includeController,
                    icon: Icons.add_circle_outline,
                    hintText: 'Ví dụ: thịt bò, rau cải...',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Exclude section
                  _buildFilterSection(
                    title: 'Hiển thị các món không có:',
                    subtitle: 'Loại bỏ các món có chứa từ khóa này',
                    controller: _excludeController,
                    icon: Icons.remove_circle_outline,
                    hintText: 'Ví dụ: cay, ngọt...',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Quick filters
                  const Text(
                    'Bộ lọc nhanh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickFilterChip('Món chay', Icons.eco),
                      _buildQuickFilterChip('Món cay', Icons.local_fire_department),
                      _buildQuickFilterChip('Món ngọt', Icons.cake),
                      _buildQuickFilterChip('Món mặn', Icons.restaurant),
                      _buildQuickFilterChip('Dễ làm', Icons.speed),
                      _buildQuickFilterChip('Nhanh gọn', Icons.timer),
                    ],
                  ),
                  
                  // Add some bottom padding to prevent content from being cut off
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Bottom buttons
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Reset button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _includeController.clear();
                      _excludeController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Đặt lại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Apply button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      // Parse include ingredients (split by comma)
                      List<String>? includeIngredients;
                      final includeText = _includeController.text.trim();
                      if (includeText.isNotEmpty) {
                        includeIngredients = includeText
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                      }

                      // Parse exclude ingredients (split by comma)
                      List<String>? excludeIngredients;
                      final excludeText = _excludeController.text.trim();
                      if (excludeText.isNotEmpty) {
                        excludeIngredients = excludeText
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                      }

                      final hasTitleQuery = widget.initialQuery.trim().isNotEmpty;
                      final hasIncludeFilters = includeIngredients != null && includeIngredients.isNotEmpty;
                      final hasExcludeFilters = excludeIngredients != null && excludeIngredients.isNotEmpty;
                      final hasAnyFilter = hasTitleQuery || hasIncludeFilters || hasExcludeFilters;

                      if (!hasAnyFilter) {
                        // Show error if no filter is applied
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập từ khóa hoặc nguyên liệu để tìm kiếm'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      print('🔍 [FILTER] Applying filter:');
                      print('   Title: ${widget.initialQuery.trim().isNotEmpty ? widget.initialQuery.trim() : "None"}');
                      print('   Include: $includeIngredients');
                      print('   Exclude: $excludeIngredients');

                      // Close bottom sheet first, then call callback
                      Navigator.pop(context);
                      
                      // Call callback after closing bottom sheet
                      // Use Future.microtask to ensure Navigator.pop completes first
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
    required String subtitle,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () => controller.clear(),
                      child: const Icon(
                        Icons.clear,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                    )
                  : null,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Add to include filter
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
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
