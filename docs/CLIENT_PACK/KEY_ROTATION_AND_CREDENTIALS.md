# IronFlow — Key Rotation & Credentials Management SOP

**Classification:** Confidential — Client Technical Documentation  
**Version:** 2.0.0

---

## 1. Zero-Secrets Architecture Overview

IronFlow strictly implements a **zero-trust secrets policy**:
- **Zero Secrets in Code**: No API keys, database credentials, private signing certificates, or service account tokens exist in source control or Git history.
- **Fail-Closed Release Builds**: Client release builds compile with `allowDirectAiApiKeys = false`. If a client build is run without the backend proxy URL, it immediately throws a `StateError` rather than falling back to unvetted local keys.
- **Automated CI Scanning**: Continuous integration pipelines scan every commit and pull request using `gitleaks` to block inadvertent key commits.

---

## 2. Credentials Inventory

| Credential Name | Storage Location | Sensitivity | Rotation Frequency | Purpose |
| :--- | :--- | :---: | :---: | :--- |
| **Google Gemini API Key** | Google Cloud / Firebase Secret Manager (`GEMINI_API_KEY`) | **High** | 90 days or on incident | Authenticates Cloud Functions proxy with Google Gemini LLM |
| **Android Release Keystore** | Secure Offline Vault / CI Secret (`android/key.properties`) | **Critical** | Permanent (Backup mandatory) | Signs production `.aab` / `.apk` binaries for Google Play Store |
| **Firebase Service Account** | GitHub Actions Secrets (`FIREBASE_SERVICE_ACCOUNT`) | **High** | 180 days | Automates CI deployments for Firebase Hosting and Functions |
| **Device Encryption Key** | Platform Keystore / Keychain (`flutter_secure_storage`) | **Critical (Per Device)** | Generated on first launch | AES-256 master key encrypting local Hive health and workout data |
| **Firebase App Check Key** | Google Cloud Console / Firebase Console | **Medium** | Annual | Verifies client app authenticity (Play Integrity / reCAPTCHA) |

---

## 3. Key Rotation Procedures

### A. Rotating the Gemini API Key
To rotate the Gemini API key without downtime:
1. Generate a new API key in [Google AI Studio](https://aistudio.google.com/) or Google Cloud Console.
2. Update the secret in Firebase Secret Manager:
   ```bash
   firebase functions:secrets:set GEMINI_API_KEY
   # Paste the new key when prompted
   ```
3. Re-deploy the Cloud Functions proxy:
   ```bash
   firebase deploy --only functions:aiGenerate
   ```
4. Test a live coaching query on the mobile or web app to verify the new key is active.
5. In Google AI Studio, delete the previous (deprecated) key.

---

### B. Rotating the Firebase CI/CD Service Account
1. Open Google Cloud Console > **IAM & Admin** > **Service Accounts**.
2. Select the GitHub Actions deployer service account (e.g. `github-deployer@<project>.iam.gserviceaccount.com`).
3. Under the **Keys** tab, click **Add Key** > **Create new key (JSON)**.
4. Download the new JSON key.
5. In your GitHub repository:
   - Navigate to **Settings** > **Secrets and variables** > **Actions**.
   - Update `FIREBASE_SERVICE_ACCOUNT` with the new base64 or JSON string.
6. Trigger a CI build to confirm successful authentication.
7. Return to Google Cloud Console and delete the old key.

---

### C. Android Keystore Security & Backup
The Android upload keystore signs your app. **If lost, you cannot update the application on Google Play without submitting an identity reset request to Google Play Support.**

1. **Storage Rules**:
   - Store the `.jks` or `.keystore` file in a dedicated encrypted password manager (1Password, Bitwarden, or AWS Secrets Manager).
   - Never commit `key.properties` or `*.jks` to Git (both are gitignored).
2. **Generating a New Release Keystore**:
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload -storetype JKS
   ```
3. **Configuring `android/key.properties`**:
   ```properties
   storePassword=YOUR_SECURE_STORE_PASSWORD
   keyPassword=YOUR_SECURE_KEY_PASSWORD
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

---

## 4. Emergency Incident Response: Credential Leak SOP

If a production key or credential is leaked or suspected of being compromised:

1. **Phase 1: Immediate Revocation (<15 minutes)**:
   - Go to Google Cloud Console > **APIs & Services** > **Credentials**.
   - Immediately delete or revoke the compromised key.
2. **Phase 2: Remote Kill Switch (`ADR-005`)**:
   - In Firebase Remote Config, set `ai_coach_enabled = false` and `remote_kill_switch_active = true`.
   - All active mobile apps will gracefully disable remote AI routing and fallback to the local deterministic rule-based coach within 5 minutes.
3. **Phase 3: Deploy New Credentials**:
   - Follow Procedure A above to generate and deploy a fresh key.
   - Reset the Remote Config kill switch to restore full online features.
4. **Phase 4: Audit Logs**:
   - Review Cloud Functions execution logs in Cloud Logging for unexpected request surges or unauthorized IP addresses during the exposure window.

