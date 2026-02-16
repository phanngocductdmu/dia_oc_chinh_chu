import 'package:diaocchinhchu/screens/notification_detail_screen.dart';
import 'package:diaocchinhchu/screens/notification_service.dart';
import 'package:diaocchinhchu/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/search_screen.dart';
import 'screens/saved_listings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(const MyApp());

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print('🔥 [onMessageOpenedApp] data: ${message.data}');

    final clickAction = message.data['click-action'];
    final extra = message.data['extra'];

    String? notificationId;

    if (extra != null && extra is String) {
      final parts = extra.split(',');
      if (parts.length >= 2) {
        notificationId = parts[1];
      }
    }

    print('🧩 clickAction: $clickAction, notificationId: $notificationId');

    if (clickAction == 'Notification' && notificationId != null) {
      final id = int.tryParse(notificationId);
      if (id != null) {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString('access_token');

        if (accessToken != null) {
          // Đợi sau frame hiện tại để push route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (_) => NotificationDetailScreen(
                notificationId: id,
                accessToken: accessToken,
              ),
            ));
          });
        } else {
          print('⚠️ Không tìm thấy accessToken trong SharedPreferences');
        }
      } else {
        print('❗ notificationId không hợp lệ: $notificationId');
      }
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📦 [onMessage] message.data: ${message.data}');
    final notification = message.notification;

    String? notificationId;
    final extra = message.data['extra'];
    if (extra != null && extra is String) {
      final parts = extra.split(',');
      if (parts.length >= 2) {
        notificationId = parts[1];
      }
    }

    if (notification != null) {
      NotificationService().showNotification(
        notification.title ?? '',
        notification.body ?? '',
        payload: notificationId != null ? 'id:$notificationId' : null,
      );
    }
  });


  // Yêu cầu quyền notification
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Địa ốc chính chủ',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _showMap = false;
  late final MapScreen _mapScreen;
  Key _savedScreenKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _mapScreen = const MapScreen();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 1) {
        _savedScreenKey = UniqueKey();
      }
    });
  }

  void _toggleMap() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      setState(() {
        _showMap = !_showMap;
      });
    } else {
      final result = await Permission.location.request();
      if (result.isGranted) {
        setState(() {
          _showMap = true;
        });
      } else if (result.isPermanentlyDenied) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Cần quyền vị trí'),
            content: const Text('Vui lòng cấp quyền vị trí để xem bản đồ.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Mở cài đặt'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn cần cấp quyền vị trí để xem bản đồ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      SearchScreen(onMapPressed: _toggleMap),
      SavedListingsScreen(key: _savedScreenKey),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          if (_selectedIndex == 0 && _showMap)
            _mapScreen,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xff0077bb),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Tìm kiếm'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Đã lưu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Tài khoản'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? SizedBox(
        height: 40,
        child: FloatingActionButton.extended(
          heroTag: 'null',
          onPressed: _toggleMap,
          backgroundColor: const Color(0xff0077bb),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(
              _showMap ? Icons.list : Icons.map,
              color: Colors.white,
              size: 18,
            ),
          ),
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              _showMap ? 'Danh sách' : 'Bản đồ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
