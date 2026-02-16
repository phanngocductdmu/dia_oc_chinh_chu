import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'postStep1/ConfirmAddressScreen.dart';
import './postStep1/post_type_selector.dart';
import './postStep1/address_box.dart';
import './postStep1/main_info_box.dart';
import './postStep1/OtherInfoBox.dart';
import './postStep1/ContactInfoBox.dart';
import './postStep1/TitleAndDescriptionBox.dart';
import 'package:html/parser.dart' as html_parser;

class UpdateInfoPost extends StatefulWidget {
  final int id;
  final String? token;

  const UpdateInfoPost({
    super.key,
    required this.id,
    this.token,
  });

  @override
  State<UpdateInfoPost> createState() => _UpdateInfoPostState();
}

class _UpdateInfoPostState extends State<UpdateInfoPost> {
  // Dữ liệu BĐS
  String area = '';
  String? selectedType;
  String? initialRstype;
  String selectedTypeInfo = '';
  String price = '', unit = '', title = '', description = '', contactName = '', contactPhone = '';
  String? contactEmail, legalDoc, interior, direction, frontage = '', savedCoverImage;
  dynamic selectedProvinceId, selectedWardId, selectedRoadId;
  String? houseNumber, selectedProvinceTitle, selectedWardTitle, selectedRoadTitle, fullAddress;
  LatLng? selectedLatLng;
  List<Map<String, dynamic>>? savedSubImagesJson;
  bool showFullOptions = true, showFullAddressBox = true;
  int typeId = 0, bedrooms = 0, bathrooms = 0, floors = 1;
  double landArea = 0;
  String houseLength = '', houseWidth = '', landLength = '', landWidth = '';
  double? houseArea, totalFloorArea, pricePerM2, totalArea;
  final primaryColor = const Color(0xFF0077BB);

  @override
  void initState() {
    super.initState();
    loadPostDetail();
  }

  Future<void> loadPostDetail() async {
    final response = await http.post(
      Uri.parse('https://account.nks.vn/api/nks/user/rsitem'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'id': widget.id.toString(), 'access_token': widget.token ?? ''},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        final data = json['data'];

        final rentPrice = data['rentprice'] ?? 0;
        final sqrRentPrice = data['sqrrentprice'] ?? 0;
        final priceValue = data['price'] ?? 0;
        final sqrPriceValue = data['sqrprice'] ?? 0;

        if (rentPrice > 0 || sqrRentPrice > 0) {
          selectedType = 'Cho thuê';
          price = data['rentprice']?.toString() ?? '';
        } else if (priceValue > 0 || sqrPriceValue > 0) {
          selectedType = 'Bán';
          price = data['price']?.toString() ?? '';
        } else {
          selectedType = null;
        }
        showFullOptions = selectedType == null;

        fullAddress = data['address'];
        selectedRoadId = data['road_id'];
        selectedProvinceId = data['add_province'];
        selectedWardId = data['add_administrative'];
        selectedRoadTitle = data['road']?['title'];
        selectedProvinceTitle = data['province'];
        selectedWardTitle = '';

        if (data['geolocation'] != null) {
          final parts = data['geolocation'].toString().split(',');
          if (parts.length == 2) {
            final lat = double.tryParse(parts[0].trim());
            final lng = double.tryParse(parts[1].trim());
            if (lat != null && lng != null) selectedLatLng = LatLng(lat, lng);
          }
        }

        title = data['title'] ?? '';
        final rawDescription = data['description'] ?? '';
        description = html_parser.parse(rawDescription).body?.text ?? '';
        price = data['price']?.toString() ?? '';
        pricePerM2 = (data['sqrprice'] ?? 0).toDouble();
        totalArea = (data['total_area'] ?? 0).toDouble();
        direction = data['direction'];
        initialRstype = data['rstype'];
        bedrooms = data['bed'] ?? 0;
        bathrooms = data['bath'] ?? 0;
        floors = data['floors'] ?? 0;
        houseLength = data['construct_length']?.toString() ?? '';
        houseWidth = data['construct_width']?.toString() ?? '';
        landWidth = (data['land_width'] ?? 0).toString();
        landLength = (data['land_length'] ?? 0).toString();
        landArea = (data['land_area'] ?? 0).toDouble();
        totalArea = (data['total_area'] ?? 0).toDouble();

        direction = data['direction'];
        legalDoc = data['legal'];

        contactPhone = (data['phone'] ?? data['sale']?['phone'])?.toString() ?? '';
        contactEmail =  data['email'] ?? data['sale']?['email'];
        contactName = data['sale']?['name'] ?? '';

        setState(() {});
      }
    }
  }

  void _handleAddressSelect() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressConfirmScreen(
          initProvinceId: selectedProvinceId,
          initWardId: selectedWardId,
          initRoadId: selectedRoadId,
          initProvinceTitle: selectedProvinceTitle,
          initWardTitle: selectedWardTitle,
          initRoadTitle: selectedRoadTitle,
          initLatLng: selectedLatLng,
        ),
      ),
    );
    if (!mounted) return;
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        houseNumber = result['house_number'];
        selectedProvinceId = result['province_id'];
        selectedWardId = result['ward_id'];
        selectedRoadId = result['road_id'];
        selectedProvinceTitle = result['province_title'];
        selectedWardTitle = result['ward_title'];
        selectedRoadTitle = result['road_title'];
        fullAddress = result['full_address'];
        selectedLatLng = result['latlng'];
      });
    }
  }

  void _handleAddressEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressConfirmScreen(
          initProvinceId: selectedProvinceId,
          initWardId: selectedWardId,
          initRoadId: selectedRoadId,
          initProvinceTitle: selectedProvinceTitle,
          initWardTitle: selectedWardTitle,
          initRoadTitle: selectedRoadTitle,
          initLatLng: selectedLatLng,
          initHouseNumber: houseNumber,
        ),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        houseNumber = result['house_number'];
        selectedProvinceId = result['province_id'];
        selectedWardId = result['ward_id'];
        selectedRoadId = result['road_id'];
        selectedProvinceTitle = result['province_title'];
        selectedWardTitle = result['ward_title'];
        selectedRoadTitle = result['road_title'];
        fullAddress = result['full_address'];
        selectedLatLng = result['latlng'];
      });
    }
  }

  bool get isFormValid {
    final phoneStr = contactPhone?.trim() ?? '';
    final phoneValid = phoneStr.isNotEmpty && RegExp(r'^\d{9,15}$').hasMatch(phoneStr);
    final emailValid = contactEmail == null || contactEmail!.trim().isEmpty ||
        RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(contactEmail!.trim());

    return selectedType?.isNotEmpty == true &&
        fullAddress?.isNotEmpty == true &&
        selectedTypeInfo.isNotEmpty &&
        contactName.trim().isNotEmpty &&
        phoneValid &&
        emailValid &&
        title.trim().length >= 5 &&
        description.trim().length >= 5;
  }


  Future<void> updatePost() async {
    final body = toUpdateBody();

    // 👉 In ra toàn bộ dữ liệu chuẩn bị update
    print('====== DỮ LIỆU UPDATE ======');
    body.forEach((key, value) {
      print('$key: $value');
    });
    print('=============================');

    try {
      final response = await http.post(
        Uri.parse('https://account.nks.vn/api/nks/user/rsitem/update'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          print('✅ Update thành công!');
          Navigator.pop(context, true);
        } else {
          print('❌ Update thất bại: ${json['message']}');
        }
      } else {
        print('❌ Update lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception khi update: $e');
    }
  }

  Map<String, String> toUpdateBody() {
    final totalAreaValue = totalArea ?? 0;
    final priceValue = double.tryParse(price) ?? 0;
    final rentPriceValue = selectedType == 'Cho thuê' ? priceValue : 0;
    final sellPriceValue = selectedType == 'Bán' ? priceValue : 0;

    final sqrPrice = totalAreaValue > 0 ? (sellPriceValue / totalAreaValue).round() : 0;
    final sqrRentPrice = totalAreaValue > 0 ? (rentPriceValue / totalAreaValue).round() : 0;
    final onsale = selectedType == 'Bán' ? 1 : 0;

    return {
      'id': widget.id.toString(),
      'access_token': widget.token ?? '',

      'geolocation': selectedLatLng != null ? '${selectedLatLng!.latitude},${selectedLatLng!.longitude}' : '',
      'street_area': frontage ?? '',
      'street_number': houseNumber ?? '',

      'road_id': selectedRoadId?.toString() ?? '',
      'administrative_id': selectedWardId?.toString() ?? '',
      'province_id': selectedProvinceId?.toString() ?? '',
      'country_id': '1',
      'city': selectedProvinceTitle ?? '',
      'province_title': selectedProvinceTitle ?? '',
      'ward_title': selectedWardTitle ?? '',
      'road_title': selectedRoadTitle ?? '',

      'fulladd': fullAddress ?? '',
      'phone': contactPhone ?? '',
      'email': contactEmail ?? '',
      'website': '',

      'price': sellPriceValue.toStringAsFixed(0),
      'sqrprice': sqrPrice.toString(),
      'rentprice': rentPriceValue.toStringAsFixed(0),
      'sqrrentprice': sqrRentPrice.toString(),
      'rentdeposit': '0',
      'commision': '0',

      'land_width': landWidth,
      'land_length': landLength,
      'total_area': landArea.toStringAsFixed(0),

      'construct_width': houseWidth,
      'construct_length': houseLength,
      'construct_area': houseArea?.toStringAsFixed(0) ?? '',

      'bed': bedrooms.toString(),
      'bath': bathrooms.toString(),
      'floors': floors.toString(),
      'road_width': frontage ?? '',
      'total_floor_area': totalFloorArea?.toStringAsFixed(0) ?? '',
      'price_per_m2': pricePerM2?.toString() ?? '',
      'unit': unit ?? '',

      'legal': legalDoc ?? '',
      'interior': interior ?? '',
      'direction': direction ?? '',
      'description': description,
      'title': title ?? '',
      'onsale': onsale.toString(),

      'rsproject': '',
      'rstype': typeId.toString(),

    };
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Chỉnh sửa thông tin', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Thoát', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PostTypeSelector(
                selectedType: selectedType,
                showFullOptions: showFullOptions,
                onTypeSelected: (type) => setState(() { selectedType = type; showFullOptions = false; }),
                onCollapse: () => setState(() => showFullOptions = true),
              ),
            ),
            if (selectedType != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: AddressBox(
                  fullAddress: fullAddress,
                  selectedLatLng: selectedLatLng,
                  showFullAddressBox: showFullAddressBox,
                  onToggle: () => setState(() => showFullAddressBox = !showFullAddressBox),
                  onEdit: _handleAddressEdit,
                  onSelect: _handleAddressSelect,
                ),
              ),

            const SizedBox(height: 16),

            if (fullAddress != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MainInfoBox(
                  selectedType: selectedType!,
                  initialRstype: initialRstype,
                  initialPrice: price,
                  initialUnit: unit,
                  initialHouseLength: houseLength,
                  initialHouseWidth: houseWidth,
                  initialLandLength: landLength,
                  initialLandWidth: landWidth,
                  initialBedrooms: bedrooms,
                  initialBathrooms: bathrooms,
                  initialFloors: floors,
                  initialLandArea: landArea,
                  initialHouseArea: houseArea,
                  initialTotalFloorArea: totalFloorArea,
                  initialPricePerM2: pricePerM2,
                  initialTotalArea: totalArea,
                  onChanged: ({
                    required int typeId,
                    required String typeTitle,
                    required String price,
                    required String unit,
                    required String houseLength,
                    required String houseWidth,
                    required String landLength,
                    required String landWidth,
                    required int bedrooms,
                    required int bathrooms,
                    required int floors,
                    required double landArea,
                    required double? houseArea,
                    required double? totalFloorArea,
                    required double? pricePerM2,
                    required double? totalArea,
                  }) {
                    setState(() {
                      this.typeId = typeId;
                      selectedTypeInfo = typeTitle;
                      this.price = price;
                      this.unit = unit;
                      this.houseLength = houseLength;
                      this.houseWidth = houseWidth;
                      this.landLength = landLength;
                      this.landWidth = landWidth;
                      this.bedrooms = bedrooms;
                      this.bathrooms = bathrooms;
                      this.floors = floors;
                      this.landArea = landArea;
                      this.houseArea = houseArea;
                      this.totalFloorArea = totalFloorArea;
                      this.pricePerM2 = pricePerM2;
                      this.totalArea = totalArea;
                    });
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (totalArea != null &&  price != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OtherInfoBox(
                  initialLegalDoc: legalDoc,
                  initialDirection: direction,
                  initialInterior: interior,
                  onChanged: ({
                    required String? legalDoc,
                    required String? interior,
                    required String? direction,
                  }) => setState(() {
                    this.legalDoc = legalDoc;
                    this.interior = interior;
                    this.direction = direction;
                  }),
                ),
              ),
            const SizedBox(height: 16),

            if (selectedTypeInfo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ContactInfoBox(
                  initialName: contactName,
                  initialEmail: contactEmail,
                  initialPhone: contactPhone,
                  onChanged: ({
                    required String name,
                    required String? email,
                    required String phone,
                  }) => setState(() {
                    contactName = name;
                    contactEmail = email;
                    contactPhone = phone;
                  }),
                ),
              ),

            const SizedBox(height: 16),

            if (selectedTypeInfo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TitleAndDescriptionBox(
                  selectedType: selectedType,
                  typeId: typeId,
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
                  totalArea: totalArea,
                  onChanged: (newTitle, newDescription) {
                    setState(() {
                      this.title = newTitle;
                      this.description = newDescription;
                    });
                  },
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: isFormValid ? () async {
            updatePost();
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFormValid ? primaryColor : Colors.grey[300],
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Xác nhận'),
        ),
      ),
    );
  }
}