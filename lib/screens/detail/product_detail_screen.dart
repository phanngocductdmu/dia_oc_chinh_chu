import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'full_map_screen.dart';
import '../detail/agent_detail_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int id;
  const ProductDetailScreen({super.key, required this.id});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? item;
  bool isLoading = true;
  bool hasError = false;
  bool _isExpanded = false;
  int agentPostCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchProductDetail();
  }

  Future<void> _fetchProductDetail() async {
    try {
      final response = await http.post(
        Uri.parse('https://online.nks.vn/api/nks/rsitem'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id': widget.id.toString()},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          final data = json['data'];
          setState(() {
            item = data;
            isLoading = false;
          });

          // ✅ Sau khi có item, lấy saleId và đếm số tin đăng
          final sale = data['sale'];
          if (sale != null && sale['id'] != null) {
            final saleId = sale['id'].toString();
            final posts = await fetchAgentPosts(saleId);
            if (mounted) {
              setState(() {
                agentPostCount = posts.length;
              });
            }
          }
        } else {
          setState(() => hasError = true);
        }
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      setState(() => hasError = true);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || item == null) {
      return const Scaffold(
        body: Center(child: Text('Không thể tải dữ liệu.')),
      );
    }

    final List<String> images = [];
    final String? featureImg = item!['featureimg']?.toString();
    if (featureImg != null) {
      images.add(featureImg);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBar(),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(item!),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildDetailBody(item!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/image/avtzalo.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call, size: 20, color: Colors.white),
              label: Text(
                (item!['phone'] != null && item!['phone'].toString().length >= 4)
                    ? '${item!['phone'].toString().substring(0, item!['phone'].toString().length - 3)}***'
                    : '---',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0077bb),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Map<String, dynamic> item) {
    final String? rawFeatureImg = item['featureimg']?.toString();
    final String featureImg = rawFeatureImg != null && rawFeatureImg.isNotEmpty
        ? rawFeatureImg.replaceFirst('www.dropbox.com', 'dl.dropboxusercontent.com')
        : 'https://dl.dropboxusercontent.com/scl/fi/yt7qhc5m9dvrkllzub66f/docc-ban-nha.jpg?rlkey=abc&raw=1';

    // ✅ Lấy danh sách ảnh từ item['gallery']
    final List<String> gallery = ((item['gallery'] as List?) ?? [])
        .map((e) {
      if (e is Map && e['image'] != null) {
        return e['image'].toString();
      }
      return '';
    })
        .where((url) => url.isNotEmpty && url != featureImg)
        .toList();

    // ✅ Chèn featureImg lên đầu danh sách
    gallery.insert(0, featureImg);

    final PageController _pageController = PageController();
    int _currentPage = 0;

    return StatefulBuilder(
      builder: (context, setState) => SliverAppBar(
        pinned: true,
        stretch: true,
        expandedHeight: 260,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 12),
          child: _buildSmallIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 12),
            child: _buildSmallIconButton(icon: Icons.ios_share_rounded, onTap: () {}),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 12),
            child: _buildSmallIconButton(icon: Icons.favorite_border, onTap: () {}),
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: gallery.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final url = gallery[index];
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 60),
                    ),
                  );
                },
              ),
              if (gallery.length > 1)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${gallery.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
          stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        ),
      ),
    );
  }


  Widget _buildDetailBody(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceAreaInfo(item),
        const SizedBox(height: 10),
        Text(item['title']?.toString() ?? '---', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        _buildAddressMap(item),
        const SizedBox(height: 10),
        _buildPriceDropBox(),
        const SizedBox(height: 20),
        _buildDescription(item),
        const SizedBox(height: 12),
        const Text('Đặc điểm bất động sản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildPropertyInfo(item),
        const SizedBox(height: 12),
        _buildSellerInfo(item),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildPriceAreaInfo(Map<String, dynamic> item) {
    final String price = item['formatedPrice']?.toString() ??
        (item['formatedRentPrice'] != null ? '${item['formatedRentPrice'].toString()}/tháng' : '--');
    final String area = item['total_area']?.toString() ?? '--';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(price, style: const TextStyle(fontSize: 20, color: Color(0xff0077bb), fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Text('$area m²', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              if (item['formatedSqrPrice'] != null)
                Text(
                  '${item['formatedSqrPrice'].toString()}/m²',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildIconText(Icons.bed, '${item['bed']?.toString() ?? '-'} PN'),
              _buildIconText(Icons.bathtub, '${item['bath']?.toString() ?? '-'} WC'),
              _buildIconText(Icons.home_work, '${item['floors']?.toString() ?? '-'} tầng'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressMap(Map<String, dynamic> item) {
    final String? geo = item['geolocation']?.toString();
    final List<String> latLng = geo?.split(',') ?? [];
    final double? lat = latLng.length == 2 ? double.tryParse(latLng[0]) : null;
    final double? lng = latLng.length == 2 ? double.tryParse(latLng[1]) : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(item['address']?.toString() ?? '---', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ),
        GestureDetector(
          onTap: () {
            if (lat != null && lng != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullMapScreen(latitude: lat, longitude: lng),
                ),
              );
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/image/mapppp.jpg', height: 50, width: 50, fit: BoxFit.cover),
              ),
              const Icon(Icons.location_on, color: Colors.black, size: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDropBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          const Icon(Icons.trending_down, color: Colors.red),
          const Text('2,2%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const Text('Giá tại khu vực này đã giảm trong vòng 1 năm qua', style: TextStyle(fontSize: 13)),
          TextButton(onPressed: () {}, child: const Text('Xem lịch sử giá', style: TextStyle(color: Color(0xff0077bb)))),
        ],
      ),
    );
  }

  Widget _buildDescription(Map<String, dynamic> item) {
    final String htmlDescription = item['description']?.toString() ?? '';
    final String plainText = _parseHtmlToPlainText(htmlDescription);

    const int maxLines = 10;
    final List<String> lines = plainText.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mô tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!_isExpanded)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lines.take(maxLines).join('\n'),
                style: const TextStyle(fontSize: 14),
              ),
              if (lines.length > maxLines)
                TextButton(
                  onPressed: () => setState(() => _isExpanded = true),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF0077BB)),
                  child: const Text('Xem thêm'),
                ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Html(
                data: htmlDescription,
                style: {
                  "body": Style(fontSize: FontSize(14)),
                  "p": Style(margin: Margins.only(bottom: 10)),
                },
              ),
              TextButton(
                onPressed: () => setState(() => _isExpanded = false),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF0077BB)),
                child: const Text('Ẩn bớt'),
              ),
            ],
          ),
      ],
    );
  }

  String _parseHtmlToPlainText(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text.trim() ?? '';
  }

  Widget _buildPropertyInfo(Map<String, dynamic> item) {
    final String price = item['formatedPrice']?.toString() ??
        (item['formatedRentPrice'] != null
            ? '${item['formatedRentPrice'].toString()}/tháng'
            : '--');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.price_change, 'Mức giá', price),
          _buildInfoRow(Icons.aspect_ratio, 'Diện tích', item['total_area'] != null ? '${item['total_area']} m²' : ''),
          _buildInfoRow(Icons.bed, 'Số phòng ngủ', item['bed'] != null ? '${item['bed']}' : ''),
          _buildInfoRow(Icons.bathtub, 'Số phòng tắm, vệ sinh', item['bath'] != null ? '${item['bath']}' : ''),
          _buildInfoRow(Icons.stairs, 'Số tầng', item['floors'] != null ? '${item['floors']}' : ''),
          _buildInfoRow(Icons.description, 'Pháp lý', item['legal']?.toString() ?? ''),
          _buildInfoRow(Icons.explore, 'Hướng', item['direction']?.toString() ?? ''),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchAgentPosts(String agentId) async {
    final response = await http.post(
      Uri.parse('https://online.nks.vn/api/nks/rsitems'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'agent_id': agentId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    return [];
  }

  Widget _buildSellerInfo(Map<String, dynamic> item) {
    final Map<String, dynamic> sale = (item['sale'] ?? {}) as Map<String, dynamic>;
    final String sellerName = sale['name']?.toString() ?? '---';
    final String avatarUrl = sale['avatar']?.toString() ?? '';
    final String saleID = sale['id']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : const AssetImage('assets/image/avatar.jpg') as ImageProvider,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Môi giới chuyên nghiệp',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  Text(
                    sellerName,
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              // const Icon(Icons.verified, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 12),
          const Text('1 năm tham gia NKS', style: TextStyle(color: Colors.black, fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder:
                        (context) => AgentDetailScreen(
                          avatarUrl: avatarUrl,
                          agentId: saleID,
                          agentName: sellerName,
                          postsCount: agentPostCount,
                        )
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0077bb),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Xem $agentPostCount tin đăng'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.black87),
        onPressed: onTap,
        splashRadius: 20,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 12),
      ],
    );
  }
}
