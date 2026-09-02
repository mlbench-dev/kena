import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

/// Displays a titled card with a row/wrap of emotion tiles and an edit toggle.
class EmotionsSectionCard extends StatelessWidget {
  final String? title;
  final Color? titleColor;
  final double? titleFontSize;
  final List<Widget> tiles;
  final bool isEditMode;
  final ValueChanged<bool>? onToggleEdit;
  final bool showEmptyState;
  final String emptyText;
  final int? fillEmptySlotsTo;
  final WidgetBuilder? emptySlotBuilder;
  final bool useWrapLayout;

  const EmotionsSectionCard({
    super.key,
    this.title,
    this.titleColor,
    this.titleFontSize,
    required this.tiles,
    this.isEditMode = false,
    this.onToggleEdit,
    this.showEmptyState = true,
    this.emptyText = 'No emotions recorded',
    this.fillEmptySlotsTo,
    this.emptySlotBuilder,
    this.useWrapLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = tiles.isEmpty;

    if (isEmpty && !isEditMode && !showEmptyState) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            _Header(
              title: title!,
              titleColor: titleColor,
              titleFontSize: titleFontSize,
              isEditMode: isEditMode,
              onToggleEdit: onToggleEdit,
            ),
            SizedBox(height: 8.h),
          ],
          if (isEmpty && !isEditMode)
            _EmptyLabel(text: emptyText)
          else
            _TilesLayout(
              tiles: _buildDisplayTiles(context),
              isEditMode: isEditMode,
              useWrapLayout: useWrapLayout,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildDisplayTiles(BuildContext context) {
    final displayTiles = List<Widget>.from(tiles);

    final bool shouldFill =
        isEditMode && fillEmptySlotsTo != null && emptySlotBuilder != null;

    if (shouldFill) {
      while (displayTiles.length < fillEmptySlotsTo!) {
        displayTiles.add(emptySlotBuilder!(context));
      }
    }

    return displayTiles;
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final borderColor = isEditMode
        ? context.colors.primary.withValues(alpha: 0.8)
        : context.colors.textSecondary.withValues(alpha: 0.3);

    return BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: borderColor),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final double? titleFontSize;
  final bool isEditMode;
  final ValueChanged<bool>? onToggleEdit;

  const _Header({
    required this.title,
    this.titleColor,
    this.titleFontSize,
    required this.isEditMode,
    this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: context.typography.headline.copyWith(
            fontSize: titleFontSize ?? 14.sp,
            fontWeight: FontWeight.w600,
            color: titleColor ?? context.colors.textPrimary,
          ),
        ),
        if (onToggleEdit != null)
          _EditToggle(
            isEditMode: isEditMode,
            onTap: () => onToggleEdit!(!isEditMode),
          ),
      ],
    );
  }
}

class _EditToggle extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onTap;

  const _EditToggle({required this.isEditMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: isEditMode ? _doneText(context) : _penIcon(context),
      ),
    );
  }

  Widget _doneText(BuildContext context) {
    return Text(
      'Done',
      key: const ValueKey('done_text'),
      style: context.typography.body.copyWith(
        fontFamily: 'sfpro',
        color: context.colors.primary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _penIcon(BuildContext context) {
    return SizedBox(
      key: const ValueKey('pen_icon'),
      child: Assets.icons.penOutline.svg(
        height: 15.h,
        width: 15.w,
        color: context.colors.secondary,
      ),
    );
  }
}

class _TilesLayout extends StatelessWidget {
  final List<Widget> tiles;
  final bool isEditMode;
  final bool useWrapLayout;

  const _TilesLayout({
    required this.tiles,
    required this.isEditMode,
    required this.useWrapLayout,
  });

  @override
  Widget build(BuildContext context) {
    final spacedTiles = tiles
        .map(
          (tile) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: tile,
          ),
        )
        .toList();

    if (useWrapLayout) {
      return Wrap(spacing: 8.w, runSpacing: 8.h, children: spacedTiles);
    }

    return Row(
      mainAxisAlignment: isEditMode
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: spacedTiles,
    );
  }
}

class _EmptyLabel extends StatelessWidget {
  final String text;

  const _EmptyLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 13.sp, color: context.colors.textSecondary),
    );
  }
}
