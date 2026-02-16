import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'PickLocationScreen.dart';

class AddressConfirmScreen extends StatefulWidget {
  final dynamic initProvinceId;
  final dynamic initWardId;
  final dynamic initRoadId;
  final String? initProvinceTitle;
  final String? initWardTitle;
  final String? initRoadTitle;
  final LatLng? initLatLng;
  final String? initHouseNumber;

  const AddressConfirmScreen({
    super.key,
    this.initProvinceId,
    this.initWardId,
    this.initRoadId,
    this.initProvinceTitle,
    this.initWardTitle,
    this.initRoadTitle,
    this.initLatLng,
    this.initHouseNumber,
  });

  @override
  State<AddressConfirmScreen> createState() => _AddressConfirmScreenState();
}


class _AddressConfirmScreenState extends State<AddressConfirmScreen> {
  final MapController _mapController = MapController();
  LatLng _markerPosition = LatLng(10.8382, 106.6686);
  final TextEditingController _houseNumberController = TextEditingController();

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> wards = [];
  List<Map<String, dynamic>> roads = [];

  dynamic selectedProvinceId;
  dynamic selectedWardId;
  dynamic selectedRoadId;

  String? selectedProvinceTitle;
  String? selectedWardTitle;
  String? selectedRoadTitle;
  Timer? _debounce;
  String? fullAddress;

  @override
  void initState() {
    super.initState();

    // Gán lại các giá trị được truyền vào
    selectedProvinceId = widget.initProvinceId;
    selectedWardId = widget.initWardId;
    selectedRoadId = widget.initRoadId;

    selectedProvinceTitle = widget.initProvinceTitle;
    selectedWardTitle = widget.initWardTitle;
    selectedRoadTitle = widget.initRoadTitle;

    _houseNumberController.text = widget.initHouseNumber ?? '';

    if (widget.initLatLng != null) {
      _markerPosition = widget.initLatLng!;
    }

    fetchProvinces().then((_) async {
      if (selectedProvinceId != null) {
        await fetchWards(selectedProvinceId);
        if (selectedWardId != null) {
          await fetchRoads(selectedWardId);
          setState(() {});
        }
      }
    });
  }



  void _checkAndMoveMap() {
    if (selectedProvinceTitle != null &&
        selectedWardTitle != null &&
        selectedRoadTitle != null) {
      _moveMapToSelectedAddress();
    }
  }

  Future<void> _moveMapToSelectedAddress() async {
    final fullAddress = [selectedRoadTitle, selectedWardTitle, selectedProvinceTitle]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');

    if (fullAddress.isEmpty) return;

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$fullAddress&format=json&limit=1');

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat']);
          final lon = double.tryParse(data[0]['lon']);

          if (lat != null && lon != null) {
            final newPos = LatLng(lat, lon);
            setState(() {
              _markerPosition = newPos;
            });
            _mapController.move(newPos, 17);
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi geocoding: $e');
    }
  }

  Future<void> fetchProvinces() async {
    try {
      final response = await http.post(
        Uri.parse('https://online.nks.vn/api/nks/provinces'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'country_id': '192', 'slcBox': 'true'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['data'];
        setState(() {
          provinces = items
              .where((item) => item['id'] <= 96)
              .map((item) => {'id': item['id'], 'title': item['title']})
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy tỉnh: $e');
    }
  }

  Future<void> fetchWards(dynamic provinceId) async {
    try {
      final response = await http.post(
        Uri.parse('https://online.nks.vn/api/nks/administratives'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'province_id': '$provinceId', 'slcBox': 'true'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['data'];

        final wardList = items.map((item) => {'id': item['id'], 'title': item['title']}).toList();

        setState(() {
          wards = wardList;

          // Nếu selectedWardId có trong danh sách thì giữ lại
          if (!wards.any((w) => w['id'] == selectedWardId)) {
            selectedWardId = null;
            selectedWardTitle = null;
          }
        });

        // Nếu selectedWardId != null thì tiếp tục load roads
        if (selectedWardId != null) {
          await fetchRoads(selectedWardId);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy phường/xã: $e');
    }
  }

  Future<void> fetchRoads(dynamic wardId) async {
    try {
      final response = await http.post(
        Uri.parse('https://online.nks.vn/api/nks/roads'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'administrative_id': '$wardId', 'slcBox': 'true'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['data'];

        final roadList = items.map((item) => {'id': item['id'], 'title': item['title']}).toList();

        setState(() {
          roads = roadList;

          // Nếu selectedRoadId có trong danh sách thì giữ lại
          if (!roads.any((r) => r['id'] == selectedRoadId)) {
            selectedRoadId = null;
            selectedRoadTitle = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy đường/phố: $e');
    }
  }


  Future<void> _updateAddressFromLatLng(LatLng latlng) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${latlng.latitude}&lon=${latlng.longitude}&format=json');

      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final displayName = data['display_name'];
        final address = data['address'];

        setState(() {
          _markerPosition = latlng;
          fullAddress = displayName;

          // Lấy title trả về từ reverse geocoding
          final provinceTitle = address['state'];
          final wardTitle = address['suburb'];
          final roadTitle = address['road'];

          // Tìm ID tương ứng nếu có
          final matchedProvince = provinces.firstWhere(
                (e) => e['title'] == provinceTitle,
            orElse: () => {},
          );
          final matchedWard = wards.firstWhere(
                (e) => e['title'] == wardTitle,
            orElse: () => {},
          );
          final matchedRoad = roads.firstWhere(
                (e) => e['title'] == roadTitle,
            orElse: () => {},
          );

          // Cập nhật lại dropdown
          selectedProvinceTitle = provinceTitle;
          selectedProvinceId = matchedProvince['id'];

          selectedWardTitle = wardTitle;
          selectedWardId = matchedWard['id'];

          selectedRoadTitle = roadTitle;
          selectedRoadId = matchedRoad['id'];
        });

      }
    } catch (e) {
      debugPrint('Lỗi khi reverse geocoding: $e');
    }
  }


  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Xác nhận địa chỉ', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _buildField('Tỉnh/Thành', selectedProvinceTitle, () async {
              await _showBottomSelect(
                title: 'Chọn tỉnh/thành',
                items: provinces,
                onSelect: (item) async {
                  selectedProvinceId = item['id'];
                  selectedProvinceTitle = item['title'];
                  selectedWardId = null;
                  selectedWardTitle = null;
                  selectedRoadId = null;
                  selectedRoadTitle = null;
                  wards = [];
                  roads = [];
                  setState(() {});
                  await fetchWards(selectedProvinceId);
                },
              );
            }),

            if(selectedProvinceTitle != null)
              _buildField('Phường/Xã', selectedWardTitle, () async {
                await _showBottomSelect(
                  title: 'Chọn phường/xã',
                  items: wards,
                  onSelect: (item) async {
                    selectedWardId = item['id'];
                    selectedWardTitle = item['title'];
                    selectedRoadId = null;
                    selectedRoadTitle = null;
                    roads = [];
                    setState(() {});
                    await fetchRoads(selectedWardId);
                  },
                );
              }),

            if(selectedWardTitle != null)
              _buildField('Đường/Phố', selectedRoadTitle, () async {
                await _showBottomSelect(
                  title: 'Chọn đường/phố',
                  items: roads,
                  onSelect: (item) {
                    selectedRoadId = item['id'];
                    selectedRoadTitle = item['title'];
                    setState(() {});
                    _checkAndMoveMap();
                  },
                );
              }),

            const SizedBox(height: 12),

            if(selectedRoadTitle != null)
            TextField(
              controller: _houseNumberController,
              decoration: const InputDecoration(
                labelText: 'Số nhà / căn hộ',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {});
                  _checkAndMoveMap();
                });
              },
            ),

            const SizedBox(height: 12),

            _buildAddressBox(
              [
                _houseNumberController.text.trim(),
                selectedRoadTitle,
                selectedWardTitle,
                selectedProvinceTitle,
              ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', '),
            ),

            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    FlutterMap(
                      key: ValueKey(_markerPosition),
                      mapController: _mapController,
                      options: MapOptions(
                        center: _markerPosition,
                        zoom: 15.0,
                        interactiveFlags: InteractiveFlag.none,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=ZSxwnmKEyVRHxO66jqqP',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _markerPosition,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                            )
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        // child: IconButton(
                        //   icon: const Icon(Icons.edit_location_alt, color: Colors.blue, size: 24),
                        //   onPressed: () async {
                        //     final result = await Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (_) => PickLocationScreen(
                        //         initialPosition: _markerPosition,
                        //       )),
                        //     );
                        //
                        //     if (result != null && result is LatLng) {
                        //       setState(() {
                        //         _markerPosition = result;
                        //       });
                        //       _mapController.move(result, 15);
                        //
                        //       await _updateAddressFromLatLng(result);
                        //     }
                        //
                        //   },
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedProvinceId != null &&
                      selectedWardId != null &&
                      selectedRoadId != null) {
                    Navigator.pop(context, {
                      'house_number': _houseNumberController.text.trim(),
                      'province_id': selectedProvinceId,
                      'ward_id': selectedWardId,
                      'road_id': selectedRoadId,
                      'province_title': selectedProvinceTitle,
                      'ward_title': selectedWardTitle,
                      'road_title': selectedRoadTitle,
                      'latlng': _markerPosition,
                      'full_address': [
                        _houseNumberController.text.trim(),
                        selectedRoadTitle,
                        selectedWardTitle,
                        selectedProvinceTitle,
                      ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ')
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn đủ địa chỉ')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0077bb),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Xác nhận', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddressBox(String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Địa chỉ hiển thị trên tin đăng', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: Text(address.isNotEmpty ? address : 'Chưa chọn địa chỉ'),
        ),
      ],
    );
  }

  Widget _buildField(String label, String? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? 'Chọn $label',
                style: TextStyle(
                    color: value == null ? Colors.black45 : Colors.black),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Future<void> _showBottomSelect({
    required String title,
    required List<Map<String, dynamic>> items,
    required void Function(Map<String, dynamic>) onSelect,
  }) async {
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (_, scrollController) {
          return StatefulBuilder(builder: (context, setModalState) {
            final filtered = items
                .where((e) => e['title']
                .toLowerCase()
                .contains(controller.text.toLowerCase()))
                .toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('Không tìm thấy kết quả'))
                        : ListView.separated(
                      controller: scrollController,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (_, i) => ListTile(
                        title: Text(filtered[i]['title']),
                        trailing: const Icon(Icons.check,
                            color: Colors.blue),
                        onTap: () {
                          onSelect(filtered[i]);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}