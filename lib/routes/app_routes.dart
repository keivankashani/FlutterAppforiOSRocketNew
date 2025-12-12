import 'package:flutter/material.dart';
import '../presentation/biometric_authentication_screen/biometric_authentication_screen.dart';
import '../presentation/ai_chat_interface_screen/ai_chat_interface_screen.dart';
import '../presentation/analytics_data_screen/analytics_data_screen.dart';
import '../presentation/azure_ad_login_screen/azure_ad_login_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String biometricAuthentication =
      '/biometric-authentication-screen';
  static const String aiChatInterface = '/ai-chat-interface-screen';
  static const String analyticsData = '/analytics-data-screen';
  static const String azureAdLogin = '/azure-ad-login-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const AzureAdLoginScreen(),
    biometricAuthentication: (context) => const BiometricAuthenticationScreen(),
    aiChatInterface: (context) => const AiChatInterfaceScreen(),
    analyticsData: (context) => const AnalyticsDataScreen(),
    azureAdLogin: (context) => const AzureAdLoginScreen(),
    // TODO: Add your other routes here
  };
}
