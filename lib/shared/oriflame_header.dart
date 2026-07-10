import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

/// Brand header: AI assistant chip · ORIFLAME logo · camera button.
class OriflameHeader extends StatelessWidget {
  const OriflameHeader({
    super.key,
    this.showAssistant = true,
    this.onAssistantTap,
    this.onCameraTap,
  });

  final bool showAssistant;
  final VoidCallback? onAssistantTap;
  final VoidCallback? onCameraTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: showAssistant ? _AssistantChip(onTap: onAssistantTap) : null,
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                dark
                    ? 'assets/images/oriflame_logo_white.png'
                    : 'assets/images/oriflame_logo.png',
                height: 34,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onCameraTap == null
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onCameraTap!();
                      },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantChip extends StatelessWidget {
  const _AssistantChip({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // faint halo keeps the charcoal disc visible on the dark theme
            decoration: dark
                ? const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  )
                : null,
            padding: dark ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
            child: Image.asset(
              'assets/images/assistant_logo.png',
              width: 44,
              height: 43,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 2),
          Text('Your Assistant', style: TextStyle(fontSize: 9, color: ink)),
        ],
      ),
    );
  }
}
