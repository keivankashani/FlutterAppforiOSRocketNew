import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/authentication_button_widget.dart';
import './widgets/biometric_icon_widget.dart';
import './widgets/error_message_widget.dart';
import './widgets/fallback_option_widget.dart';

class BiometricAuthenticationScreen extends StatefulWidget {
  const BiometricAuthenticationScreen({super.key});

  @override
  State<BiometricAuthenticationScreen> createState() =>
      _BiometricAuthenticationScreenState();
}

class _BiometricAuthenticationScreenState
    extends State<BiometricAuthenticationScreen> with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isAuthenticating = false;
  bool _isAvailable = false;
  bool _isIOS = false;
  String? _errorMessage;
  int _failedAttempts = 0;
  bool _isLockedOut = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isIOS = Platform.isIOS;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _checkBiometricAvailability();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      setState(() {
        _isAvailable =
            isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
        if (!_isAvailable) {
          _errorMessage = _isIOS
              ? 'Face ID is not available on this device'
              : 'Fingerprint authentication is not available on this device';
        }
      });
    } catch (e) {
      setState(() {
        _isAvailable = false;
        _errorMessage = 'Biometric authentication is not supported';
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isLockedOut) {
      setState(() {
        _errorMessage =
            'Too many failed attempts. Please try again later or use password.';
      });
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: _isIOS
            ? 'Use Face ID to access your enterprise account'
            : 'Place your finger on the sensor to access your enterprise account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Success - provide haptic feedback
        HapticFeedback.lightImpact();

        // Navigate to analytics screen after successful authentication
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/analytics-data-screen');
        }
      } else {
        _handleAuthenticationFailure('Authentication was cancelled');
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    } catch (e) {
      _handleAuthenticationFailure('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _handlePlatformException(PlatformException e) {
    String errorMessage;

    switch (e.code) {
      case 'NotAvailable':
        errorMessage = _isIOS
            ? 'Face ID is not available'
            : 'Fingerprint authentication is not available';
        break;
      case 'NotEnrolled':
        errorMessage = _isIOS
            ? 'No Face ID enrolled. Please set up Face ID in Settings'
            : 'No fingerprints enrolled. Please set up fingerprint in Settings';
        break;
      case 'LockedOut':
        errorMessage = _isIOS
            ? 'Face ID is locked. Please use passcode'
            : 'Fingerprint is locked. Please use PIN or password';
        setState(() {
          _isLockedOut = true;
        });
        break;
      case 'PermanentlyLockedOut':
        errorMessage = 'Biometric authentication is permanently locked';
        setState(() {
          _isLockedOut = true;
        });
        break;
      case 'BiometricNotRecognized':
        _failedAttempts++;
        if (_failedAttempts >= 3) {
          errorMessage =
              'Multiple failed attempts. Please use password instead';
          setState(() {
            _isLockedOut = true;
          });
        } else {
          errorMessage = _isIOS
              ? 'Face not recognized. Try again'
              : 'Fingerprint not recognized. Try again';
        }
        break;
      default:
        errorMessage = 'Authentication failed. Please try again';
        break;
    }

    _handleAuthenticationFailure(errorMessage);
  }

  void _handleAuthenticationFailure(String message) {
    HapticFeedback.heavyImpact();
    setState(() {
      _errorMessage = message;
    });
  }

  void _usePasswordFallback() {
    // Navigate back to Azure AD login for password authentication
    Navigator.pushReplacementNamed(context, '/azure-ad-login-screen');
  }

  void _retryAuthentication() {
    setState(() {
      _errorMessage = null;
      _failedAttempts = 0;
      _isLockedOut = false;
    });
    _authenticateWithBiometrics();
  }

  String get _instructionText {
    if (_isLockedOut) {
      return 'Biometric authentication is temporarily locked';
    }

    return _isIOS
        ? 'Use Face ID to access your account'
        : 'Place your finger on the sensor to authenticate';
  }

  String get _buttonText {
    if (_isLockedOut) {
      return 'Authentication Locked';
    }

    return _isIOS
        ? 'Authenticate with Face ID'
        : 'Authenticate with Fingerprint';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface,
                  colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100.h -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: CustomIconWidget(
                                  iconName: 'arrow_back_ios',
                                  color: colorScheme.onSurface,
                                  size: 5.w,
                                ),
                                tooltip: 'Back',
                              ),
                              Expanded(
                                child: Text(
                                  'Secure Authentication',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w), // Balance the back button
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Enterprise Logo/Brand
                          Container(
                            width: 20.w,
                            height: 20.w,
                            margin: EdgeInsets.only(bottom: 4.h),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: 'business',
                                color: colorScheme.primary,
                                size: 10.w,
                              ),
                            ),
                          ),

                          // App Title
                          Text(
                            'EnterpriseHub',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Subtitle
                          Text(
                            'Secure access to your business data',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),

                          SizedBox(height: 6.h),

                          // Biometric Icon
                          BiometricIconWidget(
                            isAuthenticating: _isAuthenticating,
                            isIOS: _isIOS,
                          ),

                          SizedBox(height: 4.h),

                          // Instruction Text
                          SizedBox(
                            width: 80.w,
                            child: Text(
                              _instructionText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ),

                          SizedBox(height: 4.h),

                          // Error Message
                          ErrorMessageWidget(
                            errorMessage: _errorMessage,
                            onRetry: _isAvailable && !_isLockedOut
                                ? _retryAuthentication
                                : null,
                          ),

                          SizedBox(height: 4.h),

                          // Authentication Button
                          AuthenticationButtonWidget(
                            isLoading: _isAuthenticating,
                            onPressed: _isAvailable && !_isLockedOut
                                ? _authenticateWithBiometrics
                                : () {},
                            buttonText: _buttonText,
                          ),

                          SizedBox(height: 3.h),

                          // Fallback Option
                          FallbackOptionWidget(
                            onPressed: _usePasswordFallback,
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'shield',
                                color: colorScheme.primary,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Enterprise Security',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Your biometric data is stored securely on your device',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
