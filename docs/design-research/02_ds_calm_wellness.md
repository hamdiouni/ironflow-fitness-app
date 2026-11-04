# Command: python C:\Users\HP\.gemini\antigravity\brain\060968a6-0e51-47e1-bb82-7986b96fa8b4\scratch\ui-ux-pro-max-skill\src\ui-ux-pro-max\scripts\search.py nutrition and wellness tracker, calm --design-system -p IronFlow --density 4 --motion 3 --variance 3 --format markdown --persist --output-dir docs\design-research\run2-calm --force

## Output

```
## Design System: IronFlow

### Design Dials
- **Variance:** 3/10 — Centered / Minimal
- **Motion:** 3/10 — Subtle
- **Density:** 4/10 — Standard

### Pattern
- **Name:** Hero + Testimonials + CTA
- **Conversion Focus:** Social proof before CTA. Use a concise set of verified testimonials with photo, name, and role. CTA after social proof. Provide previous/next and pause controls; stop rotation on focus, hover, and reduced motion; announce slide position. Previous/next buttons and keyboard controls must expose every slide without dragging.
- **CTA Placement:** Hero (sticky) + Post-testimonials
- **Color Strategy:** Hero: Brand color. Testimonials: Light bg #F5F5F5. Quotes: Italic, muted color #666. CTA: Vibrant
- **Sections:** Hero > Problem statement > Solution overview > Testimonials carousel > CTA

### Style
- **Name:** Minimalism & Swiss Style
- **Mode Support:** Light supported | Dark supported
- **Keywords:** Clean, simple, spacious, functional, white space, high contrast, geometric, sans-serif, grid-based, essential
- **Best For:** Enterprise apps, dashboards, documentation sites, SaaS platforms, professional tools
- **Performance:** cost:low|drivers:none | **Accessibility:** risk:low|requires:contrast-text-4.5,keyboard,visible-focus,reduced-motion

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#6B7280` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#78716C` | `--color-secondary` |
| On Secondary | `#FFFFFF` | `--color-on-secondary` |
| Accent/CTA | `#0891B2` | `--color-accent` |
| On Accent/CTA | `#000000` | `--color-on-accent` |
| Background | `#F5F5F0` | `--color-background` |
| Foreground | `#0F172A` | `--color-foreground` |
| Card | `#FFFFFF` | `--color-card` |
| Card Foreground | `#0F172A` | `--color-card-foreground` |
| Muted | `#F6F6F7` | `--color-muted` |
| Muted Foreground | `#475569` | `--color-muted-foreground` |
| Border | `#EDEEEF` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| On Destructive | `#FFFFFF` | `--color-on-destructive` |
| Ring | `#6B7280` | `--color-ring` |

*Notes: Sage neutral + calm teal*

### Typography
- **Heading:** Lora
- **Body:** Raleway
- **Mood:** calm, wellness, health, relaxing, natural, organic
- **Best For:** Health apps, wellness, spa, meditation, yoga, organic brands
- **Google Fonts:** https://fonts.googleapis.com/css2?family=Lora:wght@400;500;600;700&family=Raleway:wght@300;400;500;600;700&display=swap
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Lora:wght@400;500;600;700&family=Raleway:wght@300;400;500;600;700&display=swap');
```

### Key Effects
Subtle hover (200-250ms), smooth transitions, sharp shadows if any, clear type hierarchy, fast loading

### Motion
**Scroll Reveal** (Subtle) — Trigger: scroll (viewport enter) | Duration: 300-400ms | Easing: `power1.out`
```js
gsap.from(el, { opacity: 0, y: 12, duration: 0.35, ease: 'power1.out', scrollTrigger: { trigger: el, start: 'top 90%', toggleActions: 'play none none reverse' } });
```
*Framework notes: Requires the ScrollTrigger plugin registered once via gsap.registerPlugin(ScrollTrigger); Use matchMedia('(prefers-reduced-motion: reduce)') to skip non-essential motion and render the final state immediately*
- ✅ Keep the y offset small (8-16px) so it reads as a fade, not a slide
- ❌ Don't reveal below-the-fold content needed for SEO/crawlers as invisible-by-default without a no-JS fallback

### Avoid (Anti-patterns)
- Inconsistent styling
- Poor contrast ratios

### Pre-Delivery Checklist
- [ ] No emojis as icons (use SVG: Heroicons/Lucide)
- [ ] cursor-pointer on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard nav
- [ ] prefers-reduced-motion respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px


============================================================
✅ Design system persisted to docs\design-research\run2-calm\design-system\ironflow/
   📄 docs\design-research\run2-calm\design-system\ironflow\MASTER.md

📖 Usage: When building a page, check docs\design-research\run2-calm\design-system\ironflow/pages/[page].md first.
   If it exists, its rules override MASTER.md. Otherwise, use MASTER.md.
============================================================

```
