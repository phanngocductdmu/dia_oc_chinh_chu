import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'package:diaocchinhchu/screens/Member/member_screen.dart';
import '../screens/detail/agent_contacts.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  String _userName = '';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final name = prefs.getString('name');
    final avatar = prefs.getString('avatar');

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _userName = name ?? '';
      _avatarUrl = avatar ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 34, 10, 10),
        children: [
          // ==== Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isLoggedIn
                ? Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: _avatarUrl.isNotEmpty
                      ? NetworkImage(_avatarUrl)
                      : null,
                  backgroundColor: const Color(0xffeaf2ff),
                  child: _avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Color(0xff0066ff))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _userName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => NotificationScreen()));
                  },
                )
              ],
            )
                : Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xffeaf2ff),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tag_faces_rounded,
                          color: Color(0xff0066ff), size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Đăng nhập tài khoản để xem thông tin và liên hệ người bán/cho thuê',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );

                      if (result == true) {
                        _checkLoginStatus();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle:
                      const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Đăng nhập',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          _buildSectionTitle('Hướng dẫn'),
          _buildMenuItem(Icons.people_alt_outlined, 'Danh bạ môi giới', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AgentContactsScreen()),
            );
          }),
          _buildMenuItem(Icons.help_outline, 'Câu hỏi thường gặp', () {
            // TODO: Thêm logic
          }),
          _buildMenuItem(Icons.bug_report_outlined, 'Góp ý báo lỗi', () {
            // TODO: Thêm logic
          }),
          _buildMenuItem(Icons.info_outline, 'Về chúng tôi', () {
            // TODO: Thêm logic
          }),

          const SizedBox(height: 24),

          _buildSectionTitle('Quy định'),
          _buildMenuItem(Icons.description_outlined, 'Điều khoản thỏa thuận', () {
            // TODO: Thêm logic
          }),
          _buildMenuItem(Icons.privacy_tip_outlined, 'Chính sách bảo mật', () {
            // TODO: Thêm logic
          }),


          const SizedBox(height: 24),

          const Text(
            'Giấy ĐKKD số 0104630479 do Sở KHĐT TP Hà Nội cấp lần đầu ngày 02/06/2010\n'
                'Chịu trách nhiệm sản GDTMDT: Ông Bạch Dương\n\n'
                'CÔNG TY CỔ PHẦN PROPERTYGURU VIỆT NAM\n'
                'Tầng 31, Keangnam Hanoi Landmark, Phạm Hùng, Nam Từ Liêm, Hà Nội\n'
                '(024) 3562 5933',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
          ),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerLeft,
            child: Image.network(
              'http://dangkywebvoibocongthuong.com/wp-content/uploads/2021/11/logo-da-dang-ky-bo-cong-thuong.png',
              height: 50,
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),

      // ===== Nút đăng tin
      floatingActionButton: SizedBox(
        height: 42,
        child: FloatingActionButton.extended(
          onPressed: () async {
            if (_isLoggedIn) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MemberScreen()),
                    (route) => false,
              );
            } else {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );

              if (result == true) {
                _checkLoginStatus();
              }
            }
          },
          backgroundColor: const Color(0xff0077bb),
          icon: const Icon(Icons.edit_note, size: 20, color: Colors.white),
          label: const Text(
            'Chuyển sang đăng tin',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }
}
