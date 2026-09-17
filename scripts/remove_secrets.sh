#!/bin/bash

# Script to remove exposed API keys from documentation files
# This will redact all exposed Gemini and NVIDIA API keys

echo "🔒 Removing exposed API keys from documentation..."

# Files to clean
FILES=(
  "docs/development/ERROR_LOGGING_ADDED.md"
  "docs/development/FIREBASE_CONFIGURATION_COMPLETE.md"
  "docs/development/GEMINI_AI_STATUS.md"
  "docs/development/FREE_AI_PLATFORMS_GUIDE.md"
  "docs/development/GEMINI_API_SETUP_COMPLETE.md"
  "docs/development/GEMINI_INTEGRATION_COMPLETE.md"
  "docs/development/HOW_TO_SEE_ERRORS.md"
  "docs/setup/SETUP_FREE_AI.md"
  "docs/development/OPTION_ONE_COMPLETE.md"
  "docs/guides/START_HERE_FREE_AI.md"
  "docs/development/FINAL_IMAGE_FIX.md"
)

# Redact Gemini API key: AIzaSyD8ATUIwoIc2k4FheWOT5T1tScwe7Eqd6E
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    sed -i 's/AIzaSyD8ATUIwoIc2k4FheWOT5T1tScwe7Eqd6E/your_gemini_api_key_here/g' "$file"
    echo "✅ Cleaned: $file"
  fi
done

# Redact NVIDIA API key
sed -i 's/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/your_nvidia_api_key_here/g' "docs/development/FINAL_IMAGE_FIX.md"

echo "✅ All API keys have been redacted!"
echo "⚠️  Next step: Commit these changes and force push to GitHub"
