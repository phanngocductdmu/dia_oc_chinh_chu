import 'package:flutter/material.dart';

class OtherInfoBox extends StatefulWidget {
  final String? initialLegalDoc;
  final String? initialInterior;
  final String? initialDirection;

  final void Function({
  required String? legalDoc,
  required String? interior,
  required String? direction,
  })? onChanged;

  const OtherInfoBox({
    super.key,
    this.onChanged,
    this.initialLegalDoc,
    this.initialInterior,
    this.initialDirection
  });

  @override
  State<OtherInfoBox> createState() => _OtherInfoBoxState();
}

class _OtherInfoBoxState extends State<OtherInfoBox> {
  bool expanded = true;

  String? selectedLegalDoc;
  String? selectedInterior;
  String? selectedDirection;
  String? frontage;


  final List<String> legalOptions = ['Sổ đỏ', 'Sổ hồng', 'Sổ chung', 'Vi bằng', 'Biên nhận riêng', 'Biên nhân chung', 'Sổ đồng sở hữu', 'Giấy quân đội cấp', 'Hợp đồng góp vốn', 'Sổ chờ'];
  final List<String> interiorOptions = ['Đầy đủ', 'Cơ bản', 'Không có'];
  final List<String> directionOptions = [
    'Đông',
    'Tây',
    'Nam',
    'Bắc',
    'Đông Bắc',
    'Đông Nam',
    'Tây Bắc',
    'Tây Nam',
  ];

  @override
  void initState() {
    super.initState();
    selectedLegalDoc = legalOptions.first;
    selectedInterior = interiorOptions.first;
    selectedDirection = directionOptions.first;selectedLegalDoc = widget.initialLegalDoc != null && legalOptions.contains(widget.initialLegalDoc!)
        ? widget.initialLegalDoc
        : legalOptions.first;

    selectedInterior = widget.initialInterior != null && interiorOptions.contains(widget.initialInterior!)
        ? widget.initialInterior
        : interiorOptions.first;

    selectedDirection = widget.initialDirection != null && directionOptions.contains(widget.initialDirection!)
        ? widget.initialDirection
        : directionOptions.first;


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) notifyParent();
    });
  }



  void notifyParent() {
    if (widget.onChanged != null) {
      widget.onChanged!(
        legalDoc: selectedLegalDoc,
        interior: selectedInterior,
        direction: selectedDirection,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Thông tin khác ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                '(không bắt buộc)',
                style: TextStyle(color: Colors.black45, fontSize: 13),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black54,
                ),
                onPressed: () => setState(() => expanded = !expanded),
              )
            ],
          ),

          if (expanded) ...[
            const SizedBox(height: 16),

            // Giấy tờ pháp lý
            DropdownButtonFormField<String>(
              value: selectedLegalDoc,
              items: legalOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() {
                selectedLegalDoc = value;
                notifyParent();
              }),

              decoration: const InputDecoration(
                hintText: 'Chọn giấy tờ pháp lý',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nội thất
            DropdownButtonFormField<String>(
              value: selectedInterior,
              items: interiorOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() {
                selectedInterior = value;
                notifyParent();
              }),

              decoration: const InputDecoration(
                hintText: 'Chọn nội thất',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Hướng nhà
            DropdownButtonFormField<String>(
              value: selectedDirection,
              items: directionOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() {
                selectedDirection = value;
                notifyParent();
              }),

              decoration: const InputDecoration(
                hintText: 'Chọn hướng nhà',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}