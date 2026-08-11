import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────

/// Simple data model for each emotion card in [EmotionStatusRow].
///
/// Pass either [emoji] (Widget) or [imageUrl] (network image).
/// If both are provided, [imageUrl] takes priority.
class EmotionItem {
  final String label;
  final Widget? emoji;
  final String? imageUrl;
  final Color backgroundColor;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const EmotionItem({
    required this.label,
    this.emoji,
    this.imageUrl,
    required this.backgroundColor,
    required this.borderColor,
    this.isSelected = false,
    this.onTap,
  });
}

// ─── Layout Container ────────────────────────────────────────────────────────

/// Responsive row that auto-sizes 1–3 [EmotionItem] cards.
///
/// Width rules (uses Row + Expanded, never wraps):
///  • 1 item → 100% width
///  • 2 items → 50% each (minus spacing)
///  • 3 items → 33.3% each (minus spacing)
///
/// ```dart
/// EmotionStatusRow(
///   items: [
///     EmotionItem(label: 'Joyful', emoji: joyWidget, backgroundColor: ..., borderColor: ...),
///     EmotionItem(label: 'Sad',    emoji: sadWidget, backgroundColor: ..., borderColor: ...),
///   ],
/// )
/// ```
class EmotionStatusRow extends StatelessWidget {
  final List<EmotionItem> items;
  final double? spacing;

  const EmotionStatusRow({super.key, required this.items, this.spacing});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Clamp to max 3 items
    final display = items.length > 3 ? items.sublist(0, 3) : items;
    final gap = spacing ?? 10.w;

    return Row(
      children: [
        for (int i = 0; i < display.length; i++) ...[
          Expanded(child: _EmotionStatusCard(item: display[i])),
          if (i < display.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

// ─── Visual Card (private) ───────────────────────────────────────────────────

/// Individual card widget — handles only the visual look.
/// Private to this file; consumers interact only with [EmotionStatusRow].
class _EmotionStatusCard extends StatelessWidget {
  final EmotionItem item;

  const _EmotionStatusCard({required this.item});

  bool get _hasImage => item.imageUrl != null && item.imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Label on top ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(bottom: 5.h),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.body.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
                fontFamily: 'sfpro',
              ),
            ),
          ),

          // ── Card container below ────────────────────────────────────
          SizedBox(
            height: 110.h,
            child: Stack(
              children: [
                _hasImage ? _buildImageCard(context) : _buildEmojiCard(context),

                // ── Green checkmark badge — same position for both ─────────
                if (item.isSelected)
                  Positioned(
                    top: 8.h,
                    right: 10.w,
                    child: CircleAvatar(
                      radius: 10.r,
                      backgroundColor: context.colors.background,
                      child: Icon(
                        Icons.check,
                        color: context.colors.primary,
                        size: 12.r,
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

  /// Image fills the entire card.
  Widget _buildImageCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: CachedNetworkImage(
        imageUrl: item.imageUrl!,
        width: double.infinity,
        height: 110.h,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            color: item.backgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: item.borderColor, width: 1.5),
          ),
          child: Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: context.colors.primary,
              size: 18,
            ),
          ),
        ),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: item.borderColor, width: 1.5),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        errorWidget: (context, url, error) => _buildEmojiCard(context),
      ),
    );
  }

  /// Emoji centered inside the colored container.
  Widget _buildEmojiCard(BuildContext context) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: item.borderColor, width: 1.5),
      ),
      child: Center(
        child: SizedBox(
          width: 36.w,
          height: 36.h,
          child: Center(child: item.emoji),
        ),
      ),
    );
  }
}
