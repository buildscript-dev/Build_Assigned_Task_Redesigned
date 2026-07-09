import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import 'widgets/post_overlays.dart';

/// Main feed. Chrome (header, tabs, bottom nav) stays put; only the media
/// area pages vertically, reels-style — per the designer note
/// "Show 3 posts. User can scroll like reels".
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
    // Figma loading sequence, then hand off to the platform's app
    // (browser website when the app isn't installed).
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Light chrome above the media area.
          ColoredBox(
            color: Colors.white,
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
                // Media pager: each page = photo + its own overlays.
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
                  ),
                ),
                // Persistent right-edge dots + bottom nav float over pages.
                Positioned(
                  right: 14,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    // Design places the dots ~40% down the media area,
                    // just above the music row.
                    alignment: const Alignment(0, -0.15),
                    child: Transform.translate(
                      offset: const Offset(0, -25),
                      child: PageDots(index: _page, total: mockPosts.length),
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
  });

  final SmartPost post;
  final int index;
  final int total;
  final void Function(SharePlatform) onShare;
  final VoidCallback onEditCaption;

  @override
  State<_PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<_PostMedia> {
  bool _showProduct = false;
  // Random pick between the two Figma card variants — sometimes the
  // trending message, sometimes the price.
  final bool _trendingCard = Random().nextBool();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Designer note: product info fades in from the bottom after 3 seconds.
    if (widget.post.product != null) {
      _timer = Timer(
        const Duration(seconds: 3),
        () => setState(() => _showProduct = true),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.post.product;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Figma anchors the visible window to the photo's bottom edge.
        Image.asset(
          widget.post.imageAsset,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
        // Header pinned to the top — independent of the bottom cluster, so
        // neither can ever force the other into a RenderFlex overflow.
        Positioned(
          left: 16,
          right: 16,
          top: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: PostHeaderRow()),
              PickCounter(index: widget.index, total: widget.total),
            ],
          ),
        ),
        // Bottom cluster sized to its own content (mainAxisSize.min) and
        // anchored to the bottom edge — it can grow upward but can never
        // overflow a fixed-height parent the way a Spacer-based Column could.
        Positioned(
          left: 16,
          right: 16,
          bottom: 92,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (product != null)
                AnimatedSlide(
                  offset: _showProduct ? Offset.zero : const Offset(0, 0.6),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _showProduct ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      // keep the card clear of the page-dot indicator
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width - 116,
                        ),
                        child: ProductCard(
                          product: product,
                          trending: _trendingCard,
                          // Whole box clickable → personal beauty store link.
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Opening your personal beauty store…',
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              MusicRow(post: widget.post),
              const SizedBox(height: 10),
              CaptionBlock(
                post: widget.post,
                index: widget.index,
                onEdit: widget.onEditCaption,
              ),
              const SizedBox(height: 14),
              QuickShareRow(onShare: widget.onShare),
            ],
          ),
        ),
      ],
    );
  }
}

