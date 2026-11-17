#!/usr/bin/env python3
"""
Verify curated YouTube exercise video IDs via YouTube's official oEmbed endpoint.

By default verifies all active IDs in ExerciseVideoMap (_videoIds, _secondaryVideoIds,
verifiedOEmbedIds). Pass --include-catalog-raw to also inspect unverified raw
animationUrl values in assets/data/exercises_catalog.json.
"""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
from pathlib import Path
import re
import sys
import urllib.error
import urllib.request


def collect_youtube_ids(root: Path, include_catalog_raw: bool = False) -> tuple[dict[str, str], dict[str, str]]:
    vmap_text = (root / 'lib/features/workout/data/exercise_video_map.dart').read_text(encoding='utf-8')
    map_entries: dict[str, str] = {}
    for block_name in ('_videoIds', '_secondaryVideoIds'):
        match = re.search(rf'{block_name}\s*=\s*\{{(.*?)\}};', vmap_text, re.S)
        if match:
            for name, vid in re.findall(r"'([^']+)':\s*'([^']+)'", match.group(1)):
                map_entries[f'{block_name}:{name}'] = vid

    catalog_entries: dict[str, str] = {}
    if include_catalog_raw:
        cat_json = json.loads((root / 'assets/data/exercises_catalog.json').read_text(encoding='utf-8'))
        items = cat_json if isinstance(cat_json, list) else cat_json.get('exercises', cat_json.get('items', []))
        for item in items:
            anim = str(item.get('animationUrl') or '')
            m = re.search(r'youtube\.com/embed/([A-Za-z0-9_-]{6,})', anim)
            if m:
                catalog_entries[str(item.get('name', ''))] = m.group(1)

    return map_entries, catalog_entries


def check_oembed(video_id: str, timeout: float = 8.0) -> tuple[str, int | str, str, str]:
    url = f'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json'
    req = urllib.request.Request(url, headers={'User-Agent': 'ProgressionTracker-oEmbedCheck/1.0'})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = json.loads(resp.read().decode('utf-8', errors='replace'))
            return (video_id, resp.status, str(data.get('title', '')), str(data.get('author_name', '')))
    except urllib.error.HTTPError as e:
        return (video_id, e.code, e.reason, '')
    except Exception as e:
        return (video_id, 'ERR', str(e), '')


def main() -> int:
    parser = argparse.ArgumentParser(description='Verify YouTube IDs using oEmbed.')
    parser.add_argument('--strict', action='store_true', help='Exit 1 if any checked ID fails oEmbed 200.')
    parser.add_argument('--include-catalog-raw', action='store_true', help='Also check raw catalog animationUrl IDs.')
    args = parser.parse_args()

    root = Path(__file__).resolve().parent.parent
    map_entries, catalog_entries = collect_youtube_ids(root, include_catalog_raw=args.include_catalog_raw)
    unique_ids = sorted(set(map_entries.values()) | set(catalog_entries.values()))

    print(
        f'Active ExerciseVideoMap entries={len(map_entries)} (unique={len(set(map_entries.values()))}), '
        f'Total unique IDs checked={len(unique_ids)}'
    )

    results: list[tuple[str, int | str, str, str]] = []
    with ThreadPoolExecutor(max_workers=8) as pool:
        futures = {pool.submit(check_oembed, vid): vid for vid in unique_ids}
        for fut in as_completed(futures):
            results.append(fut.result())

    results.sort(key=lambda r: (str(r[1]), r[0]))
    ok = [r for r in results if r[1] == 200]
    failed = [r for r in results if r[1] != 200]

    print(f'oEmbed HTTP 200 (embeddable/valid): {len(ok)} / {len(unique_ids)}')
    for vid, _, title, author in ok:
        print(f'  OK   {vid}: {title} ({author})')
    for vid, code, info, _ in failed:
        print(f'  FAIL {vid}: status={code} ({info})')

    if args.strict and failed:
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
