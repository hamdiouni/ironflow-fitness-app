#!/usr/bin/env python3
"""
IronFlow Coverage Gate & Baseline Ratchet Script.

Parses coverage/lcov.info (excluding generated files and dev-only routes),
reports overall, architectural-layer, feature-area coverage, and unimported
non-generated lib files, and enforces monotonic non-drop ratchets + Wave 2
per-area minimum floors.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
from datetime import datetime, timezone
import json
from pathlib import Path
import sys

DEFAULT_MIN_FLOORS = {
    'overall': 66.0,
    'layers': {
        'domain': 77.0,
        'data': 66.0,
        'core': 67.0,
        'presentation': 61.0,
        'shared': 73.5,
    },
    'features': {
        'auth': 52.0,
        'settings': 73.0,
        'sync': 55.0,
        'notifications': 58.0,
        'onboarding': 48.0,
        'main.dart': 45.0,
    },
}


def normalize_path(raw: str) -> str:
    return raw.replace('\\', '/').lstrip('./')


def is_excluded_source(rel_path: str) -> bool:
    norm = normalize_path(rel_path)
    return (
        norm.endswith('.g.dart')
        or norm.endswith('.freezed.dart')
        or '/l10n/' in norm
        or norm.startswith('lib/l10n/')
        or norm.startswith('lib/dev/')
    )


def parse_lcov(lcov_path: Path) -> dict[str, tuple[int, int]]:
    records: dict[str, tuple[int, int]] = {}
    current_file: str | None = None
    found = 0
    hit = 0

    for line in lcov_path.read_text(encoding='utf-8').splitlines():
        if line.startswith('SF:'):
            current_file = normalize_path(line[3:].strip())
            found = 0
            hit = 0
        elif line.startswith('LF:'):
            found = int(line[3:].strip())
        elif line.startswith('LH:'):
            hit = int(line[3:].strip())
        elif line.strip() == 'end_of_record' and current_file is not None:
            if not is_excluded_source(current_file):
                records[current_file] = (hit, found)
            current_file = None

    return records


def classify_layer(rel_path: str) -> str:
    norm = normalize_path(rel_path)
    if '/domain/' in norm:
        return 'domain'
    if '/data/' in norm:
        return 'data'
    if norm.startswith('lib/core/'):
        return 'core'
    if '/presentation/' in norm:
        return 'presentation'
    return 'shared'


def classify_feature(rel_path: str) -> str:
    norm = normalize_path(rel_path)
    parts = norm.split('/')
    if len(parts) >= 3 and parts[0] == 'lib' and parts[1] == 'features':
        return parts[2]
    if len(parts) >= 2 and parts[0] == 'lib':
        return parts[1]
    return 'other'


def pct(hit: int, found: int) -> float:
    return round((hit / found) * 100.0, 2) if found > 0 else 100.0


def count_unimported_files(lib_dir: Path, lcov_files: dict[str, tuple[int, int]]) -> list[str]:
    if not lib_dir.exists():
        return []
    imported = set(lcov_files.keys())
    missing: list[str] = []
    for dart_file in sorted(lib_dir.rglob('*.dart')):
        rel = normalize_path(str(dart_file))
        if is_excluded_source(rel):
            continue
        if rel not in imported:
            missing.append(rel)
    return missing


def compute_metrics(
    records: dict[str, tuple[int, int]],
    lib_dir: Path,
) -> dict:
    total_hit = sum(h for h, _ in records.values())
    total_found = sum(f for _, f in records.values())

    layer_sums: dict[str, list[int]] = defaultdict(lambda: [0, 0])
    feature_sums: dict[str, list[int]] = defaultdict(lambda: [0, 0])

    for path, (hit, found) in records.items():
        layer = classify_layer(path)
        layer_sums[layer][0] += hit
        layer_sums[layer][1] += found

        feat = classify_feature(path)
        feature_sums[feat][0] += hit
        feature_sums[feat][1] += found

    unimported = count_unimported_files(lib_dir, records)

    return {
        'file_count': len(records),
        'unimported_non_gen_files': len(unimported),
        'total_hit': total_hit,
        'total_found': total_found,
        'overall': pct(total_hit, total_found),
        'layers': {
            k: {
                'hit': v[0],
                'found': v[1],
                'pct': pct(v[0], v[1]),
            }
            for k, v in sorted(layer_sums.items())
        },
        'features': {
            k: {
                'hit': v[0],
                'found': v[1],
                'pct': pct(v[0], v[1]),
            }
            for k, v in sorted(feature_sums.items())
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description='Verify LCOV coverage thresholds and monotonic baseline ratchet per layer and feature.',
    )
    parser.add_argument('lcov', nargs='?', default='coverage/lcov.info', help='Path to lcov.info')
    parser.add_argument('--min-overall', type=float, default=60.0, help='Minimum overall coverage %%')
    parser.add_argument('--min-domain', type=float, default=70.0, help='Minimum domain layer coverage %%')
    parser.add_argument('--min-data', type=float, default=60.0, help='Minimum data layer coverage %%')
    parser.add_argument('--baseline', type=Path, default=None, help='Path to coverage_baseline.json')
    parser.add_argument(
        '--fail-on-drop',
        action='store_true',
        help='Fail if overall, any layer, or any tracked feature drops below baseline - max_drop (or misses min_floors).',
    )
    parser.add_argument('--lib-dir', type=Path, default=Path('lib'), help='Source lib/ root to count unimported files')
    parser.add_argument('--write-baseline', type=Path, default=None, help='Write measured baseline JSON and exit')
    args = parser.parse_args()

    lcov_path = Path(args.lcov)
    if not lcov_path.exists():
        print(f'ERROR: Coverage file not found: {lcov_path}', file=sys.stderr)
        return 1

    records = parse_lcov(lcov_path)
    metrics = compute_metrics(records, args.lib_dir)

    if args.write_baseline is not None:
        baseline_payload = {
            'schema_version': 2,
            'wave': 'wave-2',
            'generated_at_utc': datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'),
            'goal_overall_pct': 75.0,
            'max_drop_pct': 0.0,
            'lcov_files': metrics['file_count'],
            'unimported_non_gen_files': metrics['unimported_non_gen_files'],
            'overall': metrics['overall'],
            'layers': {k: v['pct'] for k, v in metrics['layers'].items()},
            'features': {k: v['pct'] for k, v in metrics['features'].items()},
            'min_floors': DEFAULT_MIN_FLOORS,
        }
        args.write_baseline.parent.mkdir(parents=True, exist_ok=True)
        args.write_baseline.write_text(json.dumps(baseline_payload, indent=2) + '\n', encoding='utf-8')
        print(f'Wrote coverage baseline to {args.write_baseline}')

    print('=' * 72)
    print(f"IRONFLOW COVERAGE REPORT ({metrics['file_count']} non-generated files in LCOV)")
    print('=' * 72)
    print(
        f"OVERALL:  {metrics['overall']:.2f}% "
        f"({metrics['total_hit']:,} / {metrics['total_found']:,} lines) "
        f"[unimported_non_gen_files={metrics['unimported_non_gen_files']}]"
    )
    print('-' * 72)
    print('BY ARCHITECTURAL LAYER:')
    for name in ('domain', 'data', 'core', 'presentation', 'shared'):
        entry = metrics['layers'].get(name, {'pct': 0.0, 'hit': 0, 'found': 0})
        print(f"  {name:<16} {entry['pct']:6.2f}% ({entry['hit']:,} / {entry['found']:,})")
    print('-' * 72)
    print('BY FEATURE AREA:')
    for feat, entry in metrics['features'].items():
        print(f"  {feat:<22} {entry['pct']:6.2f}% ({entry['hit']:,} / {entry['found']:,})")
    print('=' * 72)

    failures: list[str] = []

    if metrics['overall'] < args.min_overall:
        failures.append(f"OVERALL {metrics['overall']:.2f}% < --min-overall {args.min_overall:.2f}%")

    domain_pct = metrics['layers'].get('domain', {}).get('pct', 0.0)
    if domain_pct < args.min_domain:
        failures.append(f"domain {domain_pct:.2f}% < --min-domain {args.min_domain:.2f}%")

    data_pct = metrics['layers'].get('data', {}).get('pct', 0.0)
    if data_pct < args.min_data:
        failures.append(f"data {data_pct:.2f}% < --min-data {args.min_data:.2f}%")

    if args.baseline is not None:
        if not args.baseline.exists():
            print(f'ERROR: Baseline file not found: {args.baseline}', file=sys.stderr)
            return 1
        baseline = json.loads(args.baseline.read_text(encoding='utf-8'))
        max_drop = float(baseline.get('max_drop_pct', 0.0))

        # 1. Enforce explicit Wave 2 approved floors (always checked when baseline is supplied)
        min_floors = baseline.get('min_floors', DEFAULT_MIN_FLOORS)
        if 'overall' in min_floors and metrics['overall'] < float(min_floors['overall']):
            failures.append(
                f"OVERALL {metrics['overall']:.2f}% < floor {float(min_floors['overall']):.2f}%"
            )
        for layer_name, floor in min_floors.get('layers', {}).items():
            actual = metrics['layers'].get(layer_name, {}).get('pct', 0.0)
            if actual < float(floor):
                failures.append(f"layer:{layer_name} {actual:.2f}% < floor {float(floor):.2f}%")
        for feat_name, floor in min_floors.get('features', {}).items():
            actual = metrics['features'].get(feat_name, {}).get('pct', 0.0)
            if actual < float(floor):
                failures.append(f"feature:{feat_name} {actual:.2f}% < floor {float(floor):.2f}%")

        # 2. Enforce monotonic non-drop ratchet
        if args.fail_on_drop:
            base_overall = float(baseline['overall'])
            if metrics['overall'] + 1e-9 < base_overall - max_drop:
                failures.append(
                    f"OVERALL dropped: {metrics['overall']:.2f}% < baseline {base_overall:.2f}% (allowed drop {max_drop:.2f}%)"
                )
            for layer_name, base_pct in baseline.get('layers', {}).items():
                actual = metrics['layers'].get(layer_name, {}).get('pct', 0.0)
                if actual + 1e-9 < float(base_pct) - max_drop:
                    failures.append(
                        f"layer:{layer_name} dropped: {actual:.2f}% < baseline {float(base_pct):.2f}%"
                    )
            for feat_name, base_pct in baseline.get('features', {}).items():
                actual = metrics['features'].get(feat_name, {}).get('pct', 0.0)
                if actual + 1e-9 < float(base_pct) - max_drop:
                    failures.append(
                        f"feature:{feat_name} dropped: {actual:.2f}% < baseline {float(base_pct):.2f}%"
                    )

    if failures:
        print('COVERAGE GATE FAILED:')
        for item in failures:
            print(f'  * {item}')
        return 1

    print('COVERAGE GATE PASSED: All floors, layer thresholds, and ratchet checks met.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
