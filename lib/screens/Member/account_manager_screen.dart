import 'package:flutter/material.dart';
import './accountManagement/information_account_screen.dart';
import './accountManagement/update_information_screen.dart';
import './accountManagement/update_id.dart';
import './accountManagement/update_password_screen.dart';

class AccountManagerScreen extends StatefulWidget {
  const AccountManagerScreen({super.key});

  @override
  State<AccountManagerScreen> createState() => _AccountManagerScreenState();
}

class _AccountManagerScreenState extends State<AccountManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color primaryColor = const Color(0xFF0077BB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tài khoản'),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'Thông tin cá nhân'),
            Tab(text: 'Chỉnh sửa thông tin cá nhân'),
            Tab(text: 'Chỉnh sửa căn cước công dân'),
            Tab(text: 'Thay đổi mật khẩu'),
          ],
        ),

      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          InformationScreen(),
          UpdateInformation(),
          UpdateIdScreen(),
          UpdatePasswordScreen(),
        ],
      ),
    );
  }
}