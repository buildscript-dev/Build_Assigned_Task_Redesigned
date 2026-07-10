import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

/// Reusable design-system primitives — every shell screen builds from
/// these instead of ad hoc Containers/ListTiles, so the whole app reads
/// as one considered product instead of a pile of default widgets.

/// Elevated card: rounded corners, soft tinted shadow, optional tap with
/// the same press-scale feel as the feed's action rail.
class SoftCard extends StatefulWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color, // null = theme-adaptive (light surfaceCard / dark darkCard)
    this.radius = Corners.md,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  @override
  State<SoftCard> createState() => _SoftCardState();
}

class _SoftCardState extends State<SoftCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final resolvedColor =
        widget.color ?? (dark ? AppColors.darkCard : AppColors.surfaceCard);
    final card = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: Motion.fast,
      curve: Motion.spring,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: resolvedColor,
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: [
            const BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: dark
                  ? AppColors.cardHighlightDark
                  : AppColors.cardHighlightLight,
              blurRadius: 12,
              offset: const Offset(-3, -4),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
    if (widget.onTap == null) return card;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: card,
    );
  }
}

/// Filled gradient pill button with press-scale + haptic — the same
/// tactile language as the feed's rail icons and Save button.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final bool compact;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: enabled
          ? () {
              HapticFeedback.mediumImpact();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: Motion.fast,
        curve: Motion.spring,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 16 : 22,
            vertical: widget.compact ? 8 : 12,
          ),
          decoration: BoxDecoration(
            gradient: widget.filled && enabled ? AppColors.heroGradient : null,
            color: !widget.filled
                ? AppColors.trackGrey
                : (!enabled ? AppColors.greyMuted : null),
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.filled && enabled
                ? [
                    BoxShadow(
                      color: AppColors.brandGreen.withValues(alpha: .35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                    const BoxShadow(
                      color: AppColors.cardHighlightLight,
                      blurRadius: 10,
                      offset: Offset(-2, -3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.filled
                  ? Colors.white
                  : (enabled ? AppColors.deepGreen : AppColors.greyText),
              fontWeight: FontWeight.w700,
              fontSize: widget.compact ? 13 : 14.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Consistent heading + optional subtitle used at the top of every screen.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: ink,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Staggered fade+rise entrance for list/grid items — wrap each item with
/// its index so a screen's content settles in instead of popping in flat.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 40 * widget.index), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.12),
      duration: Motion.base,
      curve: Motion.smooth,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: Motion.base,
        child: widget.child,
      ),
    );
  }
}

/// Small label used above grouped content ("TRENDING PRODUCTS", etc.)
class KickerLabel extends StatelessWidget {
  const KickerLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.brandGreen,
      ),
    );
  }
}
