// 홈 화면의 시작/일시정지/초기화/종료 조작 버튼 묶음을 렌더링한다.
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

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
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: _StartPauseButton(
            onTap: primaryAction,
            icon: primaryIcon,
            label: primaryLabel,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: _SecondaryControlPill(
            onReset: canReset ? onReset : null,
            onStop: canStop ? onStop : null,
          ),
        ),
      ],
    );
  }
}

class _StartPauseButton extends StatelessWidget {
  const _StartPauseButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onTap;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppStyles.pillRadius,
          onTap: onTap,
          child: Ink(
            height: 64,
            decoration: AppStyles.primaryPillDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryTextOn,
                  size: 26,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppStyles.buttonText.copyWith(
                    color: AppColors.primaryTextOn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryControlPill extends StatelessWidget {
  const _SecondaryControlPill({
    required this.onReset,
    required this.onStop,
  });

  final VoidCallback? onReset;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    Widget actionButton({
      required IconData icon,
      required VoidCallback? onTap,
    }) {
      final enabled = onTap != null;

      return Expanded(
        child: InkWell(
          borderRadius: AppStyles.pillRadius,
          onTap: onTap,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : 0.4,
              child: Icon(
                icon,
                size: 24,
                color: AppColors.iconSoft,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 64,
      decoration: AppStyles.softPillDecoration,
      child: Row(
        children: [
          actionButton(
            icon: Icons.refresh_rounded,
            onTap: onReset,
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.line,
          ),
          actionButton(
            icon: Icons.stop_rounded,
            onTap: onStop,
          ),
        ],
      ),
    );
  }
}
