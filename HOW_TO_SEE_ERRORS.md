# 🔍 How to See Errors in Browser Console

**Updated**: May 2, 2026  
**Status**: Comprehensive error logging added ✅

---

## ✅ What I Added

### Detailed Error Logging in:

1. **AI Provider** (`lib/features/ai/presentation/providers/ai_provider.dart`)
   - Step-by-step processing logs
   - Detailed error messages with stack traces
   - Clear visual separators

2. **Gemini Service** (`lib/features/ai/data/datasources/gemini_ai_service.dart`)
   - API call logging
   - HTTP status code details
   - Response parsing logs
   - Error categorization

---

## 🌐 How to Open Browser Console

### Method 1: Keyboard Shortcut
- **Windows/Linux**: Press `F12`
- **Mac**: Press `Cmd + Option + I`

### Method 2: Right-Click Menu
1. Right-click anywhere on the page
2. Click "Inspect" or "Inspect Element"
3. Click the "Console" tab

### Method 3: Chrome Menu
1. Click the three dots (⋮) in top-right
2. More Tools → Developer Tools
3. Click "Console" tab

---

## 📊 What You'll See in Console

### When Everything Works ✅:

```
═══════════════════════════════════════
🚀 [AI CHAT] Starting message processing
📝 [AI CHAT] User message: Hello, are you working?
═══════════════════════════════════════
📊 [AI CHAT] Step 1: Gathering user data...
👤 [AI CHAT] Step 2: Getting user profile...
✅ [AI CHAT] User profile: John Doe
🏋️ [AI CHAT] Step 3: Getting recent workouts...
✅ [AI CHAT] Found 0 workouts
🍎 [AI CHAT] Step 4: Getting nutrition history...
✅ [AI CHAT] Found 0 nutrition days
📏 [AI CHAT] Step 5: Getting body measurements...
✅ [AI CHAT] Found 0 body entries
🔧 [AI CHAT] Step 6: Building system prompt...
✅ [AI CHAT] System prompt built (450 chars)
═══════════════════════════════════════
🤖 [AI CHAT] Step 7: Calling Gemini AI (FREE!)
📡 [AI CHAT] Sending request to Gemini API...
═══════════════════════════════════════
🔧 [GEMINI SERVICE] Starting API call
═══════════════════════════════════════
🔑 [GEMINI SERVICE] Validating API key...
✅ [GEMINI SERVICE] API key validated
🔄 [GEMINI SERVICE] Converting messages to Gemini format...
✅ [GEMINI SERVICE] Converted 3 messages
📦 [GEMINI SERVICE] Request body prepared
🌐 [GEMINI SERVICE] API URL: https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent
📡 [GEMINI SERVICE] Sending HTTP POST request...
📨 [GEMINI SERVICE] Response received
📊 [GEMINI SERVICE] Status code: 200
📏 [GEMINI SERVICE] Response length: 1234 bytes
✅ [GEMINI SERVICE] Success! Parsing response...
═══════════════════════════════════════
🎉 [GEMINI SERVICE] Success!
📝 [GEMINI SERVICE] Response text length: 250 chars
💬 [GEMINI SERVICE] Preview: Yes! I'm your AI fitness coach powered by Gemini...
═══════════════════════════════════════
✅ [AI CHAT] Gemini response received!
📝 [AI CHAT] Response length: 250 chars
💬 [AI CHAT] Response preview: Yes! I'm your AI fitness coach...
═══════════════════════════════════════
💾 [AI CHAT] Step 8: Saving response to chat...
═══════════════════════════════════════
🎉 [AI CHAT] Message processing complete!
📊 [AI CHAT] Total messages: 2
═══════════════════════════════════════
```

---

### When Gemini Fails (Fallback to LocalAI) ⚠️:

```
═══════════════════════════════════════
🤖 [AI CHAT] Step 7: Calling Gemini AI (FREE!)
📡 [AI CHAT] Sending request to Gemini API...
═══════════════════════════════════════
❌ [GEMINI SERVICE ERROR] 403 Forbidden - Invalid API key
🔑 [GEMINI SERVICE ERROR] API key used: AIzaSyD8ATUIwoIc2k4F...
═══════════════════════════════════════
❌ [AI CHAT ERROR] Gemini API failed!
🔴 [AI CHAT ERROR] Error type: GeminiAIServiceException
🔴 [AI CHAT ERROR] Error message: Invalid API key or API not enabled.
Get your free key at: https://makersuite.google.com/app/apikey
🔴 [AI CHAT ERROR] Stack trace:
[stack trace lines...]
═══════════════════════════════════════
🔄 [AI CHAT] Falling back to LocalAI...
✅ [AI CHAT] LocalAI response generated
📝 [AI CHAT] Response length: 150 chars
```

---

### When There's a Fatal Error ❌:

```
═══════════════════════════════════════
❌❌❌ [AI CHAT FATAL ERROR] ❌❌❌
🔴 [AI CHAT ERROR] Error type: TypeError
🔴 [AI CHAT ERROR] Error message: Cannot read property 'name' of null
🔴 [AI CHAT ERROR] Full stack trace:
[detailed stack trace...]
═══════════════════════════════════════
```

---

## 🔍 Common Error Patterns

### Error 1: API Key Not Found

**Console shows:**
```
❌ [GEMINI SERVICE ERROR] API key validation failed
🔴 Error: Gemini API key not configured
```

**Cause**: `.env` file not loaded or key missing

**Fix**:
1. Check `.env` file exists
2. Verify `GEMINI_API_KEY=AIzaSyD8ATUIwoIc2k4FheWOT5T1tScwe7Eqd6E`
3. Restart app

---

### Error 2: Invalid API Key

**Console shows:**
```
❌ [GEMINI SERVICE ERROR] 403 Forbidden - Invalid API key
🔑 [GEMINI SERVICE ERROR] API key used: AIzaSyD8ATUIwoIc2k4F...
```

**Cause**: API key is wrong or expired

**Fix**:
1. Get new key: https://makersuite.google.com/app/apikey
2. Update `.env` file
3. Restart app

---

### Error 3: Rate Limit Exceeded

**Console shows:**
```
❌ [GEMINI SERVICE ERROR] 429 Rate Limit Exceeded
⏰ [GEMINI SERVICE ERROR] Free tier: 60 requests/min
```

**Cause**: Sent too many requests too fast

**Fix**: Wait 1 minute and try again

---

### Error 4: Network Error

**Console shows:**
```
❌❌❌ [GEMINI SERVICE FATAL ERROR] ❌❌❌
🔴 [GEMINI SERVICE ERROR] Error type: SocketException
🔴 [GEMINI SERVICE ERROR] Error message: Failed host lookup
```

**Cause**: No internet connection

**Fix**: Check internet connection

---

### Error 5: Timeout

**Console shows:**
```
⏰ [GEMINI SERVICE ERROR] Request timeout after 30 seconds
```

**Cause**: API is slow or network is slow

**Fix**: Try again, or check network speed

---

## 📋 How to Report Errors

### If you see an error:

1. **Open Console** (F12)
2. **Find the error** (look for ❌ or 🔴)
3. **Copy the error section**:
   - Start from `═══════════════════════════════════════`
   - End at next `═══════════════════════════════════════`
4. **Share the error** with me

### Example Error to Copy:

```
═══════════════════════════════════════
❌ [GEMINI SERVICE ERROR] 403 Forbidden - Invalid API key
🔑 [GEMINI SERVICE ERROR] API key used: AIzaSyD8ATUIwoIc2k4F...
═══════════════════════════════════════
```

---

## 🎯 What to Look For

### Good Signs ✅:
- Lots of ✅ checkmarks
- "Success!" messages
- "Gemini response received"
- No ❌ or 🔴 symbols

### Bad Signs ❌:
- ❌ or 🔴 symbols
- "ERROR" in messages
- "FATAL ERROR" messages
- Stack traces

### Fallback Signs ⚠️:
- "Falling back to LocalAI"
- Means Gemini failed but app still works
- You'll get generic responses

---

## 🔧 Console Filters

### To see only errors:
1. Open Console (F12)
2. Click "Errors" filter at top
3. Only error messages will show

### To see only AI logs:
1. Open Console (F12)
2. In filter box, type: `AI`
3. Only AI-related logs will show

### To clear console:
1. Right-click in console
2. Click "Clear console"
3. Or press `Ctrl + L` (Windows) / `Cmd + K` (Mac)

---

## 📊 Network Tab (For API Calls)

### To see API requests:

1. Open DevTools (F12)
2. Click "Network" tab
3. Send a message in AI Chat
4. Look for request to `generativelanguage.googleapis.com`
5. Click on it to see:
   - Request headers
   - Request body
   - Response status
   - Response body

### What to check:
- **Status**: Should be 200 (green)
- **Response**: Should contain AI text
- **Time**: Should be 3-10 seconds

---

## 🎉 Summary

**What I added:**
- ✅ Detailed step-by-step logging
- ✅ Clear error messages
- ✅ Visual separators for readability
- ✅ Stack traces for debugging
- ✅ HTTP status code details
- ✅ Response previews

**How to use:**
1. Open Console (F12)
2. Send a message in AI Chat
3. Watch the logs appear
4. Look for ❌ or 🔴 for errors
5. Copy error section if needed

**Now you can see exactly what's happening!** 🔍

---

## 🚀 Next Steps

1. **Restart the app** to load new logging
2. **Open Console** (F12)
3. **Send a test message**
4. **Watch the logs**
5. **Share any errors** you see

**The logs will tell you exactly what's wrong!** 💪
