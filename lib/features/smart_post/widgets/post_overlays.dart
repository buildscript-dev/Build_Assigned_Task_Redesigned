import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../data/mock_posts.dart';
import '../../../data/models.dart';
import '../../../shared/frosted_panel.dart';

const overlayTextShadows = [
  Shadow(color: Colors.black54, blurRadius: 5),
  Shadow(color: Colors.black38, blurRadius: 12),
];

/// Avatar + gradient "Ready to share" pill (gentle looping pulse) + label.
/// Tinted with the post's own mood color instead of one fixed brand color.
class PostHeaderRow extends StatefulWidget {
  const PostHeaderRow({super.key, required this.mood});

  final Color mood;

  @override
  State<PostHeaderRow> createState() => _PostHeaderRowState();
}

class _PostHeaderRowState extends State<PostHeaderRow>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.mood.withValues(alpha: .5),
                blurRadius: 10,
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/images/avatar.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) => Transform.scale(
                  scale: 1.0 + (_pulse.value * 0.035),
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.mood, AppColors.gold],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: widget.mood.withValues(alpha: .5),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    '✨ Ready to share',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'High-converting in Oriflame Community',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  shadows: overlayTextShadows,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "N of total" counter pill with a soft glass edge.
class PickCounter extends StatelessWidget {
  const PickCounter({super.key, required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Motion.base,
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Container(
        key: ValueKey(index),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          '${index + 1} of $total',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Indicator dots. Every dot occupies a fixed, unchanging box — only fill
/// color and an internal scale transform change with the active index, so
/// this can never itself be a source of layout overflow.
class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.index,
    required this.total,
    this.mood,
  });

  final int index;
  final int total;
  final Color? mood;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      radius: 18,
      color: Colors.black.withValues(alpha: 0.13),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                width: 14,
                height: 14,
                child: Center(
                  child: AnimatedScale(
                    scale: i == index ? 1.0 : 0.64,
                    duration: Motion.base,
                    curve: Motion.smooth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: i == index
                            ? LinearGradient(
                                colors: [
                                  mood ?? AppColors.brandGreen,
                                  AppColors.gold,
                                ],
                              )
                            : null,
                        color: i == index ? null : Colors.white70,
                        boxShadow: i == index
                            ? [
                                BoxShadow(
                                  color: (mood ?? AppColors.brandGreen)
                                      .withValues(alpha: .6),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: const SizedBox(width: 10, height: 10),
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

/// Music row with an animated note icon that bobs subtly.
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
    return FrostedPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      color: Colors.black.withValues(alpha: 0.11),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _bob,
            builder: (_, child) => Transform.rotate(
              angle: (_bob.value - 0.5) * 0.35,
              child: child,
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: AppColors.gold,
              size: 19,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  shadows: overlayTextShadows,
                ),
                children: [
                  const TextSpan(text: 'Recommended:  '),
                  TextSpan(
                    text: widget.post.trackTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: AppColors.gold,
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

/// Product card — press-scale interaction, gradient discount badge, glow.
class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.trending = true,
  });

  final Product product;
  final VoidCallback onTap;
  final bool trending;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  Widget _badge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      gradient: AppColors.goldGradient,
      borderRadius: BorderRadius.circular(6),
      boxShadow: [
        BoxShadow(color: AppColors.gold.withValues(alpha: .5), blurRadius: 6),
      ],
    ),
    child: Text(
      widget.product.discount,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _pressed = true);
      },
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: Motion.fast,
        curve: Motion.spring,
        child: FrostedPanel(
          padding: const EdgeInsets.all(8),
          color: Colors.white24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: AppColors.cream,
                  width: 56,
                  height: 56,
                  child: Image.asset(product.thumbAsset, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.trending)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.gold,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          const Flexible(
                            child: Text(
                              'Trending right now and on sale',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _badge(),
                        ],
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.price,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _badge(),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Caption block — animated edit-pencil wiggle on tap, smooth expand.
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
    const italic = TextStyle(
      color: Colors.white,
      fontSize: 13.5,
      fontStyle: FontStyle.italic,
      shadows: overlayTextShadows,
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
          color: Colors.black.withValues(alpha: 0.13),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        shadows: overlayTextShadows,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.auto_fix_high_rounded,
                    color: AppColors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Edit Caption',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        shadows: overlayTextShadows,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.35,
                            shadows: overlayTextShadows,
                          ),
                          children: [
                            TextSpan(
                              text: expanded
                                  ? body
                                  : '${body.substring(0, body.length < 64 ? body.length : 64)}... ',
                            ),
                            if (!expanded)
                              const TextSpan(
                                text: 'see more',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gold,
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

/// Quick-share row — each icon bounces + haptic-taps independently.
class QuickShareRow extends StatelessWidget {
  const QuickShareRow({super.key, required this.onShare});

  final void Function(SharePlatform) onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Quick share to:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            shadows: overlayTextShadows,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sharePlatforms.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) =>
                  _ShareIcon(platform: sharePlatforms[i], onShare: onShare),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShareIcon extends StatefulWidget {
  const _ShareIcon({required this.platform, required this.onShare});

  final SharePlatform platform;
  final void Function(SharePlatform) onShare;

  @override
  State<_ShareIcon> createState() => _ShareIconState();
}

class _ShareIconState extends State<_ShareIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _pressed = true);
      },
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onShare(widget.platform);
      },
      child: AnimatedScale(
        scale: _pressed ? 1.22 : 1.0,
        duration: Motion.fast,
        curve: Motion.spring,
        child: Image.asset(
          widget.platform.iconAsset,
          width: 46,
          height: 46,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Slim collapsed info strip — replaces the old full-width caption/music
/// panels that sat permanently on the photo. Only this thin bar (plus a
/// short gradient scrim behind it) touches the image; tapping it opens the
/// full Post Details sheet. The photo stays the star.
class PostMiniBar extends StatefulWidget {
  const PostMiniBar({
    super.key,
    required this.caption,
    required this.trackTitle,
    required this.mood,
    required this.onTap,
  });

  final String caption;
  final String trackTitle;
  final Color mood;
  final VoidCallback onTap;

  @override
  State<PostMiniBar> createState() => _PostMiniBarState();
}

class _PostMiniBarState extends State<PostMiniBar> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: Motion.fast,
        child: FrostedPanel(
          radius: 18,
          // Match the lighter caption/music treatment elsewhere — the
          // photo should read clearly through this bar too.
          color: Colors.black.withValues(alpha: 0.12),
          blur: 1.5,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [widget.mood, AppColors.gold],
                  ),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        shadows: overlayTextShadows,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '♫ ${widget.trackTitle}  ·  tap for details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        shadows: overlayTextShadows,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small floating tag (not a full card) so the product mention doesn't
/// block the photo. Fades in after 3s per the designer note; tap opens the
/// Post Details sheet scrolled to the product.
class ProductChip extends StatefulWidget {
  const ProductChip({
    super.key,
    required this.discount,
    required this.mood,
    required this.onTap,
  });

  final String discount;
  final Color mood;
  final VoidCallback onTap;

  @override
  State<ProductChip> createState() => _ProductChipState();
}

class _ProductChipState extends State<ProductChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: Motion.fast,
        curve: Motion.spring,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.mood, AppColors.gold]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.mood.withValues(alpha: .5),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_offer_rounded,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                widget.discount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
