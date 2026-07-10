import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../data/mock_posts.dart';
import '../../data/mock_shell.dart';
import '../../data/models.dart';
import '../../shared/ui_kit.dart';
import '../edit_caption/edit_caption_page.dart';
import '../share/generating_link_dialog.dart';
import '../share/share_launcher.dart';
import 'post_detail_sheet.dart';

/// Profile-card post style, now also the live Smart Post feed's card
/// design. This screen (reachable from Profile) is a standalone list for
/// trying the style; SmartPostScreen renders the same ExperimentPostCard.
class PostCardExperimentScreen extends StatelessWidget {
  const PostCardExperimentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? AppColors.darkBg : AppColors.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('New Post Card (Experiment)'),
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: mockPosts.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: ExperimentPostCard(post: mockPosts[i], index: i),
        ),
      ),
    );
  }
}

Future<void> _share(
  BuildContext context,
  SharePlatform platform,
  int index,
) async {
  HapticFeedback.mediumImpact();
  await showGeneratingLinkDialog(context);
  await launchPlatform(platform, text: captionTextFor(index));
}

Future<void> _editCaption(
  BuildContext context,
  int index,
  VoidCallback onSaved,
) async {
  HapticFeedback.lightImpact();
  final edited = await showEditCaptionSheet(context, captionTextFor(index));
  if (edited != null) {
    editedCaptions[index] = edited;
    onSaved();
  }
}

/// Focused share sheet — just the platform list, no caption/music/product
/// clutter. This is what both the small and full-size card's Share action
/// open now (Post Details is reachable separately via the Edit menu).
void _showShareSheet(BuildContext context, int index) {
  HapticFeedback.selectionClick();
  final dark = Theme.of(context).brightness == Brightness.dark;
  final ink = dark ? Colors.white : AppColors.ink;
  showModalBottomSheet(
    context: context,
    backgroundColor: dark ? AppColors.darkCard : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.greyMuted,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share to',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 22,
              runSpacing: 18,
              children: [
                for (final p in sharePlatforms)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _share(context, p, index);
                    },
                    child: SizedBox(
                      width: 64,
                      child: Column(
                        children: [
                          Image.asset(
                            p.iconAsset,
                            width: 46,
                            height: 46,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: ink),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Drag-to-reposition + pinch-to-zoom editor for "which part of the photo
/// should show" — live-previews the result at both the small-card and
/// full-size-card aspect ratios so there's no guessing before Save.
Future<void> _editImageFocus(
  BuildContext context,
  SmartPost post,
  int index,
  VoidCallback onSaved,
) {
  var focus = imageFocus[index] ?? Alignment.center;
  var zoom = imageZoom[index] ?? 1.0;
  var baseZoom = zoom;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    // The crop frame owns drag/pinch itself — a draggable sheet would
    // otherwise compete with (and sometimes steal) that gesture.
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final dark = Theme.of(sheetContext).brightness == Brightness.dark;
      final ink = dark ? Colors.white : AppColors.ink;
      return StatefulBuilder(
        builder: (context, setSheetState) {
          Widget preview(double aspect, double width, String label) {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.sm),
                  child: SizedBox(
                    width: width,
                    height: width / aspect,
                    child: Transform.scale(
                      scale: zoom,
                      child: Image.asset(
                        post.imageAsset,
                        fit: BoxFit.cover,
                        alignment: focus,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            );
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: dark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.greyMuted,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Crop & position',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Drag to reposition, pinch to zoom',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: AppColors.greyText),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.lg),
                  child: GestureDetector(
                    onScaleStart: (_) => baseZoom = zoom,
                    onScaleUpdate: (details) => setSheetState(() {
                      zoom = (baseZoom * details.scale).clamp(1.0, 3.0);
                      focus = Alignment(
                        (focus.x - details.focalPointDelta.dx / 130).clamp(
                          -1.0,
                          1.0,
                        ),
                        (focus.y - details.focalPointDelta.dy / 130).clamp(
                          -1.0,
                          1.0,
                        ),
                      );
                    }),
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Transform.scale(
                        scale: zoom,
                        child: Image.asset(
                          post.imageAsset,
                          fit: BoxFit.cover,
                          alignment: focus,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    preview(0.82, 74, 'Small card'),
                    const SizedBox(width: 24),
                    preview(1.05, 100, 'Full size'),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Save',
                  onTap: () {
                    imageFocus[index] = focus;
                    imageZoom[index] = zoom;
                    onSaved();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showEditMenu(
  BuildContext context,
  SmartPost post,
  int index,
  VoidCallback onChanged,
) {
  HapticFeedback.selectionClick();
  final dark = Theme.of(context).brightness == Brightness.dark;
  final ink = dark ? Colors.white : AppColors.ink;
  showModalBottomSheet(
    context: context,
    backgroundColor: dark ? AppColors.darkCard : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.greyMuted,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.auto_fix_high_rounded,
              color: AppColors.brandGreen,
            ),
            title: Text('Edit caption', style: TextStyle(color: ink)),
            subtitle: const Text('Opens in a slide sheet'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              _editCaption(context, index, onChanged);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.crop_rounded,
              color: AppColors.brandGreen,
            ),
            title: Text('Edit image area', style: TextStyle(color: ink)),
            subtitle: const Text('Crop, zoom, and preview both card sizes'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              _editImageFocus(context, post, index, onChanged);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.visibility_rounded,
              color: AppColors.brandGreen,
            ),
            title: Text('Preview full post', style: TextStyle(color: ink)),
            subtitle: const Text('Caption, music, product, quick share'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              showPostDetailSheet(
                context,
                post: post,
                index: index,
                onEditCaption: () => _editCaption(context, index, onChanged),
                onShare: (p) => _share(context, p, index),
              );
            },
          ),
        ],
      ),
    ),
  );
}

void _openExpanded(BuildContext context, int index) {
  HapticFeedback.lightImpact();
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Motion.slow,
      reverseTransitionDuration: Motion.slow,
      pageBuilder: (_, _, _) => _ExpandedPostView(initialIndex: index),
      transitionsBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Motion.smooth)),
        child: child,
      ),
    ),
  );
}

/// Rounded-corner photo with the ad chip floating above the caption area —
/// shared by both the small card and the full-size page so a crop/zoom
/// edit looks identical in both places.
class _PostImage extends StatelessWidget {
  const _PostImage({
    required this.post,
    required this.index,
    required this.aspectRatio,
    required this.showAd,
  });

  final SmartPost post;
  final int index;
  final double aspectRatio;
  final bool showAd;

  @override
  Widget build(BuildContext context) {
    final focus = imageFocus[index] ?? Alignment.center;
    final zoom = imageZoom[index] ?? 1.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Corners.lg),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Transform.scale(
              scale: zoom,
              child: Image.asset(
                post.imageAsset,
                fit: BoxFit.cover,
                alignment: focus,
              ),
            ),
          ),
          if (post.product != null)
            Positioned(
              left: 14,
              bottom: 14,
              child: AnimatedSlide(
                offset: showAd ? Offset.zero : const Offset(0, 0.5),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: showAd ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: _AdChip(
                    product: post.product!,
                    mood: post.moodA,
                    onTap: () => showPostDetailSheet(
                      context,
                      post: post,
                      index: index,
                      onEditCaption: () => _editCaption(context, index, () {}),
                      onShare: (p) => _share(context, p, index),
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

/// Product thumbnail + price ad reveal — replaces a plain "30% off" text
/// chip with the actual product image and price, per feedback.
class _AdChip extends StatefulWidget {
  const _AdChip({
    required this.product,
    required this.mood,
    required this.onTap,
  });

  final Product product;
  final Color mood;
  final VoidCallback onTap;

  @override
  State<_AdChip> createState() => _AdChipState();
}

class _AdChipState extends State<_AdChip> {
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
        scale: _pressed ? 0.94 : 1.0,
        duration: Motion.fast,
        curve: Motion.spring,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.mood, AppColors.gold]),
            borderRadius: BorderRadius.circular(16),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.white,
                  width: 34,
                  height: 34,
                  child: Image.asset(
                    widget.product.thumbAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product.price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      widget.product.discount,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Name/caption/track + the plain (un-boxed) Ads/Share/Edit row — shared by
/// the small card and the full-size page so both read as the same design.
class _PostInfoBody extends StatelessWidget {
  const _PostInfoBody({
    required this.post,
    required this.index,
    required this.caption,
    required this.captionMaxLines,
    required this.showAd,
    required this.onToggleAd,
    required this.onEdit,
  });

  final SmartPost post;
  final int index;
  final String caption;
  final int? captionMaxLines;
  final bool showAd;
  final VoidCallback onToggleAd;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    const subtle = AppColors.greyText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        consultantName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.brandGreen,
                        size: 16,
                      ),
                    ],
                  ),
                  Text(
                    'High-converting',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          caption,
          maxLines: captionMaxLines,
          overflow: captionMaxLines == null ? null : TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13.5, height: 1.35, color: ink),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.music_note_rounded,
              color: AppColors.gold,
              size: 15,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '${post.trackTitle} · ${post.trackArtist}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subtle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: onToggleAd,
              child: Row(
                children: [
                  Icon(
                    showAd
                        ? Icons.local_offer_rounded
                        : Icons.local_offer_outlined,
                    size: 17,
                    color: ink.withValues(alpha: .7),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    post.product?.discount ?? 'Ads',
                    style: TextStyle(fontWeight: FontWeight.w700, color: ink),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            GestureDetector(
              onTap: () => _showShareSheet(context, index),
              child: Row(
                children: [
                  Icon(
                    Icons.share_rounded,
                    size: 17,
                    color: ink.withValues(alpha: .7),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Share',
                    style: TextStyle(fontWeight: FontWeight.w700, color: ink),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _EditPillButton(onTap: onEdit),
          ],
        ),
      ],
    );
  }
}

class ExperimentPostCard extends StatefulWidget {
  const ExperimentPostCard({
    super.key,
    required this.post,
    required this.index,
  });

  final SmartPost post;
  final int index;

  @override
  State<ExperimentPostCard> createState() => _ExperimentPostCardState();
}

class _ExperimentPostCardState extends State<ExperimentPostCard> {
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    if (widget.post.product != null) {
      Future.delayed(
        const Duration(seconds: 3),
        () => mounted ? setState(() => _showAd = true) : null,
      );
    }
  }

  void _refresh() => setState(() {});

  void _toggleAd() {
    if (widget.post.product == null) return;
    HapticFeedback.selectionClick();
    setState(() => _showAd = !_showAd);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final post = widget.post;
    final caption = editedCaptions[widget.index] ?? post.caption;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(Corners.lg),
        boxShadow: [
          const BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openExpanded(context, widget.index),
            child: _PostImage(
              post: post,
              index: widget.index,
              aspectRatio: 0.82,
              showAd: _showAd,
            ),
          ),
          const SizedBox(height: 14),
          _PostInfoBody(
            post: post,
            index: widget.index,
            caption: caption,
            captionMaxLines: 2,
            showAd: _showAd,
            onToggleAd: _toggleAd,
            onEdit: () => _showEditMenu(context, post, widget.index, _refresh),
          ),
        ],
      ),
    );
  }
}

class _EditPillButton extends StatefulWidget {
  const _EditPillButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_EditPillButton> createState() => _EditPillButtonState();
}

class _EditPillButtonState extends State<_EditPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: Motion.fast,
        curve: Motion.spring,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkSurface : AppColors.trackGrey,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w700, color: ink),
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit_rounded, size: 15, color: ink),
            ],
          ),
        ),
      ),
    );
  }
}

/// Swipeable full-size view across every post — reel-style paging with a
/// haptic + scale/fade transition per page, instead of a static single-post
/// screen. Each page keeps the small card's exact look, just bigger.
class _ExpandedPostView extends StatefulWidget {
  const _ExpandedPostView({required this.initialIndex});

  final int initialIndex;

  @override
  State<_ExpandedPostView> createState() => _ExpandedPostViewState();
}

class _ExpandedPostViewState extends State<_ExpandedPostView> {
  late final _controller = PageController(initialPage: widget.initialIndex);
  late int _page = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.surface,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: mockPosts.length,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _page = i);
            },
            itemBuilder: (context, i) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final hasPage =
                    _controller.hasClients &&
                    _controller.position.haveDimensions;
                final delta =
                    ((hasPage ? _controller.page! : _page.toDouble()) - i)
                        .clamp(-1.0, 1.0)
                        .abs();
                return Opacity(
                  opacity: 1 - (delta * 0.35),
                  child: Transform.scale(
                    scale: 1 - (delta * 0.05),
                    child: child,
                  ),
                );
              },
              child: _ExpandedPostPage(post: mockPosts[i], index: i),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: SafeArea(
              bottom: false,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
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

class _ExpandedPostPage extends StatefulWidget {
  const _ExpandedPostPage({required this.post, required this.index});

  final SmartPost post;
  final int index;

  @override
  State<_ExpandedPostPage> createState() => _ExpandedPostPageState();
}

class _ExpandedPostPageState extends State<_ExpandedPostPage> {
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    if (widget.post.product != null) {
      Future.delayed(
        const Duration(seconds: 3),
        () => mounted ? setState(() => _showAd = true) : null,
      );
    }
  }

  void _refresh() => setState(() {});

  void _toggleAd() {
    if (widget.post.product == null) return;
    HapticFeedback.selectionClick();
    setState(() => _showAd = !_showAd);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final post = widget.post;
    final caption = editedCaptions[widget.index] ?? post.caption;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 70, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-size, undiminished — the ad chip is a small overlay, not a
          // caption panel eating into the photo.
          _PostImage(
            post: post,
            index: widget.index,
            aspectRatio: 1.05,
            showAd: _showAd,
          ),
          const SizedBox(height: 14),
          // Same soft brand gradient wash as the Communities earn cards —
          // one shared "glass" look across the app instead of a flat panel.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brandGreen.withValues(alpha: dark ? .22 : .14),
                  AppColors.gold.withValues(alpha: dark ? .16 : .10),
                ],
              ),
              borderRadius: BorderRadius.circular(Corners.lg),
              border: Border.all(
                color: AppColors.brandGreen.withValues(alpha: .14),
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: _PostInfoBody(
              post: post,
              index: widget.index,
              caption: caption,
              captionMaxLines: null,
              showAd: _showAd,
              onToggleAd: _toggleAd,
              onEdit: () =>
                  _showEditMenu(context, post, widget.index, _refresh),
            ),
          ),
        ],
      ),
    );
  }
}
