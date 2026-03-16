import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.rows,
    required this.totalLabel,
    required this.totalValue,
  });

  final List<({String label, String value})> rows;
  final String totalLabel;
  final String totalValue;

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color(0x26B6C2CF);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6A7481),
                      ),
                    ),
                  ),
                  Text(
                    row.value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111418),
                    ),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(height: 1, color: dividerColor),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  totalLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E6BFF),
                  ),
                ),
              ),
              Text(
                totalValue,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E6BFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
