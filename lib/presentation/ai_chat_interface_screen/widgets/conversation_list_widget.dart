import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import './message_bubble_widget.dart';
import './typing_indicator_widget.dart';

class ConversationListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final bool isLoading;
  final ScrollController scrollController;
  final VoidCallback? onRefresh;
  final Function(Map<String, dynamic>)? onRegenerateResponse;

  const ConversationListWidget({
    super.key,
    required this.messages,
    required this.scrollController,
    this.isLoading = false,
    this.onRefresh,
    this.onRegenerateResponse,
  });

  @override
  State<ConversationListWidget> createState() => _ConversationListWidgetState();
}

class _ConversationListWidgetState extends State<ConversationListWidget> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      child:
          widget.messages.isEmpty && !widget.isLoading
              ? _buildEmptyState(theme, colorScheme)
              : ListView.builder(
                controller: widget.scrollController,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                itemCount: widget.messages.length + (widget.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == widget.messages.length) {
                    return TypingIndicatorWidget(isVisible: widget.isLoading);
                  }

                  final message = widget.messages[index];
                  final isUser = (message['isUser'] as bool?) ?? false;

                  return MessageBubbleWidget(
                    message: message,
                    isUser: isUser,
                    onRegenerateResponse:
                        !isUser
                            ? () => widget.onRegenerateResponse?.call(message)
                            : null,
                  );
                },
              ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 70.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: CustomIconWidget(
                iconName: 'smart_toy',
                color: colorScheme.primary,
                size: 12.w,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Welcome to AI Assistant',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'I\'m here to help you with business insights, analytics, and answer any questions you might have.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            _buildSuggestedQuestions(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions(ThemeData theme, ColorScheme colorScheme) {
    final suggestions = [
      {
        'icon': 'analytics',
        'title': 'Show Analytics',
        'subtitle': 'View business performance data',
        'query': 'Show me the latest analytics dashboard',
      },
      {
        'icon': 'trending_up',
        'title': 'Sales Trends',
        'subtitle': 'Analyze sales performance',
        'query': 'What are the current sales trends?',
      },
      {
        'icon': 'insights',
        'title': 'Business Insights',
        'subtitle': 'Get actionable recommendations',
        'query': 'Give me insights about my business performance',
      },
    ];

    return Column(
      children:
          suggestions.map((suggestion) {
            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: InkWell(
                onTap:
                    () => _handleSuggestionTap(suggestion['query'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
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
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.w),
                        ),
                        child: CustomIconWidget(
                          iconName: suggestion['icon'] as String,
                          color: colorScheme.primary,
                          size: 6.w,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion['title'] as String,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              suggestion['subtitle'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'arrow_forward_ios',
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 4.w,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _handleSuggestionTap(String query) {
    // This would typically trigger sending the suggested query
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suggested query: $query'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
