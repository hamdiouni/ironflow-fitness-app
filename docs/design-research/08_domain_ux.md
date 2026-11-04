# Command: python C:\Users\HP\.gemini\antigravity\brain\060968a6-0e51-47e1-bb82-7986b96fa8b4\scratch\ui-ux-pro-max-skill\src\ui-ux-pro-max\scripts\search.py fitness workout logger touch targets and accessibility --domain ux --max-results 5

## Output

```
## UI Pro Max Search Results
**Domain:** ux | **Query:** fitness workout logger touch targets and accessibility
**Source:** ux-guidelines.csv | **Found:** 5 results

### Result 1
- **Category:** Touch
- **Issue:** Touch Spacing
- **Platform:** Mobile
- **Description:** Adjacent touch targets need adequate spacing
- **Do:** Minimum 8px gap between touch targets
- **Don't:** Tightly packed clickable elements
- **Code Example Good:** gap-2 between buttons
- **Code Example Bad:** gap-0 or gap-1
- **Severity:** Medium

### Result 2
- **Category:** Responsive
- **Issue:** Touch Friendly
- **Platform:** Web
- **Description:** Mobile layouts need touch-sized targets
- **Do:** Increase touch targets on mobile
- **Don't:** Same tiny buttons on mobile
- **Code Example Good:** Larger buttons on mobile
- **Code Example Bad:** Desktop-sized targets on mobile
- **Severity:** High

### Result 3
- **Category:** Accessibility
- **Issue:** Target Size (Minimum)
- **Platform:** Web
- **Description:** WCAG 2.2 AA requires 24 CSS px pointer targets or an applicable exception
- **Do:** Use at least 24 by 24 CSS px or verify spacing equivalent inline user-agent or essential exceptions
- **Don't:** Assume native 44pt or 48dp guidance defines web conformance
- **Code Example Good:** min-width: 24px; min-height: 24px
- **Code Example Bad:** tiny adjacent icon buttons
- **Severity:** High

### Result 4
- **Category:** Touch
- **Issue:** Touch Target Size
- **Platform:** Mobile
- **Description:** Touch target guidance depends on platform and web context
- **Do:** Use 44pt on iOS and 48dp on Android; for web use the separate WCAG Target Size rule
- **Don't:** Treat one unit or minimum as universal across platforms
- **Code Example Good:** iOS 44pt; Android 48dp; Web 24 CSS px plus WCAG exceptions
- **Code Example Bad:** w-6 h-6 buttons
- **Severity:** High

### Result 5
- **Category:** Touch
- **Issue:** Pull to Refresh
- **Platform:** Mobile
- **Description:** Accidental refresh is frustrating
- **Do:** Disable where not needed
- **Don't:** Enable by default everywhere
- **Code Example Good:** overscroll-behavior: contain
- **Code Example Bad:** Default overscroll
- **Severity:** Low


```
