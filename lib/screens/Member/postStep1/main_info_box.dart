import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class MainInfoBox extends StatefulWidget {
  final String selectedType;
  final String initialPrice;
  final String initialUnit;
  final String initialHouseLength;
  final String initialHouseWidth;
  final String initialLandLength;
  final String initialLandWidth;
  final int initialBedrooms;
  final int initialBathrooms;
  final int initialFloors;
  final String? initialRstype;
  final double initialLandArea;
  final double? initialHouseArea;
  final double? initialTotalFloorArea;
  final double? initialPricePerM2;
  final double? initialTotalArea;

  final void Function({
  required int typeId,
  required String typeTitle,
  required String price,
  required String unit,
  required String houseLength,
  required String houseWidth,
  required String landLength,
  required String landWidth,
  required int bedrooms,
  required int bathrooms,
  required int floors,
  required double landArea,
  required double? houseArea,
  required double? totalFloorArea,
  required double? totalArea,
  required double? pricePerM2,
  })? onChanged;

  const MainInfoBox({
    super.key,
    this.onChanged,
    required this.selectedType,
    required this.initialPrice,
    required this.initialUnit,
    required this.initialHouseLength,
    required this.initialHouseWidth,
    required this.initialLandLength,
    required this.initialLandWidth,
    required this.initialBedrooms,
    required this.initialBathrooms,
    required this.initialFloors,
    required this.initialLandArea,
    this.initialHouseArea,
    this.initialTotalFloorArea,
    this.initialPricePerM2,
    this.initialTotalArea,
    this.initialRstype
  });

  @override
  State<MainInfoBox> createState() => _MainInfoBoxState();
}

class _MainInfoBoxState extends State<MainInfoBox> {
  List<Map<String, dynamic>> propertyTypes = [];
  Map<String, dynamic>? selectedPropertyType;
  int bedrooms = 0;
  int bathrooms = 0;
  int floors = 1;
  int totalArea = 0;

  final List<String> priceUnits = ['VND', 'Giá/m²', 'Thoả thuận'];
  String selectedPriceUnit = 'VND';

  final TextEditingController priceController = TextEditingController();
  final TextEditingController houseLengthController = TextEditingController();
  final TextEditingController houseWidthController = TextEditingController();
  final TextEditingController landLengthController = TextEditingController();
  final TextEditingController landWidthController = TextEditingController();
  final TextEditingController totalAreaController = TextEditingController();

  bool expanded = true;
  final formatter = NumberFormat.decimalPattern('vi_VN');
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    priceController.text = widget.initialPrice;
    houseLengthController.text = widget.initialHouseLength;
    houseWidthController.text = widget.initialHouseWidth;
    landLengthController.text = widget.initialLandLength;
    landWidthController.text = widget.initialLandWidth;
    bedrooms = widget.initialBedrooms;
    bathrooms = widget.initialBathrooms;
    floors = widget.initialFloors;
    // totalArea = widget.initialTotalArea;

    if (widget.initialTotalArea != null && widget.initialTotalArea! > 0) {
      totalAreaController.text = widget.initialTotalArea!.toStringAsFixed(1);
    }

    fetchPropertyTypes().then((types) {
      if (!mounted) return;

      Map<String, dynamic>? defaultType;
      if (widget.initialRstype != null && widget.initialRstype!.isNotEmpty) {
        defaultType = types.firstWhere(
              (type) => type['title'].toString().toLowerCase() == widget.initialRstype!.toLowerCase(),
          orElse: () => types.isNotEmpty ? types[0] : {},
        );
      }

      setState(() {
        propertyTypes = types;
        selectedPropertyType = defaultType ?? (types.isNotEmpty ? types[0] : null);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notifyParent();
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchPropertyTypes() async {
    try {
      final response = await http.post(Uri.parse('https://online.nks.vn/api/nks/rstypes'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        debugPrint('API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
      return [];
    }
  }

  bool get isTownhouse {
    try {
      final title = selectedPropertyType?['title']?.toString().toLowerCase() ?? '';
      return title.contains('nhà phố') || title.contains('nhà mặt tiền');
    } catch (_) {
      return false;
    }
  }

  void _notifyParent() {
    try {
      if (widget.onChanged != null && selectedPropertyType != null) {
        final double? houseWidth = double.tryParse(houseWidthController.text);
        final double? houseLength = double.tryParse(houseLengthController.text);
        final double? landWidth = double.tryParse(landWidthController.text);
        final double? landLength = double.tryParse(landLengthController.text);
        final double? price = double.tryParse(priceController.text.replaceAll('.', '').replaceAll(',', ''));

        final double landArea = isTownhouse
            ? (houseWidth ?? 0) * (houseLength ?? 0)
            : (landWidth ?? 0) * (landLength ?? 0);

        final double? houseArea = (houseWidth != null && houseLength != null) ? houseWidth * houseLength : null;
        final double? totalFloorArea = isTownhouse && houseArea != null ? houseArea * (floors > 0 ? floors : 1) : null;

        double? pricePerM2;
        if (price != null) {
          final double? baseArea = isTownhouse ? totalFloorArea : (landArea > 0 ? landArea : null);
          if (baseArea != null && baseArea > 0) {
            pricePerM2 = price / baseArea / 1e6;
          }
        }

        widget.onChanged!(
          typeId: selectedPropertyType!['id'],
          typeTitle: selectedPropertyType!['title'],
          price: priceController.text,
          unit: selectedPriceUnit,
          houseLength: houseLengthController.text,
          houseWidth: houseWidthController.text,
          landLength: landLengthController.text,
          landWidth: landWidthController.text,
          bedrooms: bedrooms,
          bathrooms: bathrooms,
          floors: floors,
          landArea: landArea,
          houseArea: houseArea,
          totalFloorArea: totalFloorArea,
          pricePerM2: pricePerM2,
          totalArea: landArea,
        );
      }
    } catch (e) {
      debugPrint('Notify parent error: $e');
    }
  }

  String formatNumber(String value) {
    try {
      final numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
      final number = int.tryParse(numericString);
      return number != null ? formatter.format(number) : '';
    } catch (_) {
      return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Thông tin chính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: () => setState(() => expanded = !expanded),
                child: Icon(expanded ? Icons.expand_less : Icons.expand_more, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!expanded)
            Row(
              children: [
                Flexible(
                  child: Text(selectedPropertyType?['title'] ?? '', style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                ),
                const Text(' · ', style: TextStyle(color: Colors.black54)),
                Text('${priceController.text} $selectedPriceUnit', style: const TextStyle(fontSize: 14)),
              ],
            )
          else ...[
            _buildDropdown(),
            const SizedBox(height: 16),
            _buildCounterRow('Số phòng ngủ', bedrooms, (val) => setState(() {
              bedrooms = val;
              _notifyParent();
            })),
            const SizedBox(height: 12),
            _buildCounterRow('Số phòng tắm, vệ sinh', bathrooms, (val) => setState(() {
              bathrooms = val;
              _notifyParent();
            })),
            const SizedBox(height: 12),
            _buildCounterRow('Số tầng', floors, (val) => setState(() {
              floors = val;
              _notifyParent();
            })),
            const SizedBox(height: 12),
            _buildInput('Chiều ngang nhà (m)', houseWidthController),
            _buildInput('Chiều dài nhà (m)', houseLengthController),
            _buildInput('Chiều ngang đất (m)', landWidthController),
            _buildInput('Chiều dài đất (m)', landLengthController),
            _buildInput('Diện tích đất (m²)', totalAreaController),
            const SizedBox(height: 16),
            _buildPriceInput(),
            const SizedBox(height: 16),
            _buildPriceSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Loại BĐS', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      DropdownButtonFormField<Map<String, dynamic>>(
        value: selectedPropertyType,
        items: propertyTypes.map((item) => DropdownMenuItem(value: item, child: Text(item['title']))).toList(),
        onChanged: (value) => setState(() {
          selectedPropertyType = value;
          _notifyParent();
        }),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
    ],
  );

  Widget _buildPriceInput() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Mức giá', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                isDense: true,
                hintText: 'Nhập giá',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              onChanged: (value) {
                if (_isFormatting) return;
                _isFormatting = true;

                final formatted = formatNumber(value);
                if (priceController.text != formatted) {
                  final cursor = formatted.length;
                  setState(() {
                    priceController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: cursor),
                    );
                  });
                }
                _isFormatting = false;
                _notifyParent();
              },
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: selectedPriceUnit,
            items: priceUnits.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) => setState(() {
              selectedPriceUnit = value!;
              _notifyParent();
            }),
          ),
        ],
      ),
    ],
  );

  Widget _buildPriceSummary() {
    final double? price = double.tryParse(priceController.text.replaceAll('.', '').replaceAll(',', ''));
    final double? houseWidth = double.tryParse(houseWidthController.text);
    final double? houseLength = double.tryParse(houseLengthController.text);
    final double? landWidth = double.tryParse(landWidthController.text);
    final double? landLength = double.tryParse(landLengthController.text);

    final double? houseArea = (houseWidth != null && houseLength != null) ? houseWidth * houseLength : null;
    final double? totalFloorArea = (houseArea != null && isTownhouse) ? houseArea * (floors > 0 ? floors : 1) : null;
    final double? landArea = (landWidth != null && landLength != null) ? landWidth * landLength : null;

    final double? pricePerM2 = (() {
      final area = isTownhouse ? totalFloorArea : landArea;
      if (area != null && area > 0 && price != null) {
        return price / area / 1e6;
      }
      return null;
    })();

    if (price == null || selectedPriceUnit == 'Thoả thuận') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (landWidth != null) Text('Chiều ngang đất: ${landWidth.toStringAsFixed(1)} m'),
        if (landLength != null) Text('Chiều dài đất: ${landLength.toStringAsFixed(1)} m'),
        if (landArea != null) Text('Diện tích đất: ${landArea.toStringAsFixed(1)} m²'),
        if (houseWidth != null) Text('Chiều ngang nhà: ${houseWidth.toStringAsFixed(1)} m'),
        if (houseLength != null) Text('Chiều dài nhà: ${houseLength.toStringAsFixed(1)} m'),
        if (houseArea != null) Text('Diện tích nhà: ${houseArea.toStringAsFixed(1)} m²'),
        if (isTownhouse && totalFloorArea != null)
          Text('Tổng diện tích sàn: ${totalFloorArea.toStringAsFixed(1)} m²'),
        if (pricePerM2 != null)
          Text(
            'Giá/m²: ~${pricePerM2.toStringAsFixed(0)} triệu${widget.selectedType == 'Cho thuê' ? '/tháng' : ''}',
          ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            isDense: true,
            hintText: 'Nhập số',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          onChanged: (_) => setState(_notifyParent),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCounterRow(String label, int value, Function(int newVal) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Row(
          children: [
            _buildCounterButton(Icons.remove, () {
              if (value > 0) onChanged(value - 1);
            }),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('$value')),
            _buildCounterButton(Icons.add, () => onChanged(value + 1)),
          ],
        )
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.grey),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
