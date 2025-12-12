import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricIconWidget extends StatefulWidget {
  final bool isAuthenticating;
  final bool isIOS;

  const BiometricIconWidget({
    super.key,
    required this.isAuthenticating,
    required this.isIOS,
  });

  @override
  State<BiometricIconWidget> createState() => _BiometricIconWidgetState();
}

class _BiometricIconWidgetState extends State<BiometricIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAuthenticating) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BiometricIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAuthenticating != oldWidget.isAuthenticating) {
      if (widget.isAuthenticating) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: widget.isAuthenticating
                  ? colorScheme.primary
                      .withValues(alpha: _pulseAnimation.value * 0.5)
                  : colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Transform.scale(
            scale: widget.isAuthenticating ? _scaleAnimation.value : 1.0,
            child: Center(
              child: Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: widget.isIOS ? 'face' : 'fingerprint',
                    color: colorScheme.primary,
                    size: 8.w,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
