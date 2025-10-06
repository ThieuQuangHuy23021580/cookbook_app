import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: const Color(0xFFEF3A16),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEF3A16), Color(0xFFFF5A00)],
                ),
              ),
              child: Column(
                children: const [
                  CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(0xFFEF3A16))),
                  SizedBox(height: 12),
                  Text('Tên người dùng', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('user@example.com', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _StatTile(label: 'Bài đã đăng', value: '12'),
                  _StatTile(label: 'Đã lưu', value: '58'),
                  _StatTile(label: 'Người theo dõi', value: '230'),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _infoTile(icon: Icons.badge, title: 'Họ và tên', value: 'Tên người dùng'),
                  _infoTile(icon: Icons.phone, title: 'Số điện thoại', value: '+84 123 456 789'),
                  _infoTile(icon: Icons.location_on, title: 'Địa chỉ', value: 'TP. Hồ Chí Minh'),
                  const SizedBox(height: 16),
                  const Text('Bài viết của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Search my posts
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm bài viết của tôi...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                    onSubmitted: (q) {
                      // TODO: filter list (mock)
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            const SizedBox(height: 8),
            // My posts list (mock)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) => ListTile(
                  leading: Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8))),
                  title: Text('Món tôi đăng ${i + 1}'),
                  subtitle: const Text('Đã đăng • 5 phút trước'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: mở chi tiết bài viết
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({required IconData icon, required String title, required String value}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFEF3A16)),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.edit),
        onTap: () {},
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}


