import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final int postId;
  final String title;
  final String address;
  final String imageUrl;
  final int selectedDays;
  final int pricePerDay;
  final DateTime startDate;
  final DateTime endDate;
  final int discount;
  final int total;

  const PaymentSuccessScreen({
    super.key,
    required this.postId,
    required this.title,
    required this.address,
    required this.imageUrl,
    required this.selectedDays,
    required this.pricePerDay,
    required this.startDate,
    required this.endDate,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Kết quả giao dịch', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
          const SizedBox(height: 12),
          const Text('Đăng tin thành công', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '${(pricePerDay * selectedDays).toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} đ',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          const Text('Tin của bạn sẽ được kiểm duyệt trong vòng 8h', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('Trạng thái', 'Chờ duyệt', badgeColor: Colors.orange),
                const SizedBox(height: 12),
                _buildInfoRow('Mã tin', postId.toString(), isCopyable: true),
                const SizedBox(height: 12),
                _buildInfoRow('Thời gian đăng', '${formatter.format(startDate)} - ${formatter.format(endDate)}'),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Bạn đánh giá thế nào về trải nghiệm đăng tin mới?', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (_) => const Icon(Icons.star_border, size: 32, color: Colors.grey)),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Dùng kèm các dịch vụ sau để “chốt đơn” nhanh hơn',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          int count = 0;
                          Navigator.popUntil(context, (_) => count++ >= 2);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.black26),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text(
                          'Đăng tiếp',
                          style: TextStyle(fontSize: 15, color: Color(0xff0077bb)),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Quản lý tin đăng
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff0077bb),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Quản lý tin đăng', style: TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCopyable = false, Color? badgeColor}) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.black54))),
        if (badgeColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600)),
          )
        else if (isCopyable)
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.copy, size: 16, color: Colors.grey),
            ],
          )
        else
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}