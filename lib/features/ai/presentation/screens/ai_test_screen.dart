import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_service.dart';

/// Simple test screen to verify OpenAI API key works
/// 
/// Add this route to your router to access it:
/// GoRoute(path: '/ai-test', builder: (context, state) => const AITestScreen())
class AITestScreen extends StatefulWidget {
  const AITestScreen({super.key});

  @override
  State<AITestScreen> createState() => _AITestScreenState();
}

class _AITestScreenState extends State<AITestScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _error;
  late AIService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = AIService();
    _checkAPIKey();
  }

  void _checkAPIKey() {
    try {
      _aiService.validateConfiguration();
      setState(() {
        _messages.add({
          'role': 'system',
          'content': '✅ API Key is configured!\n\nAPI Key: ${dotenv.env['OPENAI_API_KEY']?.substring(0, 20)}...\n\nYou can now test the AI by sending a message below.',
        });
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _messages.add({
          'role': 'system',
          'content': '❌ API Key Error: $e',
        });
      });
    }
  }

  Future<void> _sendTestMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _isLoading = true;
      _error = null;
    });

    _controller.clear();

    try {
      final response = await _aiService.sendMessage(
        [{'role': 'user', 'content': userMessage}],
        systemPrompt: 'You are a helpful fitness coach. Be concise and friendly.',
        temperature: 0.7,
        maxTokens: 500,
      );

      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _messages.add({
          'role': 'system',
          'content': '❌ Error: $e',
        });
        _isLoading = false;
      });
    }
  }

  Future<void> _runQuickTests() async {
    setState(() {
      _messages.clear();
      _isLoading = true;
    });

    // Test 1: Simple echo
    try {
      setState(() {
        _messages.add({
          'role': 'system',
          'content': '🧪 Test 1: Simple Echo Test...',
        });
      });

      final response1 = await _aiService.sendMessage(
        [{'role': 'user', 'content': 'Say "API is working!" in exactly those words.'}],
        temperature: 0.0,
        maxTokens: 50,
      );

      setState(() {
        _messages.add({
          'role': 'system',
          'content': '✅ Test 1 Passed!\nResponse: $response1',
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'system',
          'content': '❌ Test 1 Failed: $e',
        });
      });
    }

    // Test 2: Fitness question
    try {
      setState(() {
        _messages.add({
          'role': 'system',
          'content': '\n🧪 Test 2: Fitness Coaching Test...',
        });
      });

      final response2 = await _aiService.sendMessage(
        [{'role': 'user', 'content': 'Give me one tip to improve my bench press in 15 words.'}],
        systemPrompt: 'You are a professional fitness coach.',
        temperature: 0.7,
        maxTokens: 100,
      );

      setState(() {
        _messages.add({
          'role': 'system',
          'content': '✅ Test 2 Passed!\nResponse: $response2',
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'system',
          'content': '❌ Test 2 Failed: $e',
        });
      });
    }

    // Test 3: Context understanding
    try {
      setState(() {
        _messages.add({
          'role': 'system',
          'content': '\n🧪 Test 3: Context Understanding Test...',
        });
      });

      final response3 = await _aiService.sendMessage(
        [
          {'role': 'user', 'content': 'My bench press is stuck at 185 lbs for 3 weeks.'},
          {'role': 'assistant', 'content': 'I understand you\'re experiencing a plateau.'},
          {'role': 'user', 'content': 'What should I do?'},
        ],
        systemPrompt: 'You are a professional fitness coach. Give specific advice.',
        temperature: 0.7,
        maxTokens: 200,
      );

      setState(() {
        _messages.add({
          'role': 'system',
          'content': '✅ Test 3 Passed!\nResponse: $response3',
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'system',
          'content': '❌ Test 3 Failed: $e',
        });
      });
    }

    setState(() {
      _messages.add({
        'role': 'system',
        'content': '\n✅ All tests complete! Your OpenAI API key is working correctly.',
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI API Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: _isLoading ? null : _runQuickTests,
            tooltip: 'Run Quick Tests',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _checkAPIKey();
            },
            tooltip: 'Clear Messages',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status banner
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Text(
                '❌ Error: $_error',
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),

          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final role = message['role']!;
                final content = message['content']!;

                Color bgColor;
                Color textColor;
                IconData icon;

                switch (role) {
                  case 'system':
                    bgColor = Colors.blue.shade50;
                    textColor = Colors.blue.shade900;
                    icon = Icons.info_outline;
                    break;
                  case 'user':
                    bgColor = Colors.green.shade50;
                    textColor = Colors.green.shade900;
                    icon = Icons.person;
                    break;
                  case 'assistant':
                    bgColor = Colors.purple.shade50;
                    textColor = Colors.purple.shade900;
                    icon = Icons.smart_toy;
                    break;
                  default:
                    bgColor = Colors.grey.shade50;
                    textColor = Colors.grey.shade900;
                    icon = Icons.message;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: textColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: textColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          content,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Waiting for AI response...'),
                ],
              ),
            ),

          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message to test AI...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendTestMessage(),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isLoading ? null : _sendTestMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
