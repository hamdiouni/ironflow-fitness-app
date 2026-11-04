# Command: python C:\Users\HP\.gemini\antigravity\brain\060968a6-0e51-47e1-bb82-7986b96fa8b4\scratch\ui-ux-pro-max-skill\src\ui-ux-pro-max\scripts\search.py sports fitness, energetic --design-system -p IronFlow --density 6 --motion 9 --variance 8 --format markdown --persist --output-dir docs\design-research\run3-energetic --force

## Output

```
## Design System: IronFlow

### Design Dials
- **Variance:** 8/10 — Bold / Asymmetric
- **Motion:** 9/10 — Complex
- **Density:** 6/10 — Standard

### Pattern
- **Name:** Hero-Centric Design
- **Conversion Focus:** One primary CTA. Let the hero dominate the initial viewport without hiding the next content cue. Use a static hero and non-pulsing CTA when reduced motion is requested; provide video controls. Pause hero media offscreen/hidden and keep the final hero message and CTA static under reduced motion.
- **CTA Placement:** Hero dominant (center/bottom) + Sticky nav CTA
- **Color Strategy:** Hero: High-impact visual. Minimal text. Verify CTA label text against the button fill at 4.5:1 minimum; use 7:1 only for an explicit AAA normal-text target.
- **Sections:** Full-bleed Hero (headline + visual) > Single value prop strip > Key benefit or proof > Primary CTA

### Style
- **Name:** Brutalism
- **Mode Support:** Light supported | Dark supported
- **Keywords:** Raw, unpolished, stark, high contrast, plain text, default fonts, visible borders, asymmetric, anti-design
- **Best For:** Design portfolios, artistic projects, counter-culture brands, editorial/media sites, tech blogs
- **Performance:** cost:low|drivers:none | **Accessibility:** risk:low|requires:contrast-text-4.5,keyboard,visible-focus,reduced-motion

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#DC2626` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#EF4444` | `--color-secondary` |
| On Secondary | `#000000` | `--color-on-secondary` |
| Accent/CTA | `#DC2626` | `--color-accent` |
| On Accent/CTA | `#FFFFFF` | `--color-on-accent` |
| Background | `#FEF2F2` | `--color-background` |
| Foreground | `#7F1D1D` | `--color-foreground` |
| Card | `#FFFFFF` | `--color-card` |
| Card Foreground | `#7F1D1D` | `--color-card-foreground` |
| Muted | `#F0EDF1` | `--color-muted` |
| Muted Foreground | `#475569` | `--color-muted-foreground` |
| Border | `#FECACA` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| On Destructive | `#FFFFFF` | `--color-on-destructive` |
| Ring | `#DC2626` | `--color-ring` |

*Notes: Team red + championship gold [Accent adjusted from #FBBF24]*

### Typography
- **Heading:** Barlow Condensed
- **Body:** Barlow
- **Mood:** sports, fitness, athletic, energetic, condensed, action
- **Best For:** Sports, fitness, gyms, athletic brands, competition
- **Google Fonts:** https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@400;500;600;700&family=Barlow:wght@300;400;500;600;700&display=swap
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@400;500;600;700&family=Barlow:wght@300;400;500;600;700&display=swap');
```

### Key Effects
No smooth transitions (instant), sharp corners (0px), bold typography (700+), visible grid, large blocks

### Motion
**Page Transition** (Complex) — Trigger: route change | Duration: 500-800ms | Easing: `expo.inOut`
```js
const state = Flip.getState('.hero-image'); navigate(); Flip.from(state, { duration: 0.6, ease: 'expo.inOut', absolute: true, zIndex: 100 });
```
*Framework notes: Requires the GSAP Flip plugin; the 'from' and 'to' route must render the same element with a shared data-flip-id; Use matchMedia('(prefers-reduced-motion: reduce)') to skip non-essential motion and render the final state immediately*
- ✅ Verify the shared element exists in both DOM states before calling Flip.from to avoid a silent no-op
- ❌ Don't use shared-element transitions across more than one element pair per navigation; compounding Flips are hard to time correctly

### Avoid (Anti-patterns)
- Static content
- Poor fan engagement

### Pre-Delivery Checklist
- [ ] No emojis as icons (use SVG: Heroicons/Lucide)
- [ ] cursor-pointer on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard nav
- [ ] prefers-reduced-motion respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px


============================================================
✅ Design system persisted to docs\design-research\run3-energetic\design-system\ironflow/
   📄 docs\design-research\run3-energetic\design-system\ironflow\MASTER.md

📖 Usage: When building a page, check docs\design-research\run3-energetic\design-system\ironflow/pages/[page].md first.
   If it exists, its rules override MASTER.md. Otherwise, use MASTER.md.
============================================================

```
