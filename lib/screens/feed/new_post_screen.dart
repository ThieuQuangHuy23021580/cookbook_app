import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/post_model.dart';
import '../profile/user_profile_screen.dart';
import 'post_detail_screen.dart';
class NewPostScreen extends StatefulWidget {

  const NewPostScreen({super.key});
  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final List<TextEditingController> _ingredientNameCtrls = List.generate(1, (_) => TextEditingController());
  final List<TextEditingController> _ingredientQuantityCtrls = List.generate(1, (_) => TextEditingController()..text = '0');
  final List<TextEditingController> _ingredientUnitCtrls = List.generate(1, (_) => TextEditingController()..text = 'cái');
  final List<TextEditingController> _stepTitleCtrls = List.generate(1, (_) => TextEditingController());
  final List<File> _images = [];
  final List<List<File>> _stepImages = List.generate(1, (_) => []);
  final ImagePicker _picker = ImagePicker();
  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _ingredientNameCtrls) c.dispose();
    for (final c in _ingredientQuantityCtrls) c.dispose();
    for (final c in _ingredientUnitCtrls) c.dispose();
    for (final c in _stepTitleCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Chọn nguồn ảnh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFEF3A16)),
                title: const Text('Thư viện ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFEF3A16)),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Lỗi mở chọn ảnh: $e');
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
        _showSuccessSnackBar('Đã thêm ảnh thành công');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi chọn ảnh: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFEF3A16).withOpacity(0.9),
                const Color(0xFFFF5A00).withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: AppBar(
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: Text(
                "Đăng món mới",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF000000),
                        const Color(0xFF0A0A0A),
                        const Color(0xFF0F0F0F),
                      ]
                    : [
                        const Color(0xFFFAFAFA),
                        const Color(0xFFF8FAFC),
                        const Color(0xFFF1F5F9),
                      ],
              ),
            ),
          ),
          ...List.generate(8, (index) =>
            Positioned(
              top: (index * 80.0) % MediaQuery.of(context).size.height,
              left: (index * 100.0) % MediaQuery.of(context).size.width,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 3000 + (index * 200)),
                curve: Curves.easeInOut,
                width: 6 + (index % 3) * 2,
                height: 6 + (index % 3) * 2,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFEF3A16).withOpacity(0.15)
                      : const Color(0xFFFF6B35).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imagePickerSection(),
                  const SizedBox(height: 20),
                  _buildNeumorphicField(
                    controller: _titleCtrl,
                    labelText: 'Tên món',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildNeumorphicField(
                    controller: _descCtrl,
                    labelText: 'Mô tả',
                    maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                      'Nguyên liệu',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                        letterSpacing: -0.3,
                      ),
                  ),
                  const SizedBox(height: 12),
                  ..._ingredientNameCtrls.asMap().entries.map((e) => _buildIngredientField(
                    index: e.key,
                    nameController: e.value,
                    quantityController: _ingredientQuantityCtrls[e.key],
                    unitController: _ingredientUnitCtrls[e.key],
                    onRemove: _ingredientNameCtrls.length > 1 ? () => _removeIngredient(e.key) : null,
                  )),
                  _buildAddButton(
                    text: 'Thêm nguyên liệu',
                    onPressed: () => _addIngredient(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                      'Các bước thực hiện',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                        letterSpacing: -0.3,
                      ),
                  ),
                  const SizedBox(height: 12),
                  ..._stepTitleCtrls.asMap().entries.map((e) => _buildStepField(
                    index: e.key,
                    titleController: e.value,
                    images: _stepImages[e.key],
                    onRemove: _stepTitleCtrls.length > 1 ? () => _removeStep(e.key) : null,
                    onAddImage: () => _pickStepImage(e.key),
                    onRemoveImage: (imageIndex) => _removeStepImage(e.key, imageIndex),
                  )),
                  _buildAddButton(
                    text: 'Thêm bước',
                    onPressed: () => _addStep(),
                  ),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _imagePickerSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
          width: isDark ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              spreadRadius: 3,
              blurRadius: 15,
              offset: const Offset(0, 0),
            ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
          if (!isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hình ảnh',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    letterSpacing: -0.3,
                  ),
                ),
                _buildNeumorphicButton(
                  text: 'Thêm ảnh',
                  icon: Icons.add_photo_alternate,
                  onPressed: _pickImage,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_images.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
                    width: isDark ? 2.0 : 2,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: isDark ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ] : [
                    BoxShadow(
                      color: const Color(0xFF64748B).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 8,
                      offset: const Offset(-4, -4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa có ảnh',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) => _buildImageCard(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildImageCard(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 140,
      height: 110,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE2E8F0),
          width: isDark ? 2.0 : 2,
        ),
        boxShadow: isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            spreadRadius: 3,
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
        ] : [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              _images[index],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.image,
                  color: Color(0xFF64748B),
                  size: 36,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _images.removeAt(index)),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEF3A16),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F0F0F).withOpacity(0.8)
            : const Color(0xFFEF3A16).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.15)
              : const Color(0xFFEF3A16).withOpacity(0.2),
          width: isDark ? 2.0 : 1.0,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: isDark ? Colors.white : const Color(0xFFEF3A16),
          letterSpacing: -0.3,
        ),
      ),
    );
  }
  Widget _buildNeumorphicField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 2.0,
        ) : null,
        boxShadow: isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            spreadRadius: 3,
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
        ] : [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.transparent,
        ),
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  Widget _buildDynamicField({
    required TextEditingController controller,
    required String labelText,
    VoidCallback? onRemove,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                validator: validator,
                decoration: InputDecoration(
                  labelText: labelText,
                  labelStyle: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF3A16).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: Color(0xFFEF3A16),
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildAddButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: _buildNeumorphicButton(
        text: text,
        icon: Icons.add,
        onPressed: onPressed,
      ),
    );
  }
  Widget _buildNeumorphicButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 2.0,
          ) : null,
          boxShadow: isDark ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              spreadRadius: 3,
              blurRadius: 15,
              offset: const Offset(0, 0),
            ),
          ] : [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 8,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.grey[400] : const Color(0xFF357ABD),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : const Color(0xFF357ABD),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF3A16).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFEF3A16).withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (_validateAll()) {
            await _submitRecipe();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF3A16),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Đăng bài',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredientNameCtrls.add(TextEditingController());
      _ingredientQuantityCtrls.add(TextEditingController()..text = '1');
      _ingredientUnitCtrls.add(TextEditingController()..text = 'cái');
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientNameCtrls[index].dispose();
      _ingredientQuantityCtrls[index].dispose();
      _ingredientUnitCtrls[index].dispose();
      _ingredientNameCtrls.removeAt(index);
      _ingredientQuantityCtrls.removeAt(index);
      _ingredientUnitCtrls.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _stepTitleCtrls.add(TextEditingController());
      _stepImages.add([]);
    });
  }

  void _removeStep(int index) {
    setState(() {
      _stepTitleCtrls[index].dispose();
      _stepTitleCtrls.removeAt(index);
      _stepImages.removeAt(index);
    });
  }

  Future<void> _pickStepImage(int stepIndex) async {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'Chọn ảnh cho bước ${stepIndex + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildImageSourceButton(
                            icon: Icons.camera_alt,
                            label: 'Máy ảnh',
                            onTap: () {
                              Navigator.pop(context);
                              _pickStepImageFromSource(stepIndex, ImageSource.camera);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildImageSourceButton(
                            icon: Icons.photo_library,
                            label: 'Thư viện',
                            onTap: () {
                              Navigator.pop(context);
                              _pickStepImageFromSource(stepIndex, ImageSource.gallery);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: $e')),
      );
    }
  }

  Future<void> _pickStepImageFromSource(int stepIndex, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _stepImages[stepIndex].add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: $e')),
      );
    }
  }

  void _removeStepImage(int stepIndex, int imageIndex) {
    setState(() {
      _stepImages[stepIndex].removeAt(imageIndex);
    });
  }
  Widget _buildIngredientField({
    required int index,
    required TextEditingController nameController,
    required TextEditingController quantityController,
    required TextEditingController unitController,
    VoidCallback? onRemove,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
          width: isDark ? 2.0 : 1.5,
        ),
        boxShadow: isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            spreadRadius: 3,
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Nguyên liệu ${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                if (onRemove != null)
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                labelText: 'Tên nguyên liệu',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                hintText: 'Ví dụ: Thịt bò, Cà chua...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[300]!,
                    width: isDark ? 2.0 : 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[300]!,
                    width: isDark ? 2.0 : 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: isDark ? Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 2.0,
                      ) : null,
                      boxShadow: isDark ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ] : [
                        BoxShadow(
                          color: const Color(0xFF64748B).withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 4,
                          offset: const Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final currentValue = int.tryParse(quantityController.text) ?? 1;
                            if (currentValue > 1) {
                              quantityController.text = (currentValue - 1).toString();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90E2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.remove, size: 18, color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: quantityController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '1',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                quantityController.text = '1';
                              }
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final currentValue = int.tryParse(quantityController.text) ?? 1;
                            quantityController.text = (currentValue + 1).toString();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90E2),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.add, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: unitController,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Đơn vị',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      hintText: 'cái, kg, ml...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[300]!,
                          width: isDark ? 2.0 : 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[300]!,
                          width: isDark ? 2.0 : 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStepField({
    required int index,
    required TextEditingController titleController,
    required List<File> images,
    VoidCallback? onRemove,
    VoidCallback? onAddImage,
    Function(int)? onRemoveImage,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F).withOpacity(0.9) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
          width: isDark ? 2.0 : 1.5,
        ),
        boxShadow: isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            spreadRadius: 3,
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Bước ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (onRemove != null)
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: titleController,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              labelText: 'Mô tả chi tiết',
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              hintText: 'Ví dụ: Rửa sạch rau củ, thái nhỏ vừa ăn...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[300]!,
                  width: isDark ? 2.0 : 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[300]!,
                  width: isDark ? 2.0 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
            ),
            maxLines: 4,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Ảnh minh họa:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAddImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_photo_alternate, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Thêm ảnh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (images.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey[200]!,
                  width: isDark ? 2.0 : 1.0,
                ),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: images.length,
                itemBuilder: (context, imageIndex) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          images[imageIndex],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemoveImage?.call(imageIndex),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF3A16), Color(0xFFFF6B35)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }
  bool _validateAll() {
    final formOk = _formKey.currentState!.validate();
    if (!formOk) return false;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cần ít nhất 1 ảnh')));
      return false;
    }
    if (_ingredientNameCtrls.take(1).any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cần ít nhất 1 nguyên liệu')));
      return false;
    }
    if (_stepTitleCtrls.take(3).any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cần ít nhất 1 bước')));
      return false;
    }
    return true;
  }

  Future<void> _submitRecipe() async {

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      _showErrorSnackBar('Vui lòng đăng nhập để đăng bài');
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang đăng bài...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    try {
      print(' [NEW POST] Starting recipe creation...');
      print(' [NEW POST] Uploading main image...');
      String? mainImageUrl;
      if (_images.isNotEmpty) {
        final uploadResult = await ApiService.uploadImage(
          imageFile: _images.first,
          type: 'recipes',
        );
        if (uploadResult.success && uploadResult.data != null) {
          mainImageUrl = uploadResult.data!.fileUrl;
          print(' [NEW POST] Main image uploaded: $mainImageUrl');
        } else {
          throw Exception('Upload ảnh chính thất bại: ${uploadResult.message}');
        }
      }
      print(' [NEW POST] Uploading step images...');
      final List<List<Map<String, dynamic>>> stepsWithImages = [];
      for (int stepIndex = 0; stepIndex < _stepTitleCtrls.length; stepIndex++) {
        final stepImagesList = <Map<String, dynamic>>[];
        if (_stepImages[stepIndex].isNotEmpty) {
          for (int imgIdx = 0; imgIdx < _stepImages[stepIndex].length; imgIdx++) {
            final imageFile = _stepImages[stepIndex][imgIdx];
            final uploadResult = await ApiService.uploadImage(
              imageFile: imageFile,
              type: 'steps',
            );
            if (uploadResult.success && uploadResult.data != null) {
              stepImagesList.add({
                'imageUrl': uploadResult.data!.fileUrl,
                'orderNumber': imgIdx + 1,
              });
              print(' [NEW POST] Step ${stepIndex + 1} image ${imgIdx + 1} uploaded');
            }
          }
        }
        stepsWithImages.add(stepImagesList);
      }
      print(' [NEW POST] Preparing recipe data...');
      final recipeData = {
        'title': _titleCtrl.text.trim(),
        'imageUrl': mainImageUrl,
        'servings': 4,
        'cookingTime': 30,
        'ingredients': _ingredientNameCtrls.asMap().entries.map((entry) {
          return {
            'name': entry.value.text.trim(),
            'quantity': _ingredientQuantityCtrls[entry.key].text.trim().isEmpty
                ? '1'
                : _ingredientQuantityCtrls[entry.key].text.trim(),
            'unit': _ingredientUnitCtrls[entry.key].text.trim().isEmpty
                ? 'cái'
                : _ingredientUnitCtrls[entry.key].text.trim(),
          };
        }).toList(),
        'steps': _stepTitleCtrls.asMap().entries.map((entry) {
          return {
            'stepNumber': entry.key + 1,
            'title': entry.value.text.trim(),
            'images': stepsWithImages[entry.key],
          };
        }).toList(),
      };
      print(' [NEW POST] Recipe data prepared:');
      print('   - Title: ${recipeData['title']}');
      print('   - Image URL: ${recipeData['imageUrl']}');
      print('   - Ingredients count: ${(recipeData['ingredients'] as List).length}');
      print('   - Steps count: ${(recipeData['steps'] as List).length}');
      print(' [NEW POST] Ingredients:');
      for (var i = 0; i < (recipeData['ingredients'] as List).length; i++) {
        final ing = (recipeData['ingredients'] as List)[i];
        print('   ${i + 1}. ${ing['name']} - ${ing['quantity']} ${ing['unit']}');
      }
      print(' [NEW POST] Steps:');
      for (var i = 0; i < (recipeData['steps'] as List).length; i++) {
        final step = (recipeData['steps'] as List)[i];
        print('   ${i + 1}. ${step['title']} - ${(step['images'] as List).length} images');
      }
      print(' [NEW POST] Creating recipe...');
      final recipeProvider = context.read<RecipeProvider>();
      final response = await recipeProvider.createRecipe(recipeData);
      Navigator.pop(context);
      if (response.success) {
        print('');
        print(' ==========================================');
        print(' [NEW POST] ĐĂNG BÀI THÀNH CÔNG!');
        print(' ==========================================');
        print(' Recipe ID: ${response.data?.id}');
        print(' Title: ${response.data?.title}');
        print(' Image URL: ${response.data?.imageUrl}');
        print(' Ingredients: ${response.data?.ingredients.length ?? 0}');
        print(' Steps: ${response.data?.steps.length ?? 0}');
        print(' ==========================================');
        print('');
        final authProvider = context.read<AuthProvider>();
        final currentUser = authProvider.currentUser;
        final recipeProvider = context.read<RecipeProvider>();
        final recipeId = response.data!.id;
        print(' [NEW POST] Fetching full recipe detail for ID: $recipeId');
        final recipe = await recipeProvider.getRecipeById(recipeId);
        if (recipe == null) {
          print(' [NEW POST] Failed to load recipe detail');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi tải chi tiết bài viết'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        print(' [NEW POST] Recipe data check:');
        print('   - userName: ${recipe.userName}');
        print('   - currentUser: ${currentUser?.fullName}');
        print('   - createdAt: ${recipe.createdAt}');
        print('   - ingredients count: ${recipe.ingredients.length}');
        print('   - steps count: ${recipe.steps.length}');
        final ingredientsList = <String>[];
        for (var ing in recipe.ingredients) {
          final text = '${ing.name}${ing.quantity != null ? " ${ing.quantity}" : ""}${ing.unit != null ? " ${ing.unit}" : ""}';
          ingredientsList.add(text);
          print('   - Ingredient: $text');
        }

        final stepsList = <String>[];
        for (var step in recipe.steps) {
          final text = '${step.stepNumber}. ${step.title}';
          stepsList.add(text);
          print('   - Step: $text');
        }

        final post = Post(
          id: recipe.id.toString(),
          title: recipe.title,
          author: recipe.userName ?? currentUser?.fullName ?? 'Unknown',
          minutesAgo: recipe.createdAt != null
              ? DateTime.now().difference(recipe.createdAt!).inMinutes
              : 0,
          savedCount: recipe.bookmarksCount,
          imageUrl: recipe.imageUrl ?? '',
          ingredients: ingredientsList,
          steps: stepsList,
          createdAt: recipe.createdAt ?? DateTime.now(),
        );
        print(' [NEW POST] Post object created:');
        print('   - Author: ${post.author}');
        print('   - Ingredients: ${post.ingredients.length}');
        print('   - Steps: ${post.steps.length}');
        print('   - CreatedAt: ${post.createdAt}');
        if (!mounted) return;
        _showSuccessSnackBar(' Đăng bài thành công! Đang hiển thị bài viết...');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
        print(' [NEW POST] Navigated to Post Detail Screen');
        print(' [NEW POST] Reloading recipes in background...');
        context.read<RecipeProvider>().loadRecipes().then((_) {
          print(' [NEW POST] Feed recipes reloaded');
        });
        context.read<RecipeProvider>().loadMyRecipes().then((_) {
          print(' [NEW POST] My recipes reloaded');
        });
        context.read<AuthProvider>().loadUserStats().then((_) {
          print(' [NEW POST] User stats reloaded');
        });
      } else {
        print('');
        print(' ==========================================');
        print(' [NEW POST] ĐĂNG BÀI THẤT BẠI!');
        print(' ==========================================');
        print(' Error: ${response.message}');
        print(' ==========================================');
        print('');
        _showErrorSnackBar(response.message ?? 'Đăng bài thất bại');
      }
    } catch (e, stackTrace) {
      print(' [NEW POST] Error: $e');
      print(' [NEW POST] Stack trace: $stackTrace');
      Navigator.pop(context);
      _showErrorSnackBar('Lỗi: $e');
    }
  }
}
