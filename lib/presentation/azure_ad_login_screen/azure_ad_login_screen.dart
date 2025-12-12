import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/azure_login_button_widget.dart';
import './widgets/enterprise_logo_widget.dart';
import './widgets/error_message_widget.dart';
import './widgets/offline_indicator_widget.dart';
import './widgets/security_badge_widget.dart';

class AzureAdLoginScreen extends StatefulWidget {
  const AzureAdLoginScreen({super.key});

  @override
  State<AzureAdLoginScreen> createState() => _AzureAdLoginScreenState();
}

class _AzureAdLoginScreenState extends State<AzureAdLoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Mock credentials for demonstration
  final Map<String, String> _mockCredentials = {
    'admin@enterprisehub.com': 'Admin123!',
    'user@enterprisehub.com': 'User123!',
    'manager@enterprisehub.com': 'Manager123!',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkConnectivity();
    _setupConnectivityListener();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimationController.forward();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected =
            results.any((result) => result != ConnectivityResult.none);

        if (mounted) {
          setState(() {
            _isOffline = !isConnected;
          });
        }
      },
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final isConnected = connectivityResults
          .any((result) => result != ConnectivityResult.none);

      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOffline = true;
        });
      }
    }
  }

  Future<void> _handleAzureLogin() async {
    if (_isLoading) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Clear previous error
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate Azure AD authentication process
      await Future.delayed(const Duration(seconds: 2));

      if (_isOffline) {
        throw Exception(
            'No internet connection. Please check your network and try again.');
      }

      // Simulate random authentication scenarios
      final scenarios = [
        'success',
        'invalid_credentials',
        'account_not_found',
        'network_error',
      ];

      final randomScenario =
          scenarios[DateTime.now().millisecond % scenarios.length];

      switch (randomScenario) {
        case 'success':
          // Success - navigate to biometric authentication
          HapticFeedback.mediumImpact();
          if (mounted) {
            Navigator.pushReplacementNamed(
                context, '/biometric-authentication-screen');
          }
          break;

        case 'invalid_credentials':
          throw Exception(
              'Invalid credentials. Please verify your Microsoft account credentials and try again.');

        case 'account_not_found':
          throw Exception(
              'Account not found. Please contact your administrator to verify your access permissions.');

        case 'network_error':
          throw Exception(
              'Unable to connect to Azure services. Please check your internet connection and try again.');

        default:
          throw Exception('Authentication failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _dismissError() {
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Top spacing
                          SizedBox(height: 8.h),

                          // Enterprise Logo
                          const EnterpriseLogoWidget(),

                          SizedBox(height: 6.h),

                          // Azure Integration Message
                          Container(
                            width: 85.w,
                            constraints: BoxConstraints(maxWidth: 400),
                            child: Text(
                              'Sign in with your Microsoft account to access enterprise analytics, AI chat, and secure business data.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.8),
                                    fontSize: 3.5.w > 16 ? 16 : 3.5.w,
                                    height: 1.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          // Error Message
                          ErrorMessageWidget(
                            errorMessage: _errorMessage,
                            onDismiss: _dismissError,
                          ),

                          SizedBox(height: 2.h),

                          // Azure Login Button
                          AzureLoginButtonWidget(
                            onPressed: _handleAzureLogin,
                            isLoading: _isLoading,
                          ),

                          SizedBox(height: 4.h),

                          // Security Badge
                          const SecurityBadgeWidget(),

                          SizedBox(height: 3.h),

                          // Mock Credentials Info (for demo purposes)
                          if (_errorMessage != null &&
                              _errorMessage!.contains('Invalid credentials'))
                            Container(
                              width: 85.w,
                              constraints: BoxConstraints(maxWidth: 400),
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Demo Credentials:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: 1.h),
                                  ..._mockCredentials.entries
                                      .map((entry) => Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 0.5.h),
                                            child: Text(
                                              '${entry.key} / ${entry.value}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.7),
                                                    fontFamily: 'monospace',
                                                  ),
                                            ),
                                          ))
                                      ,
                                ],
                              ),
                            ),

                          // Bottom spacing
                          SizedBox(height: 4.h),

                          // Footer
                          Container(
                            width: 85.w,
                            constraints: BoxConstraints(maxWidth: 400),
                            child: Column(
                              children: [
                                Text(
                                  'By signing in, you agree to our Terms of Service and Privacy Policy.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                        fontSize: 2.8.w > 12 ? 12 : 2.8.w,
                                        height: 1.4,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'shield',
                                      color: AppTheme.successLight,
                                      size: 3.w > 14 ? 14 : 3.w,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      'Enterprise Grade Security',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.successLight,
                                            fontSize: 2.8.w > 12 ? 12 : 2.8.w,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Offline Indicator
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: OfflineIndicatorWidget(
              isOffline: _isOffline,
            ),
          ),
        ],
      ),
    );
  }
}
