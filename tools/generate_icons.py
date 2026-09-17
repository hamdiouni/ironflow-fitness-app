"""
IronFlow launcher icon generator.
Creates PNG icons at all required Android mipmap densities.
Uses only Python stdlib — no external dependencies.

Icon design: dark background (#0A0A0A), neon green (#00E676) dumbbell/flame shape.
"""

import struct
import zlib
import os
import math

# ── PNG writer ────────────────────────────────────────────────────────────────

def _write_png(filename, width, height, pixels):
    """Write RGBA pixels (list of (r,g,b,a) tuples, row-major) as PNG."""
    def chunk(name, data):
        c = name + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xFFFFFFFF)

    raw = b''
    for y in range(height):
        raw += b'\x00'  # filter type None
        for x in range(width):
            r, g, b, a = pixels[y * width + x]
            raw += bytes([r, g, b, a])

    sig = b'\x89PNG\r\n\x1a\n'
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    # RGBA = color type 6
    ihdr_data = struct.pack('>II', width, height) + bytes([8, 6, 0, 0, 0])
    idat_data = zlib.compress(raw, 9)

    png = sig
    png += chunk(b'IHDR', ihdr_data)
    png += chunk(b'IDAT', idat_data)
    png += chunk(b'IEND', b'')

    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'wb') as f:
        f.write(png)
    print(f'  Written: {filename}')


# ── Drawing helpers ───────────────────────────────────────────────────────────

def lerp(a, b, t):
    return a + (b - a) * t

def clamp(v, lo, hi):
    return max(lo, min(hi, v))

def circle_sdf(px, py, cx, cy, r):
    """Signed distance to circle (negative = inside)."""
    return math.sqrt((px - cx)**2 + (py - cy)**2) - r

def rounded_rect_sdf(px, py, x, y, w, h, r):
    """Signed distance to rounded rectangle."""
    qx = abs(px - (x + w/2)) - w/2 + r
    qy = abs(py - (y + h/2)) - h/2 + r
    return math.sqrt(max(qx, 0)**2 + max(qy, 0)**2) + min(max(qx, qy), 0) - r

def aa_alpha(sdf, aa=1.2):
    """Anti-aliased alpha from SDF."""
    return clamp((-sdf + aa/2) / aa, 0.0, 1.0)

def blend(bg, fg, alpha):
    """Alpha-blend fg over bg."""
    a = alpha / 255.0
    return tuple(int(bg[i] * (1 - a) + fg[i] * a) for i in range(3)) + (255,)


# ── Icon renderer ─────────────────────────────────────────────────────────────

BG      = (10,  10,  10)   # #0A0A0A
GREEN   = (0,  230, 118)   # #00E676
GREEN2  = (0,  176,  80)   # darker green for gradient
WHITE   = (255, 255, 255)

def render_icon(size):
    """Render the IronFlow icon at given pixel size."""
    pixels = []
    s = size
    cx = s / 2
    cy = s / 2
    pad = s * 0.08

    for y in range(s):
        for x in range(s):
            # ── Background: dark rounded square ──────────────────────────────
            bg_sdf = rounded_rect_sdf(x + 0.5, y + 0.5, pad, pad,
                                       s - 2*pad, s - 2*pad, s * 0.18)
            bg_a = aa_alpha(bg_sdf)

            # Start with transparent
            r, g, b, a = 0, 0, 0, 0

            if bg_a > 0:
                # Background fill
                r, g, b = BG
                a = int(bg_a * 255)

                # ── Subtle radial gradient on background ──────────────────────
                dist_center = math.sqrt((x - cx)**2 + (y - cy)**2) / (s * 0.5)
                glow = max(0, 1 - dist_center * 1.4)
                gr = int(lerp(BG[0], 30, glow))
                gg = int(lerp(BG[1], 30, glow))
                gb = int(lerp(BG[2], 30, glow))
                r, g, b = gr, gg, gb

                # ── Dumbbell shape ────────────────────────────────────────────
                # Bar (horizontal rectangle)
                bar_h = s * 0.10
                bar_w = s * 0.52
                bar_x = cx - bar_w / 2
                bar_y = cy - bar_h / 2
                bar_sdf = rounded_rect_sdf(x + 0.5, y + 0.5,
                                            bar_x, bar_y, bar_w, bar_h, bar_h/2)
                bar_a = aa_alpha(bar_sdf)

                # Left weight plate (big circle)
                lp_r = s * 0.175
                lp_cx = cx - bar_w / 2 - lp_r * 0.3
                lp_sdf = circle_sdf(x + 0.5, y + 0.5, lp_cx, cy, lp_r)
                lp_a = aa_alpha(lp_sdf)

                # Right weight plate (big circle)
                rp_r = s * 0.175
                rp_cx = cx + bar_w / 2 + rp_r * 0.3
                rp_sdf = circle_sdf(x + 0.5, y + 0.5, rp_cx, cy, rp_r)
                rp_a = aa_alpha(rp_sdf)

                # Left inner collar
                lc_r = s * 0.095
                lc_cx = cx - bar_w / 2 + s * 0.04
                lc_sdf = circle_sdf(x + 0.5, y + 0.5, lc_cx, cy, lc_r)
                lc_a = aa_alpha(lc_sdf)

                # Right inner collar
                rc_r = s * 0.095
                rc_cx = cx + bar_w / 2 - s * 0.04
                rc_sdf = circle_sdf(x + 0.5, y + 0.5, rc_cx, cy, rc_r)
                rc_a = aa_alpha(rc_sdf)

                # Combine dumbbell parts
                db_a = max(bar_a, lp_a, rp_a, lc_a, rc_a)

                if db_a > 0:
                    # Gradient: bright green top → darker green bottom
                    t = (y + 0.5) / s
                    fg_r = int(lerp(GREEN[0], GREEN2[0], t))
                    fg_g = int(lerp(GREEN[1], GREEN2[1], t))
                    fg_b = int(lerp(GREEN[2], GREEN2[2], t))

                    blend_a = db_a * bg_a
                    r = int(r * (1 - blend_a) + fg_r * blend_a)
                    g = int(g * (1 - blend_a) + fg_g * blend_a)
                    b = int(b * (1 - blend_a) + fg_b * blend_a)

                # ── Hole in weight plates ─────────────────────────────────────
                lh_sdf = circle_sdf(x + 0.5, y + 0.5, lp_cx, cy, lp_r * 0.32)
                rh_sdf = circle_sdf(x + 0.5, y + 0.5, rp_cx, cy, rp_r * 0.32)
                lh_a = aa_alpha(lh_sdf)
                rh_a = aa_alpha(rh_sdf)

                if lh_a > 0:
                    r = int(r * (1 - lh_a * bg_a) + BG[0] * lh_a * bg_a)
                    g = int(g * (1 - lh_a * bg_a) + BG[1] * lh_a * bg_a)
                    b = int(b * (1 - lh_a * bg_a) + BG[2] * lh_a * bg_a)
                if rh_a > 0:
                    r = int(r * (1 - rh_a * bg_a) + BG[0] * rh_a * bg_a)
                    g = int(g * (1 - rh_a * bg_a) + BG[1] * rh_a * bg_a)
                    b = int(b * (1 - rh_a * bg_a) + BG[2] * rh_a * bg_a)

                # ── Neon glow around dumbbell ─────────────────────────────────
                glow_sdf = min(
                    circle_sdf(x + 0.5, y + 0.5, lp_cx, cy, lp_r),
                    circle_sdf(x + 0.5, y + 0.5, rp_cx, cy, rp_r),
                    rounded_rect_sdf(x + 0.5, y + 0.5, bar_x, bar_y, bar_w, bar_h, bar_h/2),
                )
                glow_dist = max(0, glow_sdf)
                glow_intensity = max(0, 1 - glow_dist / (s * 0.06)) * 0.35
                if glow_intensity > 0:
                    r = int(clamp(r + GREEN[0] * glow_intensity, 0, 255))
                    g = int(clamp(g + GREEN[1] * glow_intensity, 0, 255))
                    b = int(clamp(b + GREEN[2] * glow_intensity, 0, 255))

            pixels.append((
                clamp(r, 0, 255),
                clamp(g, 0, 255),
                clamp(b, 0, 255),
                clamp(a, 0, 255),
            ))

    return pixels


# ── Main ──────────────────────────────────────────────────────────────────────

DENSITIES = {
    'mipmap-mdpi':    48,
    'mipmap-hdpi':    72,
    'mipmap-xhdpi':   96,
    'mipmap-xxhdpi':  144,
    'mipmap-xxxhdpi': 192,
}

BASE = 'android/app/src/main/res'

print('Generating IronFlow launcher icons...')
for density, size in DENSITIES.items():
    print(f'  Rendering {density} ({size}x{size})...')
    pixels = render_icon(size)
    path = os.path.join(BASE, density, 'ic_launcher.png')
    _write_png(path, size, size, pixels)

print('Done! All icons generated.')
