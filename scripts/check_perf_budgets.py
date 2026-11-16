#!/usr/bin/env python3
"""
IronFlow Performance, Asset Size, & Android R8 Budget Gate.

Validates static assets, Web JS bundle sizes, Android APK sizes, and
optionally enforces presence of release APK + R8 mapping artifacts in CI.
"""

from __future__ import annotations

import argparse
import gzip
from pathlib import Path
import sys

# Approved Wave 5.1 / Wave 2.3 Budgets
MAX_WEB_GZIPPED_JS_MB = 2.5
MAX_WEB_ASSETS_MB = 6.0
MAX_FONTS_DIR_MB = 1.5
MAX_DATA_DIR_MB = 1.0
MAX_PER_ABI_RELEASE_APK_MB = 35.0
MAX_DEBUG_APK_MB = 250.0


def dir_size_bytes(path: Path) -> int:
    if not path.exists():
        return 0
    return sum(f.stat().st_size for f in path.rglob('*') if f.is_file())


def to_mb(size_bytes: int) -> float:
    return size_bytes / (1024 * 1024)


def gzip_size_bytes(path: Path) -> int:
    data = path.read_bytes()
    return len(gzip.compress(data, compresslevel=9))


def main() -> int:
    parser = argparse.ArgumentParser(
        description='Verify IronFlow asset, Web bundle, APK size, and R8 mapping budgets.',
    )
    parser.add_argument(
        '--require-web',
        action='store_true',
        help='Fail if build/web/main.dart.js or build/web/assets is missing.',
    )
    parser.add_argument(
        '--require-release-apk',
        action='store_true',
        help='Fail if split/release APKs are missing under build/app/outputs/flutter-apk.',
    )
    parser.add_argument(
        '--require-r8-mapping',
        action='store_true',
        help='Fail if build/app/outputs/mapping/release/mapping.txt is missing or empty.',
    )
    args = parser.parse_args()

    print('=' * 56)
    print('  IronFlow Performance & Size Budget Gate (W2.3 / W5.1) ')
    print('=' * 56)

    failures: list[str] = []

    # 1. Static Assets Check
    print('\n[Assets Audit]')
    fonts_dir = Path('assets/fonts')
    if fonts_dir.exists():
        fonts_mb = to_mb(dir_size_bytes(fonts_dir))
        print(f'  assets/fonts: {fonts_mb:.2f} MB (budget <= {MAX_FONTS_DIR_MB} MB)')
        if fonts_mb > MAX_FONTS_DIR_MB:
            failures.append(f'assets/fonts ({fonts_mb:.2f} MB) > {MAX_FONTS_DIR_MB} MB')
        else:
            print('  PASS: assets/fonts within budget.')

    data_dir = Path('assets/data')
    if data_dir.exists():
        data_mb = to_mb(dir_size_bytes(data_dir))
        print(f'  assets/data: {data_mb:.2f} MB (budget <= {MAX_DATA_DIR_MB} MB)')
        if data_mb > MAX_DATA_DIR_MB:
            failures.append(f'assets/data ({data_mb:.2f} MB) > {MAX_DATA_DIR_MB} MB')
        else:
            print('  PASS: assets/data within budget.')

    # 2. Web Build Check
    print('\n[Web Bundle Audit]')
    web_js = Path('build/web/main.dart.js')
    web_assets = Path('build/web/assets')

    if web_js.exists():
        raw_mb = to_mb(web_js.stat().st_size)
        gz_mb = to_mb(gzip_size_bytes(web_js))
        print(f'  main.dart.js: {raw_mb:.2f} MB raw, {gz_mb:.2f} MB gzipped (budget <= {MAX_WEB_GZIPPED_JS_MB} MB)')
        if gz_mb > MAX_WEB_GZIPPED_JS_MB:
            failures.append(f'main.dart.js gzipped ({gz_mb:.2f} MB) > {MAX_WEB_GZIPPED_JS_MB} MB')
        else:
            print('  PASS: main.dart.js gzipped within budget.')
    elif args.require_web:
        failures.append('Missing build/web/main.dart.js (--require-web set)')
    else:
        print('  SKIP: build/web/main.dart.js not present.')

    if web_assets.exists():
        w_assets_mb = to_mb(dir_size_bytes(web_assets))
        print(f'  build/web/assets: {w_assets_mb:.2f} MB (budget <= {MAX_WEB_ASSETS_MB} MB)')
        if w_assets_mb > MAX_WEB_ASSETS_MB:
            failures.append(f'build/web/assets ({w_assets_mb:.2f} MB) > {MAX_WEB_ASSETS_MB} MB')
        else:
            print('  PASS: build/web/assets within budget.')
    elif args.require_web:
        failures.append('Missing build/web/assets directory (--require-web set)')

    # 3. Android APK & R8 Mapping Check
    print('\n[Android Binary & R8 Audit]')
    apk_dir = Path('build/app/outputs/flutter-apk')
    release_apks = sorted(apk_dir.glob('*release.apk')) if apk_dir.exists() else []
    debug_apk = apk_dir / 'app-debug.apk'

    if release_apks:
        for apk in release_apks:
            apk_mb = to_mb(apk.stat().st_size)
            limit = MAX_PER_ABI_RELEASE_APK_MB if ('arm' in apk.name or 'x86' in apk.name) else 80.0
            print(f'  {apk.name}: {apk_mb:.2f} MB (budget <= {limit} MB)')
            if apk_mb > limit:
                failures.append(f'{apk.name} ({apk_mb:.2f} MB) > {limit} MB')
            else:
                print(f'  PASS: {apk.name} within budget.')
    elif args.require_release_apk:
        failures.append('No *release.apk artifacts found under build/app/outputs/flutter-apk (--require-release-apk set)')
    else:
        print('  SKIP: No release APKs present under build/app/outputs/flutter-apk.')

    if debug_apk.exists():
        dbg_mb = to_mb(debug_apk.stat().st_size)
        print(f'  app-debug.apk: {dbg_mb:.2f} MB (budget <= {MAX_DEBUG_APK_MB} MB)')
        if dbg_mb > MAX_DEBUG_APK_MB:
            failures.append(f'app-debug.apk ({dbg_mb:.2f} MB) > {MAX_DEBUG_APK_MB} MB')
        else:
            print('  PASS: app-debug.apk within budget.')

    mapping_file = Path('build/app/outputs/mapping/release/mapping.txt')
    if mapping_file.exists():
        mapping_bytes = mapping_file.stat().st_size
        mapping_mb = to_mb(mapping_bytes)
        print(f'  R8 mapping.txt: {mapping_mb:.2f} MB ({mapping_bytes} bytes)')
        if mapping_bytes <= 0:
            failures.append('R8 mapping.txt exists but is empty (0 bytes)')
        else:
            print('  PASS: Non-empty R8 mapping.txt emitted.')
    elif args.require_r8_mapping:
        failures.append('Missing R8 mapping.txt at build/app/outputs/mapping/release/mapping.txt (--require-r8-mapping set)')
    else:
        print('  SKIP: R8 mapping.txt not present.')

    print('\n' + '-' * 56)
    if failures:
        print('  RESULT: BUDGET / R8 GATE FAILED:')
        for item in failures:
            print(f'    * {item}')
        return 1

    print('  RESULT: All performance, size, & R8 checks PASSED.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
