import 'package:flutter/material.dart';

import '../glass_widgets.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
    required this.primaryAction,
    required this.primaryIcon,
    required this.primaryLabel,
    required this.onReset,
    required this.onStop,
    required this.canReset,
    required this.canStop,
  });

  final VoidCallback? primaryAction;
  final IconData primaryIcon;
  final String primaryLabel;
  final VoidCallback? onReset;
  final VoidCallback? onStop;
  final bool canReset;
  final bool canStop;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: 88,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GlassButton(
              icon: primaryIcon,
              onPressed: primaryAction,
              height: 56,
              padding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: GlassButton(
              icon: Icons.refresh_rounded,
              onPressed: canReset ? onReset : null,
              height: 56,
              padding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: GlassButton(
              icon: Icons.stop_rounded,
              onPressed: canStop ? onStop : null,
              height: 56,
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }
}
