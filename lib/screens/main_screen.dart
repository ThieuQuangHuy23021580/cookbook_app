import 'package:flutter/material.dart';
import 'feed/feed_screen.dart';
import 'library/library_screen.dart';
class MainScreen extends StatefulWidget {

  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    FeedScreen(),
    LibraryScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            border: isDark ? Border(
              top: BorderSide(color: Colors.white.withOpacity(0.15), width: 2.0),
            ) : null,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: const Color(0xFFEF3A16),
            unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Kho món ngon của tôi'),
            ],
          ),
        ),
      ),
    );
  }
}
