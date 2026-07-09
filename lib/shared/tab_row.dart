import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

const _tabs = ['Smart Post', 'Library', 'Communities', 'Share&Win'];

/// Redesigned tab row — equal-width slots + a LayoutBuilder computes the
/// underline's exact center under each label arithmetically (no RenderBox
/// measurement/timing to drift out of alignment).
class SmartTabRow extends StatelessWidget {
  const SmartTabRow({super.key, this.activeIndex = 0, this.onTap});

  final int activeIndex;
  final void Function(int index)? onTap;

  static const _underlineWidth = 30.0;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / _tabs.length;
          return SizedBox(
            width: constraints.maxWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onTap == null
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  onTap!(i);
                                },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            child: AnimatedDefaultTextStyle(
                              duration: Motion.base,
                              curve: Motion.smooth,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: i == activeIndex
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: i == activeIndex
                                    ? AppColors.brandGreen
                                    : dark
                                        ? Colors.white
                                        : AppColors.ink,
                              ),
                              child: Text(
                                _tabs[i],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                AnimatedPositioned(
                  duration: Motion.base,
                  curve: Motion.smooth,
                  left: activeIndex * slotWidth +
                      (slotWidth - _underlineWidth) / 2,
                  bottom: 2,
                  width: _underlineWidth,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
