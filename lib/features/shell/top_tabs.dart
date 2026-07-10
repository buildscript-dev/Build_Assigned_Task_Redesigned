import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.ink;
    return ShellScaffold(
      index: -1,
      topTabIndex: 2,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const SectionHeading('Communities'),
          const SizedBox(height: 18),
          for (var i = 0; i < _communities.length; i++)
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
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          gradient: AppColors.heroGradient,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _communities[i].$1[0],
                          style: const TextStyle(
                            color: Colors.white,
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
                              _communities[i].$1,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: ink,
                              ),
                            ),
                            Text(
                              _communities[i].$2,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                        compact: true,
                        filled: !_communities[i].$3,
                        label: _communities[i].$3 ? 'Joined' : 'Join',
                        onTap: () => setState(
                          () => _communities[i] = (
                            _communities[i].$1,
                            _communities[i].$2,
                            !_communities[i].$3,
                          ),
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

/// Share&Win: weekly sharing challenge with a leaderboard.
class ShareWinScreen extends StatelessWidget {
  const ShareWinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.ink;
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(Corners.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGreen.withValues(alpha: .35),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
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
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Share $goal Smart Posts, win a Giordani Gold set',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: shared / goal,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$shared of $goal shared — ${goal - shared} to go!',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
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
