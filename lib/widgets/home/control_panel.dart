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
      height: 96,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GlassButton(
              label: primaryLabel,
              icon: primaryIcon,
              onPressed: primaryAction,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: GlassButton(
              label: '초기화',
              icon: Icons.refresh_rounded,
              onPressed: canReset ? onReset : null,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: GlassButton(
              label: '종료',
              icon: Icons.stop_rounded,
              onPressed: canStop ? onStop : null,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
