#!/usr/bin/env dart
/// Quick command-line test for Google Gemini API (FREE!)
/// 
/// Run with: dart test_gemini_api.dart

import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  print('🧪 Testing Google Gemini API (FREE!)...\n');

  // Read API key from .env file
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ Error: .env file not found!');
    print('   Create a .env file with your Gemini API key.');
    exit(1);
  }

  final envContent = await envFile.readAsString();
  final apiKeyMatch = RegExp(r'GEMINI_API_KEY=(.+)').firstMatch(envContent);
  
  if (apiKeyMatch == null) {
    print('❌ Error: GEMINI_API_KEY not found in .env file!');
    print('');
    print('Get your FREE API key:');
    print('1. Go to: https://makersuite.google.com/app/apikey');
    print('2. Click "Create API Key"');
    print('3. Copy the key');
    print('4. Add to .env: GEMINI_API_KEY=your_key_here');
    exit(1);
  }

  final apiKey = apiKeyMatch.group(1)!.trim();
  
  if (apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
    print('❌ Error: Gemini API key is not configured!');
    print('');
    print('Get your FREE API key:');
    print('1. Go to: https://makersuite.google.com/app/apikey');
    print('2. Click "Create API Key"');
    print('3. Copy the key');
    print('4. Replace placeholder in .env file');
    exit(1);
  }

  print('✅ API Key found: ${apiKey.substring(0, 20)}...\n');

  // Test 1: Simple API call
  print('📡 Test 1: Sending test message to Gemini...');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'),
    );

    request.headers.set('Content-Type', 'application/json');

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': 'Say "Gemini API is working!" in exactly those words.'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.0,
        'maxOutputTokens': 50,
      },
    });

    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      
      print('✅ Test 1 PASSED!');
      print('   Response: $text\n');
    } else if (response.statusCode == 403) {
      print('❌ Test 1 FAILED!');
      print('   Error: Invalid API key or API not enabled');
      print('   Status: ${response.statusCode}');
      print('');
      print('Get your FREE API key:');
      print('https://makersuite.google.com/app/apikey');
      print('');
      exit(1);
    } else if (response.statusCode == 429) {
      print('⚠️  Test 1 WARNING!');
      print('   Error: Rate limit exceeded');
      print('   Free tier: 60 requests per minute');
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
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'),
    );

    request.headers.set('Content-Type', 'application/json');

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': 'You are a professional fitness coach. Give me one specific tip to improve my bench press in 20 words or less.'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 100,
      },
    });

    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      
      print('✅ Test 2 PASSED!');
      print('   Fitness Advice: $text\n');
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
  print('Your FREE Gemini API is working correctly!');
  print('');
  print('Benefits:');
  print('✅ Completely FREE (no costs)');
  print('✅ 60 requests per minute');
  print('✅ 1500 requests per day');
  print('✅ High quality responses');
  print('✅ No credit card required');
  print('');
  print('Next steps:');
  print('1. Update your AI provider to use Gemini');
  print('2. Test in app: Navigate to /ai-chat');
  print('3. Enjoy free AI coaching!');
  print('');
  print('💡 Rate limits:');
  print('   - 60 requests/minute (plenty for testing)');
  print('   - 1500 requests/day (150-300 users/day)');
  print('');
}
