import 'package:flutter/material.dart';

import '../theme_tokens.dart';

/// Subtle placeholder used while list/table content is being loaded.
class AnaSoilSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const AnaSoilSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AnaSoilRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.55,
    );

    if (reduceMotion) {
      return _SkeletonShape(
        width: width,
        height: height,
        radius: radius,
        color: baseColor,
      );
    }

    return _SkeletonPulse(
      width: width,
      height: height,
      radius: radius,
      baseColor: baseColor,
    );
  }
}

class AnaSoilSkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const AnaSoilSkeletonLine({super.key, this.width, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return AnaSoilSkeletonBox(
      width: width,
      height: height,
      radius: AnaSoilRadius.sm,
    );
  }
}

class AnaSoilSkeletonCard extends StatelessWidget {
  final bool leading;
  final int lines;
  final double height;

  const AnaSoilSkeletonCard({
    super.key,
    this.leading = true,
    this.lines = 3,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AnaSoilSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          if (leading) ...[
            const AnaSoilSkeletonBox(width: 44, height: 44),
            const SizedBox(width: AnaSoilSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnaSoilSkeletonLine(width: 180, height: 14),
                const SizedBox(height: AnaSoilSpacing.sm),
                for (var i = 1; i < lines; i++) ...[
                  AnaSoilSkeletonLine(width: i == lines - 1 ? 120 : null),
                  if (i != lines - 1) const SizedBox(height: AnaSoilSpacing.xs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnaSoilSkeletonList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;
  final bool leading;
  final double itemHeight;

  const AnaSoilSkeletonList({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.all(AnaSoilSpacing.lg),
    this.leading = true,
    this.itemHeight = 96,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AnaSoilSpacing.md),
      itemBuilder: (_, _) =>
          AnaSoilSkeletonCard(leading: leading, height: itemHeight),
    );
  }
}

class AnaSoilSkeletonTable extends StatelessWidget {
  final int rows;
  final int columns;
  final String? title;
  final IconData? titleIcon;

  const AnaSoilSkeletonTable({
    super.key,
    this.rows = 8,
    this.columns = 5,
    this.title,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AnaSoilSpacing.xl),
            child: Row(
              children: [
                if (titleIcon != null) ...[
                  AnaSoilSkeletonBox(width: 24, height: 24),
                  const SizedBox(width: AnaSoilSpacing.sm),
                ],
                AnaSoilSkeletonLine(
                  width: title == null ? 180 : 220,
                  height: 16,
                ),
                const Spacer(),
                const AnaSoilSkeletonBox(width: 96, height: 36),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AnaSoilSpacing.xl),
            child: Column(
              children: [
                for (var row = 0; row < rows; row++) ...[
                  Row(
                    children: [
                      for (var column = 0; column < columns; column++) ...[
                        Expanded(
                          flex: column == 0 ? 2 : 1,
                          child: AnaSoilSkeletonLine(
                            width: column == columns - 1 ? 72 : null,
                            height: 12,
                          ),
                        ),
                        if (column != columns - 1)
                          const SizedBox(width: AnaSoilSpacing.lg),
                      ],
                    ],
                  ),
                  if (row != rows - 1)
                    const SizedBox(height: AnaSoilSpacing.xl),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonPulse extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  final Color baseColor;

  const _SkeletonPulse({
    this.width,
    required this.height,
    required this.radius,
    required this.baseColor,
  });

  @override
  State<_SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<_SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return _SkeletonShape(
          width: widget.width,
          height: widget.height,
          radius: widget.radius,
          color: Color.lerp(
            widget.baseColor,
            Theme.of(context).colorScheme.surface,
            0.36 * _animation.value,
          )!,
        );
      },
    );
  }
}

class _SkeletonShape extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color color;

  const _SkeletonShape({
    this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
