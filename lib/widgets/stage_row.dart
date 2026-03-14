import 'package:flutter/material.dart';

// "항목 이름 - 값" 한 줄을 재사용하기 위한 작은 위젯입니다.
class StageRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const StageRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    // 합계처럼 강조가 필요한 줄은 더 굵게 보이도록 합니다.
    final style = baseStyle?.copyWith(
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
