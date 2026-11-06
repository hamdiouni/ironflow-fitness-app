#!/usr/bin/env python3
"""
IronFlow Coverage Gate & Per-Area LCOV Analyzer (Wave 2.1).

Usage:
  python scripts/check_coverage.py [path/to/lcov.info] [--min-overall 53.5] [--min-domain 65.0] [--min-data 55.0]
"""

from __future__ import annotations

import argparse
import pathlib
import sys
from collections import defaultdict


def parse_lcov(lcov_path: pathlib.Path) -> dict[str, tuple[int, int]]:
    """Returns {normalized_file_path: (lines_hit, lines_found)} excluding generated files."""
    if not lcov_path.exists():
        raise FileNotFoundError(f"LCOV file not found: {lcov_path}")

    records: dict[str, dict[int, int]] = defaultdict(dict)
    current_file: str | None = None

    for raw_line in lcov_path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw_line.strip()
        if line.startswith("SF:"):
            sf = line[3:].replace("\\", "/")
            if "lib/" in sf:
                sf = "lib/" + sf.split("lib/", 1)[1]
            current_file = sf
        elif line.startswith("DA:") and current_file:
            parts = line[3:].split(",")
            if len(parts) >= 2:
                line_no = int(parts[0])
                hits = int(parts[1])
                prev = records[current_file].get(line_no, 0)
                records[current_file][line_no] = max(prev, hits)
        elif line == "end_of_record":
            current_file = None

    summary: dict[str, tuple[int, int]] = {}
    for file_path, line_map in records.items():
        if (
            file_path.endswith(".g.dart")
            or file_path.endswith(".freezed.dart")
            or file_path.startswith("lib/l10n/")
            or file_path.startswith("lib/dev/")
            or "/preview/" in file_path
        ):
            continue
        found = len(line_map)
        hit = sum(1 for c in line_map.values() if c > 0)
        if found > 0:
            summary[file_path] = (hit, found)
    return summary


def classify_layer(path: str) -> str:
    if "/domain/" in path:
        return "domain"
    if "/data/" in path:
        return "data"
    if "/presentation/" in path:
        return "presentation"
    if path.startswith("lib/core/"):
        return "core"
    return "shared"


def classify_feature(path: str) -> str:
    parts = path.split("/")
    if len(parts) >= 3 and parts[0] == "lib" and parts[1] == "features":
        return parts[2]
    if len(parts) >= 2 and parts[0] == "lib":
        return parts[1]
    return "other"


def pct(hit: int, found: int) -> float:
    return (hit / found * 100.0) if found > 0 else 0.0


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify LCOV coverage thresholds per layer and feature.")
    parser.add_argument("lcov", nargs="?", default="coverage/lcov.info", help="Path to lcov.info")
    parser.add_argument("--min-overall", type=float, default=60.0, help="Minimum overall line coverage %% (never drop below Wave 2 baseline)")
    parser.add_argument("--min-domain", type=float, default=70.0, help="Minimum domain layer line coverage %%")
    parser.add_argument("--min-data", type=float, default=60.0, help="Minimum data layer line coverage %%")
    args = parser.parse_args()

    lcov_path = pathlib.Path(args.lcov)
    summary = parse_lcov(lcov_path)

    total_hit = sum(h for h, _ in summary.values())
    total_found = sum(f for _, f in summary.values())
    overall_pct = pct(total_hit, total_found)

    layer_totals: dict[str, list[int]] = defaultdict(lambda: [0, 0])
    feature_totals: dict[str, list[int]] = defaultdict(lambda: [0, 0])

    for path, (h, f) in summary.items():
        layer = classify_layer(path)
        layer_totals[layer][0] += h
        layer_totals[layer][1] += f

        feat = classify_feature(path)
        feature_totals[feat][0] += h
        feature_totals[feat][1] += f

    print("=" * 72)
    print(f"IRONFLOW COVERAGE REPORT ({len(summary)} non-generated files in LCOV)")
    print("=" * 72)
    print(f"OVERALL: {overall_pct:6.2f}% ({total_hit:,} / {total_found:,} lines)")
    print("-" * 72)
    print("BY ARCHITECTURAL LAYER:")
    for layer in ("domain", "data", "core", "presentation", "shared"):
        h, f = layer_totals[layer]
        print(f"  {layer:<15} {pct(h, f):6.2f}% ({h:,} / {f:,})")
    print("-" * 72)
    print("BY FEATURE AREA:")
    for feat, (h, f) in sorted(feature_totals.items()):
        print(f"  {feat:<15} {pct(h, f):6.2f}% ({h:,} / {f:,})")
    print("=" * 72)

    domain_pct = pct(*layer_totals["domain"])
    data_pct = pct(*layer_totals["data"])

    failures: list[str] = []
    if overall_pct < args.min_overall:
        failures.append(f"Overall coverage {overall_pct:.2f}% is below threshold {args.min_overall:.2f}%")
    if domain_pct < args.min_domain:
        failures.append(f"Domain layer coverage {domain_pct:.2f}% is below threshold {args.min_domain:.2f}%")
    if data_pct < args.min_data:
        failures.append(f"Data layer coverage {data_pct:.2f}% is below threshold {args.min_data:.2f}%")

    if failures:
        print("COVERAGE GATE FAILED:")
        for msg in failures:
            print(f"  - {msg}")
        return 1

    print("COVERAGE GATE PASSED: All layer and overall thresholds met.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

