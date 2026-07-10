import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../data/mock_posts.dart';
import '../../data/models.dart';
import '../../shared/bottom_nav.dart';
import '../../shared/oriflame_header.dart';
import '../../shared/tab_row.dart';
import '../edit_caption/edit_caption_page.dart';
import '../share/generating_link_dialog.dart';
import '../share/share_launcher.dart';
import '../shell/camera_service.dart';
import '../shell/shell.dart';
import 'post_detail_sheet.dart';
import 'widgets/action_rail.dart';
import 'widgets/post_overlays.dart';

/// Main feed. Chrome (header, tabs, bottom nav) stays put; only the media
/// area pages vertically, reels-style — per the designer note
/// "Show 3 posts. User can scroll like reels". The photo itself stays
/// unobstructed: only a slim mini-bar touches it, full content lives in
/// the Post Details sheet.
class SmartPostScreen extends StatefulWidget {
  const SmartPostScreen({super.key});

  @override
  State<SmartPostScreen> createState() => _SmartPostScreenState();
}

class _SmartPostScreenState extends State<SmartPostScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share(SharePlatform platform) async {
    HapticFeedback.mediumImpact();
    await showGeneratingLinkDialog(context);
    await launchPlatform(platform, text: captionTextFor(_page));
  }

  Future<void> _editCaption() async {
    HapticFeedback.lightImpact();
    final page = _page;
    final edited = await showEditCaptionSheet(context, captionTextFor(page));
    if (edited != null && mounted) {
      setState(() => editedCaptions[page] = edited);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Caption saved')));
    }
  }

  void _openDetails(int index) {
    showPostDetailSheet(
      context,
      post: mockPosts[index],
      index: index,
      onEditCaption: _editCaption,
      onShare: _share,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mood = mockPosts[_page].moodA;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          ColoredBox(
            color: dark ? AppColors.darkSurface : Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  OriflameHeader(
                    onAssistantTap: () => openAssistant(context),
                    onCameraTap: () => captureToGallery(context),
                  ),
                  SmartTabRow(onTap: (i) => goTopTab(context, 0, i)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  itemCount: mockPosts.length,
                  onPageChanged: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _page = i);
                  },
                  itemBuilder: (context, i) => _PostMedia(
                    post: mockPosts[i],
                    index: i,
                    total: mockPosts.length,
                    onShare: _share,
                    onEditCaption: _editCaption,
                    onOpenDetails: () => _openDetails(i),
                  ),
                ),
                // Persistent dots — tinted to whichever post is on screen.
                Positioned(
                  right: 14,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: const Alignment(0, -0.55),
                    child: PageDots(
                      index: _page,
                      total: mockPosts.length,
                      mood: mood,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: AppBottomNav(
                      onTap: (i) => goTab(context, tabFeed, i),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostMedia extends StatefulWidget {
  const _PostMedia({
    required this.post,
    required this.index,
    required this.total,
    required this.onShare,
    required this.onEditCaption,
    required this.onOpenDetails,
  });

  final SmartPost post;
  final int index;
  final int total;
  final void Function(SharePlatform) onShare;
  final VoidCallback onEditCaption;
  final VoidCallback onOpenDetails;

  @override
  State<_PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<_PostMedia> with TickerProviderStateMixin {
  bool _showChip = false;
  bool get _liked => likedPosts.contains(widget.index);

  late final AnimationController _heartController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _heartScale = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 1.3,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 45,
    ),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 15),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 20,
    ),
  ]).animate(_heartController);

  @override
  void initState() {
    super.initState();
    if (widget.post.product != null) {
      Future.delayed(
        const Duration(seconds: 3),
        () => mounted ? setState(() => _showChip = true) : null,
      );
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _like({bool fromDoubleTap = false}) {
    setState(() {
      if (fromDoubleTap) {
        likedPosts.add(widget.index);
      } else {
        if (_liked) {
          likedPosts.remove(widget.index);
        } else {
          likedPosts.add(widget.index);
        }
      }
    });
    if (_liked) {
      _heartController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.post.product;
    final mood = widget.post.moodA;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: () {
        HapticFeedback.mediumImpact();
        _like(fromDoubleTap: true);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.post.imageAsset,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
          // Double-tap heart burst — the "fall in love with the app" beat.
          IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                animation: _heartScale,
                builder: (context, child) => Opacity(
                  opacity: _heartScale.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _heartScale.value < 0
                        ? 0
                        : (_heartScale.value > 1.3 ? 1.3 : _heartScale.value),
                    child: child,
                  ),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 110,
                  shadows: [
                    Shadow(color: mood.withValues(alpha: .8), blurRadius: 40),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: PostHeaderRow(mood: mood)),
                PickCounter(index: widget.index, total: widget.total),
              ],
            ),
          ),
          // Floating action rail — right edge, clear of the header dots.
          Positioned(
            right: 18,
            bottom: 172,
            child: ActionRail(
              mood: mood,
              liked: _liked,
              onLike: _like,
              onComment: () => openAssistant(context),
              onShare: widget.onOpenDetails,
            ),
          ),
          // Only a slim strip + tiny product chip touch the photo now.
          Positioned(
            left: 16,
            right: 16,
            bottom: 92,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product != null)
                  AnimatedSlide(
                    offset: _showChip ? Offset.zero : const Offset(0, 0.5),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: _showChip ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ProductChip(
                          discount: product.discount,
                          mood: mood,
                          onTap: widget.onOpenDetails,
                        ),
                      ),
                    ),
                  ),
                PostMiniBar(
                  caption: editedCaptions[widget.index] ?? widget.post.caption,
                  trackTitle: widget.post.trackTitle,
                  mood: mood,
                  onTap: widget.onOpenDetails,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
