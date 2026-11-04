# Command: python C:\Users\HP\.gemini\antigravity\brain\060968a6-0e51-47e1-bb82-7986b96fa8b4\scratch\ui-ux-pro-max-skill\src\ui-ux-pro-max\scripts\search.py progressive overload and calorie tracking charts --domain chart --max-results 5

## Output

```
## UI Pro Max Search Results
**Domain:** chart | **Query:** progressive overload and calorie tracking charts
**Source:** charts.csv | **Found:** 3 results

### Result 1
- **Data Type:** Distribution / Statistical
- **Keywords:** distribution, statistical, spread, median, outlier, quartile, boxplot, accessible chart, keyboard accessible chart
- **Best Chart Type:** Box Plot
- **Secondary Options:** Violin Plot, Beeswarm
- **When to Use:** Showing spread, median, and outliers of a dataset; comparing distributions across multiple groups
- **When NOT to Use:** Fewer than 20 data points per group (distribution is not meaningful); audience unfamiliar with statistical charts
- **Data Volume Threshold:** Any sample size; aggregated representation so rendering is ⚡ Excellent at any volume
- **Color Guidance:** Box fill: #BBDEFB. Border: #1976D2. Median line: #D32F2F bold. Outlier dots: #F44336
- **Accessibility Grade:** deprecated: use Accessibility Risk
- **Accessibility Risk:** risk:low
- **Accessibility Notes:** Label median, quartiles, whiskers, and outliers directly; do not use color alone for statistical roles.
- **A11y Fallback:** Statistics table plus distribution summary. Keyboard: focus reveals the same statistics as hover.
- **Library Recommendation:** Plotly, D3.js, Chart.js (plugin)
- **Interactive Level:** Hover

### Result 2
- **Data Type:** Multi-Variable Comparison
- **Keywords:** radar, spider, multi-variable, attributes, dimensions, comparison, accessible chart, keyboard accessible chart
- **Best Chart Type:** Radar / Spider Chart
- **Secondary Options:** Parallel Coordinates, Grouped Bar
- **When to Use:** Comparing multiple entities across the same fixed set of attributes (e.g., product feature comparison)
- **When NOT to Use:** Axes > 8 (unreadable); values need precise comparison (use grouped bar); audience unfamiliar with radar charts
- **Data Volume Threshold:** 2–3 datasets maximum per chart; 5–8 axes; beyond 8 axes switch to parallel coordinates
- **Color Guidance:** Single dataset: #0080FF at 20% fill. Multiple: distinct hues with 30% fill. Border: full opacity
- **Accessibility Grade:** deprecated: use Accessibility Risk
- **Accessibility Risk:** risk:conditional
- **Accessibility Notes:** Use line styles, point shapes, and direct series labels in addition to color. Do not rely on color alone.
- **A11y Fallback:** Raw data table and grouped-bar alternative plus comparison summary. Keyboard: focus reveals values; buttons toggle series.
- **Library Recommendation:** Chart.js, Recharts, ApexCharts
- **Interactive Level:** Hover + Toggle

### Result 3
- **Data Type:** Part-to-Whole
- **Keywords:** part-to-whole, pie, donut, percentage, proportion, share, accessible chart, keyboard accessible chart
- **Best Chart Type:** Pie Chart or Donut
- **Secondary Options:** Stacked Bar, Waffle Chart
- **When to Use:** ≤5 categories; one dominant segment vs rest; emphasis on visual proportion over exact values
- **When NOT to Use:** Categories > 5; slice differences < 5% (visually indistinguishable); user needs precise values; accessibility-first context
- **Data Volume Threshold:** Max 6 slices; beyond that switch to stacked bar 100%
- **Color Guidance:** 5–6 max colors. Contrasting palette. Largest slice at 12 o'clock. Always label slices with %
- **Accessibility Grade:** deprecated: use Accessibility Risk
- **Accessibility Risk:** risk:high
- **Accessibility Notes:** Pie charts do not inherently fail WCAG; unlabeled color-only slices are inaccessible. Use direct labels and patterns, with a non-pie fallback. Do not rely on color alone.
- **A11y Fallback:** Percentage data table and concise part-to-whole summary; offer a stacked bar view. Keyboard: focus reveals slice values; Enter/Space drills in; Back button returns.
- **Library Recommendation:** Chart.js, Recharts, D3.js
- **Interactive Level:** Hover + Drill


```
