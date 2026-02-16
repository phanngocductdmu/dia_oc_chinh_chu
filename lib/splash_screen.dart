import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await requestPermissions(); // Yêu cầu quyền

    // Sau khi xin xong quyền, chuyển sang màn hình chính
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ].request();

    // Ghi log ra nếu muốn debug
    statuses.forEach((permission, status) {
      print('$permission: $status');
    });

    // Nếu người dùng từ chối vĩnh viễn, có thể đưa họ đến cài đặt
    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      openAppSettings(); // mở trang cài đặt ứng dụng
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/image/nks_logo.png',
          width: 180,
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}