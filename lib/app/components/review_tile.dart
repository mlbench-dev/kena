import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class ReviewTile extends StatefulWidget {
  const ReviewTile({
    super.key,
    required this.name,
    required this.rating,
    required this.timeStamp,
    required this.content,
    this.imageUrl,
    this.isExpandable = false,
  });

  final String name;
  final double rating;
  final String timeStamp;
  final String content;
  final String? imageUrl;
  final bool isExpandable;

  @override
  State<ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<ReviewTile> {
  bool expanded = false;
  bool isOverflowing = false;
  final int maxCollapsedLines = 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- Header (Avatar + Name + Rating) ---
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.white60,
                backgroundImage: widget.imageUrl != null
                    ? NetworkImage(widget.imageUrl!)
                    : null,
              ),
              SizedBox(width: 8.w),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name, style: context.typography.title),

                  Row(
                    children: [
                      RatingBarIndicator(
                        itemPadding: EdgeInsets.only(right: 3.w),
                        rating: widget.rating,
                        itemSize: 17.w,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                      ),
                      Text(widget.timeStamp),
                    ],
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8.h),

          /// --- Description + View more / View less ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: LayoutBuilder(
              builder: (context, size) {
                // Measure text overflow
                final textPainter = TextPainter(
                  text: TextSpan(
                    text: widget.content,
                    style: context.typography.body.copyWith(fontSize: 14.sp),
                  ),
                  maxLines: maxCollapsedLines,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: size.maxWidth);

                isOverflowing = textPainter.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.content,
                      maxLines: expanded ? null : maxCollapsedLines,
                      overflow: expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: context.typography.body.copyWith(fontSize: 14.sp),
                    ),

                    if (widget.isExpandable && isOverflowing)
                      GestureDetector(
                        onTap: () => setState(() => expanded = !expanded),
                        child: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            expanded ? "View less" : "View more",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
