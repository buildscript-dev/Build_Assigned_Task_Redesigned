import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

const _tabs = ['Smart Post', 'Library', 'Communities', 'Share & Win'];

/// Redesigned tab row — labels keep their natural width and are spread
/// with [MainAxisAlignment.spaceBetween] so the gap *between* words reads
/// as even, instead of forcing every label into an equal-width slot (which
/// looks lopsided once word lengths differ, e.g. "Library" vs
/// "Communities"). The underline position is measured from each label's
/// actual rendered rect via [GlobalKey] rather than computed arithmetically,
/// since slot widths are no longer uniform.
class SmartTabRow extends StatefulWidget {
  const SmartTabRow({super.key, this.activeIndex = 0, this.onTap});

  final int activeIndex;
  final void Function(int index)? onTap;

  @override
  State<SmartTabRow> createState() => _SmartTabRowState();
}

class _SmartTabRowState extends State<SmartTabRow> {
  static const _underlineWidth = 22.0;

  final _stackKey = GlobalKey();
  final _labelKeys = List.generate(_tabs.length, (_) => GlobalKey());
  final _lefts = List<double>.filled(_tabs.length, 0);
  final _widths = List<double>.filled(_tabs.length, 0);
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant SmartTabRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.attached) return;
    for (var i = 0; i < _tabs.length; i++) {
      final box =
          _labelKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) return;
      _lefts[i] = box.localToGlobal(Offset.zero, ancestor: stackBox).dx;
      _widths[i] = box.size.width;
    }
    if (mounted) setState(() => _measured = true);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final activeIndex = widget.activeIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Stack(
        key: _stackKey,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _tabs.length; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onTap == null
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          widget.onTap!(i);
                        },
                  child: Padding(
                    key: _labelKeys[i],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: AnimatedDefaultTextStyle(
                      duration: Motion.base,
                      curve: Motion.smooth,
                      style: TextStyle(
                        fontSize: 13.5,
                        letterSpacing: -0.1,
                        fontWeight: i == activeIndex
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: i == activeIndex
                            ? AppColors.brandGreen
                            : dark
                            ? Colors.white
                            : AppColors.ink,
                      ),
                      child: Text(_tabs[i], maxLines: 1),
                    ),
                  ),
                ),
            ],
          ),
          if (_measured)
            AnimatedPositioned(
              duration: Motion.base,
              curve: Motion.smooth,
              left:
                  _lefts[activeIndex] +
                  (_widths[activeIndex] - _underlineWidth) / 2,
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
  }
}
