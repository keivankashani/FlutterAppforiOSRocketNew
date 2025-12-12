import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EnterpriseLogoWidget extends StatelessWidget {
  const EnterpriseLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 80.w,
      constraints: BoxConstraints(
        maxWidth: 300,
        minWidth: 200,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enterprise Logo Container
          Container(
            width: 25.w,
            height: 25.w,
            constraints: BoxConstraints(
              maxWidth: 120,
              maxHeight: 120,
              minWidth: 80,
              minHeight: 80,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'business',
                    color: colorScheme.primary,
                    size: 8.w > 40 ? 40 : 8.w,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'EH',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 4.w > 20 ? 20 : 4.w,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          // App Name
          Text(
            'EnterpriseHub',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 6.w > 28 ? 28 : 6.w,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          // Subtitle
          Text(
            'Secure Enterprise Access',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 3.5.w > 16 ? 16 : 3.5.w,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
