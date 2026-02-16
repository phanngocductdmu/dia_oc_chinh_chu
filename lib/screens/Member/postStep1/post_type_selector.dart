import 'package:flutter/material.dart';

class PostTypeSelector extends StatelessWidget {
  final String? selectedType;
  final bool showFullOptions;
  final void Function(String) onTypeSelected;
  final VoidCallback onCollapse;

  const PostTypeSelector({
    super.key,
    required this.selectedType,
    required this.showFullOptions,
    required this.onTypeSelected,
    required this.onCollapse,
  });

  final Color primaryColor = const Color(0xFF0077BB);

  @override
  Widget build(BuildContext context) {
    print('🔧 PostTypeSelector build: selectedType=$selectedType, showFullOptions=$showFullOptions');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nhu cầu', style: TextStyle(fontWeight: FontWeight.bold)),
              if (selectedType != null && !showFullOptions)
                GestureDetector(
                  onTap: onCollapse,
                  child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (showFullOptions || selectedType == null)
            Row(
              children: [
                _buildOptionButton('Bán', Icons.sell_outlined),
                const SizedBox(width: 12),
                _buildOptionButton('Cho thuê', Icons.vpn_key_outlined),
              ],
            )
          else
            Text(
              selectedType!,
              style: const TextStyle(color: Colors.black87),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String title, IconData icon) {
    final isSelected = selectedType == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeSelected(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? primaryColor : Colors.black12),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? const Color(0xFFE5F4FA) : Colors.white,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? primaryColor : Colors.black54),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: isSelected ? primaryColor : Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
