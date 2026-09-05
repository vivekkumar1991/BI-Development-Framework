# Skill: formatting

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** changing number/date formats, styles, colors, fonts, alignment.

## Purpose

Apply presentation changes with a minimal patch — no structural side effects.

## Steps

1. Target the specific item's `Style` (`Format`, `Color`, `BackgroundColor`, `FontFamily`,
   `FontSize`, `FontWeight`, `TextAlign`, `PaddingLeft`, etc.) or the cell's textbox.
2. Use standard/.NET format strings for `Format` (e.g. `C2`, `N0`, `yyyy-MM-dd`, `P1`).
3. Prefer editing the exact style property; do not restyle unrelated items.
4. For conditional formatting, use an expression on the style property (keep it simple).

## Output

A minimal style/format patch on the targeted item(s). Structural checks via
[`validation`](validation.md); visual confirmation is a developer/SSDT step.
