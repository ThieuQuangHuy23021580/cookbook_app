import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final List<TextEditingController> _ingredientCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _stepCtrls = List.generate(3, (_) => TextEditingController());
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _ingredientCtrls) c.dispose();
    for (final c in _stepCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // Show image source selection dialog
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
    // Set system UI overlay style to prevent status bar issues
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
          // Dynamic background with particles
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFAFAFA),
                  const Color(0xFFF8FAFC),
                  const Color(0xFFF1F5F9),
                ],
              ),
            ),
          ),
          // Floating particles background
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
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image picker section with Glassmorphism
                  _imagePickerSection(),
                  const SizedBox(height: 20),
                  
                  // Title field with Neumorphism
                  _buildNeumorphicField(
                    controller: _titleCtrl,
                    labelText: 'Tên món',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description field with Neumorphism
                  _buildNeumorphicField(
                    controller: _descCtrl,
                    labelText: 'Mô tả',
                    maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // Ingredients section
                  _buildSectionHeader('Nguyên liệu (tối thiểu 3)'),
                  const SizedBox(height: 12),
                  ..._ingredientCtrls.asMap().entries.map((e) => _buildDynamicField(
                    controller: e.value,
                    labelText: 'Nguyên liệu ${e.key + 1}',
                    onRemove: _ingredientCtrls.length > 3 ? () => setState(() => _ingredientCtrls.removeAt(e.key)) : null,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                  )),
                  _buildAddButton(
                    text: 'Thêm nguyên liệu',
                    onPressed: () => setState(() => _ingredientCtrls.add(TextEditingController())),
                  ),
                  const SizedBox(height: 20),
                  
                  // Steps section
                  _buildSectionHeader('Các bước (tối thiểu 3)'),
                  const SizedBox(height: 12),
                  ..._stepCtrls.asMap().entries.map((e) => _buildDynamicField(
                    controller: e.value,
                    labelText: 'Bước ${e.key + 1}',
                    onRemove: _stepCtrls.length > 3 ? () => setState(() => _stepCtrls.removeAt(e.key)) : null,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                  )),
                  _buildAddButton(
                    text: 'Thêm bước',
                    onPressed: () => setState(() => _stepCtrls.add(TextEditingController())),
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit button with 3D effect
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hình ảnh (tối thiểu 1)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
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
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: Color(0xFF64748B),
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Chưa có ảnh',
                        style: TextStyle(
                          color: Color(0xFF64748B),
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
    return Container(
      width: 140,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 2,
        ),
        boxShadow: [
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF3A16).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF3A16).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Color(0xFFEF3A16),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
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
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.transparent,
        ),
        style: const TextStyle(
          color: Color(0xFF1F2937),
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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
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
              color: const Color(0xFFEF3A16),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFEF3A16),
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
            final recipeProvider = context.read<RecipeProvider>();
            final authProvider = context.read<AuthProvider>();
            
            if (!authProvider.isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng đăng nhập để đăng bài'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            // Prepare recipe data
            final recipeData = {
              'title': _titleCtrl.text,
              'description': _descCtrl.text,
              'servings': 4, // Default servings
              'cookingTime': 30, // Default cooking time
              'ingredients': _ingredientCtrls.map((ctrl) => {
                'name': ctrl.text,
                'quantity': '1',
                'unit': 'cái',
              }).toList(),
              'steps': _stepCtrls.asMap().entries.map((entry) => {
                'stepNumber': entry.key + 1,
                'title': 'Bước ${entry.key + 1}',
                'description': entry.value.text,
                'images': [],
              }).toList(),
              // TODO: Upload images to server and get URLs
              // For now, we'll use placeholder URLs
              'images': _images.map((file) => {
                'url': 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
                'caption': 'Ảnh món ăn',
              }).toList(),
            };
            
            // Show loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
            
            // Create recipe
            final response = await recipeProvider.createRecipe(recipeData);
            
            // Hide loading
            Navigator.pop(context);
            
            if (response.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đăng bài thành công!'),
                  backgroundColor: const Color(0xFFEF3A16),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.message ?? 'Đăng bài thất bại'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
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

  bool _validateAll() {
    final formOk = _formKey.currentState!.validate();
    if (!formOk) return false;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cần ít nhất 1 ảnh')));
      return false;
    }
    if (_ingredientCtrls.take(3).any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cần ít nhất 3 nguyên liệu')));
      return false;
    }
    if (_stepCtrls.take(3).any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cần ít nhất 3 bước')));
      return false;
    }
    return true;
  }
}


