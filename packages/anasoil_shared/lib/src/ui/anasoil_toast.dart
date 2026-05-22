import 'dart:async';

import 'package:flutter/material.dart';

import '../theme_tokens.dart';

/// Notification type for [AnaSoilToast].
enum AnaSoilToastType { success, error, warning, info }

/// Sonner-inspired pile-stacking toast notifications for AnaSoil apps.
///
/// Toasts stack on top of each other like a deck of cards.
/// The newest toast is always in front; older ones peek from behind,
/// slightly scaled-down and shifted upward.
///
/// Appears at the bottom-right on wide screens (≥ 700 px)
/// and bottom-center on narrow screens.
///
/// Usage:
/// ```dart
/// AnaSoilToast.success(context, 'Análise excluída com sucesso!');
/// AnaSoilToast.error(context, 'Erro ao excluir: $e');
/// ```
abstract final class AnaSoilToast {
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(context, message, AnaSoilToastType.success, duration);

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) =>
      _show(context, message, AnaSoilToastType.error, duration);

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) =>
      _show(context, message, AnaSoilToastType.warning, duration);

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(context, message, AnaSoilToastType.info, duration);

  static void _show(
    BuildContext context,
    String message,
    AnaSoilToastType type,
    Duration duration,
  ) =>
      _ToastController.instance.show(
        Overlay.of(context),
        message,
        type,
        duration,
      );
}

// ─── Data ────────────────────────────────────────────────────────────────────

class _ToastData {
  final String message;
  final AnaSoilToastType type;
  final Duration duration;

  /// Stable identity used as a [ValueKey] so the pile-transform animation
  /// state survives reorders in the [Stack].
  final Object id = Object();
  final GlobalKey<_ToastItemState> itemKey = GlobalKey();
  Timer? timer;

  _ToastData({
    required this.message,
    required this.type,
    required this.duration,
  });
}

// ─── Controller ──────────────────────────────────────────────────────────────

class _ToastController {
  _ToastController._();
  static final instance = _ToastController._();

  OverlayEntry? _entry;
  final _stackKey = GlobalKey<_ToastStackState>();

  void show(
    OverlayState overlay,
    String message,
    AnaSoilToastType type,
    Duration duration,
  ) {
    final data = _ToastData(message: message, type: type, duration: duration);
    final needsInsert = _stackKey.currentState == null;

    if (needsInsert) {
      _entry?.remove();
      _entry = OverlayEntry(builder: (_) => _ToastStack(key: _stackKey));
      overlay.insert(_entry!);
    }

    // State may not be available yet on the very first insert — wait one frame.
    if (needsInsert) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stackKey.currentState?.push(data);
      });
    } else {
      _stackKey.currentState!.push(data);
    }
  }
}

// ─── Toast stack (single overlay widget) ─────────────────────────────────────

class _ToastStack extends StatefulWidget {
  const _ToastStack({super.key});

  @override
  State<_ToastStack> createState() => _ToastStackState();
}

class _ToastStackState extends State<_ToastStack> {
  final _toasts = <_ToastData>[];

  void push(_ToastData toast) {
    if (!mounted) return;
    setState(() => _toasts.add(toast));
    toast.timer = Timer(toast.duration, () => _dismiss(toast));
  }

  void _dismiss(_ToastData toast) {
    toast.timer?.cancel();
    toast.itemKey.currentState?.animateOut(() {
      if (mounted) setState(() => _toasts.remove(toast));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_toasts.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= AnaSoilBreakpoints.mobile;
    final toastWidth = isWide ? 360.0 : screenWidth - 32.0;

    // Show at most 3 in the pile; everything older is hidden behind.
    final start = _toasts.length > 3 ? _toasts.length - 3 : 0;
    final visible = _toasts.sublist(start);

    return Positioned(
      bottom: 16,
      right: isWide ? 16 : null,
      left: isWide ? null : 16,
      width: toastWidth,
      // A Stack where the last child = highest z-order = front toast.
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          for (int i = 0; i < visible.length; i++)
            _PileSlot(
              key: ValueKey(visible[i].id),
              distanceFromFront: (visible.length - 1) - i,
              child: _ToastItem(
                key: visible[i].itemKey,
                message: visible[i].message,
                type: visible[i].type,
                onDismiss: () => _dismiss(visible[i]),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Pile slot – smoothly animates its position in the pile ──────────────────

/// Wraps a [_ToastItem] and applies the scaled + translated transform that
/// positions it in the pile. Uses Flutter's implicit animation API so the
/// transforms smoothly tween whenever [distanceFromFront] changes.
class _PileSlot extends ImplicitlyAnimatedWidget {
  const _PileSlot({
    super.key,
    required this.distanceFromFront,
    required this.child,
  }) : super(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
        );

  /// 0 = front toast, 1 = one behind, 2 = two behind.
  final int distanceFromFront;
  final Widget child;

  @override
  ImplicitlyAnimatedWidgetState<_PileSlot> createState() =>
      _PileSlotState();
}

class _PileSlotState extends AnimatedWidgetBaseState<_PileSlot> {
  // Sonner defaults: 5 % scale reduction and 14 px peek per level.
  static const _scaleStep = 0.05;
  static const _peekPx = 14.0;

  Tween<double>? _scale;
  Tween<double>? _dy;
  Tween<double>? _opacity;

  double get _targetScale => 1.0 - widget.distanceFromFront * _scaleStep;
  double get _targetDy => -(widget.distanceFromFront * _peekPx);
  // Front toast fully opaque; each level behind drops by 20 %.
  double get _targetOpacity => 1.0 - widget.distanceFromFront * 0.2;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _scale = visitor(
      _scale,
      _targetScale,
      (v) => Tween<double>(begin: v as double),
    ) as Tween<double>?;

    _dy = visitor(
      _dy,
      _targetDy,
      (v) => Tween<double>(begin: v as double),
    ) as Tween<double>?;

    _opacity = visitor(
      _opacity,
      _targetOpacity,
      (v) => Tween<double>(begin: v as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _scale!.evaluate(animation);
    final dy = _dy!.evaluate(animation);
    final opacity = _opacity!.evaluate(animation);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Transform.scale(
          scale: scale,
          // Anchor the scale at the bottom edge so the card shrinks upward,
          // keeping its bottom edge flush with the front toast.
          alignment: Alignment.bottomCenter,
          child: widget.child,
        ),
      ),
    );
  }
}

// ─── Toast item ───────────────────────────────────────────────────────────────

class _ToastItem extends StatefulWidget {
  const _ToastItem({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final AnaSoilToastType type;
  final VoidCallback onDismiss;

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    // Slide up from just below its final position.
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  void animateOut(VoidCallback onComplete) {
    if (!mounted) {
      onComplete();
      return;
    }
    _ctrl.reverse().then((_) => onComplete());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(widget.type);

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AnaSoilSpacing.md,
              vertical: AnaSoilSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(AnaSoilRadius.md),
              border: Border.all(color: style.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.09),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(style.icon, size: 18, color: style.foreground),
                const SizedBox(width: AnaSoilSpacing.sm),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: style.foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AnaSoilSpacing.xs),
                GestureDetector(
                  onTap: () => animateOut(widget.onDismiss),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: style.foreground.withValues(alpha: 0.5),
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

// ─── Style ────────────────────────────────────────────────────────────────────

class _ToastStyle {
  const _ToastStyle({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final IconData icon;
}

_ToastStyle _styleFor(AnaSoilToastType type) => switch (type) {
      AnaSoilToastType.success => _ToastStyle(
          background: AnaSoilSemanticColors.statusSuccessSoft,
          border:
              AnaSoilSemanticColors.statusSuccess.withValues(alpha: 0.30),
          foreground: AnaSoilSemanticColors.statusSuccess,
          icon: Icons.check_circle_outline_rounded,
        ),
      AnaSoilToastType.error => _ToastStyle(
          background: AnaSoilSemanticColors.statusDangerSoft,
          border:
              AnaSoilSemanticColors.statusDanger.withValues(alpha: 0.30),
          foreground: AnaSoilSemanticColors.statusDanger,
          icon: Icons.error_outline_rounded,
        ),
      AnaSoilToastType.warning => _ToastStyle(
          background: AnaSoilSemanticColors.statusWarningSoft,
          border:
              AnaSoilSemanticColors.statusWarning.withValues(alpha: 0.30),
          foreground: AnaSoilSemanticColors.statusWarning,
          icon: Icons.warning_amber_rounded,
        ),
      AnaSoilToastType.info => _ToastStyle(
          background: AnaSoilSemanticColors.surfaceMuted,
          border: AnaSoilSemanticColors.borderSubtle,
          foreground: AnaSoilSemanticColors.textSecondary,
          icon: Icons.info_outline_rounded,
        ),
    };
