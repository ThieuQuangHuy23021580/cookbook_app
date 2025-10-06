import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: const Color(0xFFEF3A16),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEF3A16),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.settings,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cài đặt ứng dụng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Settings sections
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                        trailing: Switch(value: true, onChanged: (value) {}),
                      ),
                      _buildSettingsItem(
                        icon: Icons.language,
                        title: 'Ngôn ngữ',
                        subtitle: 'Tiếng Việt',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        icon: Icons.dark_mode,
                        title: 'Chế độ tối',
                        subtitle: 'Tự động theo hệ thống',
                        trailing: Switch(value: false, onChanged: (value) {}),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF3A16),
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFEF3A16)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
