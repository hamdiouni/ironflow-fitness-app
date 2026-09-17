# 🆓 Setup FREE AI with Google Gemini

## Why Gemini?

- ✅ **Completely FREE** (no credit card needed)
- ✅ **60 requests per minute** (plenty for testing)
- ✅ **High quality** responses
- ✅ **Easy setup** (5 minutes)
- ✅ **No costs** ever (within free tier)

**vs OpenAI:**
- OpenAI: $0.025 per message ($25 per 1000 messages)
- Gemini: $0 per message ($0 per ∞ messages)

---

## 🚀 Quick Setup (5 minutes)

### Step 1: Get FREE API Key

1. Go to: **https://makersuite.google.com/app/apikey**
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy the key (looks like: `AIzaSy...`)

### Step 2: Add to .env File

Open your `.env` file and add:

```env
# Google Gemini API (FREE!)
GEMINI_API_KEY=AIzaSyYourKeyHere
```

**Note:** You can keep your OpenAI key too if you want to switch between them.

### Step 3: Test It

Run the test script:

```bash
dart test_gemini_api.dart
```

**Expected output:**
```
🧪 Testing Google Gemini API (FREE!)...
✅ API Key found: AIzaSy...
📡 Test 1: Sending test message to Gemini...
✅ Test 1 PASSED!
   Response: Gemini API is working!
📡 Test 2: Testing fitness coaching...
✅ Test 2 PASSED!
   Fitness Advice: Focus on progressive overload...
🎉 ALL TESTS PASSED!
```

---

## 🔄 Switch from OpenAI to Gemini

### Option 1: Update AI Provider (Recommended)

Update `lib/features/ai/presentation/providers/ai_provider.dart`:

```dart
// Change this import
import 'package:progression_tracker/features/ai/data/datasources/gemini_ai_service.dart';

// Change the provider
final aiServiceProvider = Provider<GeminiAIService>((ref) {
  return GeminiAIService();
});
```

### Option 2: Create Hybrid Service

Use Gemini for free users, OpenAI for premium:

```dart
class HybridAIService {
  final GeminiAIService _gemini = GeminiAIService();
  final AIService _openai = AIService();
  
  Future<String> sendMessage(
    List<Map<String, String>> messages, {
    required bool isPremium,
  }) async {
    if (isPremium) {
      return _openai.sendMessage(messages);
    } else {
      return _gemini.sendMessage(messages);
    }
  }
}
```

---

## 📊 Gemini vs OpenAI Comparison

| Feature | Gemini (Free) | OpenAI GPT-4 |
|---------|---------------|--------------|
| **Cost** | $0 | $0.025/msg |
| **Quality** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Speed** | Fast | Fast |
| **Rate Limit** | 60/min | 3/min (free) |
| **Daily Limit** | 1500/day | 200/day (free) |
| **Setup** | Easy | Easy |
| **Credit Card** | Not required | Required |

**Verdict:** Gemini is perfect for testing and early users!

---

## 🎯 Rate Limits

### Free Tier:
- **60 requests per minute**
- **1500 requests per day**

### What this means:
- 1 user sending 10 messages = 10 requests
- 60 req/min = 6 users sending 10 messages each
- 1500 req/day = 150 users sending 10 messages each

**Conclusion:** Free tier is enough for:
- ✅ Testing and development
- ✅ First 100-200 users
- ✅ MVP launch

---

## 💡 Best Practices

### 1. Cache Common Responses
```dart
final cache = <String, String>{};

Future<String> getCachedResponse(String query) async {
  if (cache.containsKey(query)) {
    return cache[query]!;
  }
  
  final response = await geminiService.sendMessage([
    {'role': 'user', 'content': query}
  ]);
  
  cache[query] = response;
  return response;
}
```

### 2. Rate Limit Users
```dart
// Free users: 5 messages per week
// Premium users: Unlimited (or use OpenAI)

class MessageLimiter {
  final Map<String, int> _userCounts = {};
  
  bool canSendMessage(String userId, bool isPremium) {
    if (isPremium) return true;
    
    final count = _userCounts[userId] ?? 0;
    return count < 5; // 5 messages per week
  }
}
```

### 3. Handle Rate Limits
```dart
try {
  final response = await geminiService.sendMessage(messages);
  return response;
} on GeminiAIServiceException catch (e) {
  if (e.code == 'RATE_LIMIT') {
    // Wait and retry
    await Future.delayed(Duration(seconds: 60));
    return await geminiService.sendMessage(messages);
  }
  rethrow;
}
```

---

## 🔧 Troubleshooting

### Error: "Invalid API key"

**Solution:**
1. Go to: https://makersuite.google.com/app/apikey
2. Make sure API is enabled
3. Create a new key if needed
4. Update `.env` file

### Error: "Rate limit exceeded"

**Solution:**
- Free tier: 60 requests/minute
- Wait 1 minute and try again
- Implement rate limiting in your app

### Error: "API not enabled"

**Solution:**
1. Go to: https://console.cloud.google.com/
2. Enable "Generative Language API"
3. Try again

---

## 📈 Scaling Strategy

### Phase 1: Testing (Now)
- Use Gemini free tier
- 0-200 users
- $0 cost

### Phase 2: Early Users (Month 1-3)
- Gemini for free users (5 msg/week)
- OpenAI for premium users (unlimited)
- ~$50-100/month

### Phase 3: Growth (Month 4-12)
- Gemini for free users
- OpenAI for premium users
- Consider Gemini paid tier if needed
- ~$200-500/month

---

## ✅ Setup Checklist

- [ ] Got Gemini API key from https://makersuite.google.com/app/apikey
- [ ] Added `GEMINI_API_KEY` to `.env` file
- [ ] Ran `dart test_gemini_api.dart` successfully
- [ ] Updated AI provider to use Gemini
- [ ] Tested in app (sent message in AI chat)
- [ ] Verified response quality
- [ ] Implemented rate limiting
- [ ] Set up error handling

---

## 🎉 You're Done!

Your app now uses **FREE AI** with Google Gemini!

**Next steps:**
1. Test in your app
2. Implement freemium model (5 free messages/week)
3. Add premium tier with OpenAI for power users
4. Monitor usage and scale as needed

**Questions?**
- Gemini Docs: https://ai.google.dev/docs
- API Key: https://makersuite.google.com/app/apikey
- Rate Limits: https://ai.google.dev/pricing

---

**💰 Cost Savings: 100%**

You're now using completely free AI instead of paying $25 per 1000 messages!
