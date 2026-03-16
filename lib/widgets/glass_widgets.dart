import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

const double _glassBlur = 30;
const double _glassRadius = 24;
const double _glassMinHeight = 64;

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.alignment = Alignment.center,
    this.blur = _glassBlur,
    this.borderRadius = _glassRadius,
    this.minHeight = _glassMinHeight,
    this.surfaceColor = AppColors.glassSurface,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Alignment alignment;
  final double blur;
  final double borderRadius;
  final double minHeight;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolvedWidth = width ?? _resolveWidth(constraints);
          final resolvedHeight = _resolveHeight(constraints);
          final radius = BorderRadius.circular(borderRadius);

          return Container(
            width: resolvedWidth,
            height: resolvedHeight,
            constraints: BoxConstraints(minHeight: minHeight),
            decoration: AppStyles.glassPanelDecoration(
              borderRadius: radius,
              color: surfaceColor,
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Align(
                  alignment: alignment,
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _resolveWidth(BoxConstraints constraints) {
    if (constraints.hasBoundedWidth && constraints.maxWidth.isFinite) {
      return constraints.maxWidth;
    }
    return double.infinity;
  }

  double? _resolveHeight(BoxConstraints constraints) {
    if (height != null) {
      return height;
    }
    if (constraints.hasBoundedHeight && constraints.maxHeight.isFinite) {
      return constraints.maxHeight;
    }
    return null;
  }
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    this.label = '',
    this.icon,
    this.height = 64,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final hasLabel = label.isNotEmpty;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w600,
        );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: SizedBox(
            width: width,
            child: GlassContainer(
              height: height,
              borderRadius: 16,
              padding: padding,
              surfaceColor: AppColors.glassSurfaceSecondary,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: AppColors.primaryText),
                        if (hasLabel) const SizedBox(width: 6),
                      ],
                      if (hasLabel)
                        Text(
                          label,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: textStyle,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 64,
    this.tint,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: GlassContainer(
            width: size,
            height: size,
            minHeight: size,
            borderRadius: size / 2,
            blur: 24,
            padding: EdgeInsets.zero,
            surfaceColor: AppColors.glassSurfaceSecondary,
            child: Icon(icon, color: tint ?? AppColors.primaryText, size: 28),
          ),
        ),
      ),
    );
  }
}

class GlassSegmentedControl extends StatelessWidget {
  const GlassSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 72,
  }) : assert(labels.length > 0);

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: height,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            Expanded(
              child: _SegmentItem(
                label: labels[i],
                selected: selectedIndex == i,
                onTap: () => onChanged(i),
              ),
            ),
            if (i != labels.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background =
        selected ? AppColors.glassSurface : AppColors.glassSurfaceSecondary;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: AppStyles.glassPanelDecoration(
            borderRadius: BorderRadius.circular(14),
            color: background,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selected ? AppColors.primaryText : AppColors.secondaryText,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassBottomBarItem {
  const GlassBottomBarItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class GlassBottomBar extends StatelessWidget {
  const GlassBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 54,
  }) : assert(items.length > 0);

  final List<GlassBottomBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: height,
      borderRadius: 24,
      blur: 32,
      padding: const EdgeInsets.all(6),
      surfaceColor: AppColors.glassSurfaceSecondary,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
              child: _BottomBarItem(
                item: items[i],
                selected: selectedIndex == i,
                onTap: () => onChanged(i),
              ),
            ),
            if (i != items.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassBottomBarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: AppStyles.glassPanelDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? AppColors.accent.withValues(alpha: 0.20)
                : AppColors.glassSurfaceSecondary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 18,
                color: selected ? AppColors.accent : AppColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? AppColors.accent : AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
