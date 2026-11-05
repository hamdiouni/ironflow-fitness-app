# ADR-006: Body Map Rendering Architecture — Pre-Parsed 2D Vector Paths vs 3D Mesh

- **Status**: Proposed (Awaiting Owner Approval before Wave 4.6)
- **Date**: 2026-11-05
- **Wave**: Wave 4.6

## 1. Problem
Wave 4 introduces the interactive **Body Map** showing front and back muscle regions colored by Recovery (`Fresh`, `Recovering`, `Needs rest`), Load (7/30/90d), or Balance, with instant tap hit-testing on every muscle region and 60/120fps performance on mobile and web.

## 2. Options Considered

| Option | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **Option A: Single `CustomPainter` with Pre-Parsed `ui.Path` Regions + `Path.contains(localPosition)` Hit-Testing** | Store original anatomical front/back muscle region SVG path strings in a single Dart asset file, parse them once into `ui.Path` objects on initialization (scaled via `Matrix4`), render all regions + outlines in one `CustomPainter` pass, and use `path.contains(offset)` for exact pixel-accurate tap detection. | **0 new dependencies**; < 0.4ms frame paint time; exact arbitrary-polygon hit-testing; 100% identical behavior on Android, iOS, and Web (CanvasKit/Skwasm); trivial to overlay patterns/stripes for color-blind accessibility. | 2D front/back silhouette rather than rotatable 3D camera. |
| **Option B: Multi-Layer `flutter_svg` Widget Stack** | Render 18 separate `SvgPicture` widgets stacked on top of each other. | Uses existing `flutter_svg`. | Poor hit-testing (bounding box instead of exact muscle polygon); 18x compositing overhead. |
| **Option C: Real 3D `.glb` Model (`flutter_3d_controller` / `thermion_flutter` / Three.js WebView)** | Render a 3D anatomical mesh with per-submesh material tinting and raycast picking. | Flashy 360-degree rotation. | Heavy memory/GPU cost on low-end Android & Web; requires commercially licensed 3D anatomical mesh (~$150–$500); raycast picking across WebView/FFI is fragile and slow to load on Today screen. |

## 3. Recommendation
- **Option A (Single `CustomPainter` with pre-parsed `ui.Path` regions + `path.contains()` hit-testing + full accessible list view alternative)** for Wave 4.
- Keep Option C (Real 3D) strictly as a future Wave 6 proposal only if a licensed 3D mesh is acquired.
- **License of Vector Art**: Must be 100% original anatomical vector paths authored for IronFlow (or explicitly licensed CC0/MIT vector paths with recorded attribution — never copied from any third-party app).
