import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PickLocationScreen extends StatefulWidget {
  final LatLng initialPosition;

  const PickLocationScreen({super.key, required this.initialPosition});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  final MapController _mapController = MapController();
  LatLng _center = LatLng(10.7769, 106.7009);

  @override
  void initState() {
    super.initState();
    _center = widget.initialPosition;
  }

  Future<void> _printAddressFromLatLng(LatLng latlng) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${latlng.latitude}&lon=${latlng.longitude}&format=json');

      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'];
        debugPrint('📍 Địa chỉ hiện tại: $address');
      } else {
        debugPrint('❌ Lỗi khi lấy địa chỉ: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi reverse geocoding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar tuỳ chỉnh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Vị trí trên bản đồ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),

            // Hướng dẫn
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Kéo bản đồ để đổi vị trí ghim',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),

            // Bản đồ
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: widget.initialPosition,
                      zoom: 15.0,
                      onPositionChanged: (pos, _) {
                        setState(() {
                          _center = pos.center!;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.app',
                      ),
                    ],
                  ),

                  // Icon ghim ở giữa
                  const Positioned(
                    child: Icon(Icons.location_on,
                        size: 40, color: Colors.red),
                  ),

                  // Nút zoom
                  Positioned(
                    bottom: 20,
                    right: 12,
                    child: Column(
                      children: [
                        _zoomButton(Icons.add, () {
                          _mapController.move(
                              _center, _mapController.zoom + 1);
                        }),
                        const SizedBox(height: 8),
                        _zoomButton(Icons.remove, () {
                          _mapController.move(
                              _center, _mapController.zoom - 1);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nút Đặt lại và Lưu
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _center = LatLng(10.7769, 106.7009);
                          _mapController.move(_center, 17);
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        side: const BorderSide(color: Colors.black12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Đặt lại',
                          style: TextStyle(color: Color(0xff0077bb))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _printAddressFromLatLng(_center);
                        Navigator.pop(context, _center); // Trả về vị trí đã chọn
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0077bb),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Lưu',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
