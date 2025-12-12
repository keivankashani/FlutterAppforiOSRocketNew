import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/chat_header_widget.dart';
import './widgets/chat_input_widget.dart';
import './widgets/conversation_list_widget.dart';

class AiChatInterfaceScreen extends StatefulWidget {
  const AiChatInterfaceScreen({super.key});

  @override
  State<AiChatInterfaceScreen> createState() => _AiChatInterfaceScreenState();
}

class _AiChatInterfaceScreenState extends State<AiChatInterfaceScreen>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isOnline = true;
  final String _conversationTitle = 'AI Assistant';

  // Mock conversation data
  final List<Map<String, dynamic>> _mockMessages = [
    {
      'id': '1',
      'content':
          'Hello! I\'m your AI business assistant. How can I help you today?',
      'isUser': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'status': 'delivered',
      'quickActions': [
        {
          'label': 'View Analytics',
          'type': 'navigate',
          'data': '/analytics-data-screen',
        },
        {
          'label': 'Show Reports',
          'type': 'navigate',
          'data': '/analytics-data-screen',
        },
      ],
    },
    {
      'id': '2',
      'content': 'Can you show me the latest sales performance data?',
      'isUser': true,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
      'status': 'delivered',
    },
    {
      'id': '3',
      'content':
          'Based on your latest data, sales have increased by 15% this quarter. Revenue is up \$45,000 compared to last quarter. Your top performing products are Enterprise Software licenses and Professional Services.',
      'isUser': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
      'status': 'delivered',
      'quickActions': [
        {
          'label': 'View Details',
          'type': 'navigate',
          'data': '/analytics-data-screen',
        },
        {
          'label': 'Export Report',
          'type': 'copy',
          'data': 'Sales Performance Report - Q4 2024',
        },
      ],
    },
    {
      'id': '4',
      'content': 'What are the key areas I should focus on for improvement?',
      'isUser': true,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
      'status': 'delivered',
    },
    {
      'id': '5',
      'content':
          'I recommend focusing on these key areas:\n\n1. **Customer Retention**: Your churn rate is 8%, industry average is 5%\n2. **Marketing ROI**: Digital campaigns show 23% better conversion\n3. **Product Development**: Feature requests indicate demand for mobile app\n4. **Team Productivity**: Consider automation for routine tasks',
      'isUser': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 1)),
      'status': 'delivered',
      'quickActions': [
        {
          'label': 'Create Action Plan',
          'type': 'regenerate',
          'data': null,
        },
        {
          'label': 'Share Insights',
          'type': 'copy',
          'data': 'Business Improvement Recommendations',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadConversationHistory();
    _checkConnectivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Handle keyboard appearance/disappearance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }

  void _loadConversationHistory() {
    // Simulate loading conversation history from local cache
    setState(() {
      _messages = List.from(_mockMessages);
    });
  }

  void _checkConnectivity() {
    // Simulate connectivity check
    setState(() {
      _isOnline = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          ChatHeaderWidget(
            title: _conversationTitle,
            subtitle: _isOnline
                ? 'Online • Ready to help'
                : 'Offline • Limited functionality',
            isOnline: _isOnline,
            onSettingsTap: _showChatSettings,
            onHistoryTap: _showChatHistory,
          ),
          Expanded(
            child: ConversationListWidget(
              messages: _messages,
              isLoading: _isLoading,
              scrollController: _scrollController,
              onRefresh: _refreshConversation,
              onRegenerateResponse: _regenerateResponse,
            ),
          ),
          ChatInputWidget(
            controller: _messageController,
            isLoading: _isLoading,
            isEnabled: _isOnline,
            onSend: _sendMessage,
            onAttachment: _handleAttachment,
            onVoiceInput: _handleVoiceInput,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isLoading) return;

    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': messageText,
      'isUser': true,
      'timestamp': DateTime.now(),
      'status': 'sending',
    };

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    _simulateAIResponse(messageText);

    // Update message status
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          final index =
              _messages.indexWhere((m) => m['id'] == userMessage['id']);
          if (index != -1) {
            _messages[index]['status'] = 'delivered';
          }
        });
      }
    });
  }

  void _simulateAIResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      String aiResponse = _generateAIResponse(userMessage);

      final aiMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': aiResponse,
        'isUser': false,
        'timestamp': DateTime.now(),
        'status': 'delivered',
        'quickActions': _generateQuickActions(userMessage),
      };

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();
      HapticFeedback.lightImpact();
    });
  }

  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('analytics') || lowerMessage.contains('data')) {
      return 'I can help you with analytics! Your current metrics show strong performance with 23% growth in user engagement and \$127K revenue this month. Would you like me to show you the detailed analytics dashboard?';
    } else if (lowerMessage.contains('sales') ||
        lowerMessage.contains('revenue')) {
      return 'Your sales performance is trending upward! This quarter shows a 15% increase with \$45,000 additional revenue. Top performers include Enterprise licenses (35% of sales) and Professional Services (28% of sales).';
    } else if (lowerMessage.contains('help') ||
        lowerMessage.contains('support')) {
      return 'I\'m here to assist you with:\n• Business analytics and insights\n• Sales performance data\n• Market trends analysis\n• Operational recommendations\n• Financial reporting\n\nWhat specific area would you like to explore?';
    } else if (lowerMessage.contains('report') ||
        lowerMessage.contains('export')) {
      return 'I can generate various reports for you:\n• Sales Performance Report\n• Customer Analytics Report\n• Financial Summary Report\n• Operational Metrics Report\n\nWhich report would you like me to prepare?';
    } else {
      return 'Thank you for your question! Based on your business data, I can provide insights and recommendations. Could you be more specific about what information you\'re looking for? I can help with analytics, sales data, reports, or general business insights.';
    }
  }

  List<Map<String, dynamic>>? _generateQuickActions(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('analytics') || lowerMessage.contains('data')) {
      return [
        {
          'label': 'View Dashboard',
          'type': 'navigate',
          'data': '/analytics-data-screen',
        },
        {
          'label': 'Export Data',
          'type': 'copy',
          'data': 'Analytics Export Request',
        },
      ];
    } else if (lowerMessage.contains('sales') ||
        lowerMessage.contains('revenue')) {
      return [
        {
          'label': 'Sales Details',
          'type': 'navigate',
          'data': '/analytics-data-screen',
        },
        {
          'label': 'Share Report',
          'type': 'copy',
          'data': 'Sales Performance Summary',
        },
      ];
    }

    return [
      {
        'label': 'More Info',
        'type': 'regenerate',
        'data': null,
      },
    ];
  }

  void _regenerateResponse(Map<String, dynamic> message) {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Find the user message that prompted this AI response
    final messageIndex = _messages.indexOf(message);
    String userPrompt = 'Please provide more details';

    if (messageIndex > 0) {
      final previousMessage = _messages[messageIndex - 1];
      if (previousMessage['isUser'] == true) {
        userPrompt = previousMessage['content'] as String;
      }
    }

    // Remove the old AI response
    setState(() {
      _messages.remove(message);
    });

    // Generate new response
    _simulateAIResponse('$userPrompt (regenerate with more details)');
  }

  void _handleAttachment() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'insert_drive_file',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _handleDocumentSelection();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _handleCameraCapture();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _handleImageSelection() {
    // Simulate image selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image selection feature coming soon')),
    );
  }

  void _handleDocumentSelection() {
    // Simulate document selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document selection feature coming soon')),
    );
  }

  void _handleCameraCapture() {
    // Simulate camera capture
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera capture feature coming soon')),
    );
  }

  void _handleVoiceInput() {
    // Simulate voice input
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice input feature coming soon')),
    );
  }

  void _showChatSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'clear_all',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Clear Conversation'),
              onTap: () {
                Navigator.pop(context);
                _clearConversation();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Export Chat'),
              onTap: () {
                Navigator.pop(context);
                _exportChat();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: const Text('Chat Preferences'),
              onTap: () {
                Navigator.pop(context);
                _showChatPreferences();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showChatHistory() {
    Navigator.pushNamed(context, '/ai-chat-interface-screen');
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text(
            'Are you sure you want to clear this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _exportChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat export feature coming soon')),
    );
  }

  void _showChatPreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat preferences feature coming soon')),
    );
  }

  Future<void> _refreshConversation() async {
    // Simulate refreshing conversation from server
    await Future.delayed(const Duration(seconds: 1));
    _checkConnectivity();
  }

  void _scrollToBottom() {
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
}
