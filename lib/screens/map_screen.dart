import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapController = MapController();
  List<Marker> _markers = [];
  List<Map<String, dynamic>> provinces = [];
  Map<String, dynamic>? selectedProvince;
  LatLng? _currentPosition;
  Timer? _debounce;
  final double _zoomThreshold = 13;
  bool _isFetching = false;
  int totalProperties = 0;
  bool _isLoadingLocation = true;
  Map<String, dynamic>? selectedWard;
  List<Map<String, dynamic>> _allData = [];
  double rotationAngle = 0;


  bool isLoading = true;
  String selectedMode = 'Mua';
  String selectedType = 'Loại nhà đất';
  String selectedPrice = 'Khoảng giá';
  String selectedArea = 'Diện tích';
  String selectedBedroom = 'Số phòng ngủ';
  String selectedDirection = 'Hướng nhà';
  RangeValues selectedPriceRange = const RangeValues(0, 60000000000);
  RangeValues selectedAreaRange = const RangeValues(0, 1000);

  final List<String> sortOptions = [
    'Sắp xếp',
    'Giá thấp đến cao',
    'Giá cao đến thấp',
    'Giá/m² thấp đến cao',
    'Giá/m² cao đến thấp',
    'Diện tích nhỏ đến lớn',
    'Diện tích lớn đến nhỏ',
  ];

  final List<String> propertyTypes = [
    'Tất cả',
    'Nhà phố',
    'Biệt thự',
    'Căn hộ',
    'Shophouse',
    'Mặt bằng',
    'Văn phòng',
    'Đất nền',
  ];

  final List<String> bedroomCounts = [
    'Tất cả',
    '1 phòng',
    '2 phòng',
    '3 phòng',
    '4 phòng',
    '5+ phòng',
  ];

  final List<String> houseDirections = [
    'Tất cả',
    'Đông',
    'Tây',
    'Nam',
    'Bắc',
    'Đông Bắc',
    'Đông Nam',
    'Tây Bắc',
    'Tây Nam',
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final permission = await Permission.location.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần cấp quyền vị trí để hiển thị bản đồ')),
      );
      setState(() => _isLoadingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final latLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentPosition = latLng;
      _isLoadingLocation = false;
    });

    mapController.move(latLng, 15);
    _fetchRealEstateListings(latLng);
  }

  void _onMapMoved(LatLng center) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchRealEstateListings(center);
    });
  }

  bool _matchesBedroom(int bed, String selected) {
    selected = selected.toLowerCase();
    if (selected.contains('tất cả') || selected.contains('số phòng ngủ')) return true;
    if (selected.contains('1 phòng')) return bed == 1;
    if (selected.contains('2 phòng')) return bed == 2;
    if (selected.contains('3 phòng')) return bed == 3;
    if (selected.contains('4 phòng')) return bed == 4;
    if (selected.contains('5+')) return bed >= 5;
    return true;
  }

  List<Map<String, dynamic>> filterAndSortProperties({
    required List<Map<String, dynamic>> all,
    required String selectedMode,
    required String selectedType,
    required double minPrice,
    required double maxPrice,
    required double minArea,
    required double maxArea,
    required String selectedBedroom,
    required String selectedDirection,
  }) {
    String clean(dynamic s) => s?.toString().trim().toLowerCase() ?? '';
    final cleanSelectedType = clean(selectedType);
    final cleanSelectedDirection = clean(selectedDirection);
    final filtered = all.where((item) {
      final price = item['price'] ?? 0;
      final rentPrice = item['rentprice'] ?? 0;
      final type = clean(item['rstype']);
      final area = (item['total_area'] ?? item['area'] ?? item['sqr'])?.toDouble() ?? 0;
      final bed = item['bed'] ?? 0;
      final direction = clean(item['direction']);
      final isBuy = selectedMode == 'Mua' && price != 0;
      final isRent = selectedMode == 'Thuê' && rentPrice != 0;
      final matchesType = cleanSelectedType == 'tất cả' || cleanSelectedType == 'loại nhà đất' || cleanSelectedType == type;
      final selectedValue = selectedMode == 'Mua' ? price : rentPrice;
      final matchesPrice = selectedValue >= minPrice && selectedValue <= maxPrice;
      final matchesArea = area >= minArea && area <= maxArea;
      final matchesBedroom = selectedBedroom == 'Số phòng ngủ' || _matchesBedroom(bed, selectedBedroom);
      final matchesDirection =
          cleanSelectedDirection == 'tất cả' ||
              cleanSelectedDirection == '' ||
              cleanSelectedDirection == 'hướng nhà' ||
              cleanSelectedDirection == direction;
      return (isBuy || isRent) &&
          matchesType &&
          matchesPrice &&
          matchesArea &&
          matchesBedroom &&
          matchesDirection;
    }).toList();
    return filtered;
  }

  Future<void> _fetchRealEstateListings(LatLng center) async {
    final bounds = mapController.bounds;
    final zoom = mapController.camera.zoom;

    if (bounds == null || zoom < _zoomThreshold || _isFetching) return;

    _isFetching = true;
    print('🛰️ Đang gửi request lấy dữ liệu bất động sản...');

    try {
      final response = await http.post(
        Uri.parse("https://online.nks.vn/api/nks/rsitems"),
      );
      print('📥 Đã nhận response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];
        _allData = List<Map<String, dynamic>>.from(data);

        final filtered = filterAndSortProperties(
          all: _allData,
          selectedMode: selectedMode,
          selectedType: selectedType,
          minPrice: selectedPriceRange.start,
          maxPrice: selectedPriceRange.end,
          minArea: selectedAreaRange.start,
          maxArea: selectedAreaRange.end,
          selectedBedroom: selectedBedroom,
          selectedDirection: selectedDirection,
        );

        List<Marker> loadedMarkers = [];

        for (var item in filtered) {
          final geoRaw = item['geolocation'];
          final geo = geoRaw?.split(',');
          final price = item['formatedRentPrice'] ?? item['formatedPrice'];

          if (geo != null && geo.length == 2) {
            final lat = double.tryParse(geo[0].trim());
            final lng = double.tryParse(geo[1].trim());

            if (lat != null && lng != null) {
              final point = LatLng(lat, lng);

              if (bounds.contains(point)) {
                loadedMarkers.add(
                  Marker(
                    point: LatLng(lat, lng),
                    width: 120,
                    height: 60,
                    alignment: Alignment.topCenter,
                    rotate: false,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..rotateZ(-mapController.camera.rotation * math.pi / 180), // Phản xoay để triệt tiêu góc xoay của bản đồ
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xff0077bb),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.home, color: Colors.white, size: 18),
                                const SizedBox(width: 3),
                                Text(
                                  price,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
          }
        }

        setState(() {
          _markers = loadedMarkers;
          totalProperties = filtered.length;
        });
      }
    } catch (e) {
      print('❌ Lỗi khi gửi request: $e');
    } finally {
      _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? const LatLng(10.7769, 106.7009),
              initialZoom: 15,
              onPositionChanged: (MapPosition pos, bool hasGesture) {
                if (pos.center != null) {
                  _onMapMoved(pos.center!);
                }
              },

            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=ZSxwnmKEyVRHxO66jqqP',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: _markers,
                rotate: false,
              ),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndFilterBar(totalProperties),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(int total) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xff0077bb).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(30),
                    selectedColor: Colors.white,
                    color: const Color(0xff0077bb),
                    fillColor: const Color(0xff0077bb),
                    selectedBorderColor: const Color(0xff0077bb),
                    borderColor: const Color(0xff0077bb),
                    constraints: const BoxConstraints(minHeight: 36, minWidth: 50),
                    isSelected: [selectedMode == 'Mua', selectedMode == 'Thuê'],
                    onPressed: (index) {
                      setState(() {
                        selectedMode = index == 0 ? 'Mua' : 'Thuê';
                      });
                      if (_currentPosition != null) {
                        _fetchRealEstateListings(_currentPosition!); 
                      }
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Mua', style: TextStyle(fontSize: 13)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Thuê', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildDropdownFilter('Loại nhà đất', selectedType, propertyTypes, (val) => setState(() => selectedType = val)),

                buildRangeFilterButton(
                  label: 'Khoảng giá',
                  displayText:
                  '${_formatMoney(selectedPriceRange.start.toInt())} - '
                      '${_formatMoney(selectedPriceRange.end.toInt())}'
                      '${selectedPriceRange.end.toInt() >= 60000000000 ? '+' : ''}',

                  onTap: () => _showSliderRangeFilter(
                    context: context,
                    title: 'Khoảng giá (VNĐ)',
                    initialRange: selectedPriceRange,
                    min: 0,
                    max: 60000000000,
                    divisions: 100,
                    unit: '₫',
                    onChanged: (val) => setState(() => selectedPriceRange = val),
                  ),
                ),

                buildRangeFilterButton(
                  label: 'Diện tích',
                  displayText:
                  '${selectedAreaRange.start.round()} - '
                      '${selectedAreaRange.end.round()}'
                      '${selectedAreaRange.end.round() >= 1000 ? 'm²+' : 'm²'}',

                  onTap: () => _showSliderRangeFilter(
                    context: context,
                    title: 'Diện tích (m²)',
                    initialRange: safeRange(selectedAreaRange, 0, 1000),
                    min: 0,
                    max: 1000,
                    divisions: 100,
                    unit: 'm²',
                    onChanged: (val) => setState(() => selectedAreaRange = val),
                  ),
                ),
                _buildDropdownFilter('Số phòng ngủ', selectedBedroom, bedroomCounts, (val) => setState(() => selectedBedroom = val)),
                _buildDropdownFilter('Hướng nhà', selectedDirection, houseDirections, (val) => setState(() => selectedDirection = val)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
      String label,
      String value,
      List<String> options,
      void Function(String) onChanged,
      ) {
    return Builder(builder: (context) {
      // Tính chiều rộng text
      final textPainter = TextPainter(
        text: TextSpan(
          text: value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      // Cộng thêm icon và padding: 14 (padding) + 6 (spacing) + 18 (icon)
      double totalWidth = textPainter.width + 14 + 6 + 18 + 20; // tăng thêm 2

      totalWidth = totalWidth.clamp(90.0, 260.0); // hoặc 280.0 nếu chữ dài


      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => _buildBottomSheetOptions(
              label,
              options.where((e) => e != label).toList(),
              value,
              onChanged,
            ),
          );
        },

        child: Container(
          width: totalWidth,
          height: 36,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F9FC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E6ED), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.expand_more, size: 18, color: Colors.black54),
            ],
          ),
        ),
      );
    });
  }
  RangeValues safeRange(RangeValues range, double min, double max) {
    double start = range.start.clamp(min, max);
    double end = range.end.clamp(min, max);
    if (start > end) start = end;
    return RangeValues(start, end);
  }

  String _formatMoney(int amount, {bool addPlus = false}) {
    String result;
    if (amount >= 1000000000) {
      result = '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    } else {
      result = '${(amount / 1000000).round()} triệu';
    }
    return addPlus ? '$result+' : result;
  }

  String _formatArea(int area, {bool addPlus = false}) {
    return addPlus ? '$area+' : '$area';
  }

  void _showSliderRangeFilter({
    required BuildContext context,
    required String title,
    required RangeValues initialRange,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required void Function(RangeValues) onChanged,
  }) {
    RangeValues currentRange = initialRange;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        unit == '₫'
                            ? '${_formatMoney(currentRange.start.round())}'
                            : '${_formatArea(currentRange.start.round())} $unit',
                      ),
                      Text(
                        unit == '₫'
                            ? '${_formatMoney(currentRange.end.round(), addPlus: currentRange.end >= max)}'
                            : '${_formatArea(currentRange.end.round(), addPlus: currentRange.end >= max)} $unit',
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: currentRange,
                    min: min,
                    max: max,
                    divisions: divisions,
                    labels: RangeLabels(
                      unit == '₫'
                          ? _formatMoney(currentRange.start.round())
                          : _formatArea(currentRange.start.round()),
                      unit == '₫'
                          ? _formatMoney(currentRange.end.round(), addPlus: currentRange.end >= max)
                          : _formatArea(currentRange.end.round(), addPlus: currentRange.end >= max),
                    ),
                    onChanged: (val) {
                      setModalState(() => currentRange = val);
                    },
                    onChangeEnd: (val) {
                      Navigator.pop(context);
                      onChanged(val);
                      if (_currentPosition != null) {
                        _fetchRealEstateListings(_currentPosition!); // Tải lại dữ liệu ngay lập tức
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildRangeFilterButton({
    required String label,
    required String displayText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F9FC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E6ED), width: 1),
        ),
        child: Row(
          children: [
            Text(
              displayText,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOptions(String label, List<String> options, String selectedValue, void Function(String) onChanged) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...options.map((opt) {
                final bool isSelected = opt == selectedValue;
                return ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? const Color(0xff0077bb) : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    onChanged(opt);
                    Navigator.pop(context);
                    if (_currentPosition != null) {
                      _fetchRealEstateListings(_currentPosition!);
                    }
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}