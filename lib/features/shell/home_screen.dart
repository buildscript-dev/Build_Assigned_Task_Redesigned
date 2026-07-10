import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/mock_posts.dart';
import '../../data/mock_shell.dart';
import '../../shared/ui_kit.dart';
import 'shell.dart';

/// Consultant dashboard: greeting, stats, trending products, recent posts.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    return ShellScaffold(
      index: tabHome,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          SectionHeading(
            'Hi $consultantName 👋',
            subtitle: "Here's how your sharing is going",
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (final (i, s) in dashStats.indexed) ...[
                Expanded(
                  child: _StatCard(
                    icon: const [
                      Icons.grid_view_rounded,
                      Icons.link_rounded,
                      Icons.payments_rounded,
                    ][i],
                    value: s.value,
                    label: s.label,
                    delay: Duration(milliseconds: i * 120),
                  ),
                ),
                if (s != dashStats.last) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 28),
          const KickerLabel('Trending products'),
          const SizedBox(height: 10),
          SizedBox(
            height: 128,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                for (final item in searchCorpus.where(
                  (s) => s.kind == 'Product',
                ))
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SoftCard(
                      color: AppColors.cream,
                      padding: const EdgeInsets.all(14),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.title} · ${item.subtitle}'),
                        ),
                      ),
                      child: SizedBox(
                        width: 128,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                gradient: AppColors.goldGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
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
          ),
          const SizedBox(height: 28),
          const KickerLabel('Your recent Smart Posts'),
          const SizedBox(height: 10),
          for (final p in mockPosts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                padding: const EdgeInsets.all(10),
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Corners.sm),
                      child: Image.asset(
                        p.imageAsset,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '♫ ${p.trackTitle} · ${p.trackArtist}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.greyMuted,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bento-style stat card: a progress ring behind the icon and a count-up
/// number, both animating in on mount (staggered per card via [delay]).
class _StatCard extends StatefulWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.delay,
  });

  final IconData icon;
  final String value;
  final String label;
  final Duration delay;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  static final _valuePattern = RegExp(r'^(\D*)([\d,]+)(.*)$');

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = _valuePattern.firstMatch(widget.value);
    final prefix = match?.group(1) ?? '';
    final target = int.tryParse((match?.group(2) ?? '0').replaceAll(',', ''));
    final suffix = match?.group(3) ?? '';
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: AnimatedBuilder(
              animation: _curve,
              builder: (context, child) => Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _curve.value * 0.78,
                    strokeWidth: 3,
                    backgroundColor: AppColors.trackGrey,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.brandGreen,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (r) => AppColors.heroGradient.createShader(r),
            child: AnimatedBuilder(
              animation: _curve,
              builder: (context, child) {
                final shown = target == null
                    ? widget.value
                    : '$prefix${(target * _curve.value).round()}$suffix';
                return Text(
                  shown,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 3),
          Text(
            widget.label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }
}
