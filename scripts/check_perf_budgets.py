#!/usr/bin/env python3
"""
Performance & Size Budget Gate for IronFlow CI (Wave 5.1).

Validates:
1. Web bundle budgets:
   - main.dart.js gzipped <= 2.5 MB (Current ~1.60 MB)
   - Total web assets <= 6.0 MB (Current ~2.91 MB excluding canvaskit engine)
2. Assets directory budgets:
   - assets/fonts/ <= 1.5 MB (Current ~0.99 MB)
   - assets/data/ <= 1.0 MB (Current ~0.39 MB)
3. Android binary budgets (if build/ exists):
   - Per-ABI release APK <= 35.0 MB (R8-shrunk)
   - Unsplit debug APK <= 250.0 MB
"""

import gzip
import os
import sys

# Budget Thresholds in MegaBytes
MAX_WEB_GZIPPED_JS_MB = 2.5
MAX_WEB_ASSETS_MB = 6.0
MAX_FONTS_DIR_MB = 1.5
MAX_DATA_DIR_MB = 1.0
MAX_PER_ABI_RELEASE_APK_MB = 35.0
MAX_DEBUG_APK_MB = 250.0

def get_dir_size_bytes(directory: str) -> int:
    total = 0
    if not os.path.isdir(directory):
        return 0
    for root, _, files in os.walk(directory):
        for f in files:
            fp = os.path.join(root, f)
            if not os.path.islink(fp):
                total += os.path.getsize(fp)
    return total

def check_budgets() -> bool:
    print("==================================================")
    print("  IronFlow Performance & Size Budget Gate (W5.1) ")
    print("==================================================")
    all_passed = True

    # 1. Assets Directory Budgets
    fonts_mb = get_dir_size_bytes("assets/fonts") / (1024 * 1024)
    data_mb = get_dir_size_bytes("assets/data") / (1024 * 1024)

    print(f"\n[Assets Audit]")
    if fonts_mb <= MAX_FONTS_DIR_MB:
        print(f"  PASS: assets/fonts is {fonts_mb:.2f} MB (budget <= {MAX_FONTS_DIR_MB} MB)")
    else:
        print(f"  FAIL: assets/fonts is {fonts_mb:.2f} MB (exceeds budget {MAX_FONTS_DIR_MB} MB)")
        all_passed = False

    if data_mb <= MAX_DATA_DIR_MB:
        print(f"  PASS: assets/data is {data_mb:.2f} MB (budget <= {MAX_DATA_DIR_MB} MB)")
    else:
        print(f"  FAIL: assets/data is {data_mb:.2f} MB (exceeds budget {MAX_DATA_DIR_MB} MB)")
        all_passed = False

    # 2. Web Bundle Budgets (if build/web exists)
    web_dir = "build/web"
    if os.path.isdir(web_dir):
        print(f"\n[Web Bundle Audit]")
        main_js = os.path.join(web_dir, "main.dart.js")
        if os.path.isfile(main_js):
            raw_mb = os.path.getsize(main_js) / (1024 * 1024)
            with open(main_js, "rb") as f:
                gz_mb = len(gzip.compress(f.read())) / (1024 * 1024)
            if gz_mb <= MAX_WEB_GZIPPED_JS_MB:
                print(f"  PASS: main.dart.js is {raw_mb:.2f} MB raw, {gz_mb:.2f} MB gzipped (budget <= {MAX_WEB_GZIPPED_JS_MB} MB)")
            else:
                print(f"  FAIL: main.dart.js gzipped is {gz_mb:.2f} MB (exceeds budget {MAX_WEB_GZIPPED_JS_MB} MB)")
                all_passed = False

        web_assets_mb = get_dir_size_bytes(os.path.join(web_dir, "assets")) / (1024 * 1024)
        if web_assets_mb <= MAX_WEB_ASSETS_MB:
            print(f"  PASS: build/web/assets is {web_assets_mb:.2f} MB (budget <= {MAX_WEB_ASSETS_MB} MB)")
        else:
            print(f"  FAIL: build/web/assets is {web_assets_mb:.2f} MB (exceeds budget {MAX_WEB_ASSETS_MB} MB)")
            all_passed = False
    else:
        print("\n[Web Bundle Audit] Skipped (build/web not present)")

    # 3. Android APK Budgets (if build/app/outputs/flutter-apk exists)
    apk_dir = "build/app/outputs/flutter-apk"
    if os.path.isdir(apk_dir):
        print(f"\n[Android Binary Audit]")
        for f in os.listdir(apk_dir):
            if f.endswith(".apk"):
                fp = os.path.join(apk_dir, f)
                mb = os.path.getsize(fp) / (1024 * 1024)
                if "debug" in f:
                    if mb <= MAX_DEBUG_APK_MB:
                        print(f"  PASS: {f} is {mb:.2f} MB (budget <= {MAX_DEBUG_APK_MB} MB)")
                    else:
                        print(f"  FAIL: {f} is {mb:.2f} MB (exceeds budget {MAX_DEBUG_APK_MB} MB)")
                        all_passed = False
                elif "release" in f:
                    if mb <= MAX_PER_ABI_RELEASE_APK_MB:
                        print(f"  PASS: {f} is {mb:.2f} MB (budget <= {MAX_PER_ABI_RELEASE_APK_MB} MB)")
                    else:
                        print(f"  FAIL: {f} is {mb:.2f} MB (exceeds budget {MAX_PER_ABI_RELEASE_APK_MB} MB)")
                        all_passed = False
    else:
        print("\n[Android Binary Audit] Skipped (build/app/outputs/flutter-apk not present)")

    print("\n--------------------------------------------------")
    if all_passed:
        print("  RESULT: All performance & size budgets PASSED.")
        print("--------------------------------------------------")
        return True
    else:
        print("  RESULT: Performance or size budgets FAILED.")
        print("--------------------------------------------------")
        return False

if __name__ == "__main__":
    success = check_budgets()
    sys.exit(0 if success else 1)

