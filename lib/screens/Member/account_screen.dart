import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../notification_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String name = '';
  String email = '';
  String role = '';
  String avatarUrl = '';
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      role = prefs.getString('role') ?? '';
      avatarUrl = prefs.getString('avatar') ?? '';
      userId = prefs.getInt('id') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 30) : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('$role', style: TextStyle(color: Colors.grey[700]))
                  ],
                ),

                Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => NotificationScreen()));
                  },
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Số dư tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('TK tin đăng', style: TextStyle(color: Colors.grey)),
                      Text('0'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('TK khuyến mãi', style: TextStyle(color: Colors.grey)),
                      Text('0'),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mã chuyển khoản', style: TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          const SelectableText(
                            'BDS42203703',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: 'BDS42203703'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã sao chép mã chuyển khoản')),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 20, color: Color(0xff0077bb)), // icon nhỏ, màu đồng bộ
                            tooltip: 'Sao chép',
                          ),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(icon: Icons.list_alt, title: 'Quản lý tin đăng'),
            _buildSection(icon: Icons.group, title: 'Quản lý khách hàng', badge: 'Mới'),
            _buildSection(icon: Icons.card_membership, title: 'Gói hội viên', badge: 'Tiết kiệm đến 39%'),
            _buildSection(icon: Icons.attach_money, title: 'Quản lý tài chính'),
            _buildSection(icon: Icons.edit_note, title: 'Báo giá và Hướng dẫn'),
            _buildSection(icon: Icons.settings, title: 'Tiện ích'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.search, color: Colors.white), // ✅ icon trắng
                label: const Text('Chuyển sang tìm kiếm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0077bb), // ✅ màu nền xanh
                  foregroundColor: Colors.white, // màu chữ
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            SizedBox(height: 50)
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, String? badge}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: badge != null
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badge == 'Mới' ? Colors.red : Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge,
          style: TextStyle(
            color: badge == 'Mới' ? Colors.white : Colors.red,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : const Icon(Icons.keyboard_arrow_right),
      onTap: () {},
    );
  }
}
