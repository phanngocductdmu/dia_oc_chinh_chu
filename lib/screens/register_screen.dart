import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child:  Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                child: ListView(
                  children: [
                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 23, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      'Chào mừng bạn trở lại!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Vui lòng đăng nhập để tiếp tục',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email / SDT
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email hoặc số điện thoại';
                        }
                        return null;
                      },
                      decoration: _buildInputDecoration('Số điện thoại hoặc email', Icons.person_outline),
                    ),

                    // Ghi nhớ + Quên MK

                    const SizedBox(height: 20),

                    // Đăng nhập
                    ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff0077bb),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),

                    const SizedBox(height: 28),

                    // Hoặc
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Hoặc', style: TextStyle(color: Colors.black45)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Social login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon('https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png'),
                        const SizedBox(width: 20),
                        _buildSocialIcon('https://upload.wikimedia.org/wikipedia/commons/0/05/Facebook_Logo_%282019%29.png'),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Đăng ký
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Bạn đã có tài khoản'),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Đăng nhập', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Điều khoản
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        children: [
                          const TextSpan(text: 'Khi tiếp tục, bạn đã đồng ý với '),
                          _linkSpan('Điều khoản'),
                          const TextSpan(text: ', '),
                          _linkSpan('Chính sách bảo mật'),
                          const TextSpan(text: ' và '),
                          _linkSpan('Quy chế sử dụng'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade700),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xff0077bb), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildSocialIcon(String imageUrl) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      backgroundImage: NetworkImage(imageUrl),
    );
  }

  TextSpan _linkSpan(String text) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
        color: Colors.black,
      ),
    );
  }
}
