import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class IntensityCircle extends StatelessWidget {
  final int intensity;
  final Widget centerWidget;
  final String label;
  final String? imageUrl;

  final VoidCallback? onUpload;
  final VoidCallback? onRemove;
  final bool isDisabled; // optional: blocks upload/remove taps, e.g. while another circle's image uploads

  final Color? progressColor;
  final Color? backgroundColor;
  final Color? cardColor;

  const IntensityCircle({
    super.key,
    required this.intensity,
    required this.centerWidget,
    required this.label,
    this.imageUrl,
    this.onUpload,
    this.onRemove,
    this.isDisabled = false,
    this.progressColor,
    this.backgroundColor,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = intensity.clamp(0, 5) / 5;
    final double size = 65.r;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7.w,
                  backgroundColor: backgroundColor ?? const Color(0xFFf1e2c5),
                  valueColor: AlwaysStoppedAnimation(
                    progressColor ?? const Color(0xFF32683b),
                  ),
                ),
              ),

              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardColor ?? Colors.white,
                ),
                child: Center(
                  child: imageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            imageUrl!,
                            width: 56.r,
                            height: 56.r,
                            fit: BoxFit.cover,
                          ),
                        )
                      : centerWidget,
                ),
              ),

              // Upload Button
              if (onUpload != null)
                Positioned(
                  bottom: -2.r,
                  right: -2.r,
                  child: _ActionButton(
                    icon: Icons.file_upload_outlined,
                    onTap: isDisabled ? null : onUpload!,
                    isDisabled: isDisabled,
                  ),
                ),

              // Remove Button
              if (onRemove != null)
                Positioned(
                  top: -6.r,
                  right: -2.r,
                  child: _ActionButton(
                    icon: Icons.remove,
                    onTap: isDisabled ? null : onRemove!,
                    isDisabled: isDisabled,
                  ),
                ),
            ],
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                '$intensity/5',
                style: TextStyle(
                  color: const Color(0xFF399969),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1,
        child: Container(
          width: 24.r,
          height: 24.r,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 14.r, color: const Color(0xFFa30558)),
        ),
      ),
    );
  }
}
