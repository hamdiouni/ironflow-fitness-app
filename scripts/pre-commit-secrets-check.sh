#!/usr/bin/env bash
set -euo pipefail

# Pre-commit & CI Secret Guard for IronFlow
# Blocks accidental commits of Google/Gemini API keys (outside Firebase client configs),
# NVIDIA NIM keys (nvapi-), private keys, or env.json files.

if command -v gitleaks >/dev/null 2>&1; then
  if [[ "${1:-}" == "--ci-verify" ]]; then
    gitleaks detect --source . --config .gitleaks.toml --log-opts="HEAD" --no-banner
  else
    gitleaks protect --staged --config .gitleaks.toml --no-banner
  fi
fi

# Deterministic regex check (works even when gitleaks binary is not installed locally)
FORBIDDEN_NVAPI=$(git grep -I -l -E "nvapi-[0-9A-Za-z_-]{20,}" -- . || true)
if [[ -n "$FORBIDDEN_NVAPI" ]]; then
  echo "ERROR: Forbidden nvapi- key pattern detected in tracked files:"
  echo "$FORBIDDEN_NVAPI"
  exit 1
fi

FORBIDDEN_AIZA=$(git grep -I -l -E "AIza[0-9A-Za-z_-]{35}" -- . \
  ':!lib/firebase_options.dart' \
  ':!android/app/google-services.json' \
  ':!ios/Runner/GoogleService-Info.plist' || true)
if [[ -n "$FORBIDDEN_AIZA" ]]; then
  echo "ERROR: Forbidden Google/Gemini API key pattern detected outside Firebase client configs:"
  echo "$FORBIDDEN_AIZA"
  exit 1
fi

if git ls-files --error-unmatch env.json >/dev/null 2>&1; then
  echo "ERROR: env.json must never be tracked by Git."
  exit 1
fi

echo "Secret check passed: 0 forbidden key patterns in tracked files."

