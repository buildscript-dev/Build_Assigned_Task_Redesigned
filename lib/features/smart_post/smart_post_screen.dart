import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/mock_posts.dart';
import '../../shared/bottom_nav.dart';
import '../../shared/oriflame_header.dart';
import '../../shared/tab_row.dart';
import '../shell/camera_service.dart';
import '../shell/shell.dart';
import 'post_card_experiment.dart';

/// Main feed. Chrome (header, tabs, bottom nav) stays put; the card style
/// below it is the profile-card design promoted from the experiment screen
/// (see post_card_experiment.dart for the card/expanded-view implementation).
class SmartPostScreen extends StatelessWidget {
  const SmartPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.surface,
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
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                  itemCount: mockPosts.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: ExperimentPostCard(post: mockPosts[i], index: i),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? AppColors.darkSurface : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow.withValues(alpha: .25),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: AppBottomNav(
                        color: dark ? Colors.white : AppColors.ink,
                        onTap: (i) => goTab(context, tabFeed, i),
                      ),
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
