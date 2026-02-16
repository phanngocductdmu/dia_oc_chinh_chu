import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddressBox extends StatelessWidget {
  final String? fullAddress;
  final LatLng? selectedLatLng;
  final bool showFullAddressBox;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onSelect;

  const AddressBox({
    super.key,
    required this.fullAddress,
    required this.selectedLatLng,
    required this.showFullAddressBox,
    required this.onToggle,
    required this.onEdit,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề và nút toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nhập địa chỉ', style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    showFullAddressBox ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (fullAddress != null && selectedLatLng != null)
            showFullAddressBox
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fullAddress!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: onEdit,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FlutterMap(
                      options: MapOptions(
                        center: selectedLatLng,
                        zoom: 15,
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
                              point: selectedLatLng!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on,
                                  color: Colors.red, size: 36),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
                : Text(fullAddress!, style: const TextStyle(fontSize: 14))
          else
            GestureDetector(
              onTap: onSelect,
              child: AbsorbPointer(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Nhập địa chỉ chi tiết...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
