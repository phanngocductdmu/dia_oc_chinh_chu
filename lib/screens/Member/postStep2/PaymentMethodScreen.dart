import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../postStep3/post_step3_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  final String selectedType;
  final dynamic selectedProvinceId;
  final dynamic selectedWardId;
  final dynamic selectedRoadId;
  final int typeId;
  final String? selectedProvinceTitle;
  final String? selectedWardTitle;
  final String? selectedRoadTitle;
  final String? fullAddress;
  final LatLng? selectedLatLng;
  final String selectedTypeInfo;
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

  const PaymentMethodScreen({
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
    required this.typeId,
    required this.selectedType,
    required this.houseLength,
    required this.houseWidth,
    required this.landLength,
    required this.landWidth,
    required this.landArea,
    this.houseArea,
    this.totalFloorArea,
    this.pricePerM2,
    this.totalArea,
    this.coverImage,
    required this.subImagesJson,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0077BB);


    // print('🔹 selectedType (widget): ${selectedType}');
    // print('🔹 initialImages: ${coverImage}');
    // print('🔹 selectedProvinceId: ${selectedProvinceId}');
    // print('🔹 selectedWardId: ${selectedWardId}');
    // print('🔹 selectedRoadId: ${selectedRoadId}');
    // print('🔹 selectedProvinceTitle: ${selectedProvinceTitle}');
    // print('🔹 selectedWardTitle: ${selectedWardTitle}');
    // print('🔹 selectedRoadTitle: ${selectedRoadTitle}');
    // print('🔹 fullAddress: ${fullAddress}');
    // print('🔹 selectedLatLng: ${selectedLatLng?.latitude}, ${selectedLatLng?.longitude}');
    // print('🔹 selectedTypeInfo: ${selectedTypeInfo}');
    // print('🔹 typeId: ${typeId}');
    // print('🔹 area: ${area}');
    // print('🔹 price: ${price}');
    // print('🔹 unit: ${unit}');
    // print('🔹 legalDoc: ${legalDoc}');
    // print('🔹 interior: ${interior}');
    // print('🔹 direction: ${direction}');
    // print('🔹 bedrooms: ${bedrooms}');
    // print('🔹 bathrooms: ${bathrooms}');
    // print('🔹 floors: ${floors}');
    // print('🔹 frontage: ${frontage}');
    // print('🔹 contactName: ${contactName}');
    // print('🔹 contactEmail: ${contactEmail}');
    // print('🔹 contactPhone: ${contactPhone}');
    // print('🔹 title: ${title}');
    // print('🔹 description: ${description}');
    // print('🔹 houseLength: ${houseLength}');
    // print('🔹 houseWidth: ${houseWidth}');
    // print('🔹 landLength: ${landLength}');
    // print('🔹 landWidth: ${landWidth}');
    // print('🔹 landArea: ${landArea}');
    // print('🔹 houseArea: ${houseArea}');
    // print('🔹 totalFloorArea: ${totalFloorArea}');
    // print('🔹 pricePerM2: ${pricePerM2}');
    // print('🔹 totalArea: ${totalArea}');
    // print('✅ coverImage: $coverImage');
    // print('✅ subImagesJson:');

    // for (var i = 0; i < subImagesJson.length; i++) {
    //   final base64 = subImagesJson[i]['image'] ?? '';
    //   final type = subImagesJson[i]['type'] ?? '';
    //   final desc = subImagesJson[i]['description'] ?? '';
    //
    //   print('🖼️ [$i]');
    //   print('📦 type: $type');
    //   print('📝 desc: $desc');
    //   print('📸 base64:\n$base64\n');
    // }


    Widget buildPaymentOption({
      required String title,
      required String description1,
      required String description2,
      required IconData icon,
      bool isDiscount = false,
    }) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Colors.black),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                if (isDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Giảm 25%',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(description1,
                      style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.monetization_on_outlined, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(description2,
                      style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Phương thức thanh toán mới',
            style: TextStyle(color: Colors.black)),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildPaymentOption(
              title: 'Trả theo ngày',
              description1: 'Áp dụng cho mọi loại tin',
              description2: 'Thanh toán theo ngày hiển thị',
              icon: Icons.calendar_today,
            ),
            buildPaymentOption(
              title: 'Trả theo click',
              description1: 'Chỉ áp dụng cho tin VIP',
              description2: 'Hiển thị miễn phí, chỉ thanh toán khi tin có lượt click',
              icon: Icons.flash_on,
              isDiscount: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostStep3Screen(
                  coverImage: coverImage,
                  subImagesJson: subImagesJson,
                  totalArea: totalArea,
                  typeId: typeId,
                  selectedType: selectedType,
                  selectedProvinceId: selectedProvinceId,
                  selectedWardId: selectedWardId,
                  selectedRoadId: selectedRoadId,
                  selectedProvinceTitle: selectedProvinceTitle,
                  selectedWardTitle: selectedWardTitle,
                  selectedRoadTitle: selectedRoadTitle,
                  fullAddress: fullAddress,
                  selectedLatLng: selectedLatLng,
                  selectedTypeInfo: selectedTypeInfo,
                  area: area,
                  price: price,
                  unit: unit,
                  legalDoc: legalDoc,
                  interior: interior,
                  direction: direction,
                  bedrooms: bedrooms,
                  bathrooms: bathrooms,
                  floors: floors,
                  frontage: frontage,
                  contactName: contactName,
                  contactEmail: contactEmail,
                  contactPhone: contactPhone,
                  title: title,
                  description: description,
                  houseLength: houseLength,
                  houseWidth: houseWidth,
                  landLength: landLength,
                  landWidth: landWidth,
                  landArea: landArea,
                  houseArea: houseArea,
                  totalFloorArea: totalFloorArea,
                  pricePerM2: pricePerM2,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Tiếp tục'),
        ),
      ),
    );
  }
}