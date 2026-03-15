import 'package:flutter/material.dart';

class StageRow extends StatelessWidget {
  const StageRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
        );
    final valueStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
