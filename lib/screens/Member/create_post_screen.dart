import 'package:diaocchinhchu/screens/Member/postStep1/OtherInfoBox.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'postStep1/ConfirmAddressScreen.dart';
import './postStep1/post_type_selector.dart';
import './postStep1/address_box.dart';
import './postStep1/progress_indicator.dart';
import './postStep1/main_info_box.dart';
import './postStep1/ContactInfoBox.dart';
import './postStep1/TitleAndDescriptionBox.dart';
import './postStep2/post_step2_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String? selectedType;
  bool showFullOptions = true;
  bool showFullAddressBox = true;
  int currentStep = 0;

  dynamic selectedProvinceId, selectedWardId, selectedRoadId;
  String? houseNumber, selectedProvinceTitle, selectedWardTitle, selectedRoadTitle, fullAddress;
  LatLng? selectedLatLng;

  String selectedTypeInfo = '';
  int typeId = 0;
  String area = '', price = '', unit = '';
  String? legalDoc, interior, direction;
  int bedrooms = 0, bathrooms = 0, floors = 1;
  double landArea = 0;
  String houseLength = '', houseWidth = '', landLength = '', landWidth = '';
  double? houseArea, totalFloorArea, pricePerM2, totalArea;
  String? frontage = '';
  String contactName = '', contactPhone = '', title = '', description = '';
  String? contactEmail;
  String? savedCoverImage;
  List<Map<String, dynamic>>? savedSubImagesJson;

  final primaryColor = const Color(0xFF0077BB);

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
    final phoneValid = RegExp(r'^\d{9,15}$').hasMatch(contactPhone.trim());
    final emailValid = contactEmail == null || contactEmail!.trim().isEmpty ||
        RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(contactEmail!.trim());


    return selectedType?.isNotEmpty == true &&
        fullAddress?.isNotEmpty == true &&
        selectedTypeInfo.isNotEmpty &&
        pricePerM2 != null &&
        contactName.trim().isNotEmpty &&
        phoneValid &&
        emailValid &&
        title.trim().length >= 5 &&
        description.trim().length >= 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Tạo tin đăng', style: TextStyle(color: Colors.black)),
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
            const PostProgressIndicator(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PostTypeSelector(
                selectedType: selectedType,
                showFullOptions: showFullOptions,
                onTypeSelected: (type) {
                  setState(() {
                    selectedType = type;
                    showFullOptions = false;
                  });
                },
                onCollapse: () {
                  setState(() {
                    showFullOptions = true;
                  });
                },
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
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
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
                    });
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (selectedTypeInfo.isNotEmpty && pricePerM2 != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OtherInfoBox(
                  onChanged: ({required String? legalDoc, required String? interior, required String? direction}) {
                    setState(() {
                      this.legalDoc = legalDoc;
                      this.interior = interior;
                      this.direction = direction;
                    });
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (selectedTypeInfo.isNotEmpty && pricePerM2 != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ContactInfoBox(
                  onChanged: ({required String name, required String? email, required String phone}) {
                    setState(() {
                      contactName = name;
                      contactEmail = email;
                      contactPhone = phone;
                    });
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (selectedTypeInfo.isNotEmpty && pricePerM2 != null)
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
          onPressed: isFormValid
              ? () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostStep2Screen(
                  selectedType: selectedType ?? '',
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
                  pricePerM2: pricePerM2,
                  totalArea: totalArea,
                  initialCoverImage: savedCoverImage,
                  initialSubImagesJson: savedSubImagesJson,
                ),
              ),
            );
            if (result != null) {
              setState(() {
                savedCoverImage = result['coverImage'];
                savedSubImagesJson = List<Map<String, dynamic>>.from(result['subImagesJson']);
              });
            }
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFormValid ? primaryColor : Colors.grey[300],
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