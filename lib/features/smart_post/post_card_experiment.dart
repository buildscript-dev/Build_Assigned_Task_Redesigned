import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final tile = dark ? Colors.white.withValues(alpha: .08) : AppColors.trackGrey;
  showModalBottomSheet(
    context: context,
    backgroundColor: dark ? AppColors.darkCard : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => SafeArea(
        // Scrolls if the grid + link row exceed the sheet's max height on
        // short screens — prevents bottom overflow.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'Share to',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 8,
                childAspectRatio: 0.78,
                children: [
                  for (final p in sharePlatforms)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _share(context, p, index);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: tile,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              p.iconAsset,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.15,
                              fontWeight: FontWeight.w600,
                              color: ink.withValues(alpha: .85),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Referral link with one-tap copy — the share flow's whole point.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: tile,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 18,
                      color: AppColors.greyText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        referralLink,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.greyText,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Clipboard.setData(
                          const ClipboardData(text: referralLink),
                        );
                        setSheetState(() => _linkCopied = true);
                      },
                      child: Text(
                        _linkCopied ? 'Copied ✓' : 'Copy',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ).whenComplete(() => _linkCopied = false);
}

/// Session flag for the share sheet's "Copied ✓" feedback.
bool _linkCopied = false;

/// Ad details sheet — what the ad is about, benefits, price, and a buy
/// link. Product only: no music, no caption (that's the post's sheet).
void _showProductSheet(BuildContext context, Product product) {
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
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.sm),
                  child: Container(
                    color: Colors.white,
                    width: 72,
                    height: 72,
                    child: Image.asset(product.thumbAsset, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            product.price,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandGreen.withValues(
                                alpha: .15,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              product.discount,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product.about.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                product.about,
                style: TextStyle(fontSize: 13.5, height: 1.4, color: ink),
              ),
            ],
            if (product.benefits.isNotEmpty) ...[
              const SizedBox(height: 14),
              for (final b in product.benefits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 17,
                        color: AppColors.brandGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b,
                          style: TextStyle(fontSize: 13, color: ink),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 14),
            _BuyNowButton(
              label: 'Buy now · ${product.price}',
              onTap: () {
                Navigator.of(sheetContext).pop();
                if (product.buyUrl.isNotEmpty) {
                  launchUrl(
                    Uri.parse(product.buyUrl),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Buy Now CTA — pale-wash style, distinct from the shared [AppButton]'s
/// bold solid-gradient fill used elsewhere (Share, Join, Send, etc.).
class _BuyNowButton extends StatefulWidget {
  const _BuyNowButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_BuyNowButton> createState() => _BuyNowButtonState();
}

class _BuyNowButtonState extends State<_BuyNowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: Motion.fast,
        curve: Motion.spring,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.brandGreen.withValues(alpha: .18),
                AppColors.gold.withValues(alpha: .18),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.brandGreen.withValues(alpha: .25),
            ),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: AppColors.brandGreen,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Drag-to-reposition + pinch-to-zoom editor, per card size: pick "Small
/// card" or "Full size", each keeps its own crop. The crop frame matches the
/// real card's aspect and renders through the same _FocusZoomImage as the
/// cards themselves, so what you see here is exactly what ships.
Future<void> _editImageFocus(
  BuildContext context,
  SmartPost post,
  int index,
  VoidCallback onSaved,
) {
  var full = false;
  final focus = {
    false: imageFocus[cropKey(index, false)] ?? Alignment.center,
    true: imageFocus[cropKey(index, true)] ?? Alignment.center,
  };
  final zoom = {
    false: imageZoom[cropKey(index, false)] ?? 1.0,
    true: imageZoom[cropKey(index, true)] ?? 1.0,
  };
  var baseZoom = 1.0;
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
          Widget preview(double aspect, double width, String label, bool f) {
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Corners.sm),
                    border: Border.all(
                      width: 2,
                      color: f == full
                          ? AppColors.brandGreen
                          : Colors.transparent,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Corners.sm),
                    child: SizedBox(
                      width: width,
                      height: width / aspect,
                      child: _FocusZoomImage(
                        asset: post.imageAsset,
                        focus: focus[f]!,
                        zoom: zoom[f]!,
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

          // Crop frame mirrors the real card's shape.
          final aspect = full ? 0.56 : 0.82;
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
                  'Pick a card size, then drag to reposition and pinch to zoom',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: AppColors.greyText),
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Small card')),
                    ButtonSegment(value: true, label: Text('Full size')),
                  ],
                  selected: {full},
                  onSelectionChanged: (s) =>
                      setSheetState(() => full = s.first),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.lg),
                  child: GestureDetector(
                    onScaleStart: (_) => baseZoom = zoom[full]!,
                    onScaleUpdate: (details) => setSheetState(() {
                      zoom[full] = (baseZoom * details.scale).clamp(1.0, 3.0);
                      focus[full] = Alignment(
                        (focus[full]!.x - details.focalPointDelta.dx / 100)
                            .clamp(-1.0, 1.0),
                        (focus[full]!.y - details.focalPointDelta.dy / 100)
                            .clamp(-1.0, 1.0),
                      );
                    }),
                    child: SizedBox(
                      width: 300 * aspect,
                      height: 300,
                      child: _FocusZoomImage(
                        asset: post.imageAsset,
                        focus: focus[full]!,
                        zoom: zoom[full]!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    preview(0.82, 74, 'Small card', false),
                    const SizedBox(width: 24),
                    preview(0.56, 62, 'Full size', true),
                  ],
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: 'Save',
                  onTap: () {
                    imageFocus[cropKey(index, false)] = focus[false]!;
                    imageZoom[cropKey(index, false)] = zoom[false]!;
                    imageFocus[cropKey(index, true)] = focus[true]!;
                    imageZoom[cropKey(index, true)] = zoom[true]!;
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
      // Fade, not slide: the Hero flies the photo small→full in place, so
      // the image never visibly changes position.
      pageBuilder: (_, _, _) => _ExpandedPostView(initialIndex: index),
      transitionsBuilder: (_, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Motion.smooth),
        child: child,
      ),
    ),
  );
}

/// Rounded-corner photo with the ad chip floating above the caption area —
/// shared by both the small card and the full-size page so a crop/zoom
/// edit looks identical in both places.
/// Renders the photo under a (focus, zoom) crop: zoom enlarges the image
/// inside a clipped box, focus (-1..1 on both axes) pans which part shows.
/// Shared by the cards and the crop editor so the edit is exactly what
/// renders everywhere.
class _FocusZoomImage extends StatelessWidget {
  const _FocusZoomImage({
    required this.asset,
    required this.focus,
    required this.zoom,
  });

  final String asset;
  final Alignment focus;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => ClipRect(
        child: OverflowBox(
          minWidth: c.maxWidth * zoom,
          maxWidth: c.maxWidth * zoom,
          minHeight: c.maxHeight * zoom,
          maxHeight: c.maxHeight * zoom,
          alignment: focus,
          child: Image.asset(asset, fit: BoxFit.cover, alignment: focus),
        ),
      ),
    );
  }
}

class _PostImage extends StatelessWidget {
  const _PostImage({
    required this.post,
    required this.index,
    required this.aspectRatio,
    required this.showAd,
    this.full = false,
  });

  final SmartPost post;
  final int index;

  /// Null = fill whatever height the parent gives (feed cards sized to the
  /// viewport); non-null = fixed aspect (experiment list, expanded view).
  final double? aspectRatio;
  final bool showAd;

  /// Which saved crop to render: the small card's or the full-size view's.
  final bool full;

  @override
  Widget build(BuildContext context) {
    final focus = imageFocus[cropKey(index, full)] ?? Alignment.center;
    final zoom = imageZoom[cropKey(index, full)] ?? 1.0;
    final image = _FocusZoomImage(
      asset: post.imageAsset,
      focus: focus,
      zoom: zoom,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(Corners.lg),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (aspectRatio == null)
            SizedBox.expand(child: image)
          else
            AspectRatio(aspectRatio: aspectRatio!, child: image),
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
                    onTap: () => _showProductSheet(context, post.product!),
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
    required this.onShowMore,
    required this.onEdit,
    this.pinActions = false,
  });

  final SmartPost post;
  final int index;
  final String caption;
  final int? captionMaxLines;
  final VoidCallback onShowMore;
  final VoidCallback onEdit;

  /// True inside a fixed-height panel: the action row pins to the bottom so
  /// it sits at the same spot regardless of caption length.
  final bool pinActions;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    const subtle = AppColors.greyText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: pinActions ? MainAxisSize.max : MainAxisSize.min,
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
        if (pinActions) const Spacer() else const SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: onShowMore,
              child: Row(
                children: [
                  Icon(
                    Icons.expand_more_rounded,
                    size: 19,
                    color: ink.withValues(alpha: .7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Show more',
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
    this.fillHeight = false,
  });

  final SmartPost post;
  final int index;

  /// True when the parent gives the card a fixed height (feed): the image
  /// flexes to fill leftover space instead of forcing a 0.82 aspect ratio.
  final bool fillHeight;

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
          if (widget.fillHeight)
            Expanded(
              child: GestureDetector(
                onTap: () => _openExpanded(context, widget.index),
                child: Hero(
                  tag: 'post-image-${widget.index}',
                  child: _PostImage(
                    post: post,
                    index: widget.index,
                    aspectRatio: null,
                    showAd: _showAd,
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _openExpanded(context, widget.index),
              child: Hero(
                tag: 'post-image-${widget.index}',
                child: _PostImage(
                  post: post,
                  index: widget.index,
                  aspectRatio: 0.82,
                  showAd: _showAd,
                ),
              ),
            ),
          const SizedBox(height: 14),
          _PostInfoBody(
            post: post,
            index: widget.index,
            caption: caption,
            captionMaxLines: 2,
            onShowMore: () => showPostDetailSheet(
              context,
              post: post,
              index: widget.index,
              onEditCaption: () =>
                  _editCaption(context, widget.index, _refresh),
            ),
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

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final caption = editedCaptions[widget.index] ?? post.caption;
    // One full-screen card: photo fills it, info sits directly on the photo
    // over a bottom fade so the background stays visible behind the text.
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Corners.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'post-image-${widget.index}',
              child: _PostImage(
                post: post,
                index: widget.index,
                aspectRatio: null,
                showAd: false,
                full: true,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                if (post.product != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 14, bottom: 14),
                    child: AnimatedSlide(
                      offset: _showAd ? Offset.zero : const Offset(0, 0.5),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        opacity: _showAd ? 1 : 0,
                        duration: const Duration(milliseconds: 400),
                        child: _AdChip(
                          product: post.product!,
                          mood: post.moodA,
                          onTap: () =>
                              _showProductSheet(context, post.product!),
                        ),
                      ),
                    ),
                  ),
                // Fixed height + capped caption: avatar and action row sit
                // at the same spot on every page instead of drifting with
                // caption length.
                Container(
                  width: double.infinity,
                  height: 260,
                  padding: const EdgeInsets.fromLTRB(18, 26, 18, 16),
                  decoration: const BoxDecoration(
                    // No panel — just a fade so text reads on any photo.
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black38,
                        Colors.black54,
                      ],
                    ),
                  ),
                  // Force light ink: text sits on the photo now.
                  child: Theme(
                    data: ThemeData(brightness: Brightness.dark),
                    child: _PostInfoBody(
                      post: post,
                      index: widget.index,
                      caption: caption,
                      captionMaxLines: 4,
                      pinActions: true,
                      onShowMore: () => showPostDetailSheet(
                        context,
                        post: post,
                        index: widget.index,
                        onEditCaption: () =>
                            _editCaption(context, widget.index, _refresh),
                      ),
                      onEdit: () =>
                          _showEditMenu(context, post, widget.index, _refresh),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
