import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/mock_shell.dart';
import '../../shared/ui_kit.dart';
import 'shell.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _focused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.ink;
    final results = _query.isEmpty
        ? searchCorpus
        : searchCorpus
              .where(
                (s) =>
                    s.title.toLowerCase().contains(_query.toLowerCase()) ||
                    s.subtitle.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();
    return ShellScaffold(
      index: tabSearch,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: AnimatedContainer(
              duration: Motion.base,
              curve: Motion.smooth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Corners.lg),
                boxShadow: _focused
                    ? [
                        BoxShadow(
                          color: AppColors.brandGreen.withValues(alpha: .3),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: SoftCard(
                padding: EdgeInsets.zero,
                radius: Corners.lg,
                child: TextField(
                  focusNode: _focusNode,
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(color: ink),
                  decoration: const InputDecoration(
                    hintText: 'Search products, posts, people…',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.brandGreen,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      'No results for "$_query"',
                      style: const TextStyle(color: AppColors.greyText),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final r = results[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SoftCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.brandGreen.withValues(
                                        alpha: .18,
                                      ),
                                      AppColors.gold.withValues(alpha: .18),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    Corners.sm,
                                  ),
                                  border: Border.all(
                                    color: AppColors.brandGreen.withValues(
                                      alpha: .25,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  switch (r.kind) {
                                    'Product' => Icons.shopping_bag_rounded,
                                    'Post' => Icons.image_rounded,
                                    _ => Icons.person_rounded,
                                  },
                                  color: AppColors.brandGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: ink,
                                      ),
                                    ),
                                    Text(
                                      r.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.brandGreen.withValues(
                                    alpha: .12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  r.kind,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
