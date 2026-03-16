import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.height = 48,
    this.textColor,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 16,
    this.horizontalPadding = 14,
    this.trailing,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final double height;
  final Color? textColor;
  final FontWeight fontWeight;
  final double fontSize;
  final double horizontalPadding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected
        ? const Color(0xFFF4F7FA)
        : const Color(0xFFE3E8EE);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: textColor ?? const Color(0xFF2F3A44),
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 6),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
