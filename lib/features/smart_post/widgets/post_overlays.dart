import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../data/mock_posts.dart';
import '../../../data/models.dart';
import '../../../shared/frosted_panel.dart';

/// Recommended-track row — bobbing note icon + track credit.
class MusicRow extends StatefulWidget {
  const MusicRow({super.key, required this.post});

  final SmartPost post;

  @override
  State<MusicRow> createState() => _MusicRowState();
}

class _MusicRowState extends State<MusicRow>
    with SingleTickerProviderStateMixin {
  late final _bob = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    final accent = dark ? AppColors.gold : AppColors.pillPink;
    return FrostedPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      color: Colors.transparent,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _bob,
            builder: (_, child) => Transform.rotate(
              angle: (_bob.value - 0.5) * 0.35,
              child: child,
            ),
            child: Icon(Icons.music_note_rounded, color: accent, size: 19),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(color: ink, fontSize: 14),
                children: [
                  const TextSpan(text: 'Recommended:  '),
                  TextSpan(
                    text: widget.post.trackTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: accent,
                    ),
                  ),
                  TextSpan(text: ' by ${widget.post.trackArtist}'),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// AI caption panel — tap to edit; outside the details sheet it truncates
/// with a "see more" toggle.
class CaptionBlock extends StatefulWidget {
  const CaptionBlock({
    super.key,
    required this.post,
    required this.index,
    required this.onEdit,
    this.alwaysExpanded = false,
  });

  final SmartPost post;
  final int index;
  final VoidCallback onEdit;

  /// True inside the Post Details sheet — shows the full caption with no
  /// truncation/expand affordance.
  final bool alwaysExpanded;

  @override
  State<CaptionBlock> createState() => _CaptionBlockState();
}

class _CaptionBlockState extends State<CaptionBlock>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    final accent = dark ? AppColors.gold : AppColors.pillPink;
    final italic = TextStyle(
      color: ink,
      fontSize: 13.5,
      fontStyle: FontStyle.italic,
    );
    final edited = editedCaptions[widget.index];
    final body = edited ?? widget.post.caption;
    final expanded = widget.alwaysExpanded || _expanded;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onEdit,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: Motion.fast,
        child: FrostedPanel(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'CAPTION SUGGESTION',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.auto_fix_high_rounded, color: accent, size: 16),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Edit Caption',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: widget.alwaysExpanded
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        setState(() => _expanded = !_expanded);
                      },
                child: AnimatedSize(
                  duration: Motion.base,
                  curve: Motion.smooth,
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.alwaysExpanded ? 1000 : 150,
                    ),
                    child: SingleChildScrollView(
                      physics: expanded
                          ? const ClampingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: ink,
                            fontSize: 14,
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(
                              text: expanded
                                  ? body
                                  : '${body.substring(0, body.length < 64 ? body.length : 64)}... ',
                            ),
                            if (!expanded)
                              TextSpan(
                                text: 'see more',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (edited == null) ...[
                const SizedBox(height: 10),
                Text(
                  'Use my referral code: $referralCode',
                  maxLines: expanded ? null : 1,
                  overflow: expanded ? null : TextOverflow.ellipsis,
                  style: italic,
                ),
                Text(
                  'Use my referral link: $referralLink',
                  maxLines: expanded ? null : 1,
                  overflow: expanded ? null : TextOverflow.ellipsis,
                  style: italic,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
