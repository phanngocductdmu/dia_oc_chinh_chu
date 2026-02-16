import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'update_info_post.dart';
import 'update_image_post.dart';
import '../detail/product_detail_screen.dart';

class PostManagementScreen extends StatefulWidget {
  const PostManagementScreen({super.key});

  @override
  State<PostManagementScreen> createState() => _PostManagementScreenState();
}

class _PostManagementScreenState extends State<PostManagementScreen> {
  final Color primaryColor = const Color(0xFF0077BB);
  List<dynamic> postItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.post(
      Uri.parse('https://account.nks.vn/api/nks/user/rsitems'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'access_token': token}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        postItems = data['data'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      debugPrint('Lỗi tải tin đăng: ${response.statusCode}');
    }
  }

  Future<void> _editPost(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final id = item['id'];

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateInfoPost(
          id: id,
          token: token,
        ),
      ),
    );

    if (updated == true) {
      // Load lại danh sách tin
      fetchPosts();
    }
  }

  Future<void> _editImages(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final id = item['id'];

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateImagePost(
          id: id,
          token: token,
        ),
      ),
    );
    if (updated == true) {
      fetchPosts();
    }
  }

  void _deletePost(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa tin này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('https://account.nks.vn/api/nks/user/rsitem/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': item['id'],
          'access_token': token,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          postItems.removeWhere((e) => e['id'] == item['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa tin thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa thất bại. Vui lòng thử lại.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quản lý tin', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff0077bb),))
          : postItems.isEmpty
          ? const Center(child: Text('Không có tin đăng nào'))
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 66),
        itemCount: postItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = postItems[index];
          final imageUrl = item['featureimg']?.toString();
          final title = item['title'] ?? '';
          final address = item['address'] ?? '';
          final price = item['formatedPrice'] ?? '0 đ';
          final area = item['total_area']?.toString() ?? '--';
          final type = item['rstype'] ?? '';
          final status = 'Chờ duyệt';

          return GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProductDetailScreen(id: item['id'])));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh và trạng thái
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null
                            ? Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40, color: Colors.grey),
                        )
                            : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                                  ),
                                ),
                                const Spacer(),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        _editPost(item);
                                        break;
                                      case 'image':
                                        _editImages(item);
                                        break;
                                      case 'delete':
                                        _deletePost(item);
                                        break;
                                    }
                                  },
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: Colors.white,
                                  elevation: 4,
                                  itemBuilder: (context) => [
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: const [
                                          Icon(Icons.edit, color: Colors.grey, size: 20),
                                          SizedBox(width: 10),
                                          Text('Chỉnh sửa thông tin', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'image',
                                      child: Row(
                                        children: const [
                                          Icon(Icons.image, color: Colors.grey, size: 20),
                                          SizedBox(width: 10),
                                          Text('Chỉnh sửa ảnh', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: const [
                                          Icon(Icons.delete, color: Colors.grey, size: 20),
                                          SizedBox(width: 10),
                                          Text('Xóa', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                                  splashRadius: 20,
                                )

                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$type • $address',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Info chi tiết
                  Row(
                    children: [
                      _infoItem('Diện tích', '$area m²'),
                      _infoItem('Giá bán', price),
                    ],
                  ),
                ],
              ),
            ),
          )
          );
        },
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}