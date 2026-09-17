# 🧪 Image Generation Testing Guide

## 🎯 Test Scenarios

### Test 1: Automatic Exercise Images
**Goal**: Verify that exercise images appear automatically when AI mentions exercises

**Steps**:
1. Open AI Chat screen
2. Send message: "Create a chest workout for me"
3. Wait for AI response

**Expected Result**:
- AI responds with workout including exercises like "Bench Press", "Push Ups"
- Small exercise images (100x100) appear below the AI response
- Up to 3 images show in a horizontal gallery
- Images load smoothly with loading spinner

**Pass Criteria**:
✅ Images appear automatically  
✅ Images match mentioned exercises  
✅ Loading spinner shows while loading  
✅ Images are clickable/tappable  

---

### Test 2: Generate Image Button
**Goal**: Verify "Generate Image" button appears when appropriate

**Steps**:
1. Send message: "Show me proper squat form"
2. Wait for AI response
3. Look for "Generate Image" button below response

**Expected Result**:
- AI responds with squat form instructions
- "Generate Image" button appears below response
- Button has image icon + "Generate Image" text
- Button is styled with primary color outline

**Pass Criteria**:
✅ Button appears for visual-related queries  
✅ Button is visible and clickable  
✅ Button styling matches app theme  

---

### Test 3: AI Image Generation
**Goal**: Verify AI can generate custom images using Hugging Face API

**Steps**:
1. Send message: "Show me proper deadlift form"
2. Wait for AI response
3. Click "Generate Image" button
4. Wait for image generation (may take 20-60 seconds first time)

**Expected Result**:
- Loading indicator appears: "🎨 Generating custom image..."
- After 20-60 seconds, generated image appears
- Image is full-width and high quality
- Image shows fitness-related content

**Pass Criteria**:
✅ Loading indicator shows during generation  
✅ Image generates successfully  
✅ Image is relevant to the prompt  
✅ Image displays correctly  

**Note**: First generation may take longer (20-60s) while Hugging Face loads the model. Subsequent generations are faster (5-15s).

---

### Test 4: Multiple Exercise Detection
**Goal**: Verify multiple exercises are detected and images shown

**Steps**:
1. Send message: "Give me a full body workout"
2. Wait for AI response with multiple exercises

**Expected Result**:
- AI responds with workout containing multiple exercises
- Multiple exercise images appear (up to 3)
- Images are arranged in a horizontal gallery
- Each image corresponds to a mentioned exercise

**Pass Criteria**:
✅ Multiple images appear  
✅ Maximum 3 images shown  
✅ Images match mentioned exercises  
✅ Gallery layout looks good  

---

### Test 5: No Images for Non-Visual Content
**Goal**: Verify images don't appear for non-visual queries

**Steps**:
1. Send message: "What's my calorie goal?"
2. Wait for AI response

**Expected Result**:
- AI responds with calorie information
- NO exercise images appear
- NO "Generate Image" button appears
- Response is text-only

**Pass Criteria**:
✅ No images for non-visual content  
✅ No "Generate Image" button  
✅ Clean text-only response  

---

### Test 6: Error Handling
**Goal**: Verify graceful error handling if image generation fails

**Steps**:
1. Disconnect internet (optional)
2. Send message: "Show me bench press form"
3. Click "Generate Image" button
4. Wait for response

**Expected Result**:
- If offline: Error message or fallback to pre-made images
- If API fails: Graceful error message
- App doesn't crash
- User can retry

**Pass Criteria**:
✅ No crashes  
✅ Clear error message  
✅ Can retry generation  
✅ Pre-made images still work  

---

### Test 7: Image Caching
**Goal**: Verify images are cached and load faster on subsequent views

**Steps**:
1. Send message: "Create a chest workout"
2. Wait for images to load
3. Scroll up and down to hide/show images
4. Clear chat and send same message again

**Expected Result**:
- First load: Images load with spinner
- Subsequent views: Images load instantly from cache
- No re-downloading of same images

**Pass Criteria**:
✅ Images cache correctly  
✅ Cached images load instantly  
✅ No unnecessary network requests  

---

## 🎨 Visual Quality Checks

### Exercise Images:
- [ ] Images are clear and high quality
- [ ] Images are relevant to exercises
- [ ] Images have rounded corners (12px)
- [ ] Images are properly sized (100x100)
- [ ] Images don't distort or stretch

### Generated Images:
- [ ] Images are high resolution
- [ ] Images are fitness-related
- [ ] Images match the prompt
- [ ] Images display full-width
- [ ] Images have rounded corners

### Loading States:
- [ ] Spinner is visible and animated
- [ ] Loading message is clear
- [ ] Loading container is styled nicely
- [ ] Loading doesn't block UI

---

## 📱 Platform-Specific Tests

### Web (Chrome):
- [ ] Images load in Chrome
- [ ] Generate button works
- [ ] Image generation completes
- [ ] Caching works
- [ ] No console errors

### Android (After APK build):
- [ ] Images load on Android
- [ ] Generate button works
- [ ] Image generation completes
- [ ] Caching persists after app restart
- [ ] Works on mobile data and WiFi

---

## 🐛 Known Issues & Workarounds

### Issue 1: First Image Generation Slow
**Symptom**: First image generation takes 20-60 seconds  
**Cause**: Hugging Face needs to load the model  
**Workaround**: Wait patiently, subsequent generations are faster  
**Status**: Expected behavior (free tier)

### Issue 2: Image Generation Fails
**Symptom**: "Failed to generate image" error  
**Cause**: API rate limit or model unavailable  
**Workaround**: Wait a few minutes and retry  
**Status**: Expected behavior (free tier)

### Issue 3: No Exercise Images
**Symptom**: Exercise mentioned but no image appears  
**Cause**: Exercise not in database  
**Workaround**: Use "Generate Image" button  
**Status**: Can add more exercises to database

---

## ✅ Success Criteria

### Minimum Viable:
✅ Pre-made exercise images work  
✅ Images load and display correctly  
✅ No crashes or errors  

### Full Feature:
✅ All above +  
✅ "Generate Image" button appears  
✅ AI image generation works  
✅ Loading states are smooth  
✅ Error handling is graceful  

### Excellent:
✅ All above +  
✅ Fast image loading  
✅ Beautiful UI/UX  
✅ Caching works perfectly  
✅ Works on all platforms  

---

## 🚀 Quick Test Commands

### Test Messages:
```
1. "Create a chest workout"
   → Should show bench press, push up images

2. "Show me proper squat form"
   → Should show squat image + generate button

3. "Give me a full body workout"
   → Should show multiple exercise images

4. "Explain deadlift technique"
   → Should show deadlift image + generate button

5. "What's my calorie goal?"
   → Should NOT show any images
```

---

## 📊 Test Results Template

### Web Testing Results:
- **Date**: _______
- **Browser**: Chrome
- **Test 1 (Auto Images)**: ⬜ Pass ⬜ Fail
- **Test 2 (Generate Button)**: ⬜ Pass ⬜ Fail
- **Test 3 (AI Generation)**: ⬜ Pass ⬜ Fail
- **Test 4 (Multiple Images)**: ⬜ Pass ⬜ Fail
- **Test 5 (No Images)**: ⬜ Pass ⬜ Fail
- **Test 6 (Error Handling)**: ⬜ Pass ⬜ Fail
- **Test 7 (Caching)**: ⬜ Pass ⬜ Fail

**Notes**: _______________

### Android Testing Results:
- **Date**: _______
- **Device**: _______
- **Test 1 (Auto Images)**: ⬜ Pass ⬜ Fail
- **Test 2 (Generate Button)**: ⬜ Pass ⬜ Fail
- **Test 3 (AI Generation)**: ⬜ Pass ⬜ Fail
- **Test 4 (Multiple Images)**: ⬜ Pass ⬜ Fail
- **Test 5 (No Images)**: ⬜ Pass ⬜ Fail
- **Test 6 (Error Handling)**: ⬜ Pass ⬜ Fail
- **Test 7 (Caching)**: ⬜ Pass ⬜ Fail

**Notes**: _______________

---

## 🎉 Ready to Test!

The app should be running on **http://localhost:8080**

Start with Test 1 and work your way through all tests!

