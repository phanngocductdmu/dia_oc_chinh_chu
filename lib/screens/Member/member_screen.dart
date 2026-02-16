import 'package:flutter/material.dart';
import 'account_screen.dart';
import 'customer_screen.dart';
import 'overview_screen.dart';
import 'create_post_screen.dart';
import 'post_management_screen.dart';

class MemberScreen extends StatefulWidget {
  final int initialIndex;
  const MemberScreen({super.key, this.initialIndex = 0});

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const OverviewScreen(),
    const PostManagementScreen(),
    Center(child: Text('Đăng tin', style: TextStyle(fontSize: 24))),
    const CustomerScreen(),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (index == 2) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen()));
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: _pages[_currentIndex],

      // ✅ Floating Action Button nổi và lệch xuống nhẹ
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(
          height: 64,
          width: 64,
          child: FloatingActionButton(
            onPressed: () => _onTabSelected(2),
            backgroundColor: const Color(0xff0077bb),
            shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 4),
            ),
            elevation: 8,
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ✅ BottomAppBar đổ bóng
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.white,
          elevation: 0,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildTabItem(index: 0, icon: Icons.pie_chart, label: 'Tổng quan'),
                _buildTabItem(index: 1, icon: Icons.article_outlined, label: 'Tin đăng'),
                const SizedBox(width: 48),
                _buildTabItem(index: 3, icon: Icons.group_outlined, label: 'Khách hàng'),
                _buildTabItem(index: 4, icon: Icons.more_horiz, label: 'Tài khoản'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required int index, required IconData icon, required String label}) {
    final isSelected = _currentIndex == index;

    IconData getIcon() {
      switch (index) {
        case 0:
          return isSelected ? Icons.pie_chart : Icons.pie_chart_outline;
        case 1:
          return isSelected ? Icons.article : Icons.article_outlined;
        case 3:
          return isSelected ? Icons.group : Icons.group_outlined;
        case 4:
          return Icons.more_horiz;
        default:
          return icon;
      }
    }

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(getIcon(), color: isSelected ? Colors.black : Colors.grey, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}
