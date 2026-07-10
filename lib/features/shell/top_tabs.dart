import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../data/mock_posts.dart';
import '../../data/mock_shell.dart';
import '../../shared/ui_kit.dart';
import 'shell.dart';

/// Library: the consultant's saved posts and assets.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.ink;
    return ShellScaffold(
      index: -1,
      topTabIndex: 1,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const SectionHeading(
            'Your Library',
            subtitle: 'Saved posts, ready to reshare anytime',
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.76,
            ),
            itemCount: mockPosts.length,
            itemBuilder: (context, i) {
              final p = mockPosts[i];
              return Reveal(
                index: i,
                child: SoftCard(
                  padding: const EdgeInsets.all(8),
                  onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Corners.sm),
                          child: Image.asset(
                            p.imageAsset,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                            ),
                            Text(
                              '♫ ${p.trackTitle}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Communities: joinable groups (local state only).
class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final _communities = [
    ('Oriflame Community', '2.4k members', true),
    ('Lipstick Lovers', '860 members', false),
    ('Fragrance Fans', '1.1k members', false),
    ('Lash & Brow Club', '540 members', false),
    ('Nordic Beauty Tips', '310 members', false),
  ];

  final _earnCards = const [
    (
      'The more you share, the more your community earns',
      '86',
      '\$312',
      'Earned via communities',
    ),
    (
      'Your reach is growing across every community',
      '2.4k',
      '148',
      'Link clicks via communities',
    ),
    (
      'Keep sharing to protect your weekly streak',
      '5',
      '3 of 5',
      'Shared this week',
    ),
  ];

  late final _earnController = PageController();
  int _earnPage = 0;
  bool _topStarred = true;

  final _stackKey = GlobalKey();
  late final _pageScroll = ScrollController()..addListener(_onPageScroll);
  double _stackReveal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onPageScroll());
  }

  void _onPageScroll() {
    final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final topY = box.localToGlobal(Offset.zero).dy;
    const revealDistance = 180.0;
    final referenceY = screenHeight * 0.78;
    final next = ((referenceY - topY) / revealDistance).clamp(0.0, 1.0);
    if ((next - _stackReveal).abs() > 0.002) {
      setState(() => _stackReveal = next);
    }
  }

  @override
  void dispose() {
    _earnController.dispose();
    _pageScroll.dispose();
    super.dispose();
  }

  void _showPulseDetails() {
    HapticFeedback.selectionClick();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
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
              'Community Pulse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '128 interactions across your communities this week — 24 new '
              'replies to your posts and 3 new members joined groups you '
              'lead. Keep sharing to stay ahead of the pack.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    return ShellScaffold(
      index: -1,
      topTabIndex: 2,
      body: ListView(
        controller: _pageScroll,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const SectionHeading('Communities'),
          const SizedBox(height: 16),
          SizedBox(
            height: 232,
            child: PageView.builder(
              controller: _earnController,
              itemCount: _earnCards.length,
              onPageChanged: (i) {
                HapticFeedback.selectionClick();
                setState(() => _earnPage = i);
              },
              itemBuilder: (context, i) {
                final (headline, big, earned, earnedLabel) = _earnCards[i];
                return AnimatedBuilder(
                  animation: _earnController,
                  builder: (context, child) {
                    final hasPage =
                        _earnController.hasClients &&
                        _earnController.position.haveDimensions;
                    var delta =
                        (hasPage
                            ? _earnController.page!
                            : _earnPage.toDouble()) -
                        i;
                    delta = delta.clamp(-1.0, 1.0).abs();
                    return Transform.scale(
                      scale: 1 - (delta * 0.06),
                      child: Opacity(opacity: 1 - (delta * 0.4), child: child),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _EarnCard(
                      headline: headline,
                      big: big,
                      earned: earned,
                      earnedLabel: earnedLabel,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _earnCards.length; i++)
                AnimatedContainer(
                  duration: Motion.base,
                  curve: Motion.smooth,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _earnPage ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _earnPage
                        ? AppColors.brandGreen
                        : AppColors.greyMuted,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            'Community Pulse',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 10),
          SoftCard(
            onTap: _showPulseDetails,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "This week's activity",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '128',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'interactions',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.greyText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const _MiniSparkline(),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      '24 new replies',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyText,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.greyMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _topStarred = !_topStarred);
            },
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "You're in the top 10% of sharers in Oriflame Community",
                    style: TextStyle(fontSize: 13, color: ink),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedScale(
                  scale: _topStarred ? 1.0 : 0.85,
                  duration: Motion.fast,
                  curve: Motion.spring,
                  child: Icon(
                    _topStarred
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _ChallengeTeaserCard(),
          const SizedBox(height: 26),
          const KickerLabel('Join more communities'),
          const SizedBox(height: 12),
          KeyedSubtree(
            key: _stackKey,
            child: _CommunityStack(
              items: _communities,
              reveal: _stackReveal,
              onToggleJoin: (i) => setState(
                () => _communities[i] = (
                  _communities[i].$1,
                  _communities[i].$2,
                  !_communities[i].$3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Share&Win: weekly sharing challenge with a leaderboard.
class ShareWinScreen extends StatelessWidget {
  const ShareWinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    const shared = 3, goal = 5;
    final leaderboard = [
      ('Priya S.', 7),
      ('$consultantName (you)', shared),
      ('Maria K.', 2),
    ];
    return ShellScaffold(
      index: -1,
      topTabIndex: 3,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const SectionHeading('Share & Win 🏆'),
          const SizedBox(height: 18),
          // Same soft gradient wash as the Communities earn cards — one
          // shared "glass" look for every earn/reward surface in the app.
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEEKLY CHALLENGE',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.brandGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Share $goal Smart Posts, win a Giordani Gold set',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: shared / goal,
                    minHeight: 10,
                    backgroundColor: AppColors.trackGrey,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$shared of $goal shared — ${goal - shared} to go!',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const KickerLabel('Leaderboard'),
          const SizedBox(height: 10),
          for (var i = 0; i < leaderboard.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Reveal(
                index: i,
                child: SoftCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: i == 0 ? AppColors.goldGradient : null,
                          color: i == 0 ? null : AppColors.trackGrey,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: i == 0 ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          leaderboard[i].$1,
                          style: TextStyle(
                            color: ink,
                            fontWeight: leaderboard[i].$1.contains('(you)')
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${leaderboard[i].$2} shares',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greyText,
                        ),
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

/// One page of the Communities "earn" carousel — soft gradient card, big
/// headline number, an earned-via-communities row, and an explore button
/// that simulates a request round-trip locally (no backend).
class _EarnCard extends StatelessWidget {
  const _EarnCard({
    required this.headline,
    required this.big,
    required this.earned,
    required this.earnedLabel,
  });

  final String headline;
  final String big;
  final String earned;
  final String earnedLabel;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
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
        border: Border.all(color: AppColors.brandGreen.withValues(alpha: .14)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  headline,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: ink,
                  ),
                ),
              ),
              Text(
                big,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: ink.withValues(alpha: .18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                earned,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  earnedLabel,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.greyText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _ExploreButton(),
        ],
      ),
    );
  }
}

/// "Explore the community" — tap simulates a local request round-trip
/// (loading → sent) instead of doing nothing. No network, no navigation.
class _ExploreButton extends StatefulWidget {
  const _ExploreButton();

  @override
  State<_ExploreButton> createState() => _ExploreButtonState();
}

enum _ExploreState { idle, loading, sent }

class _ExploreButtonState extends State<_ExploreButton> {
  _ExploreState _state = _ExploreState.idle;

  Future<void> _tap() async {
    if (_state != _ExploreState.idle) return;
    HapticFeedback.mediumImpact();
    setState(() => _state = _ExploreState.loading);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() => _state = _ExploreState.sent);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _state = _ExploreState.idle);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _tap,
      child: AnimatedContainer(
        duration: Motion.base,
        curve: Motion.smooth,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: dark ? Colors.white : AppColors.ink,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: Motion.fast,
          child: switch (_state) {
            _ExploreState.idle => Text(
              'Explore the community',
              key: const ValueKey('idle'),
              style: TextStyle(
                color: dark ? AppColors.ink : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            _ExploreState.loading => SizedBox(
              key: const ValueKey('loading'),
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: dark ? AppColors.ink : Colors.white,
              ),
            ),
            _ExploreState.sent => Row(
              key: const ValueKey('sent'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: dark ? AppColors.ink : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Request sent',
                  style: TextStyle(
                    color: dark ? AppColors.ink : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}

/// Decorative 7-bar sparkline — no chart dependency, just sized bars.
class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline();

  static const _heights = [8.0, 14.0, 10.0, 18.0, 13.0, 22.0, 17.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _heights.length; i++)
          Container(
            width: 4,
            height: _heights[i],
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: i == _heights.length - 1
                  ? AppColors.brandGreen
                  : AppColors.trackGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

/// Weekly-challenge teaser — a nudge toward Share&Win without navigating
/// there; tap just gives a satisfying haptic + scale-pulse acknowledgment.
class _ChallengeTeaserCard extends StatefulWidget {
  const _ChallengeTeaserCard();

  @override
  State<_ChallengeTeaserCard> createState() => _ChallengeTeaserCardState();
}

class _ChallengeTeaserCardState extends State<_ChallengeTeaserCard> {
  bool _pulsed = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        setState(() => _pulsed = true);
        await Future.delayed(Motion.base);
        if (mounted) setState(() => _pulsed = false);
      },
      child: AnimatedScale(
        scale: _pulsed ? 1.02 : 1.0,
        duration: Motion.fast,
        curve: Motion.spring,
        child: SoftCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🏆', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '3 of 5 shared — keep going for the Giordani Gold set',
                  style: TextStyle(fontSize: 13, color: ink),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.greyMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Apple-notification-style peek stack, driven entirely by [reveal] (0..1)
/// which the parent computes from how far this widget has scrolled up into
/// view — not a tap. At reveal 0 the front card is full-size with the next
/// two items peeking as thin slivers behind it; scrolling up smoothly grows
/// each row into place (front-most first), scrolling back down reverses it.
class _CommunityStack extends StatelessWidget {
  const _CommunityStack({
    required this.items,
    required this.reveal,
    required this.onToggleJoin,
  });

  final List<(String, String, bool)> items;
  final double reveal;
  final void Function(int index) onToggleJoin;

  static const _rowHeight = 68.0;
  static const _rowGap = 10.0;
  static const _peekStep = 16.0;
  static const _peekSliverHeight = 26.0;

  @override
  Widget build(BuildContext context) {
    final maxHeight = items.length * (_rowHeight + _rowGap);
    return SizedBox(
      height: maxHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < items.length; i++) _buildRow(context, i),
          if (items.length > 1)
            Positioned(
              right: 6,
              bottom: lerpDouble(-6, maxHeight - _rowHeight - 6, reveal),
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: 1 - reveal,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+${items.length - 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.expand_more_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, int i) {
    final row = _CommunityRow(
      item: items[i],
      onToggleJoin: () => onToggleJoin(i),
    );
    if (i == 0) {
      return Positioned(left: 0, right: 0, top: 0, child: row);
    }

    // Each row beyond the front gets its own local progress so the stack
    // unfurls front-first as reveal increases (and restacks in reverse).
    final t = ((reveal * items.length) - (i - 1)).clamp(0.0, 1.0);
    final depth = i <= 2 ? i : 2;
    final collapsedTop = (_rowHeight - 6) + depth * _peekStep;
    final collapsedInset = depth * 12.0;
    final collapsedHeight = i <= 2 ? _peekSliverHeight : 0.0;
    final collapsedOpacity = i == 1
        ? 0.85
        : i == 2
        ? 0.55
        : 0.0;
    final expandedTop = i * (_rowHeight + _rowGap);

    final top = lerpDouble(collapsedTop, expandedTop, t)!;
    final inset = lerpDouble(collapsedInset, 0, t)!;
    final height = lerpDouble(collapsedHeight, _rowHeight, t)!;
    final opacity = lerpDouble(collapsedOpacity, 1.0, t)!;

    return Positioned(
      top: top,
      left: inset,
      right: inset,
      child: IgnorePointer(
        ignoring: t < 0.9,
        child: Opacity(
          opacity: opacity,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: (height / _rowHeight).clamp(0.001, 1.0),
              child: row,
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar + name/members block, shared by the front-of-stack row and the
/// expanded list rows (see [_CommunityRow]).
class _CommunityIdentity extends StatelessWidget {
  const _CommunityIdentity({required this.item});

  final (String, String, bool) item;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.ink;
    final (name, members, _) = item;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.brandGreen.withValues(alpha: .18),
                AppColors.gold.withValues(alpha: .18),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.brandGreen.withValues(alpha: .25),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            name[0],
            style: const TextStyle(
              color: AppColors.brandGreen,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.w700, color: ink),
              ),
              Text(
                members,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommunityRow extends StatelessWidget {
  const _CommunityRow({required this.item, required this.onToggleJoin});

  final (String, String, bool) item;
  final VoidCallback onToggleJoin;

  @override
  Widget build(BuildContext context) {
    final joined = item.$3;
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(child: _CommunityIdentity(item: item)),
          const SizedBox(width: 12),
          _JoinPill(joined: joined, onTap: onToggleJoin),
        ],
      ),
    );
  }
}

class _JoinPill extends StatefulWidget {
  const _JoinPill({required this.joined, required this.onTap});

  final bool joined;
  final VoidCallback onTap;

  @override
  State<_JoinPill> createState() => _JoinPillState();
}

class _JoinPillState extends State<_JoinPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.joined
                ? null
                : LinearGradient(
                    colors: [
                      AppColors.brandGreen.withValues(alpha: .16),
                      AppColors.gold.withValues(alpha: .16),
                    ],
                  ),
            color: widget.joined
                ? (dark ? AppColors.darkSurface : AppColors.trackGrey)
                : null,
            border: widget.joined
                ? null
                : Border.all(color: AppColors.brandGreen.withValues(alpha: .3)),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            widget.joined ? 'Joined' : 'Join',
            style: TextStyle(
              color: widget.joined ? AppColors.greyText : AppColors.brandGreen,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
