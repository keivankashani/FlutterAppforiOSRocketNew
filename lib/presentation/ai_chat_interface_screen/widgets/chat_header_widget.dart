import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ChatHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHistoryTap;
  final bool isOnline;

  const ChatHeaderWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.onSettingsTap,
    this.onHistoryTap,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _buildBackButton(context, colorScheme),
            SizedBox(width: 3.w),
            _buildAIAvatar(colorScheme),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildTitleSection(theme, colorScheme),
            ),
            _buildActionButtons(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(6.w),
      child: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6.w),
        ),
        child: CustomIconWidget(
          iconName: 'arrow_back_ios',
          color: colorScheme.onSurface,
          size: 5.w,
        ),
      ),
    );
  }

  Widget _buildAIAvatar(ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(6.w),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: CustomIconWidget(
            iconName: 'smart_toy',
            color: colorScheme.onPrimary,
            size: 6.w,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(1.5.w),
              border: Border.all(
                color: colorScheme.surface,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ] else ...[
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(1.w),
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onHistoryTap,
          borderRadius: BorderRadius.circular(6.w),
          child: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: CustomIconWidget(
              iconName: 'history',
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 5.w,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        InkWell(
          onTap: onSettingsTap,
          borderRadius: BorderRadius.circular(6.w),
          child: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: CustomIconWidget(
              iconName: 'more_vert',
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 5.w,
            ),
          ),
        ),
      ],
    );
  }
}
