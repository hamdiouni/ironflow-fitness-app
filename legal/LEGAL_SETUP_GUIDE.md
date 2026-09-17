# Legal Documents Setup Guide

## ✅ What We Created

1. **Privacy Policy** (`PRIVACY_POLICY.md`)
2. **Terms of Service** (`TERMS_OF_SERVICE.md`)

These are **REQUIRED** by Apple App Store and Google Play Store.

---

## 🌐 Step 1: Host Legal Documents Online

You MUST host these documents on a public website. Here are your options:

### Option A: GitHub Pages (FREE, Easiest) ⭐ RECOMMENDED

1. **Create a new GitHub repository** (e.g., `ironflow-legal`)
2. **Upload the legal documents**:
   ```bash
   git init
   git add legal/
   git commit -m "Add legal documents"
   git remote add origin https://github.com/YOUR_USERNAME/ironflow-legal.git
   git push -u origin main
   ```

3. **Enable GitHub Pages**:
   - Go to repository Settings
   - Scroll to "Pages"
   - Source: Deploy from branch `main`
   - Folder: `/` (root)
   - Save

4. **Your URLs will be**:
   - Privacy: `https://YOUR_USERNAME.github.io/ironflow-legal/PRIVACY_POLICY.html`
   - Terms: `https://YOUR_USERNAME.github.io/ironflow-legal/TERMS_OF_SERVICE.html`

5. **Convert MD to HTML** (optional but recommended):
   - Use a tool like `pandoc` or online converter
   - Or use GitHub's automatic rendering

---

### Option B: Your Own Website

If you have a website (e.g., `ironflow.app`):

1. Create pages:
   - `https://ironflow.app/privacy`
   - `https://ironflow.app/terms`

2. Upload the content
3. Make sure pages are publicly accessible

---

### Option C: Google Sites (FREE)

1. Go to https://sites.google.com
2. Create a new site
3. Add pages for Privacy Policy and Terms
4. Publish the site
5. Get the public URLs

---

## 📱 Step 2: Add Links to Your App

### A. Update Settings Screen

Add legal links to your settings screen:

```dart
// In lib/features/settings/presentation/screens/settings_screen.dart

ListTile(
  leading: Icon(Icons.privacy_tip),
  title: Text('Privacy Policy'),
  trailing: Icon(Icons.open_in_new),
  onTap: () => _launchURL('https://YOUR_URL/privacy'),
),
ListTile(
  leading: Icon(Icons.description),
  title: Text('Terms of Service'),
  trailing: Icon(Icons.open_in_new),
  onTap: () => _launchURL('https://YOUR_URL/terms'),
),

// Helper method
Future<void> _launchURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

### B. Update Onboarding/Sign-Up

Add acceptance checkbox during sign-up:

```dart
CheckboxListTile(
  title: RichText(
    text: TextSpan(
      text: 'I agree to the ',
      children: [
        TextSpan(
          text: 'Terms of Service',
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _launchURL('https://YOUR_URL/terms'),
        ),
        TextSpan(text: ' and '),
        TextSpan(
          text: 'Privacy Policy',
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _launchURL('https://YOUR_URL/privacy'),
        ),
      ],
    ),
  ),
  value: _agreedToTerms,
  onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
),
```

---

## 📝 Step 3: Update App Store Listings

### Apple App Store

1. **App Store Connect** > Your App > App Information
2. **Privacy Policy URL**: Enter your privacy policy URL
3. **Terms of Service URL**: Enter your terms URL (optional but recommended)

### Google Play Store

1. **Play Console** > Your App > Store Presence > Store Listing
2. **Privacy Policy**: Enter your privacy policy URL (REQUIRED)
3. **Terms of Service**: Not required but recommended

---

## 🔧 Step 4: Customize the Documents

### Replace Placeholders

In both documents, replace:

- `[Your Company Address]` → Your actual address or "Remote Company"
- `contact@ironflow.app` → Your actual email
- `privacy@ironflow.app` → Your actual email
- `legal@ironflow.app` → Your actual email
- `support@ironflow.app` → Your actual email
- `https://ironflow.app` → Your actual website

### Add Your Information

1. **Company Name**: If you have a registered company
2. **Contact Information**: Real email addresses
3. **Jurisdiction**: Your country/state for legal purposes
4. **Data Controller**: Your name or company name (for GDPR)

---

## ⚖️ Step 5: Legal Review (Optional but Recommended)

### DIY Approach (Current)

The documents I created are based on:
- Industry best practices
- GDPR compliance
- CCPA compliance
- App Store requirements

They should be sufficient for launch.

### Professional Review

For extra protection, consider:

1. **Legal Review**: Have a lawyer review ($500-2000)
2. **Legal Templates**: Use services like:
   - TermsFeed ($200-500)
   - Termly ($200-400)
   - iubenda ($300-600)

---

## 📋 Checklist

### Before Launch:

- [ ] Host privacy policy online (publicly accessible)
- [ ] Host terms of service online (publicly accessible)
- [ ] Add links to app settings
- [ ] Add acceptance during sign-up
- [ ] Replace all placeholders with real information
- [ ] Test that links work
- [ ] Add URLs to App Store/Play Store listings

### App Store Submission:

- [ ] Privacy Policy URL in App Store Connect
- [ ] Privacy Policy URL in Play Console
- [ ] Terms acceptance in app (recommended)
- [ ] Data safety form completed (Android)
- [ ] Age rating questionnaire completed

---

## 🚨 Important Notes

### GDPR Compliance (EU Users)

If you have EU users, you MUST:

- ✅ Get explicit consent for data collection
- ✅ Allow users to access their data
- ✅ Allow users to delete their data
- ✅ Allow users to export their data
- ✅ Notify users of data breaches within 72 hours

**Your app already supports**: Access, delete, and export! ✅

### CCPA Compliance (California Users)

If you have California users, you MUST:

- ✅ Disclose data collection practices
- ✅ Allow users to opt-out of data sale
- ✅ Not discriminate against users who opt-out

**Your app**: Does NOT sell data! ✅

### Children's Privacy (COPPA)

If your app is for children under 13:

- ❌ You need parental consent
- ❌ You need additional privacy measures
- ❌ You need COPPA compliance

**Your app**: 13+ age rating, so COPPA doesn't apply ✅

---

## 🔄 Updating Legal Documents

### When to Update:

- When you add new features
- When you change data collection practices
- When you add third-party services
- When laws change
- At least once per year (review)

### How to Update:

1. Update the documents
2. Update "Last Updated" date
3. Notify users (email + in-app notification)
4. Update hosted versions
5. Keep old versions for records

---

## 📞 Support

### If Users Have Questions:

Create a support email: `support@ironflow.app`

### If You Need Legal Help:

- **LegalZoom**: https://www.legalzoom.com
- **Rocket Lawyer**: https://www.rocketlawyer.com
- **Local Attorney**: Search for "tech lawyer" or "app lawyer"

---

## ✅ Quick Start (5 Minutes)

1. **Create GitHub repo**: `ironflow-legal`
2. **Upload files**: `PRIVACY_POLICY.md` and `TERMS_OF_SERVICE.md`
3. **Enable GitHub Pages**: Settings > Pages > Deploy from main
4. **Get URLs**: `https://YOUR_USERNAME.github.io/ironflow-legal/`
5. **Add to app**: Settings screen with links
6. **Done!** ✅

---

## 🎯 Next Steps

After setting up legal documents:

1. ✅ Create app icon (all sizes)
2. ✅ Take screenshots
3. ✅ Write app description
4. ✅ Add rest timer feature
5. ✅ Add crash reporting
6. ✅ Test on real devices

---

**You're one step closer to launch!** 🚀

