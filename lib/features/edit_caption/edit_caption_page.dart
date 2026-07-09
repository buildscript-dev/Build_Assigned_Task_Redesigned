import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// Opens the caption editor as a draggable-height bottom sheet. Height
/// adapts to leave room for the keyboard so the header/Save button are
/// never pushed off-screen, and the text area scrolls (no `expands: true`,
/// which is the usual source of edit-field overflow).
Future<String?> showEditCaptionSheet(
    BuildContext context, String initialText) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EditCaptionSheet(initialText: initialText),
  );
}

class EditCaptionSheet extends StatefulWidget {
  const EditCaptionSheet({super.key, required this.initialText});

  final String initialText;

  @override
  State<EditCaptionSheet> createState() => _EditCaptionSheetState();
}

class _EditCaptionSheetState extends State<EditCaptionSheet> {
  late final TextEditingController _controller;
  late final String _original;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _original = widget.initialText;
    _controller = TextEditingController(text: _original)
      ..addListener(() {
        final dirty = _controller.text != _original;
        if (dirty != _dirty) setState(() => _dirty = dirty);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    // Cap the sheet to whatever's left above the keyboard (plus a small
    // margin) so the header always stays visible — never a fixed height
    // that could overshoot the screen once the keyboard opens.
    final maxHeight = media.size.height * 0.78;
    final availableHeight = media.size.height - keyboard - media.padding.top - 24;
    final height = availableHeight < maxHeight ? availableHeight : maxHeight;

    return AnimatedPadding(
      duration: Motion.fast,
      curve: Motion.smooth,
      padding: EdgeInsets.only(bottom: keyboard),
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.smooth,
        height: height.clamp(280.0, maxHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.greyMuted,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.ink),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text('Edit Caption',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink)),
                    ),
                    AnimatedScale(
                      scale: _dirty ? 1.0 : 0.94,
                      duration: Motion.base,
                      curve: Motion.spring,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: _dirty ? AppColors.heroGradient : null,
                          boxShadow: _dirty
                              ? [
                                  BoxShadow(
                                      color: AppColors.brandGreen
                                          .withValues(alpha: .4),
                                      blurRadius: 10)
                                ]
                              : null,
                        ),
                        child: FilledButton(
                          onPressed: _dirty
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.of(context)
                                      .pop(_controller.text);
                                }
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor:
                                AppColors.greyMuted.withValues(alpha: .5),
                            disabledForegroundColor: AppColors.greyText,
                            shadowColor: Colors.transparent,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text('Save',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    // No autofocus: keyboard appears on caption tap (2nd
                    // click), matching the annotated Figma flow.
                    style: const TextStyle(
                        fontSize: 15, height: 1.45, color: AppColors.ink),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
