import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

const double _glassBlur = 30;
const double _glassBorder = 1;
const double _glassRadius = 28;
const double _glassOpacityHigh = 0.25;
const double _glassOpacityLow = 0.05;
const double _glassBorderOpacity = 0.4;
const double _glassMinHeight = 64;

LinearGradient _glassFillGradient() {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: _glassOpacityHigh),
      Colors.white.withValues(alpha: _glassOpacityLow),
    ],
  );
}

LinearGradient _glassBorderGradient() {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: _glassBorderOpacity),
      Colors.white.withValues(alpha: _glassBorderOpacity),
    ],
  );
}

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
    this.border = _glassBorder,
    this.borderRadius = _glassRadius,
    this.minHeight = _glassMinHeight,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Alignment alignment;
  final double blur;
  final double border;
  final double borderRadius;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolvedWidth = width ?? _resolveWidth(constraints);
          final resolvedHeight = height ?? _resolveHeight(constraints, minHeight);

          return GlassmorphicContainer(
            width: resolvedWidth,
            height: resolvedHeight,
            borderRadius: borderRadius,
            blur: blur,
            alignment: alignment,
            border: border,
            linearGradient: _glassFillGradient(),
            borderGradient: _glassBorderGradient(),
            child: Padding(
              padding: padding,
              child: child,
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

  double _resolveHeight(BoxConstraints constraints, double fallback) {
    if (constraints.hasBoundedHeight && constraints.maxHeight.isFinite) {
      return constraints.maxHeight;
    }
    return fallback;
  }
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
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
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: SizedBox(
            width: width,
            child: GlassContainer(
              height: height,
              borderRadius: 999,
              padding: padding,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: Colors.black87),
                        const SizedBox(width: 6),
                      ],
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
    final background = selected
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.30 : 0.12),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.28 : 0.10),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 18,
                color: Colors.black87,
              ),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
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
