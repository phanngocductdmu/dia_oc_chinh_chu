import 'package:flutter/material.dart';

class PostProgressIndicator extends StatelessWidget {
  const PostProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0077BB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Bước 3. Cấu hình và thanh toán', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 3,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 3,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 3,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
