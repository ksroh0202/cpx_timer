import 'package:flutter/material.dart';

import 'pill_button.dart';

class StageButton extends StatelessWidget {
  const StageButton({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.65,
      child: IgnorePointer(
        ignoring: !enabled,
        child: PillButton(
          label: label,
          onTap: onTap,
          selected: selected,
          height: 42,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
          horizontalPadding: 8,
          textColor: const Color(0xFF1F2833),
        ),
      ),
    );
  }
}
