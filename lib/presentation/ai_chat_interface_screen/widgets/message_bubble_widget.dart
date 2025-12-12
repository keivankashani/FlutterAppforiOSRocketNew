import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isUser;
  final VoidCallback? onLongPress;
  final VoidCallback? onRegenerateResponse;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isUser,
    this.onLongPress,
    this.onRegenerateResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 1.h,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAIAvatar(colorScheme),
            SizedBox(width: 2.w),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 75.w,
                  minWidth: 20.w,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: isUser ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  border: !isUser
                      ? Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (message['content'] as String?) ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUser
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTimestamp(message['timestamp']),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isUser
                                ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 10.sp,
                          ),
                        ),
                        if (isUser && message['status'] != null) ...[
                          SizedBox(width: 1.w),
                          _buildMessageStatus(colorScheme),
                        ],
                      ],
                    ),
                    if (!isUser && message['quickActions'] != null)
                      _buildQuickActions(context, colorScheme),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 2.w),
            _buildUserAvatar(colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildAIAvatar(ColorScheme colorScheme) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: CustomIconWidget(
        iconName: 'smart_toy',
        color: colorScheme.primary,
        size: 4.w,
      ),
    );
  }

  Widget _buildUserAvatar(ColorScheme colorScheme) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: CustomIconWidget(
        iconName: 'person',
        color: colorScheme.onPrimary,
        size: 4.w,
      ),
    );
  }

  Widget _buildMessageStatus(ColorScheme colorScheme) {
    final status = message['status'] as String?;
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'sent':
        iconData = Icons.check;
        iconColor = colorScheme.onPrimary.withValues(alpha: 0.7);
        break;
      case 'delivered':
        iconData = Icons.done_all;
        iconColor = colorScheme.onPrimary.withValues(alpha: 0.7);
        break;
      case 'failed':
        iconData = Icons.error_outline;
        iconColor = Colors.red.withValues(alpha: 0.7);
        break;
      default:
        iconData = Icons.schedule;
        iconColor = colorScheme.onPrimary.withValues(alpha: 0.5);
    }

    return CustomIconWidget(
      iconName: iconData.codePoint.toString(),
      color: iconColor,
      size: 3.w,
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme colorScheme) {
    final quickActions = message['quickActions'] as List<Map<String, dynamic>>?;
    if (quickActions == null || quickActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 2.h),
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: quickActions.map((action) {
          return InkWell(
            onTap: () => _handleQuickAction(context, action),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.h,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                action['label'] as String? ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                    ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleQuickAction(BuildContext context, Map<String, dynamic> action) {
    final actionType = action['type'] as String?;
    final actionData = action['data'];

    switch (actionType) {
      case 'navigate':
        if (actionData is String) {
          Navigator.pushNamed(context, actionData);
        }
        break;
      case 'copy':
        if (actionData is String) {
          Clipboard.setData(ClipboardData(text: actionData));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied to clipboard')),
          );
        }
        break;
      case 'regenerate':
        onRegenerateResponse?.call();
        break;
    }
  }

  void _showMessageOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: theme.colorScheme.onSurface,
                size: 6.w,
              ),
              title: Text(
                'Copy Text',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(
                    ClipboardData(text: message['content'] as String? ?? ''));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.onSurface,
                size: 6.w,
              ),
              title: Text(
                'Share Response',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                // Share functionality would be implemented here
              },
            ),
            if (!isUser)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'refresh',
                  color: theme.colorScheme.onSurface,
                  size: 6.w,
                ),
                title: Text(
                  'Regenerate Response',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRegenerateResponse?.call();
                },
              ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime dateTime;
    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
