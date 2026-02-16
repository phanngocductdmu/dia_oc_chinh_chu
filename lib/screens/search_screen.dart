import 'package:flutter/material.dart';
import 'detail/product_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  final VoidCallback onMapPressed;
  const SearchScreen({super.key, required this.onMapPressed});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> propertyList = [];
  Map<String, dynamic>? selectedProvince;
  late Future<List<Map<String, dynamic>>> _futureData;
  int totalProperties = 0;
  Map<String, dynamic>? selectedWard;
  bool get isWardEnabled => selectedProvince != null;

  bool isLoading = true;
  String selectedSort = 'Sắp xếp';
  String selectedMode = 'Mua';
  String selectedType = 'Loại nhà đất';
  String selectedPrice = 'Khoảng giá';
  String selectedArea = 'Diện tích';
  String selectedBedroom = 'Số phòng ngủ';
  String selectedDirection = 'Hướng nhà';
  RangeValues selectedPriceRange = const RangeValues(0, 60000000000);
  RangeValues selectedAreaRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _futureData = fetchProperties();
  }

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

  Future<void> _loadProvinces() async {
    try {
      final response = await http.post(
        Uri.parse('https://online.nks.vn/api/nks/provinces'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'country_id': '192', 'slcBox': 'true'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List list = json['data'];

        setState(() {
          provinces = list
              .where((item) => item['id'] <= 96)
              .map<Map<String, dynamic>>((item) => {
            'id': item['id'],
            'title': item['title'],
          })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('API lỗi: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('❌ Lỗi tải tỉnh: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProperties() async {
    final response = await http.post(
      Uri.parse('https://online.nks.vn/api/nks/rsitems'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List data = jsonData['data'];
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Lỗi tải dữ liệu: ${response.statusCode}');
    }
  }

  List<Map<String, dynamic>> filterAndSortProperties({
    required List<Map<String, dynamic>> all,
    required String selectedMode,
    required Map<String, dynamic>? selectedProvince,
    required Map<String, dynamic>? selectedWard,
    required String selectedType,
    required double minPrice,
    required double maxPrice,
    required double minArea,
    required double maxArea,
    required String selectedBedroom,
    required String selectedDirection,
    required String selectedSort,
  }) {
    String clean(dynamic s) => s?.toString().trim().toLowerCase() ?? '';

    final cleanSelectedType = clean(selectedType);
    final cleanSelectedDirection = clean(selectedDirection);

    final filtered = all.where((item) {
      final price = item['price'] ?? 0;
      final rentPrice = item['rentprice'] ?? 0;
      final provinceId = item['add_province'];
      final wardId = item['add_administrative'];
      final type = clean(item['rstype']);
      final area = (item['total_area'] ?? item['area'] ?? item['sqr'])?.toDouble() ?? 0;
      final bed = item['bed'] ?? 0;
      final direction = clean(item['direction']);

      final isBuy = selectedMode == 'Mua' && price != 0;
      final isRent = selectedMode == 'Thuê' && rentPrice != 0;

      final matchesProvince = selectedProvince == null || selectedProvince['id'] == provinceId;

      final matchesWard = selectedWard == null || selectedWard['id'] == wardId;
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
          matchesProvince &&
          matchesWard &&
          matchesType &&
          matchesPrice &&
          matchesArea &&
          matchesBedroom &&
          matchesDirection;
    }).toList();

    return sortProperties(filtered, selectedSort, selectedMode);
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

  List<Map<String, dynamic>> sortProperties(
      List<Map<String, dynamic>> properties,
      String selectedSort,
      String selectedMode,
      ) {
    final sorted = [...properties];

    switch (selectedSort) {
      case 'Giá thấp đến cao':
        sorted.sort((a, b) {
          final aPrice = selectedMode == 'Mua' ? (a['price'] ?? 0) : (a['rentprice'] ?? 0);
          final bPrice = selectedMode == 'Mua' ? (b['price'] ?? 0) : (b['rentprice'] ?? 0);
          return aPrice.compareTo(bPrice);
        });
        break;

      case 'Giá cao đến thấp':
        sorted.sort((a, b) {
          final aPrice = selectedMode == 'Mua' ? (a['price'] ?? 0) : (a['rentprice'] ?? 0);
          final bPrice = selectedMode == 'Mua' ? (b['price'] ?? 0) : (b['rentprice'] ?? 0);
          return bPrice.compareTo(aPrice);
        });
        break;

      case 'Giá/m² thấp đến cao':
        sorted.sort((a, b) {
          final aPrice = selectedMode == 'Mua' ? (a['sqrprice'] ?? 0) : (a['sqrrentprice'] ?? 0);
          final bPrice = selectedMode == 'Mua' ? (b['sqrprice'] ?? 0) : (b['sqrrentprice'] ?? 0);
          return aPrice.compareTo(bPrice);
        });
        break;

      case 'Giá/m² cao đến thấp':
        sorted.sort((a, b) {
          final aPrice = selectedMode == 'Mua' ? (a['sqrprice'] ?? 0) : (a['sqrrentprice'] ?? 0);
          final bPrice = selectedMode == 'Mua' ? (b['sqrprice'] ?? 0) : (b['sqrrentprice'] ?? 0);
          return bPrice.compareTo(aPrice);
        });
        break;

      case 'Diện tích nhỏ đến lớn':
        sorted.sort((a, b) {
          final aArea = (a['total_area'] ?? a['area'] ?? a['sqr'])?.toDouble() ?? 0;
          final bArea = (b['total_area'] ?? b['area'] ?? b['sqr'])?.toDouble() ?? 0;
          return aArea.compareTo(bArea);
        });
        break;

      case 'Diện tích lớn đến nhỏ':
        sorted.sort((a, b) {
          final aArea = (a['total_area'] ?? a['area'] ?? a['sqr'])?.toDouble() ?? 0;
          final bArea = (b['total_area'] ?? b['area'] ?? b['sqr'])?.toDouble() ?? 0;
          return bArea.compareTo(aArea);
        });
        break;
    }
    return sorted;
  }


  Future<List<Map<String, dynamic>>> fetchWardsByProvinceId(String provinceId) async {
    final response = await http.post(
      Uri.parse('https://online.nks.vn/api/nks/administratives'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'province_id': provinceId,
        'slcBox': 'true',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json['data']);
    } else {
      throw Exception('Không thể lấy dữ liệu phường/xã');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _buildSearchAndFilterBar(totalProperties),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _futureData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xff0077bb),));
                    } else if (snapshot.hasError) {
                      final error = snapshot.error?.toString() ?? 'Không rõ lỗi';
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Đã xảy ra lỗi khi tải dữ liệu:\n$error',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu'));
                    }

                    final allData = snapshot.data!;
                    final propertyList = filterAndSortProperties(
                      all: allData,
                      selectedMode: selectedMode,
                      selectedProvince: selectedProvince,
                      selectedWard: selectedWard,
                      selectedType: selectedType,
                      minPrice: selectedPriceRange.start,
                      maxPrice: selectedPriceRange.end,
                      minArea: selectedAreaRange.start,
                      maxArea: selectedAreaRange.end,
                      selectedBedroom: selectedBedroom,
                      selectedDirection: selectedDirection,
                      selectedSort: selectedSort,
                    );

                    if (totalProperties != propertyList.length) {
                      // tránh setState vô hạn
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          totalProperties = propertyList.length;
                        });
                      });
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: propertyList.length,
                      itemBuilder: (context, index) {
                        final item = propertyList[index];
                        final List<String> images = (() {
                          // Hàm chuyển Dropbox URL sang direct link (nếu cần — vẫn giữ cho linh hoạt)
                          String fixDropboxUrl(String? url) {
                            if (url == null || url.isEmpty) return '';
                            return url.replaceFirst('www.dropbox.com', 'dl.dropboxusercontent.com');
                          }

                          // Lấy ảnh đại diện
                          final String featureImg = (() {
                            final raw = item['featureimg']?.toString();
                            final fixed = fixDropboxUrl(raw);
                            return fixed.isNotEmpty
                                ? fixed
                                : 'https://dl.dropboxusercontent.com/scl/fi/yt7qhc5m9dvrkllzub66f/docc-ban-nha.jpg?rlkey=abc&raw=1';
                          })();

                          // Lấy danh sách ảnh gallery từ key "image"
                          final List<String> galleryImages = (() {
                            final rawGallery = item['gallery'];
                            if (rawGallery is List) {
                              return rawGallery
                                  .map((e) => e is Map ? e['image']?.toString() ?? '' : '')
                                  .where((url) => url.isNotEmpty)
                                  .toList()
                                  .cast<String>(); // ✅ ép kiểu
                            }
                            return <String>[];
                          })();

                          return [featureImg, ...galleryImages];
                        })();


                        final String title = '${item['title'] ?? 'Không có tiêu đề'}';


                        String? formatedPrice = item['formatedPrice']?.toString();
                        String? formatedRentPrice = item['formatedRentPrice']?.toString();

                        String clean(String? s) => s?.trim().toLowerCase() ?? '';

                        final bool hasPrice = clean(formatedPrice) != '0' && clean(formatedPrice).isNotEmpty;
                        final bool hasRent = clean(formatedRentPrice) != '0' && clean(formatedRentPrice).isNotEmpty;

                        final String displayPrice = (hasPrice)
                            ? formatedPrice!
                            : (hasRent)
                            ? formatedRentPrice!
                            : 'Chưa có giá';

                        final String area = item['total_area']?.toString() ?? 'Chưa rõ';
                        final String pricePerM2 = '${item['formatedSqrPrice'] ?? ''}';
                        final int bedrooms = item['bed'] ?? 0;
                        final int bathrooms = item['bath'] ?? 0;
                        final String address = '${item['address'] ?? ''}';
                        final String phone = '${item['phone'] ?? ''}';
                        final sale = item['sale'] ?? {};
                        final String avatar = '${sale['avatar'] ?? ''}';
                        final String sellerName = '${sale['name'] ?? ''}';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(id: item['id']),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ảnh lớn
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.network(
                                        images.isNotEmpty ? images[0] : '',
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff0077bb),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'VIP Kim Cương',
                                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),

                                // Ảnh nhỏ
                                if (images.length >= 2)
                                  Row(
                                    children: [
                                      for (int i = 1; i < images.length && i <= 3; i++)
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 70,
                                                margin: EdgeInsets.only(right: i < 3 ? 2 : 0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.zero,
                                                  child: Image.network(
                                                    images[i],
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                              ),
                                              if (i == 3 && images.length > 4)
                                                Positioned(
                                                  bottom: 6,
                                                  right: 6,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.6),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.image, size: 12, color: Colors.white),
                                                        const SizedBox(width: 3),
                                                        Text('${images.length}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffe6f4ea),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.verified, size: 16, color: Colors.green),
                                            SizedBox(width: 4),
                                            Text('Xác thực', style: TextStyle(fontSize: 12, color: Colors.green)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          if (displayPrice != null && displayPrice.toString().isNotEmpty) ...[
                                            Text(displayPrice, style: const TextStyle(color: Color(0xff0077bb), fontWeight: FontWeight.bold)),
                                            const Text('  •  '),
                                          ],
                                          if (area != null && area.toString().isNotEmpty) ...[
                                            Text('$area m²', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            const Text('  •  '),
                                          ],
                                          if (pricePerM2 != null && pricePerM2.toString().isNotEmpty) ...[
                                            Text('$pricePerM2/m²', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                            const Text('  •  '),
                                          ],
                                          // Ví dụ thêm phòng ngủ + tắm
                                          Row(
                                            children: [
                                              Text('$bedrooms'),
                                              const SizedBox(width: 3),
                                              const Icon(Icons.bed_outlined, size: 16),
                                              const Text('  •  '),
                                              Text('$bathrooms'),
                                              const SizedBox(width: 3),
                                              const Icon(Icons.bathtub_outlined, size: 16),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              address,
                                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(avatar),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(sellerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                          const Text('Đăng hôm qua', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        ],
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0077bb),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          phone.length > 3
                                              ? phone.replaceRange(phone.length - 3, phone.length, '***')
                                              : phone,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey.shade400),
                                        ),
                                        child: const Icon(Icons.favorite_border, size: 18, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWardBottomSheet(List<Map<String, dynamic>> wards) {
    String searchKeyword = '';
    List<Map<String, dynamic>> filtered = List.from(wards);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(builder: (context, setModalState) {
              return Column(
                children: [
                  const SizedBox(height: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm phường/xã...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) {
                        searchKeyword = value.toLowerCase();
                        setModalState(() {
                          filtered = wards
                              .where((e) => e['title']
                              .toString()
                              .toLowerCase()
                              .contains(searchKeyword))
                              .toList();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            leading: const Icon(Icons.public),
                            title: const Text('Tất cả phường/xã'),
                            onTap: () {
                              setState(() => selectedWard = null);
                              Navigator.pop(context);
                            },
                          );
                        }

                        final ward = filtered[index - 1];
                        return ListTile(
                          title: Text(ward['title']),
                          onTap: () {
                            setState(() => selectedWard = ward);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            });
          },
        );
      },
    );
  }

  void _showProvinceBottomSheet() {
    String searchKeyword = '';
    List<Map<String, dynamic>> filtered = List.from(provinces);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(builder: (context, setModalState) {
              return Column(
                children: [
                  const SizedBox(height: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tỉnh/thành phố...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        searchKeyword = value.toLowerCase();
                        setModalState(() {
                          filtered = provinces
                              .where((e) => e['title']
                              .toString()
                              .toLowerCase()
                              .contains(searchKeyword))
                              .toList();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            leading: const Icon(Icons.public),
                            title: const Text('Tất cả tỉnh/thành phố'),
                            onTap: () {
                              setState(() => selectedProvince = null);
                              Navigator.pop(context);
                            },
                          );
                        }

                        final item = filtered[index - 1];
                        return ListTile(
                          title: Text(item['title']),
                            onTap: () {
                              setState(() {
                                selectedProvince = item;
                                selectedWard = null;
                              });
                              Navigator.pop(context);
                            }
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            });
          },
        );
      },
    );
  }

  Widget _buildSearchAndFilterBar(int total) {
    final bool isWardEnabled = selectedProvince != null;
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Nút chọn Mua / Thuê
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
                    setState(() => selectedMode = index == 0 ? 'Mua' : 'Thuê');
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
              const SizedBox(width: 8),

              // Dropdown chọn tỉnh
              Expanded(
                child: GestureDetector(
                  onTap: () => _showProvinceBottomSheet(),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xff0077bb), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Color(0xff0077bb), size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedProvince?['title'] ?? 'Tỉnh/Thành phố',
                            style: const TextStyle(fontSize: 13.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.expand_more, size: 18, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Nút chọn nhiều phường/xã (bị mờ khi chưa chọn tỉnh)
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: isWardEnabled ? () async {
                    if (selectedProvince == null) return;
                    final wards = await fetchWardsByProvinceId(selectedProvince!['id'].toString());
                    _showWardBottomSheet(wards);
                  } : null,
                  icon: Icon(
                    Icons.apartment_rounded,
                    size: 18,
                    color: isWardEnabled ? const Color(0xff0077bb) : Colors.grey,
                  ),
                  label: Text(
                    selectedWard != null ? selectedWard!['title'] : 'Phường/Xã',
                    style: TextStyle(
                      fontSize: 13,
                      color: isWardEnabled ? const Color(0xff0077bb) : Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    elevation: MaterialStateProperty.all(0.5),
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 10)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    side: MaterialStateProperty.all(
                      BorderSide(color: isWardEnabled ? const Color(0xff0077bb) : Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Các filter ngang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
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
          const SizedBox(height: 12),
          // Thống kê + Sắp xếp
          Row(
            children: [
              Text(
                '$total',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(' bất động sản'),
              const Spacer(),
              const Icon(Icons.sort, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedSort,
                items: sortOptions.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s, style: const TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: (val) => setState(() => selectedSort = val!),
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(10),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                dropdownColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  RangeValues safeRange(RangeValues range, double min, double max) {
    double start = range.start.clamp(min, max);
    double end = range.end.clamp(min, max);
    if (start > end) start = end;
    return RangeValues(start, end);
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
                    activeColor: const Color(0xFF0077BB),
                    inactiveColor: Colors.grey.shade300,
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

  Widget _buildBottomSheetOptions(String label, List<String> options, String selectedValue, void Function(String) onChanged,) {
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