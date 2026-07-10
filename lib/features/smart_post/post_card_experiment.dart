import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../data/mock_posts.dart';
import '../../data/mock_shell.dart';
import '../../data/models.dart';
import '../../shared/frosted_panel.dart';
import '../../shared/ui_kit.dart';
import '../edit_caption/edit_caption_page.dart';
import '../share/generating_link_dialog.dart';
import '../share/share_launcher.dart';
import 'post_detail_sheet.dart';
import 'widgets/post_overlays.dart' show ProductChip;

/// Experimental alternate post-card style, requested as a side-by-side
/// trial — a standalone screen that reuses existing sheets/data but never
/// touches SmartPostScreen or its widgets, so the shipped feed is untouched.
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
      // Small-card list scrolls normally; each card can open a separate
      // full-size page that scrolls on its own (see _ExpandedPostView).
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

/// Drag-to-reposition editor for "which area of the photo should show" in
/// the card's rounded-square frame. Saves a per-post Alignment, session-local.
Future<void> _editImageFocus(
  BuildContext context,
  SmartPost post,
  int index,
  VoidCallback onSaved,
) {
  var focus = imageFocus[index] ?? Alignment.center;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final dark = Theme.of(sheetContext).brightness == Brightness.dark;
      final ink = dark ? Colors.white : AppColors.ink;
      return StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                'Choose visible area',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Drag the photo to reposition it inside the frame',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.greyText),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(Corners.lg),
                child: GestureDetector(
                  onPanUpdate: (details) => setSheetState(() {
                    focus = Alignment(
                      (focus.x - details.delta.dx / 130).clamp(-1.0, 1.0),
                      (focus.y - details.delta.dy / 130).clamp(-1.0, 1.0),
                    );
                  }),
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Image.asset(
                      post.imageAsset,
                      fit: BoxFit.cover,
                      alignment: focus,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Save',
                onTap: () {
                  imageFocus[index] = focus;
                  onSaved();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
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
            subtitle: const Text('Choose what part of the photo shows'),
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
    final ink = dark ? Colors.white : AppColors.ink;
    final post = widget.post;
    final focus = imageFocus[widget.index] ?? Alignment.center;
    final caption = editedCaptions[widget.index] ?? post.caption;
    final tag = 'exp-post-image-${widget.index}';

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
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: Motion.slow,
                  reverseTransitionDuration: Motion.slow,
                  pageBuilder: (_, _, _) => _ExpandedPostView(
                    post: post,
                    index: widget.index,
                    heroTag: tag,
                    onChanged: _refresh,
                  ),
                  transitionsBuilder: (_, anim, _, child) => SlideTransition(
                    position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(
                          CurvedAnimation(parent: anim, curve: Motion.smooth),
                        ),
                    child: child,
                  ),
                ),
              );
            },
            child: Hero(
              tag: tag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Corners.lg),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    AspectRatio(
                      aspectRatio: 0.82,
                      child: Image.asset(
                        post.imageAsset,
                        fit: BoxFit.cover,
                        alignment: focus,
                      ),
                    ),
                    if (post.product != null)
                      Positioned(
                        left: 14,
                        bottom: 14,
                        child: AnimatedSlide(
                          offset: _showAd ? Offset.zero : const Offset(0, 0.5),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          child: AnimatedOpacity(
                            opacity: _showAd ? 1 : 0,
                            duration: const Duration(milliseconds: 400),
                            child: ProductChip(
                              discount: post.product!.discount,
                              mood: post.moodA,
                              onTap: () => showPostDetailSheet(
                                context,
                                post: post,
                                index: widget.index,
                                onEditCaption: () => _editCaption(
                                  context,
                                  widget.index,
                                  _refresh,
                                ),
                                onShare: (p) =>
                                    _share(context, p, widget.index),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
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
                    const Text(
                      'High-converting',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyText,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: _toggleAd,
                child: Row(
                  children: [
                    Icon(
                      _showAd
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
                onTap: () => showPostDetailSheet(
                  context,
                  post: post,
                  index: widget.index,
                  onEditCaption: () =>
                      _editCaption(context, widget.index, _refresh),
                  onShare: (p) => _share(context, p, widget.index),
                ),
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
              _EditPillButton(
                onTap: () =>
                    _showEditMenu(context, post, widget.index, _refresh),
              ),
            ],
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

/// Full-size page a card's photo expands into — Hero-connected, its own
/// scroll view (image + full detail scrolls as one long page), with a
/// frosted blurred action bar pinned to the bottom.
class _ExpandedPostView extends StatefulWidget {
  const _ExpandedPostView({
    required this.post,
    required this.index,
    required this.heroTag,
    required this.onChanged,
  });

  final SmartPost post;
  final int index;
  final String heroTag;
  final VoidCallback onChanged;

  @override
  State<_ExpandedPostView> createState() => _ExpandedPostViewState();
}

class _ExpandedPostViewState extends State<_ExpandedPostView> {
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

  void _toggleAd() {
    if (widget.post.product == null) return;
    HapticFeedback.selectionClick();
    setState(() => _showAd = !_showAd);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final index = widget.index;
    final onChanged = widget.onChanged;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    final focus = imageFocus[index] ?? Alignment.center;
    final caption = editedCaptions[index] ?? post.caption;
    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      AspectRatio(
                        aspectRatio: 0.95,
                        child: Image.asset(
                          post.imageAsset,
                          fit: BoxFit.cover,
                          alignment: focus,
                        ),
                      ),
                      // Auto-appears after 3s (or via the bottom bar's Ads
                      // toggle) — sits just above the name row below it.
                      if (post.product != null)
                        Positioned(
                          left: 20,
                          bottom: 16,
                          child: AnimatedSlide(
                            offset: _showAd
                                ? Offset.zero
                                : const Offset(0, 0.5),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            child: AnimatedOpacity(
                              opacity: _showAd ? 1 : 0,
                              duration: const Duration(milliseconds: 400),
                              child: ProductChip(
                                discount: post.product!.discount,
                                mood: post.moodA,
                                onTap: () => showPostDetailSheet(
                                  context,
                                  post: post,
                                  index: index,
                                  onEditCaption: () =>
                                      _editCaption(context, index, onChanged),
                                  onShare: (p) => _share(context, p, index),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      consultantName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: ink,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: AppColors.brandGreen,
                                      size: 17,
                                    ),
                                  ],
                                ),
                                const Text(
                                  'High-converting',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.greyText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        caption,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.45,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.music_note_rounded,
                            color: AppColors.gold,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${post.trackTitle} · ${post.trackArtist}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.greyText,
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
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: FrostedPanel(
                radius: 24,
                color: Colors.black.withValues(alpha: 0.35),
                blur: 8,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _BarAction(
                      icon: _showAd
                          ? Icons.local_offer_rounded
                          : Icons.local_offer_outlined,
                      label: post.product?.discount ?? 'Ads',
                      onTap: _toggleAd,
                    ),
                    const Spacer(),
                    _BarAction(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: () => showPostDetailSheet(
                        context,
                        post: post,
                        index: index,
                        onEditCaption: () =>
                            _editCaption(context, index, onChanged),
                        onShare: (p) => _share(context, p, index),
                      ),
                    ),
                    const Spacer(),
                    _BarAction(
                      icon: Icons.edit_rounded,
                      label: 'Edit',
                      onTap: () =>
                          _showEditMenu(context, post, index, onChanged),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
