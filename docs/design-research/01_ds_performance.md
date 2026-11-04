# Command: python C:\Users\HP\.gemini\antigravity\brain\060968a6-0e51-47e1-bb82-7986b96fa8b4\scratch\ui-ux-pro-max-skill\src\ui-ux-pro-max\scripts\search.py gym strength training performance mobile app --design-system -p IronFlow --density 8 --motion 7 --variance 6 --format markdown --persist --output-dir docs\design-research\run1-performance --force

## Output

```
## Design System: IronFlow

### Design Dials
- **Variance:** 6/10 — Balanced / Modern
- **Motion:** 7/10 — Standard
- **Density:** 8/10 — Dense / Dashboard

### Pattern
- **Name:** Feature-Rich Showcase
- **Conversion Focus:** Clear feature hierarchy. One key message per card. Strong CTA repetition.
- **CTA Placement:** Hero (sticky) + After features + Bottom
- **Color Strategy:** Brand primary + card bg #FAFAFA. Feature icons accent. CTA contrasting.
- **Sections:** Hero (value prop) > Feature grid/cards (4-6) > Use cases or benefits > Social proof or logos > CTA

### Style
- **Name:** Vibrant & Block-based
- **Mode Support:** Light supported | Dark supported
- **Keywords:** Bold, energetic, playful, block layout, geometric shapes, high color contrast, duotone, modern, energetic
- **Best For:** Startups, creative agencies, gaming, social media, youth-focused, entertainment, consumer
- **Performance:** cost:low|drivers:none | **Accessibility:** risk:conditional|requires:contrast-text-4.5,keyboard,visible-focus,reduced-motion

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#F97316` | `--color-primary` |
| On Primary | `#0F172A` | `--color-on-primary` |
| Secondary | `#FB923C` | `--color-secondary` |
| On Secondary | `#0F172A` | `--color-on-secondary` |
| Accent/CTA | `#22C55E` | `--color-accent` |
| On Accent/CTA | `#0F172A` | `--color-on-accent` |
| Background | `#1F2937` | `--color-background` |
| Foreground | `#F8FAFC` | `--color-foreground` |
| Card | `#313742` | `--color-card` |
| Card Foreground | `#F8FAFC` | `--color-card-foreground` |
| Muted | `#37414F` | `--color-muted` |
| Muted Foreground | `#CBD5E1` | `--color-muted-foreground` |
| Border | `#374151` | `--color-border` |
| Destructive | `#EF4444` | `--color-destructive` |
| On Destructive | `#000000` | `--color-on-destructive` |
| Ring | `#F97316` | `--color-ring` |

*Notes: Energy orange + success green*

### Typography
- **Heading:** Inter
- **Body:** Playfair Display
- **Mood:** bold typography, editorial, poster, near-black, vermillion, luxury, type-as-hero, manifesto, high-contrast
- **Best For:** Creative brand flagships, reading platforms, event apps, flash pages, luxury mobile experiences
- **Google Fonts:** https://fonts.googleapis.com/css2?family=Inter:ital,wght@0,400;0,500;0,600;0,700;0,800;1,400&family=JetBrains+Mono:wght@400&family=Playfair+Display:ital@1
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Inter:ital,wght@0,400;0,500;0,600;0,700;0,800;1,400&family=JetBrains+Mono:wght@400&family=Playfair+Display:ital@1&display=swap');
```

### Key Effects
Large sections (48px+ gaps), animated patterns, bold hover (color shift), scroll-snap, large type (32px+), 200-300ms

### Motion
**Stagger List** (Standard) — Trigger: load or scroll | Duration: 300-450ms | Easing: `back.out(1.4)`
```js
gsap.from('.grid-item', { opacity: 0, scale: 0.92, y: 16, duration: 0.4, stagger: { each: 0.06, from: 'start', grid: 'auto' }, ease: 'back.out(1.4)' });
```
*Framework notes: grid: 'auto' lets GSAP infer rows/columns from a CSS grid layout for a natural wave stagger; Use matchMedia('(prefers-reduced-motion: reduce)') to skip non-essential motion and render the final state immediately*
- ✅ Combine with from: 'center' for a bento-grid layout to draw the eye inward first
- ❌ Don't use back.out on dense data tables; the overshoot reads as sloppy on informational UI

### Avoid (Anti-patterns)
- Static design
- No gamification

### Pre-Delivery Checklist
- [ ] No emojis as icons (use SVG: Heroicons/Lucide)
- [ ] cursor-pointer on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard nav
- [ ] prefers-reduced-motion respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px


============================================================
✅ Design system persisted to docs\design-research\run1-performance\design-system\ironflow/
   📄 docs\design-research\run1-performance\design-system\ironflow\MASTER.md

📖 Usage: When building a page, check docs\design-research\run1-performance\design-system\ironflow/pages/[page].md first.
   If it exists, its rules override MASTER.md. Otherwise, use MASTER.md.
============================================================

```
