import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttachment;
  final VoidCallback? onVoiceInput;
  final bool isLoading;
  final bool isEnabled;

  const ChatInputWidget({
    super.key,
    required this.controller,
    this.onSend,
    this.onAttachment,
    this.onVoiceInput,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

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
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildAttachmentButton(colorScheme),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildTextInput(theme, colorScheme),
            ),
            SizedBox(width: 2.w),
            _buildActionButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(ColorScheme colorScheme) {
    return InkWell(
      onTap: widget.isEnabled ? widget.onAttachment : null,
      borderRadius: BorderRadius.circular(6.w),
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(6.w),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: CustomIconWidget(
          iconName: 'attach_file',
          color: widget.isEnabled
              ? colorScheme.onSurface.withValues(alpha: 0.7)
              : colorScheme.onSurface.withValues(alpha: 0.3),
          size: 5.w,
        ),
      ),
    );
  }

  Widget _buildTextInput(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 12.w,
        maxHeight: 30.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(6.w),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.isEnabled,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: widget.isLoading
              ? 'AI is thinking...'
              : 'Ask me anything about your business...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 3.w,
          ),
          isDense: true,
        ),
        onSubmitted: (_) => _handleSend(),
      ),
    );
  }

  Widget _buildActionButton(ColorScheme colorScheme) {
    if (widget.isLoading) {
      return Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6.w),
        ),
        child: Center(
          child: SizedBox(
            width: 5.w,
            height: 5.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ),
      );
    }

    if (_hasText) {
      return InkWell(
        onTap: widget.isEnabled ? _handleSend : null,
        borderRadius: BorderRadius.circular(6.w),
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: colorScheme.primary,
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
            iconName: 'send',
            color: colorScheme.onPrimary,
            size: 5.w,
          ),
        ),
      );
    }

    return InkWell(
      onTap: widget.isEnabled ? widget.onVoiceInput : null,
      borderRadius: BorderRadius.circular(6.w),
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(6.w),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: CustomIconWidget(
          iconName: 'mic',
          color: widget.isEnabled
              ? colorScheme.onSurface.withValues(alpha: 0.7)
              : colorScheme.onSurface.withValues(alpha: 0.3),
          size: 5.w,
        ),
      ),
    );
  }

  void _handleSend() {
    if (_hasText && widget.isEnabled && !widget.isLoading) {
      HapticFeedback.lightImpact();
      widget.onSend?.call();
    }
  }
}
