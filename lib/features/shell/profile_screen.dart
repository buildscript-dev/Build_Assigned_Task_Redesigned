import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../app/theme_controller.dart';
import '../../data/gallery_store.dart';
import '../../data/mock_posts.dart';
import '../../data/mock_shell.dart';
import '../../shared/ui_kit.dart';
import '../smart_post/post_card_experiment.dart';
import 'shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<File> _shots = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final shots = await GalleryStore.list();
    if (mounted) setState(() => _shots = shots);
  }

  Future<void> _confirmDelete(File photo) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete photo?'),
        content: const Text(
          'This camera shot will be removed from your gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.brandGreen),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await GalleryStore.delete(photo);
      HapticFeedback.lightImpact();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : AppColors.ink;
    // Only camera shots are deletable — the 3 seed posts are app assets.
    final tiles = <(ImageProvider, File?)>[
      for (final f in _shots) (FileImage(f), f),
      for (final p in mockPosts) (AssetImage(p.imageAsset), null),
    ];
    return ShellScaffold(
      index: tabProfile,
      onCameraReturn: _load,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          // Hero card — gradient wash behind the avatar instead of a plain row.
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brandGreen.withValues(alpha: .14),
                  AppColors.gold.withValues(alpha: .10),
                ],
              ),
              borderRadius: BorderRadius.circular(Corners.lg),
              border: Border.all(
                color: AppColors.brandGreen.withValues(alpha: .12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        gradient: AppColors.heroGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 32,
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            consultantName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                          Text(
                            consultantSince,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.greyText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Referral: $referralCode',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final s in dashStats)
                      Column(
                        children: [
                          Text(
                            s.value,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                          Text(
                            s.label,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Dark mode',
                style: TextStyle(fontWeight: FontWeight.w600, color: ink),
              ),
              secondary: Icon(
                dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.brandGreen,
              ),
              activeThumbColor: AppColors.brandGreen,
              value: dark,
              onChanged: (_) {
                HapticFeedback.selectionClick();
                toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 10),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.science_rounded, color: AppColors.gold),
              title: Text(
                'New post card (experiment)',
                style: TextStyle(fontWeight: FontWeight.w600, color: ink),
              ),
              subtitle: const Text(
                "Try the alternate style — doesn't change your feed",
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.greyMuted,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PostCardExperimentScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const KickerLabel('Gallery'),
          const SizedBox(height: 4),
          const Text(
            'Camera shots land here automatically — long-press or tap × to delete',
            style: TextStyle(fontSize: 12, color: AppColors.greyText),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, i) {
              final (image, file) = tiles[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _PhotoViewer(image: image)),
                ),
                onLongPress: file == null ? null : () => _confirmDelete(file),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Corners.sm),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Corners.sm),
                        child: Image(image: image, fit: BoxFit.cover),
                      ),
                    ),
                    // Only camera shots show a delete affordance — the 3
                    // seed posts are app assets, not user photos.
                    if (file != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _confirmDelete(file),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: InteractiveViewer(child: Image(image: image)),
        ),
      ),
    );
  }
}
