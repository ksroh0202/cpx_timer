import 'package:flutter/material.dart';

class StageRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const StageRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}