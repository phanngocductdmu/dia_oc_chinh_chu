import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FullMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const FullMapScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> with TickerProviderStateMixin {
  late final MapController _mapController;
  late final LatLng _targetLocation;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _targetLocation = LatLng(widget.latitude, widget.longitude);
  }

  Future<void> _goToMyLocation() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition();
    final userLocation = LatLng(position.latitude, position.longitude);
    setState(() => _currentLocation = userLocation);

    _mapController.move(userLocation, 16);
  }

  Future<void> _goToTargetLocation() async {
    _mapController.move(_targetLocation, 16);
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _targetLocation,
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=ZSxwnmKEyVRHxO66jqqP',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _targetLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, size: 36, color: Colors.blue),
                  ),
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.person_pin_circle, size: 32, color: Colors.red),
                    ),
                ],
              ),
            ],
          ),

          // Nút đóng
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.close, color: Colors.black),
              ),
            ),
          ),

          // Các nút điều hướng
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                _buildMapButton(Icons.person_pin_circle, _goToMyLocation), // Vị trí của tôi
                const SizedBox(height: 10),
                _buildMapButton(Icons.location_on, _goToTargetLocation), // Địa chỉ bất động sản
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }
}
