import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'PaymentSuccessScreen.dart';
import 'PostProgressIndicator.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostStep3Screen extends StatefulWidget {
  final String selectedType;
  final dynamic selectedProvinceId;
  final dynamic selectedWardId;
  final dynamic selectedRoadId;
  final String? selectedProvinceTitle;
  final String? selectedWardTitle;
  final String? selectedRoadTitle;
  final String? fullAddress;
  final LatLng? selectedLatLng;
  final String selectedTypeInfo;
  final int typeId;
  final String area;
  final String price;
  final String unit;
  final String? legalDoc;
  final String? interior;
  final String? direction;
  final int bedrooms;
  final int bathrooms;
  final int floors;
  final String? frontage;
  final String contactName;
  final String? contactEmail;
  final String contactPhone;
  final String title;
  final String description;
  final String houseLength;
  final String houseWidth;
  final String landLength;
  final String landWidth;
  final double landArea;
  final double? houseArea;
  final double? totalFloorArea;
  final double? pricePerM2;
  final double? totalArea;
  final String? coverImage;
  final List<Map<String, dynamic>> subImagesJson;

  const PostStep3Screen({
    super.key,
    required this.selectedProvinceId,
    required this.selectedWardId,
    required this.selectedRoadId,
    required this.selectedProvinceTitle,
    required this.selectedWardTitle,
    required this.selectedRoadTitle,
    required this.fullAddress,
    required this.selectedLatLng,
    required this.selectedTypeInfo,
    required this.typeId,
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
    required this.selectedType,
    required this.houseLength,
    required this.houseWidth,
    required this.landLength,
    required this.landWidth,
    required this.landArea,
    required this.houseArea,
    required this.totalFloorArea,
    required this.pricePerM2,
    this.totalArea,
    this.coverImage,
    required this.subImagesJson,
  });

  @override
  State<PostStep3Screen> createState() => _PostStep3ScreenState();
}


class _PostStep3ScreenState extends State<PostStep3Screen> {
  final Color primaryColor = const Color(0xFF0077BB);
  int selectedOffset = 0;
  int selectedDays = 7;


  DateTime get today => DateTime.now();

  DateTime get startDate => today.subtract(Duration(days: selectedOffset));
  DateTime get endDate => startDate.add(Duration(days: selectedDays));

  bool isSubmitting = false;
  final Map<int, int> pricePerDay = {
    7: 62300,
    10: 59200,
    15: 56100,
  };

  int get totalPrice => selectedDays * (pricePerDay[selectedDays] ?? 0);

  Future<void> confirmBeforePayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blueAccent),
            const SizedBox(width: 8),
            const Text(
              'Xác nhận thanh toán',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF0077BB),
              ),
            ),
          ],
        ),
        content: const Text(
          'Bạn có muốn thanh toán và đăng tin ngay bây giờ không? Tin sẽ được hiển thị sau khi thanh toán.',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077BB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // ✅ Hiện loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // ✅ Gọi API tạo tin
      await submitPostToApi();

      // ✅ Tắt loading
      if (mounted) Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            postId: 123123213123 ?? 0,
            title: widget.title,
            address: widget.fullAddress ?? '',
            imageUrl: widget.coverImage!,
            selectedDays: selectedDays,
            pricePerDay: pricePerDay[selectedDays]!,
            startDate: startDate,
            endDate: startDate.add(Duration(days: selectedDays)),
            discount: totalPrice, // nếu khuyến mãi 100%
            total: 0,
          ),
        ),
      );

    }
  }

  double parsePriceString(String input) {
    print('👉 Đầu vào giá: "$input"');

    String cleaned = input.toLowerCase().replaceAll('.', '').replaceAll(',', '');
    cleaned = cleaned.replaceAll(RegExp(r'[^\d]'), '');

    double? number = double.tryParse(cleaned);
    if (number == null) {
      print('❌ Không thể parse được: "$cleaned"');
      return 0;
    }

    if (input.contains('tỷ') || input.contains('ty')) {
      print('✅ Giá (tỷ): ${number * 1000000000}');
      return number * 1000000000;
    } else if (input.contains('triệu') || input.contains('tr')) {
      print('✅ Giá (triệu): ${number * 1000000}');
      return number * 1000000;
    }

    print('✅ Giá (raw): $number');
    return number;
  }

  Future<void> submitPostToApi() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');

    if (accessToken == null || accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy access token. Vui lòng đăng nhập lại.')),
      );
      return;
    }

    final String uuid = const Uuid().v4();
    final String slug = widget.title
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s-]"), '')
        .replaceAll(RegExp(r"\s+"), '-');

    // Parse số
    final double landWidth = double.tryParse(widget.landWidth) ?? 0;
    final double landLength = double.tryParse(widget.landLength) ?? 0;
    final double houseWidth = double.tryParse(widget.houseWidth) ?? 0;
    final double houseLength = double.tryParse(widget.houseLength) ?? 0;
    final double landArea = widget.landArea;
    final double houseArea = widget.houseArea ?? 0;
    final double totalFloorArea = widget.totalFloorArea ?? houseArea;

    final double rawPrice = parsePriceString(widget.price);
    final double priceValue = rawPrice > 0 ? rawPrice : 1;

    final String type = widget.selectedType.toLowerCase();
    final bool isForSale = type.contains('bán');
    final bool isForRent = type.contains('thuê');
    final int onsaleValue = isForSale ? 1 : 0;

    final int? saleSqrPrice = isForSale && totalFloorArea > 0
        ? (priceValue / totalFloorArea).round()
        : null;
    final int? rentSqrPrice = isForRent && totalFloorArea > 0
        ? (priceValue / totalFloorArea).round()
        : null;

    final bodyData = {
      "access_token": accessToken,
      "code": uuid,
      "title": widget.title,
      "slug": slug,
      "featureimg": widget.coverImage,
      "geolocation":
      "${widget.selectedLatLng?.latitude ?? 0.0},${widget.selectedLatLng?.longitude ?? 0.0}",
      "street_area": "",
      "street_number": "",
      "road_id": widget.selectedRoadId ?? 0,
      "administrative_id": widget.selectedWardId ?? 0,
      "province_id": widget.selectedProvinceId ?? 0,
      "country_id": 1,
      "city": widget.selectedProvinceTitle ?? "",
      "fulladd": widget.fullAddress ?? "",
      "phone": widget.contactPhone,
      "email": widget.contactEmail ?? "",
      "website": "",
      "price": isForSale ? priceValue : 0,
      "sqrprice": saleSqrPrice ?? 0,
      "rentprice": isForRent ? priceValue : 0,
      "sqrrentprice": rentSqrPrice ?? 0,
      "rentdeposit": "0",
      "commision": "0",
      "direction": widget.direction ?? "",
      "land_width": landWidth.toString(),
      "land_length": landLength.toString(),
      "land_area": landArea,
      "construct_width": houseWidth.toString(),
      "construct_length": houseLength.toString(),
      "construct_area": houseArea,
      "bed": widget.bedrooms,
      "bath": widget.bathrooms,
      "floors": widget.floors,
      "road_width": widget.frontage ?? "0",
      "legal": widget.legalDoc ?? "",
      "description": widget.description,
      "onsale": onsaleValue,
      "rsproject": "",
      "rstype": widget.typeId,
      "total_area": widget.totalArea,
    };

    try {
      final response = await http.post(
        Uri.parse('https://account.nks.vn/api/nks/user/rsitem/create'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(bodyData),
      );

      print('📤 Dữ liệu gửi đi:\n${jsonEncode(bodyData)}');
      print('📥 Phản hồi:\n${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Lấy ID bài đăng từ phản hồi
        final int? postId = responseData['data']?['id'];

        if (postId != null) {
          await uploadImageToRsItem(
            context: context,
            accessToken: accessToken,
            rsItemId: postId,
          );
        } else {
          print('⚠️ Không tìm thấy ID trong phản hồi.');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng tin thành công!')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e, stacktrace) {
      print('❌ Lỗi kết nối: $e\n$stacktrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e')),
      );
    }
  }

  Future<void> uploadImageToRsItem({
    required BuildContext context,
    required String accessToken,
    required int rsItemId,
  }) async {
    final url = Uri.parse('https://account.nks.vn/api/nks/user/rsitemimg/add');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff0077bb))),
    );

    for (var i = 0; i < widget.subImagesJson.length; i++) {
      final base64 = widget.subImagesJson[i]['image'] ?? '';
      final type = widget.subImagesJson[i]['type'] ?? '';
      final desc = widget.subImagesJson[i]['description'] ?? '';
      if (base64.isEmpty) continue;

      final bodyData = {
        "access_token": accessToken,
        "rsitem_id": rsItemId.toString(),
        "image": base64,
        "note": desc,
      };

      try {
        final response = await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bodyData),
        );

        print('📥 Status: ${response.statusCode}');
        print('📥 Response: ${response.body}');

        if (response.statusCode == 200) {
          print('✅ [$i] Upload ảnh thành công');
        } else {
          print('❌ [$i] Lỗi upload ảnh: ${response.statusCode}');
        }
      } catch (e, stack) {
        print('❌ [$i] Exception khi upload ảnh: $e');
        print('📛 Stacktrace: $stack');
      }
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Tạo tin đăng', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: const Text('Thoát',
                  style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PostProgressIndicator(),
            _buildCard(
              title: 'VIP Bạc',
              subtitle: 'Dưới VIP Vàng',
              child: Column(
                children: pricePerDay.entries.map((entry) {
                  return RadioListTile<int>(
                    title: Text('${entry.key} ngày    ${entry.value ~/ 1000}.${entry.value % 1000 ~/ 100}00 đ/ngày'),
                    value: entry.key,
                    groupValue: selectedDays,
                    onChanged: (val) => setState(() => selectedDays = val!),
                    activeColor: primaryColor,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Ngày bắt đầu: '),
                      Text(formatter.format(startDate), style: const TextStyle(fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text('Kết thúc ngày ${formatter.format(endDate)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.discount, color: Colors.green, size: 18),
                      SizedBox(width: 4),
                      Text('Đã áp dụng 1 khuyến mãi', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '${totalPrice.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")} đ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            _buildCard(
              title: 'Thanh toán',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.coverImage!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(widget.fullAddress ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRow(
                    'Đơn giá',
                    '${(pricePerDay[selectedDays]! ~/ 1000)}.${(pricePerDay[selectedDays]! % 1000 ~/ 100)}00 đ/ngày',
                  ),
                  _buildRow('Số ngày đăng', '$selectedDays ngày'),
                  _buildRow('Thời gian đăng', 'Đăng tin ngay'),
                  _buildRow('Thời gian kết thúc', formatter.format(endDate)),
                  _buildRow(
                    'Phí đăng tin',
                    '${totalPrice.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} đ',
                  ),
                  _buildRow(
                    '🔖 Khuyến mãi',
                    '-${totalPrice.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} đ',
                    valueColor: Colors.green,
                  ),
                  _buildRow('Tổng tiền', '0 đ', isBold: true, valueColor: primaryColor),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Quay lại', style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: confirmBeforePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, String? subtitle, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle),
            ],
            const SizedBox(height: 12),
            child
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}