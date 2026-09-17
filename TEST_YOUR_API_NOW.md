# 🚀 Test Your OpenAI API Key NOW

## ⚡ Fastest Test (10 seconds)

Open your terminal and run:

```bash
dart test_openai_api.dart
```

That's it! You'll see if your API key works.

---

## 📊 Expected Results

### ✅ If it works:
```
🧪 Testing OpenAI API Key...

✅ API Key found: sk-proj-JZNzMcsDWh1i...

📡 Test 1: Sending test message to OpenAI...
✅ Test 1 PASSED!
   Response: API is working!

📡 Test 2: Testing fitness coaching...
✅ Test 2 PASSED!
   Fitness Advice: Focus on progressive overload by adding 2.5-5 lbs weekly to your lifts.

═══════════════════════════════════════
🎉 ALL TESTS PASSED!
═══════════════════════════════════════

Your OpenAI API key is working correctly!
```

### ❌ If it fails:

**Error: "API key not configured"**
```
❌ Error: OPENAI_API_KEY not found in .env file!
```
**Fix:** Check your `.env` file has the API key

**Error: "Invalid API key"**
```
❌ Test 1 FAILED!
   Error: Invalid API key
   Status: 401
```
**Fix:** Your API key is wrong. Get a new one from https://platform.openai.com/api-keys

**Error: "Rate limit exceeded"**
```
⚠️  Test 1 WARNING!
   Error: Rate limit exceeded
   Wait 1 minute and try again
```
**Fix:** Wait 60 seconds and try again (free tier limit: 3 requests/minute)

---

## 🎯 What Happens Next?

Once the test passes, you can:

### 1. Test in Your App

Run your app and navigate to the AI Chat screen:

```bash
flutter run
```

Then in the app:
1. Go to Profile → AI Chat (or navigate to `/ai-chat`)
2. Type: "Hello, are you working?"
3. Wait 5-10 seconds
4. You should get a response!

### 2. Run Full Test Suite

```bash
flutter test test/features/ai/ai_service_test.dart
```

This runs 3 automated tests to verify everything works.

---

## 💡 Quick Tips

### Your API Key
- **Location:** `.env` file
- **Format:** `OPENAI_API_KEY=sk-proj-...`
- **Security:** Never commit to Git (already in `.gitignore`)

### Costs
- **Per message:** ~$0.025 (2.5 cents)
- **100 messages:** ~$2.50
- **Monitor at:** https://platform.openai.com/usage

### Rate Limits (Free Tier)
- **3 requests per minute**
- **200 requests per day**

If you hit the limit, wait 1 minute and try again.

---

## 🆘 Need Help?

### Check API Key Status
https://platform.openai.com/api-keys

### Check Usage
https://platform.openai.com/usage

### Check Billing
https://platform.openai.com/account/billing

### OpenAI Status
https://status.openai.com/

---

## ✅ Success Checklist

- [ ] Ran `dart test_openai_api.dart`
- [ ] Both tests passed
- [ ] Tested in AI Chat screen
- [ ] Got a real AI response
- [ ] Set up usage monitoring
- [ ] Set spending limits ($10/month recommended)

---

## 🎉 You're Done!

Your OpenAI API is working. Now you can:

1. Build the premium AI coaching features
2. Implement the freemium model (5 free messages/week)
3. Add advanced AI features from the product improvement plan

**Read the full guide:** `OPENAI_API_TEST_GUIDE.md`

---

**Ready? Run this now:**

```bash
dart test_openai_api.dart
```

🚀 Let's go!
