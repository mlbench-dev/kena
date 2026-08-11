import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class MenuItemTile extends StatelessWidget {
  const MenuItemTile({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    this.onTap,
  });
  final String name;
  final String price;
  final String? imageUrl;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.bottomCenter,
        height: 182.h,
        width: 105.w,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Background container (rendered first, so it's behind)
            Container(
              width: 105.w,
              height: 140.h,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(AppRadiuses.mediumRadius),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "\$$price",
                    style: context.typography.body.copyWith(
                      color: context.colors.buttonPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // Image circle (rendered on top)
            Positioned(
              top: -40,
              child: CircleAvatar(
                radius: 45.r,
                backgroundColor: Colors.white70,
                child: CircleAvatar(
                  radius: 44.r,
                  backgroundColor: Colors.white,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: imageUrl == null
                      ? Icon(
                          Icons.restaurant_menu,
                          size: 32,
                          color: context.colors.primary.withValues(alpha: 0.5),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
