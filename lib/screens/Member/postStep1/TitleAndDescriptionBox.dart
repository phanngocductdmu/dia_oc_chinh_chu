import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class TitleAndDescriptionBox extends StatefulWidget {
  final String? selectedType;
  final int typeId;
  final dynamic selectedProvinceId, selectedWardId, selectedRoadId;
  final String? selectedProvinceTitle, selectedWardTitle, selectedRoadTitle, fullAddress;
  final LatLng? selectedLatLng;
  final String selectedTypeInfo;
  final String area, price, unit;
  final String? legalDoc, interior, direction;
  final int bedrooms, bathrooms, floors;
  final String? frontage;
  final String contactName, contactPhone, title, description;
  final String? contactEmail;
  final String houseLength, houseWidth, landLength, landWidth;
  final double landArea;
  final double? houseArea, totalFloorArea, pricePerM2, totalArea;

  final void Function(String title, String description)? onChanged;

  const TitleAndDescriptionBox({
    super.key,
    required this.selectedType,
    required this.typeId,
    required this.selectedProvinceId,
    required this.selectedWardId,
    required this.selectedRoadId,
    required this.selectedProvinceTitle,
    required this.selectedWardTitle,
    required this.selectedRoadTitle,
    required this.fullAddress,
    required this.selectedLatLng,
    required this.selectedTypeInfo,
    required this.area,
    required this.price,
    required this.unit,
    required this.legalDoc,
    required this.interior,
    required this.direction,
    required this.bedrooms,
    required this.bathrooms,
    required this.floors,
    required this.frontage,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.title,
    required this.description,
    required this.houseLength,
    required this.houseWidth,
    required this.landLength,
    required this.landWidth,
    required this.landArea,
    required this.houseArea,
    required this.totalFloorArea,
    required this.pricePerM2,
    required this.totalArea,
    this.onChanged,
  });

  @override
  State<TitleAndDescriptionBox> createState() => _TitleAndDescriptionBoxState();
}

class _TitleAndDescriptionBoxState extends State<TitleAndDescriptionBox> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool expanded = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    final plainText = widget.description ?? '';
    _descriptionController = TextEditingController(text: plainText);

    _titleController.addListener(_notifyParent);
    _descriptionController.addListener(_notifyParent);
  }

  void _notifyParent() {
    widget.onChanged?.call(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
    );
  }


  Future<void> _generateDescriptionWithAI() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final mkg =
          'Viết giúp một cách giống như là tôi đang giới thiệu một khách hàng lạ để tôi copy mô tả nhà phố bao gồm: '
          ' ${widget.selectedType}, '
          '${widget.bedrooms} phòng ngủ, '
          '${widget.bathrooms} phòng vệ sinh, '
          '${widget.floors} tầng, '
          'chiều ngang đất ${widget.houseWidth}m2, '
          'chiều dài ${widget.houseLength}m2, '
          'diện tích đất ${widget.landArea}m2, '
          'giá/m2: ~${widget.pricePerM2}, '
          'căn nhà nằm tại vị trí ${widget.fullAddress}, '
          'Pháp lý là ${widget.legalDoc}, '
          'Nội thất là ${widget.interior}, '
          'tên là  ${widget.contactName}, '
          'Số điện thoại là ${widget.contactPhone}, ';

      final response = await http.post(
        Uri.parse('https://online.nks.vn/api/nks/aichat/generate'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'msg': mkg},
      );

      if (response.statusCode == 200) {
        // Parse JSON, lấy data
        final json = jsonDecode(response.body);
        final aiText = json['data'] ?? '';

        setState(() {
          _descriptionController.text = aiText;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tạo được mô tả, vui lòng thử lại.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
          Row(
            children: [
              const Text('Tiêu đề & Mô tả', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text('Tiêu đề', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              maxLength: 99,
              decoration: const InputDecoration(
                hintText: 'Mô tả ngắn gọn về loại hình, diện tích, địa chỉ...',
                counterText: 'Tối đa 99 ký tự',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateDescriptionWithAI,
                  icon: _isLoading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.auto_awesome, size: 16, color: Colors.white,),
                  label: Text(
                    _isLoading ? 'Đang tạo...' : 'Tạo mô tả với AI',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0077bb),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLength: 3000,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Mô tả chi tiết về: loại hình, vị trí, diện tích, tiện ích, nội thất...',
                counterText: 'Tối đa 3000 ký tự',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}