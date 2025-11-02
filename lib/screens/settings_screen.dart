import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Set system UI overlay style to prevent status bar issues
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.light,
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
                "Cài đặt",
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
                colors: isDark
                    ? [
                        const Color(0xFF000000), // Pure black
                        const Color(0xFF0A0A0A), // Very dark gray
                        const Color(0xFF0F0F0F), // Slightly lighter dark gray
                      ]
                    : [
                        const Color(0xFFFAFAFA),
                        const Color(0xFFF8FAFC),
                        const Color(0xFFF1F5F9),
                      ],
              ),
            ),
          ),
          // Floating particles background
          ...List.generate(10, (index) => 
            Positioned(
              top: (index * 70.0) % MediaQuery.of(context).size.height,
              left: (index * 90.0) % MediaQuery.of(context).size.width,
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
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header with Glassmorphism
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFEF3A16).withOpacity(0.9),
                        const Color(0xFFFF5A00).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(-2, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Settings icon with 3D effect
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(-2, -2),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.settings,
                              size: 40,
                              color: Color(0xFFEF3A16),
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Cài đặt ứng dụng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tùy chỉnh trải nghiệm của bạn',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Settings sections
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // General settings
                      _buildSettingsSection(
                        'Cài đặt chung',
                        [
                          _buildSettingsItem(
                            icon: Icons.notifications,
                            title: 'Thông báo',
                            subtitle: 'Quản lý thông báo',
                            trailing: _buildNeumorphicSwitch(
                              value: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                            ),
                          ),
                          _buildSettingsItem(
                            icon: Icons.language,
                            title: 'Ngôn ngữ',
                            subtitle: 'Tiếng Việt',
                            onTap: () {},
                          ),
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return _buildSettingsItem(
                                icon: Icons.dark_mode,
                                title: 'Chế độ tối',
                                subtitle: themeProvider.isDarkMode ? 'Đã bật' : 'Đã tắt',
                                trailing: _buildNeumorphicSwitch(
                                  value: themeProvider.isDarkMode,
                                  onChanged: (value) {
                                    themeProvider.toggleTheme();
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // App settings
                      _buildSettingsSection(
                        'Ứng dụng',
                        [
                          _buildSettingsItem(
                            icon: Icons.storage,
                            title: 'Dung lượng',
                            subtitle: 'Xem dung lượng đã sử dụng',
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.update,
                            title: 'Cập nhật',
                            subtitle: 'Kiểm tra phiên bản mới',
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.info,
                            title: 'Về ứng dụng',
                            subtitle: 'Phiên bản 1.0.0',
                            onTap: () {},
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Privacy settings
                      _buildSettingsSection(
                        'Quyền riêng tư',
                        [
                          _buildSettingsItem(
                            icon: Icons.privacy_tip,
                            title: 'Chính sách bảo mật',
                            subtitle: 'Đọc chính sách bảo mật',
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.description,
                            title: 'Điều khoản sử dụng',
                            subtitle: 'Đọc điều khoản sử dụng',
                            onTap: () {},
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Support
                      _buildSettingsSection(
                        'Hỗ trợ',
                        [
                          _buildSettingsItem(
                            icon: Icons.help_center,
                            title: 'Trung tâm trợ giúp',
                            subtitle: 'Câu hỏi thường gặp',
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.contact_support,
                            title: 'Liên hệ hỗ trợ',
                            subtitle: 'Gửi phản hồi',
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            icon: Icons.star,
                            title: 'Đánh giá ứng dụng',
                            subtitle: 'Đánh giá trên cửa hàng',
                            onTap: () {},
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F0F0F).withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.3),
          width: isDark ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          if (!isDark)
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                letterSpacing: -0.3,
              ),
            ),
          ),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F0F0F).withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.3),
          width: isDark ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
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
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontSize: 15,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: trailing ?? Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F0F0F)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : const Color(0xFF64748B).withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                ),
            ],
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNeumorphicSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          color: value ? const Color(0xFFEF3A16) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            // Outer shadow (dark)
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.3),
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
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? Colors.white : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    color: Color(0xFFEF3A16),
                    size: 16,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
