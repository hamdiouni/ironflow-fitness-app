#!/usr/bin/env dart
/// Quick command-line test for OpenAI API
/// 
/// Run with: dart test_openai_api.dart

import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  print('🧪 Testing OpenAI API Key...\n');

  // Read API key from .env file
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ Error: .env file not found!');
    print('   Create a .env file with your API key.');
    exit(1);
  }

  final envContent = await envFile.readAsString();
  final apiKeyMatch = RegExp(r'OPENAI_API_KEY=(.+)').firstMatch(envContent);
  
  if (apiKeyMatch == null) {
    print('❌ Error: OPENAI_API_KEY not found in .env file!');
    exit(1);
  }

  final apiKey = apiKeyMatch.group(1)!.trim();
  
  if (apiKey.isEmpty || apiKey == 'your_openai_api_key_here') {
    print('❌ Error: API key is not configured!');
    print('   Replace the placeholder with your real API key.');
    exit(1);
  }

  print('✅ API Key found: ${apiKey.substring(0, 20)}...\n');

  // Test 1: Simple API call
  print('📡 Test 1: Sending test message to OpenAI...');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
    );

    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer $apiKey');

    final body = jsonEncode({
      'model': 'gpt-4',
      'messages': [
        {'role': 'user', 'content': 'Say "API is working!" in exactly those words.'}
      ],
      'temperature': 0.0,
      'max_tokens': 50,
    });

    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final message = data['choices'][0]['message']['content'];
      
      print('✅ Test 1 PASSED!');
      print('   Response: $message\n');
    } else if (response.statusCode == 401) {
      print('❌ Test 1 FAILED!');
      print('   Error: Invalid API key');
      print('   Status: ${response.statusCode}');
      print('   Response: $responseBody\n');
      exit(1);
    } else if (response.statusCode == 429) {
      print('⚠️  Test 1 WARNING!');
      print('   Error: Rate limit exceeded');
      print('   Wait 1 minute and try again\n');
      exit(1);
    } else {
      print('❌ Test 1 FAILED!');
      print('   Status: ${response.statusCode}');
      print('   Response: $responseBody\n');
      exit(1);
    }

    client.close();
  } catch (e) {
    print('❌ Test 1 FAILED!');
    print('   Error: $e\n');
    exit(1);
  }

  // Test 2: Fitness coaching question
  print('📡 Test 2: Testing fitness coaching...');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
    );

    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer $apiKey');

    final body = jsonEncode({
      'model': 'gpt-4',
      'messages': [
        {'role': 'system', 'content': 'You are a professional fitness coach. Be concise.'},
        {'role': 'user', 'content': 'Give me one tip to improve my bench press in 15 words.'}
      ],
      'temperature': 0.7,
      'max_tokens': 100,
    });

    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final message = data['choices'][0]['message']['content'];
      
      print('✅ Test 2 PASSED!');
      print('   Fitness Advice: $message\n');
    } else {
      print('❌ Test 2 FAILED!');
      print('   Status: ${response.statusCode}');
      print('   Response: $responseBody\n');
      exit(1);
    }

    client.close();
  } catch (e) {
    print('❌ Test 2 FAILED!');
    print('   Error: $e\n');
    exit(1);
  }

  // Success!
  print('═══════════════════════════════════════');
  print('🎉 ALL TESTS PASSED!');
  print('═══════════════════════════════════════');
  print('');
  print('Your OpenAI API key is working correctly!');
  print('');
  print('Next steps:');
  print('1. Run: flutter test test/features/ai/ai_service_test.dart');
  print('2. Test in app: Navigate to /ai-test screen');
  print('3. Test AI chat: Navigate to /ai-chat screen');
  print('');
  print('💡 Tip: Monitor your usage at:');
  print('   https://platform.openai.com/usage');
  print('');
}
