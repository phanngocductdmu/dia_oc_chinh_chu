import 'package:flutter/material.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  static const primaryColor = Color(0xFF0077BB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              Text(
                'Quản lý khách hàng',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Danh sách khách hàng đã có tương tác với tin đăng của bạn',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                  Icon(Icons.info_outline, size: 16, color: Colors.black38),
                ],
              ),
              const SizedBox(height: 20),

              // Thanh tìm kiếm
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.black45),
                    hintText: 'Tìm theo tên KH, sđt hoặc email',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lọc và đếm
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('0 khách hàng', style: TextStyle(fontSize: 14)),
                  Row(
                    children: [
                      const Text('Chỉ chưa đọc', style: TextStyle(fontSize: 13)),
                      Switch(
                        value: false,
                        onChanged: (_) {},
                        activeColor: primaryColor,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Hiển thị khi không có khách hàng
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // TODO: Thay thế bằng ảnh thật nếu có
                      Icon(Icons.visibility_off, size: 90, color: Colors.grey[300]),
                      const SizedBox(height: 20),
                      const Text(
                        'Chưa có khách hàng nào',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Hiện tại chưa có khách hàng nào',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
