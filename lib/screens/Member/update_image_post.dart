import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class UpdateImagePost extends StatefulWidget {
  final int id;
  final String? token;

  const UpdateImagePost({super.key, required this.id, this.token});

  @override
  State<UpdateImagePost> createState() => _UpdateImagePostState();
}

class _UpdateImagePostState extends State<UpdateImagePost> {
  String coverImage = '';
  List<Map<String, dynamic>> subImagesJson = [];
  List<TextEditingController> subImageControllers = [];
  final primaryColor = const Color(0xFF0077BB);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    loadPostDetail();
  }

  Future<void> loadPostDetail() async {
    final res = await http.post(
      Uri.parse('https://account.nks.vn/api/nks/user/rsitem'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'id': widget.id.toString(), 'access_token': widget.token ?? ''},
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true && json['data'] != null) {
        final data = json['data'];
        coverImage = data['featureimg']?.toString() ?? '';
        final gallery = data['gallery'] as List?;
        subImagesJson = [];
        subImageControllers = [];
        if (gallery != null) {
          for (var item in gallery) {
            subImagesJson.add({
              'code': item['code'],
              'image': item['image'],
              'type': 'url',
              'description': item['note'] ?? '',
            });
            subImageControllers.add(TextEditingController(text: item['note'] ?? ''));
          }
        }
        setState(() {});
      }
    }
  }

  String encodeImageToBase64WithMime(Uint8List bytes) {
    final mime = lookupMimeType('', headerBytes: bytes) ?? 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  Future<void> _selectImageFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      final dataUri = encodeImageToBase64WithMime(bytes);
      final tempController = TextEditingController();
      setState(() {
        subImagesJson.add({
          'code': null,
          'image': dataUri,
          'type': 'base64',
          'description': '',
        });
        subImageControllers.add(tempController);
      });

      // Upload ngay
      await addSubImage(dataUri, '');
    }
  }


  Future<void> addSubImage(String dataUri, String note) async {
    final res = await http.post(
      Uri.parse('https://account.nks.vn/api/nks/user/rsitemimg/add'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'image': dataUri,
        'note': note,
        'rsitem_id': widget.id.toString(),
        'access_token': widget.token ?? '',
      },
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true && json['data'] != null) {
        final newImg = json['data'];
        setState(() {
          final idx = subImagesJson.indexWhere((e) => e['code'] == null && e['image'] == dataUri);
          if (idx != -1) {
            subImagesJson[idx] = {
              'code': newImg['code'],
              'image': newImg['image'],
              'type': 'url',
              'description': newImg['note'],
            };
            subImageControllers[idx].text = newImg['note'] ?? '';
          }
        });
      }
    }
  }

  Future<void> updateImageNote(String code, String note) async {
    await http.post(
      Uri.parse('https://account.nks.vn/api/nks/user/rsitemimg/update'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'code': code, 'note': note, 'access_token': widget.token ?? ''},
    );
  }

  Future<void> deleteSubImage(String code) async {
    final res = await http.post(
      Uri.parse('https://account.nks.vn/api/nks/user/rsitemimg/delete'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'code': code, 'access_token': widget.token ?? ''},
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        setState(() {
          final idx = subImagesJson.indexWhere((e) => e['code'] == code);
          if (idx != -1) {
            subImagesJson.removeAt(idx);
            subImageControllers[idx].dispose();
            subImageControllers.removeAt(idx);
          }
        });
      }
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Chọn từ thư viện'),
            onTap: () {
              Navigator.pop(context);
              _selectImageFromGallery();
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _saveImages() async {
    setState(() => _isSaving = true);
    for (int i = 0; i < subImagesJson.length; i++) {
      final img = subImagesJson[i];
      final note = subImageControllers[i].text;
      if (img['code'] == null && img['type'] == 'base64') {
        await addSubImage(img['image'], note);
      } else if (img['code'] != null) {
        await updateImageNote(img['code'], note);
      }
    }
    setState(() => _isSaving = false);
    Navigator.pop(context, {'coverImage': coverImage, 'subImagesJson': subImagesJson});
  }

  @override
  Widget build(BuildContext context) {
    final canSave = coverImage.isNotEmpty && subImagesJson.length >= 3 && !_isSaving;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Chỉnh sửa ảnh', style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Thoát', style: TextStyle(color: Colors.black, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Hình ảnh & video',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: _showImageSourceBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_photo_alternate_rounded, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('Thêm ảnh từ thiết bị',
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (coverImage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(coverImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: () => setState(() => coverImage = ''),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ]),
            ),
          const SizedBox(height: 16),
          if (subImagesJson.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: subImagesJson.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final img = entry.value;
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
                    child: Stack(children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: (img['type'] == 'base64')
                                ? MemoryImage(base64Decode(img['image'].split(',').last))
                                : NetworkImage(img['image']) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => deleteSubImage(img['code']),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                          ),
                          child: TextField(
                            controller: subImageControllers[idx],
                            onChanged: (v) => subImagesJson[idx]['description'] = v,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            maxLines: 2,
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Nhập mô tả ảnh...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  );
                }).toList(),
              ),
            ),
        ]),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: canSave ? _saveImages : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canSave ? primaryColor : Colors.grey[300],
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : const Text('Xác nhận', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
