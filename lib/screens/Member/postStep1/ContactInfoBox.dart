import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactInfoBox extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;
  final void Function({
  required String name,
  required String? email,
  required String phone,
  })? onChanged;

  const ContactInfoBox({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.onChanged,
  });

  @override
  State<ContactInfoBox> createState() => _ContactInfoBoxState();
}

class _ContactInfoBoxState extends State<ContactInfoBox> {
  bool expanded = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  /// Khởi tạo dữ liệu từ widget hoặc từ SharedPreferences
  Future<void> _initializeFields() async {
    if ((widget.initialName?.isNotEmpty ?? false) ||
        (widget.initialEmail?.isNotEmpty ?? false) ||
        (widget.initialPhone?.isNotEmpty ?? false)) {
      _nameController.text = widget.initialName ?? '';
      _emailController.text = widget.initialEmail ?? '';
      _phoneController.text = widget.initialPhone ?? '';
    } else {
      final prefs = await SharedPreferences.getInstance();
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
    }

    _notifyParent();
    setState(() {}); // Cập nhật UI nếu dữ liệu từ SharedPreferences
  }

  /// Gửi dữ liệu lên widget cha và lưu vào SharedPreferences
  Future<void> _notifyParent() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);

    widget.onChanged?.call(
      name: name,
      email: email.isEmpty ? null : email,
      phone: phone,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Tiêu đề
          Row(
            children: [
              const Text(
                'Thông tin liên hệ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black54,
                ),
                onPressed: () => setState(() => expanded = !expanded),
              ),
            ],
          ),

          if (expanded) ...[
            const SizedBox(height: 16),

            /// Họ tên
            _buildTextField(
              controller: _nameController,
              hintText: 'Tên liên hệ',
              keyboardType: TextInputType.name,
              onChanged: (_) => _notifyParent(),
            ),

            const SizedBox(height: 16),

            /// Email (không bắt buộc)
            _buildTextField(
              controller: _emailController,
              hintText: 'Email (không bắt buộc)',
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => _notifyParent(),
            ),

            const SizedBox(height: 16),

            /// Số điện thoại
            _buildTextField(
              controller: _phoneController,
              hintText: 'Số điện thoại',
              keyboardType: TextInputType.phone,
              onChanged: (_) => _notifyParent(),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget InputField dùng lại
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required void Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        isDense: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
