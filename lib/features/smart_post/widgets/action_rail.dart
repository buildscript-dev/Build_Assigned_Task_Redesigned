import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';

/// TikTok-style floating action rail — replaces the old full-width share
/// row sitting on the photo. Each icon is its own tiny interaction: heart
/// fills with a bounce, share glows on press.
class ActionRail extends StatelessWidget {
  const ActionRail({
    super.key,
    required this.mood,
    required this.liked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final Color mood;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailButton(
          icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: liked ? mood : Colors.white,
          glow: liked,
          bounce: liked,
          onTap: onLike,
          haptic: HapticFeedback.mediumImpact,
        ),
        const SizedBox(height: 22),
        _RailButton(
          icon: Icons.auto_awesome_rounded,
          color: Colors.white,
          onTap: onComment,
          haptic: HapticFeedback.selectionClick,
        ),
        const SizedBox(height: 22),
        _RailButton(
          icon: Icons.send_rounded,
          color: Colors.white,
          onTap: onShare,
          haptic: HapticFeedback.mediumImpact,
        ),
      ],
    );
  }
}

class _RailButton extends StatefulWidget {
  const _RailButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.haptic,
    this.glow = false,
    this.bounce = false,
  });

  final IconData icon;
  final Color color;
  final bool glow;
  final bool bounce;
  final VoidCallback onTap;
  final void Function() haptic;

  @override
  State<_RailButton> createState() => _RailButtonState();
}

class _RailButtonState extends State<_RailButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final _ringController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final _ringScale = Tween(
    begin: 0.5,
    end: 2.0,
  ).animate(CurvedAnimation(parent: _ringController, curve: Curves.easeOut));
  late final _ringFade = Tween(
    begin: 0.55,
    end: 0.0,
  ).animate(CurvedAnimation(parent: _ringController, curve: Curves.easeOut));

  @override
  void didUpdateWidget(covariant _RailButton old) {
    super.didUpdateWidget(old);
    if (widget.bounce && !old.bounce) _ringController.forward(from: 0);
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        widget.haptic();
        widget.onTap();
      },
      child: SizedBox(
        width: 43,
        height: 43,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // One-shot pulse ring — fires only on the false→true bounce
            // transition (e.g. liking a post), not every rebuild.
            AnimatedBuilder(
              animation: _ringController,
              builder: (context, child) => Opacity(
                opacity: _ringFade.value,
                child: Transform.scale(
                  scale: _ringScale.value,
                  child: Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.color, width: 1.6),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedScale(
              scale: _pressed ? 0.78 : (widget.bounce ? 1.15 : 1.0),
              duration: widget.bounce ? Motion.base : Motion.fast,
              curve: Motion.spring,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.22),
                  boxShadow: widget.glow
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: .6),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
                child: Icon(widget.icon, color: widget.color, size: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
