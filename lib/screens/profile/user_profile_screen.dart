import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/index.dart';
import '../../models/recipe_model.dart';
import '../../models/post_model.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../feed/post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSelectionMode = false;
  Set<int> _selectedRecipeIds = {};

  @override
  void initState() {
    super.initState();
    // Load user profile, stats, and recipes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUserProfile();
      context.read<AuthProvider>().loadUserStats();
      context.read<RecipeProvider>().loadMyRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Không xác định';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Future<void> _deleteSelectedRecipes() async {
    if (_selectedRecipeIds.isEmpty) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Xóa ${_selectedRecipeIds.length} bài viết?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa ${_selectedRecipeIds.length} bài viết đã chọn? Hành động này không thể hoàn tác.',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Text('Đang xóa ${_selectedRecipeIds.length} bài viết...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final recipeProvider = context.read<RecipeProvider>();
      final recipeIds = _selectedRecipeIds.toList();
      int successCount = 0;
      int failCount = 0;

      // Delete recipes one by one
      for (final recipeId in recipeIds) {
        final response = await recipeProvider.deleteRecipe(recipeId);
        if (response.success) {
          successCount++;
        } else {
          failCount++;
        }
      }

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);

      // Clear selection
      setState(() {
        _selectedRecipeIds.clear();
        _isSelectionMode = false;
      });

      // Show result
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failCount > 0
                  ? 'Đã xóa $successCount bài viết. $failCount bài viết xóa thất bại.'
                  : 'Đã xóa $successCount bài viết thành công!',
            ),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xóa bài viết. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      // Reload data
      context.read<RecipeProvider>().loadMyRecipes();
      context.read<AuthProvider>().loadUserStats();
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    print('🗑️ [DELETE RECIPE] Starting deletion...');
    print('🗑️ [DELETE RECIPE] Recipe ID: ${recipe.id}');
    print('🗑️ [DELETE RECIPE] Recipe Title: ${recipe.title}');

    // Show loading dialog
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
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                  SizedBox(height: 16),
                  Text('Đang xóa bài viết...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final recipeProvider = context.read<RecipeProvider>();
      final response = await recipeProvider.deleteRecipe(recipe.id);

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);

      if (response.success) {
        print('');
        print('✅ ==========================================');
        print('✅ [DELETE RECIPE] XÓA BÀI VIẾT THÀNH CÔNG!');
        print('✅ ==========================================');
        print('✅ Recipe ID: ${recipe.id}');
        print('✅ Recipe Title: ${recipe.title}');
        print('✅ ==========================================');
        print('');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa bài viết "${recipe.title}" thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Reload data
        context.read<RecipeProvider>().loadMyRecipes();
        context.read<AuthProvider>().loadUserStats();
      } else {
        print('');
        print('❌ ==========================================');
        print('❌ [DELETE RECIPE] XÓA BÀI VIẾT THẤT BẠI!');
        print('❌ ==========================================');
        print('❌ Error: ${response.message}');
        print('❌ ==========================================');
        print('');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Xóa bài viết thất bại'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ [DELETE RECIPE] Error: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _uploadAvatar(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    try {
      // Show bottom sheet to choose camera or gallery
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Chọn ảnh đại diện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF3A16).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFFEF3A16)),
                ),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF3A16).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: Color(0xFFEF3A16)),
                ),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // Validate file extension
      final path = image.path.toLowerCase();
      if (!path.endsWith('.jpg') && !path.endsWith('.jpeg') && 
          !path.endsWith('.png') && !path.endsWith('.gif')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chỉ chấp nhận file ảnh (.jpg, .jpeg, .png, .gif)'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF3A16)),
                  ),
                  SizedBox(height: 16),
                  Text('Đang tải ảnh lên...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Upload image
      print('🔍 [AVATAR UPLOAD] Starting upload...');
      print('🔍 [AVATAR UPLOAD] Image path: ${image.path}');
      
      final uploadResponse = await ApiService.uploadImage(
        imageFile: File(image.path),
        type: 'avatars',
        token: authProvider.token,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      print('🔍 [AVATAR UPLOAD] Upload response success: ${uploadResponse.success}');
      print('🔍 [AVATAR UPLOAD] File URL: ${uploadResponse.data?.fileUrl}');

      if (uploadResponse.success && uploadResponse.data?.fileUrl != null) {
        final rawAvatarUrl = uploadResponse.data!.fileUrl!;
        // Fix URL nếu là localhost
        final newAvatarUrl = ApiConfig.fixImageUrl(rawAvatarUrl);
        print('🔍 [AVATAR UPLOAD] Raw avatar URL from server: $rawAvatarUrl');
        print('🔍 [AVATAR UPLOAD] Fixed avatar URL: $newAvatarUrl');
        
        // Update user profile with new avatar URL
        final updatedData = <String, dynamic>{
          'fullName': user.fullName,
          'avatarUrl': newAvatarUrl,
          'bio': user.bio ?? '',
          'hometown': user.hometown ?? '',
        };

        print('🔍 [AVATAR UPLOAD] Updating user profile with data: $updatedData');

        final updateResponse = await ApiService.updateUser(
          user.id,
          updatedData,
          authProvider.token!,
        );

        print('🔍 [AVATAR UPLOAD] Update response success: ${updateResponse.success}');
        print('🔍 [AVATAR UPLOAD] Updated user avatar: ${updateResponse.data?.avatar}');

        if (updateResponse.success && mounted) {
          // Clear image cache for the old avatar if exists
          if (user.avatar != null && user.avatar!.isNotEmpty) {
            try {
              final oldImageProvider = NetworkImage(user.avatar!);
              await oldImageProvider.evict();
              print('🔍 [AVATAR UPLOAD] Cleared cache for old avatar');
            } catch (e) {
              print('⚠️ [AVATAR UPLOAD] Failed to clear old cache: $e');
            }
          }
          
          // Clear cache for new avatar to ensure fresh load
          try {
            final newImageProvider = NetworkImage(newAvatarUrl);
            await newImageProvider.evict();
            print('🔍 [AVATAR UPLOAD] Cleared cache for new avatar');
          } catch (e) {
            print('⚠️ [AVATAR UPLOAD] Failed to clear new cache: $e');
          }
          
          // Reload user profile to fetch latest data
          await authProvider.loadUserProfile();
          
          // Force rebuild the widget
          if (mounted) {
            setState(() {});
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật ảnh đại diện thành công!\nURL: $newAvatarUrl'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(updateResponse.message ?? 'Cập nhật thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(uploadResponse.message ?? 'Upload ảnh thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editProfile(BuildContext context, String field, String currentValue) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    final controller = TextEditingController(text: currentValue);

    // Get field label
    String label;
    switch (field) {
      case 'fullName':
        label = 'Họ và tên';
        break;
      case 'hometown':
        label = 'Quê quán';
        break;
      case 'bio':
        label = 'Giới thiệu';
        break;
      default:
        label = 'Cập nhật';
    }

    // Show dialog to edit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: field == 'bio' ? 3 : 1,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              
              if (newValue.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không được để trống')),
                  );
                }
                return;
              }

              // Validate based on field
              if (field == 'fullName' && newValue.length > 100) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Họ và tên không được vượt quá 100 ký tự')),
                  );
                }
                return;
              } else if (field == 'hometown' && newValue.length > 100) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quê quán không được vượt quá 100 ký tự')),
                  );
                }
                return;
              } else if (field == 'bio' && newValue.length > 500) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Giới thiệu không được vượt quá 500 ký tự')),
                  );
                }
                return;
              }

              // Build update data according to backend UserRequestDTO
              // Note: Don't include password if not updating
              final updatedData = <String, dynamic>{
                'email': user.email, // Keep current email
                'fullName': field == 'fullName' ? newValue : user.fullName,
                'avatarUrl': user.avatar ?? '', // Map avatar to avatarUrl
                'bio': field == 'bio' ? newValue : (user.bio ?? ''),
                'hometown': field == 'hometown' ? newValue : (user.hometown ?? ''),
              };

              // Call update API
              final response = await ApiService.updateUser(
                user.id,
                updatedData,
                authProvider.token!,
              );

              if (response.success && mounted) {
                // Reload user profile
                await authProvider.loadUserProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response.message ?? 'Cập nhật thất bại'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF3A16),
            ),
            child: const Text('Lưu'),
          ),
        ],
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
                "Thông tin cá nhân",
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
          ...List.generate(12, (index) => 
            Positioned(
              top: (index * 60.0) % MediaQuery.of(context).size.height,
              left: (index * 80.0) % MediaQuery.of(context).size.width,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header - Modern & Elegant Design
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 8,
                        offset: const Offset(-2, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    child: Column(
                      children: [
                        // Avatar with subtle shadow
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF64748B).withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  final user = authProvider.currentUser;
                                  final hasAvatar = user?.avatar != null && user!.avatar!.isNotEmpty;
                                  
                                  print('🔍 [AVATAR DISPLAY] User avatar URL: ${user?.avatar}');
                                  print('🔍 [AVATAR DISPLAY] Has avatar: $hasAvatar');
                                  
                                  // Fix URL nếu cần (đảm bảo không chứa localhost)
                                  final avatarUrl = hasAvatar 
                                      ? ApiConfig.fixImageUrl(user!.avatar!)
                                      : null;
                                  
                                  if (hasAvatar && user!.avatar!.contains('localhost')) {
                                    print('⚠️ [AVATAR DISPLAY] WARNING: URL contains localhost!');
                                    print('⚠️ [AVATAR DISPLAY] Fixed URL: $avatarUrl');
                                  }
                                  
                                  return CircleAvatar(
                                    key: ValueKey(user?.avatar ?? 'no_avatar_${DateTime.now().millisecondsSinceEpoch}'),
                                    radius: 50,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    foregroundImage: avatarUrl != null
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    onForegroundImageError: hasAvatar ? (exception, stackTrace) {
                                      print('❌ [AVATAR DISPLAY] Failed to load image: $exception');
                                      print('❌ [AVATAR DISPLAY] URL was: ${user!.avatar}');
                                      print('❌ [AVATAR DISPLAY] Stack trace: $stackTrace');
                                    } : null,
                                    child: !hasAvatar
                                        ? const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Color(0xFF64748B),
                                          )
                                        : null,
                                  );
                                },
                              ),
                            ),
                            // Edit button - subtle design
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () => _uploadAvatar(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF0EA5E9),
                                        Color(0xFF3B82F6),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Text(
                              authProvider.currentUser?.fullName ?? 'Tên người dùng',
                              style: const TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Text(
                              authProvider.currentUser?.email ?? 'user@example.com',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats with Glassmorphism
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: Consumer2<AuthProvider, RecipeProvider>(
                      builder: (context, authProvider, recipeProvider, child) {
                        if (authProvider.isLoadingProfile) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF3A16)),
                              ),
                            ),
                          );
                        }
                        
                        final user = authProvider.currentUser;
                        // Use actual count from myRecipes if stats is null or 0
                        final actualRecipesCount = recipeProvider.myRecipes.length;
                        final recipesCount = (user?.recipesCount ?? 0) > 0 
                            ? user!.recipesCount 
                            : actualRecipesCount;
                        
                        // Calculate total likes from user's recipes
                        final totalLikesFromRecipes = recipeProvider.myRecipes.fold<int>(
                          0,
                          (sum, recipe) => sum + recipe.likesCount,
                        );
                        // Use stats from API if available, otherwise use calculated total
                        final likesReceived = (user?.likesReceived ?? 0) > 0
                            ? user!.likesReceived
                            : totalLikesFromRecipes;
                        
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatTile(
                              label: 'Bài đã đăng', 
                              value: recipesCount.toString()
                            ),
                            _StatTile(
                              label: 'Lượt thích', 
                              value: likesReceived.toString()
                            ),
                            _StatTile(
                              label: 'Người theo dõi', 
                              value: user?.followersCount.toString() ?? '0'
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Personal Info Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        const Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final user = authProvider.currentUser;
                            return Column(
                              children: [
                                _infoTile(
                                  icon: Icons.badge, 
                                  title: 'Họ và tên', 
                                  value: user?.fullName ?? 'Chưa cập nhật',
                                  onTap: () => _editProfile(context, 'fullName', user?.fullName ?? ''),
                                ),
                                _infoTile(
                                  icon: Icons.location_on, 
                                  title: 'Quê quán', 
                                  value: user?.hometown ?? 'Chưa cập nhật',
                                  onTap: () => _editProfile(context, 'hometown', user?.hometown ?? ''),
                                ),
                                _infoTile(
                                  icon: Icons.info_outline, 
                                  title: 'Giới thiệu', 
                                  value: user?.bio ?? 'Chưa cập nhật',
                                  onTap: () => _editProfile(context, 'bio', user?.bio ?? ''),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // My Posts Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        // Title and selection mode toggle
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _isSelectionMode && _selectedRecipeIds.isNotEmpty
                                    ? 'Đã chọn ${_selectedRecipeIds.length} bài viết'
                                    : 'Bài viết của tôi',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Color(0xFF1F2937),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            // Selection mode toggle button
                            IconButton(
                              icon: Icon(
                                _isSelectionMode ? Icons.close : Icons.checklist,
                                color: _isSelectionMode 
                                    ? Colors.red 
                                    : const Color(0xFF64748B),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isSelectionMode = !_isSelectionMode;
                                  if (!_isSelectionMode) {
                                    _selectedRecipeIds.clear();
                                  }
                                });
                              },
                              tooltip: _isSelectionMode ? 'Thoát chế độ chọn' : 'Chọn nhiều bài viết',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search my posts with Neumorphism
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              // Outer shadow (dark)
                              BoxShadow(
                                color: const Color(0xFF64748B).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(4, 4),
                              ),
                              // Inner shadow (light)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 8,
                                offset: const Offset(-4, -4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Tìm bài viết của tôi...',
                              hintStyle: TextStyle(
                                color: const Color(0xFF64748B).withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: const Color(0xFF64748B).withOpacity(0.7),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: const Color(0xFF64748B).withOpacity(0.7),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onChanged: (q) {
                              setState(() {
                                _searchQuery = q;
                              });
                            },
                            onSubmitted: (q) {
                              setState(() {
                                _searchQuery = q;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Delete selected button (shown when in selection mode with selected items)
                        if (_isSelectionMode && _selectedRecipeIds.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.red.shade400,
                                  Colors.red.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _deleteSelectedRecipes,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Xóa ${_selectedRecipeIds.length} bài viết',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // My posts list with enhanced design
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: Consumer<RecipeProvider>(
                    builder: (context, recipeProvider, child) {
                      if (recipeProvider.isLoadingMyRecipes) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF3A16)),
                            ),
                          ),
                        );
                      }
                      
                      if (recipeProvider.myRecipesError != null) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Lỗi tải bài viết: ${recipeProvider.myRecipesError}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<RecipeProvider>().loadMyRecipes();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF3A16),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      final myRecipes = recipeProvider.myRecipes;
                      
                      if (myRecipes.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Chưa có bài viết nào',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hãy tạo bài viết đầu tiên của bạn!',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      // Filter recipes based on search query
                      final filteredRecipes = _searchQuery.isEmpty 
                          ? myRecipes 
                          : myRecipes.where((recipe) => 
                              recipe.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                      
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRecipes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _buildRecipeCard(filteredRecipes[i]),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final isSelected = _selectedRecipeIds.contains(recipe.id);
    
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          // Toggle selection
          setState(() {
            if (isSelected) {
              _selectedRecipeIds.remove(recipe.id);
            } else {
              _selectedRecipeIds.add(recipe.id);
            }
          });
        } else {
          // Navigate to post detail
          final post = Post(
            id: recipe.id.toString(),
            title: recipe.title,
            author: recipe.userName ?? 'Unknown',
            minutesAgo: recipe.createdAt != null 
                ? DateTime.now().difference(recipe.createdAt!).inMinutes
                : 0,
            savedCount: recipe.bookmarksCount,
            imageUrl: recipe.imageUrl ?? '',
            ingredients: recipe.ingredients.map((ing) => ing.name).toList(),
            steps: recipe.steps.map((step) => step.description ?? step.title).toList(),
            createdAt: recipe.createdAt,
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)))
              .then((_) {
            if (!mounted) return;
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!mounted) return;
              context.read<RecipeProvider>().loadRecentlyViewedRecipes(limit: 9);
            });
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
              // Checkbox (shown only in selection mode)
              if (_isSelectionMode) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected 
                        ? Colors.red.shade600
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected 
                          ? Colors.red.shade600
                          : const Color(0xFF64748B),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
              ],
              // Thumbnail with shadow
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFFF1F5F9),
                    child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                        ? Image.network(
                            recipe.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.restaurant_menu,
                              color: Color(0xFF64748B),
                              size: 30,
                            ),
                          )
                        : const Icon(
                            Icons.restaurant_menu,
                            color: Color(0xFF64748B),
                            size: 30,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Star rating
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < recipe.averageRating.floor()
                                  ? Icons.star
                                  : (starIndex < recipe.averageRating
                                      ? Icons.star_half
                                      : Icons.star_border),
                              size: 16,
                              color: const Color(0xFFFFA500),
                            );
                          }),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          recipe.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${recipe.ratingsCount})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Chevron icon
              SizedBox(
                width: 32,
                height: 32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
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
                  child: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile({required IconData icon, required String title, required String value, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEF3A16).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFEF3A16),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
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
          child: const Icon(
            Icons.edit,
            color: Color(0xFF64748B),
            size: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEF3A16).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
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
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFFEF3A16),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


