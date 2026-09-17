# OpenAI API Testing Guide

Your OpenAI API key is now configured! Here's how to test it.

## ✅ Your API Key

**Status**: Configured in `.env` file  
**Key**: `[REDACTED - See your .env file]`

**⚠️ IMPORTANT**: Never commit this key to Git! It's already in `.gitignore`.

---

## Method 1: Run Automated Tests (Recommended)

### Step 1: Run the test file

```bash
flutter test test/features/ai/ai_service_test.dart
```

### What it tests:
1. ✅ API key is configured
2. ✅ Can send a simple message
3. ✅ Can get fitness coaching advice
4. ✅ Handles invalid API keys gracefully

### Expected output:
```
✅ API Response: Hello from IronFlow!
✅ Fitness Advice: Focus on progressive overload...
✅ All tests passed!
```

---

## Method 2: Test in the App (Interactive)

### Step 1: Add test route to your router

Open `lib/core/router/app_router.dart` and add this route:

```dart
// Add this import at the top
import '../../features/ai/presentation/screens/ai_test_screen.dart';

// Add this route in your routes list
GoRoute(
  path: '/ai-test',
  builder: (context, state) => const AITestScreen(),
),
```

### Step 2: Navigate to the test screen

Add a button somewhere in your app (e.g., Profile screen) or navigate directly:

```dart
context.push('/ai-test');
```

### Step 3: Run quick tests

1. Open the test screen
2. Tap the **science icon** (🧪) in the app bar
3. Watch the automated tests run
4. See results in real-time

### Step 4: Test manually

1. Type a message like "Give me a workout tip"
2. Tap send
3. Wait for AI response (5-10 seconds)
4. Verify you get a real response

---

## Method 3: Test in AI Chat Screen (Production)

### Step 1: Navigate to AI Chat

```dart
context.push('/ai-chat');
```

### Step 2: Send a test message

Try these test messages:
- "Hello, are you working?"
- "Give me a tip to improve my bench press"
- "Analyze my workout progress"

### Expected behavior:
- ✅ Message appears in chat
- ✅ Loading indicator shows
- ✅ AI response appears in 5-10 seconds
- ✅ Response is relevant and helpful

---

## Troubleshooting

### Error: "OpenAI API key not configured"

**Solution**: Make sure `.env` file exists and has the API key:
```bash
# Check if .env exists
ls -la .env

# Check content
cat .env
```

### Error: "Invalid API key"

**Possible causes**:
1. API key is incorrect (typo)
2. API key has been revoked
3. API key doesn't have permissions

**Solution**: 
1. Go to https://platform.openai.com/api-keys
2. Verify your key is active
3. Generate a new key if needed
4. Update `.env` file

### Error: "Rate limit exceeded"

**Cause**: You've sent too many requests

**Solution**: 
- Wait 1 minute and try again
- OpenAI free tier has limits:
  - 3 requests per minute
  - 200 requests per day

### Error: "Request timeout"

**Cause**: Network is slow or OpenAI is down

**Solution**:
- Check your internet connection
- Try again in a few seconds
- Check OpenAI status: https://status.openai.com/

### Error: "Insufficient quota"

**Cause**: Your OpenAI account has no credits

**Solution**:
1. Go to https://platform.openai.com/account/billing
2. Add payment method
3. Add credits ($5 minimum)

---

## API Usage & Costs

### Current Configuration:
- **Model**: GPT-4
- **Max tokens**: 2000 per response
- **Temperature**: 0.7 (balanced creativity)

### Estimated Costs:
- **GPT-4**: $0.03 per 1K input tokens, $0.06 per 1K output tokens
- **Average message**: ~500 tokens total
- **Cost per message**: ~$0.025 (2.5 cents)
- **100 messages**: ~$2.50
- **1000 messages**: ~$25

### Cost Optimization Tips:

1. **Use GPT-3.5-turbo for testing** (10x cheaper):
```dart
// In ai_service.dart, change:
static const String _model = 'gpt-3.5-turbo'; // Instead of 'gpt-4'
```

2. **Reduce max tokens**:
```dart
maxTokens: 500, // Instead of 2000
```

3. **Cache common responses** (implement later)

4. **Rate limit users**:
- Free: 5 messages per week
- Premium: Unlimited

---

## Next Steps

### 1. Test the API (Do this now!)

Run one of the test methods above to verify everything works.

### 2. Monitor Usage

Check your usage at: https://platform.openai.com/usage

### 3. Set Spending Limits

1. Go to https://platform.openai.com/account/billing/limits
2. Set a monthly budget (e.g., $10)
3. Get email alerts at 75% and 100%

### 4. Implement Freemium

Once testing is done, implement the freemium model:
- Free users: 5 AI messages per week
- Premium users: Unlimited messages

### 5. Add Error Handling

Make sure your app handles all error cases gracefully:
- Invalid API key
- Rate limits
- Network errors
- Quota exceeded

---

## Quick Test Commands

```bash
# Test 1: Run automated tests
flutter test test/features/ai/ai_service_test.dart

# Test 2: Run app and navigate to test screen
flutter run
# Then navigate to /ai-test

# Test 3: Check API key is loaded
flutter run
# Check console for any .env loading errors

# Test 4: Run app in debug mode and check logs
flutter run --verbose
# Look for "OpenAI API" in logs
```

---

## Success Checklist

- [ ] API key is in `.env` file
- [ ] `.env` is in `.gitignore`
- [ ] Automated tests pass
- [ ] Can send message in test screen
- [ ] Can send message in AI chat screen
- [ ] AI responses are relevant
- [ ] Error handling works
- [ ] Usage monitoring is set up
- [ ] Spending limits are configured

---

## Support

If you encounter issues:

1. **Check OpenAI Status**: https://status.openai.com/
2. **Check API Key**: https://platform.openai.com/api-keys
3. **Check Usage**: https://platform.openai.com/usage
4. **Check Billing**: https://platform.openai.com/account/billing

---

**🎉 Your AI is ready to use!**

Once you've verified it works, you can start building the premium AI coaching features from the product improvement plan.
