import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'PostProgressIndicator.dart';
import 'PaymentMethodScreen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';

class PostStep2Screen extends StatefulWidget {
  //step2
  final String? initialCoverImage;
  final List<Map<String, dynamic>>? initialSubImagesJson;
  // step1
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

  const PostStep2Screen({
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
    this.houseArea,
    this.totalFloorArea,
    this.pricePerM2,
    this.totalArea,
    this.initialCoverImage,
    this.initialSubImagesJson,
  });

  @override
  State<PostStep2Screen> createState() => _PostStep2ScreenState();
}

class _PostStep2ScreenState extends State<PostStep2Screen> {

  String coverImage = '';
  List<Map<String, dynamic>> subImagesJson = [];
  final TextEditingController descriptionController = TextEditingController();
  List<TextEditingController> subImageControllers = [];

  @override
  void initState() {
    super.initState();
    coverImage = widget.initialCoverImage ?? '';
    subImagesJson = widget.initialSubImagesJson ?? [];

    subImageControllers = subImagesJson
        .map((e) => TextEditingController(text: e['description'] ?? ''))
        .toList();
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  if (coverImage.isEmpty || coverImage == '') {
                    _selectCoverImageFromGallery();
                  } else {
                    _selectImageFromGallery();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh (đang tắt)'),
                enabled: false,
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectCoverImageFromGallery() {
    Navigator.pop(context);
    setState(() {
      coverImage = 'https://www.dropbox.com/scl/fi/6h0r6hhoffgvnijkq3adq/docc-cho-thue-nha-nguyen-can-le-van-sy-hem-o-to-2-chieu-4pn-gia-thue-chi-17-trieu-thang.jpg?rlkey=bpjphp12w0039aq3j8b9z1qlh&st=j9slas05&raw=1';
    });
  }

  String encodeImageToBase64WithMime(Uint8List bytes) {
    final mimeType = lookupMimeType('', headerBytes: bytes) ?? 'image/jpeg';
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();

      // ✅ Dùng lại hàm encode
      final dataUri = encodeImageToBase64WithMime(bytes);

      // ✅ Lấy mimeType từ dataUri
      final mimeType = dataUri.split(';')[0].split(':')[1];

      final newController = TextEditingController();

      setState(() {
        subImagesJson.add({
          "image": dataUri,
          "type": mimeType,
          "description": '',
        });
        subImageControllers.add(newController);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0077BB);
    debugPrint('selectedType: ${widget.selectedType}');
    debugPrint('selectedProvinceId: ${widget.selectedProvinceId}');
    debugPrint('selectedWardId: ${widget.selectedWardId}');
    debugPrint('selectedRoadId: ${widget.selectedRoadId}');
    debugPrint('selectedProvinceTitle: ${widget.selectedProvinceTitle ?? "null"}');
    debugPrint('selectedWardTitle: ${widget.selectedWardTitle ?? "null"}');
    debugPrint('selectedRoadTitle: ${widget.selectedRoadTitle ?? "null"}');
    debugPrint('fullAddress: ${widget.fullAddress ?? "null"}');
    debugPrint('selectedLatLng: ${widget.selectedLatLng != null ? "${widget.selectedLatLng!.latitude}, ${widget.selectedLatLng!.longitude}" : "null"}');
    debugPrint('selectedTypeInfo: ${widget.selectedTypeInfo}');
    debugPrint('typeId: ${widget.typeId}');
    debugPrint('area: ${widget.area}');
    debugPrint('price: ${widget.price}');
    debugPrint('unit: ${widget.unit}');
    debugPrint('legalDoc: ${widget.legalDoc ?? "null"}');
    debugPrint('interior: ${widget.interior ?? "null"}');
    debugPrint('direction: ${widget.direction ?? "null"}');
    debugPrint('bedrooms: ${widget.bedrooms}');
    debugPrint('bathrooms: ${widget.bathrooms}');
    debugPrint('floors: ${widget.floors}');
    debugPrint('frontage: ${widget.frontage ?? "null"}');
    debugPrint('contactName: ${widget.contactName}');
    debugPrint('contactEmail: ${widget.contactEmail ?? "null"}');
    debugPrint('contactPhone: ${widget.contactPhone}');
    debugPrint('title: ${widget.title}');
    debugPrint('description: ${widget.description}');
    debugPrint('houseLength: ${widget.houseLength}');
    debugPrint('houseWidth: ${widget.houseWidth}');
    debugPrint('landLength: ${widget.landLength}');
    debugPrint('landWidth: ${widget.landWidth}');
    debugPrint('landArea: ${widget.landArea}');
    debugPrint('houseArea: ${widget.houseArea ?? "null"}');
    debugPrint('totalFloorArea: ${widget.totalFloorArea ?? "null"}');
    debugPrint('pricePerM2: ${widget.pricePerM2 ?? "null"}');
    debugPrint('totalArea: ${widget.totalArea ?? "null"}');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tạo tin đăng', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: Colors.black),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text(
                'Thoát',
                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child:  Column(
          children: [
            const PostProgressIndicator(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Hình ảnh & video',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: _showImageSourceBottomSheet,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, color: Colors.grey),
                      SizedBox(width: 12),
                      Text('Thêm ảnh từ thiết bị',
                          style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (coverImage != '') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _showImageSourceBottomSheet,
                  child: Stack(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(coverImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              coverImage = '';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Nhập mô tả ảnh...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (value) {
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            if (subImagesJson.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 12,
                    runSpacing: 12,
                    children: subImagesJson.asMap().entries.map((entry) {
                      final index = entry.key;
                      final imgData = entry.value;
                      final base64Image = imgData['image'];
                      final description = imgData['description'] ?? '(Không có mô tả)';

                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
                        child: Stack(
                          children: [
                            // Ảnh
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: MemoryImage(base64Decode(base64Image.split(',').last),),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // Nút xoá ảnh
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    subImagesJson.removeAt(index);
                                    subImageControllers[index].dispose();
                                    subImageControllers.removeAt(index);
                                  });
                                },

                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),

                            // TextField mô tả (nằm dưới cùng của ảnh)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: TextField(
                                    controller: subImageControllers[index],
                                  onChanged: (value) {
                                    subImagesJson[index]['description'] = value;
                                  },
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  maxLines: 2,
                                  cursorColor: Colors.white,
                                  decoration: const InputDecoration(
                                    hintText: 'Nhập mô tả ảnh...',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Nút Quay lại
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'coverImage': coverImage,
                    'subImagesJson': subImagesJson,
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Quay lại', style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 12),
            // Nút Tiếp tục
            Expanded(
              child: ElevatedButton(
                onPressed: (coverImage != '' && subImagesJson.length >= 3)
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentMethodScreen(
                        coverImage: coverImage,
                        subImagesJson: subImagesJson,
                        selectedType: widget.selectedType,
                        typeId: widget.typeId,
                        selectedProvinceId: widget.selectedProvinceId,
                        selectedWardId: widget.selectedWardId,
                        selectedRoadId: widget.selectedRoadId,
                        selectedProvinceTitle: widget.selectedProvinceTitle,
                        selectedWardTitle: widget.selectedWardTitle,
                        selectedRoadTitle: widget.selectedRoadTitle,
                        fullAddress: widget.fullAddress,
                        selectedLatLng: widget.selectedLatLng,
                        selectedTypeInfo: widget.selectedTypeInfo,
                        area: widget.area,
                        price: widget.price,
                        unit: widget.unit,
                        legalDoc: widget.legalDoc,
                        interior: widget.interior,
                        direction: widget.direction,
                        bedrooms: widget.bedrooms,
                        bathrooms: widget.bathrooms,
                        floors: widget.floors,
                        frontage: widget.frontage,
                        contactName: widget.contactName,
                        contactEmail: widget.contactEmail,
                        contactPhone: widget.contactPhone,
                        title: widget.title,
                        description: widget.description,
                        houseLength: widget.houseLength,
                        houseWidth: widget.houseWidth,
                        landLength: widget.landLength,
                        landWidth: widget.landWidth,
                        landArea: widget.landArea,
                        houseArea: widget.houseArea,
                        totalFloorArea: widget.totalFloorArea,
                        pricePerM2: widget.pricePerM2,
                        totalArea: widget.totalArea,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (coverImage != '' && subImagesJson.length >= 3)
                      ? primaryColor
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Tiếp tục'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}