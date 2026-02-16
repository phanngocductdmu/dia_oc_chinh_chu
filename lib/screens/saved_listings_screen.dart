import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  State<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends State<SavedListingsScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus(); // gọi lại mỗi lần chuyển tab quay về
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // bắt buộc khi dùng AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tin đã lưu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xfffdfdfd),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: _isLoggedIn
              ? _buildLoggedInMessage()
              : _buildLoginPrompt(context),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xffeaf2ff),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bookmark_border, size: 28, color: Color(0xff0066ff)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Đăng nhập tài khoản để xem các tin đăng bạn đã lưu',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.black, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              if (result == true) {
                _checkLoginStatus(); // Sau khi đăng nhập xong, cập nhật lại
              }
            },
            child: const Text('Đăng nhập'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInMessage() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lưu lại tin đăng bạn quan tâm.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          'Nhấn vào biểu tượng trái tim khi lướt tìm kiếm để lưu lại tin đăng.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}