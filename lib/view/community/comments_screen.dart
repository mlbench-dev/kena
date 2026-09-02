import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_bottom_sheet.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// ---------------------------------------------------------------------------
// How to open it from anywhere:
//
//   CommentBottomSheet.show(
//     context,
//     entryOwnerId: '...',
//     communityId: '...',
//   );
// ---------------------------------------------------------------------------

class CommentBottomSheet {
  CommentBottomSheet._();

  /// Call this from any screen to open the comment sheet
  static void show(
    BuildContext context, {
    required String entryOwnerId,
    required String communityId,
    void Function(int newCount)? onCommentCountChanged,
  }) {
    MyBottomSheet.show(
      context,
      isDismissible: true,
      enableDrag: true,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        child: _CommentContent(
          entryOwnerId: entryOwnerId,
          communityId: communityId,
          onCommentCountChanged: onCommentCountChanged,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Comment Content (stateful inner widget)
// ---------------------------------------------------------------------------

class _CommentContent extends StatefulWidget {
  final String entryOwnerId;
  final String communityId;
  final void Function(int newCount)? onCommentCountChanged;

  const _CommentContent({
    required this.entryOwnerId,
    required this.communityId,
    this.onCommentCountChanged,
  });

  @override
  State<_CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<_CommentContent> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final UserHomeService _service = UserHomeService();

  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);

    final result = await _service.getFeedComments(
      entryOwnerId: widget.entryOwnerId,
      communityId: widget.communityId,
      context: context,
    );

    if (mounted) {
      setState(() {
        _comments = result;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final result = await _service.postFeedComment(
      entryOwnerId: widget.entryOwnerId,
      communityId: widget.communityId,
      content: text,
      context: context,
    );

    if (!mounted) return;

    if (result != null) {
      _commentController.clear();
      // Reload comments from API to get the full comment data
      await _loadComments();
      // Notify parent about new comment count
      widget.onCommentCountChanged?.call(_comments.length);

      // Scroll to the newly added comment
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
          child: Container(
            height: 5.h,
            width: 54.w,
            decoration: BoxDecoration(
              color: const Color(0xFF6B6E80),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),

        // Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            "Comments",
            style: TextStyle(
              color: const Color(0xFF1A2E25),
              fontSize: 18.sp,
              fontFamily: "Raleway",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Divider(color: const Color(0xFFEAEAEA), height: 1.h),

        // Comments list
        Expanded(
          child: _isLoading
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: context.colors.primary,
                    size: 45,
                  ),
                )
              : _comments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 40.sp,
                        color: const Color(0xFFCDD6D2),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "No comments yet.\nBe the first to comment!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF8A9E96),
                          fontSize: 14.sp,
                          fontFamily: "Raleway",
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    final author =
                        comment['author'] as Map<String, dynamic>? ?? {};

                    return _CommentTile(
                      userName:
                          author['aliasName'] ?? author['username'] ?? 'User',
                      avatarUrl: author['avatarUrl'] ?? '',
                      content: comment['content'] ?? '',
                      timeAgo: _formatTime(comment['createdAt']),
                    );
                  },
                ),
        ),

        // Add comment input bar
        _CommentInputBar(
          controller: _commentController,
          focusNode: _focusNode,
          isSending: _isSending,
          onSend: _sendComment,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Comment Tile
// ---------------------------------------------------------------------------

class _CommentTile extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final String content;
  final String timeAgo;

  const _CommentTile({
    required this.userName,
    required this.avatarUrl,
    required this.content,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: userName, radius: 17.r, imageUrl: avatarUrl),
          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        color: const Color(0xFF1A2E25),
                        fontSize: 13.sp,
                        fontFamily: "sfpro",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: const Color(0xFF8A9E96),
                        fontSize: 11.sp,
                        fontFamily: "sfpro",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  content,
                  style: TextStyle(
                    color: const Color(0xFF2D3E37),
                    fontSize: 13.sp,
                    fontFamily: "Raleway",
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Comment Input Bar
// ---------------------------------------------------------------------------

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;

  const _CommentInputBar({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 12.w,
        top: 10.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFEAEAEA), width: 1.h),
        ),
      ),
      child: Row(
        children: [
          ListenableBuilder(
            listenable: SessionController(),
            builder: (context, _) {
              final currentUser = SessionController().user;
              final name =
                  currentUser?.aliasName ?? currentUser?.username ?? 'User';
              return _Avatar(
                name: name,
                radius: 17.r,
                imageUrl: currentUser?.avatarUrl,
              );
            },
          ),
          SizedBox(width: 10.w),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F4),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                enableIMEPersonalizedLearning: false,
                style: TextStyle(
                  color: const Color(0xFF1A2E25),
                  fontSize: 14.sp,
                  fontFamily: "Raleway",
                ),
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  fillColor: Colors.transparent,
                  hintStyle: TextStyle(
                    color: const Color(0xFF8A9E96),
                    fontSize: 14.sp,
                    fontFamily: "Raleway",
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Send button
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.w, right: 10.w),
              child: isSending
                  ? LoadingWidget(size: 20, color: context.colors.primary)
                  : Assets.icons.send.svg(
                      width: 24.w,
                      height: 24.h,
                      color: context.colors.primary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar Widget
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final String name;
  final double radius;
  final String? imageUrl;

  const _Avatar({required this.name, required this.radius, this.imageUrl});

  Color _colorFromName(String name) {
    final colors = [
      const Color(0xFF2E7D5E),
      const Color(0xFF5C6BC0),
      const Color(0xFFE57373),
      const Color(0xFF26A69A),
      const Color(0xFFFF7043),
      const Color(0xFF8D6E63),
      const Color(0xFF42A5F5),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (_, provider) =>
            CircleAvatar(radius: radius, backgroundImage: provider),
        placeholder: (_, _) => CircleAvatar(
          radius: radius,
          backgroundColor: _colorFromName(name),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.75,
              fontFamily: "sfpro",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        errorWidget: (_, _, _) => _fallbackAvatar(),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _colorFromName(name),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.75,
          fontFamily: "sfpro",
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
