# ADR-0009: Breakpoints and the window-size class live in `design_system`

- **Status:** Accepted
- **Date:** 2026-10-13
- **Milestone:** v0.1

## Context

CLAUDE.md section 6 requires the breakpoints to be "declared once ... as named
constants", and a raw `600` must never appear in a widget. ADR-0002 put them in
`core/`, together with the adaptive navigation shell.

ADR-0003 then split the app into packages (`design_system`, `network`, the
features and the app shell) and there is no `core/` any more. For a while the
breakpoints had no home at all, and it showed: `design_system` already has
tokens with a mobile and a larger variant (`AppSpacing.marginMobile` /
`AppSpacing.margin`, `AppTypography.displayLgMobile` / `displayLg`), but nothing
could choose between them, so `AuthLayout` and `AppTitle` used the mobile value
even in a desktop browser.

Whatever holds the breakpoints must be importable by every feature, and by the
design system's own widgets, without breaking the package rules in section 4.

## Decision

**1. The breakpoints and the helper that classifies a width live in
`design_system`.** `Breakpoints` holds the named thresholds (600, 840, 1200,
1600), `WindowSizeClass` is the enum of the five Material 3 classes with
`WindowSizeClass.fromWidth` and `isAtLeast`, and `context.windowSizeClass` reads
the current class through `MediaQuery.sizeOf`. They are exported from the
package barrel.

They are design tokens of the same kind as spacing and type: they decide which
variant of a token applies. Every feature already depends on `design_system`,
and `design_system`'s own widgets (`AppTitle`) need them too.

**2. The adaptive navigation shell, when it is built, lives in the app shell**
(`apps/marketplace_app`), not in `design_system`. Only the shell owns routing,
and a navigation bar or rail is chrome around routes. It reads the same
`context.windowSizeClass`.

This amends ADR-0002 (decisions 2 and 4 named `core/`) and ADR-0003 (which
removed `core/`) on this one point.

## Alternatives considered

### A new `core` package

A package that holds only the breakpoints (and maybe the shell). Rejected: a
`pubspec.yaml`, an `analysis_options.yaml`, a barrel and a test setup for four
constants and one enum, and every feature would gain a second dependency to
decide the same thing `design_system` already decides. If shared code that is
not design appears later, that is the moment to reconsider.

### Constants in each feature

Each feature declaring its own thresholds. Rejected: it breaks "declared once".
Two features could disagree on where "wide" begins, and the day Material moves a
threshold it would be a hunt across packages.

### Keep them in the app shell

Rejected: features may not import the shell (section 4), so the screens that
need to branch could not read the thresholds.

## Consequences

**Positive**

- One definition of the thresholds; a screen asks for a class, not a number.
- Tokens with a mobile and a larger variant can finally be chosen between, with
  `isAtLeast(WindowSizeClass.expanded)`.
- No new package and no new dependency.

**Negative**

- `design_system` now holds a little layout logic as well as visual tokens. It
  stays free of anything feature-specific.
- The shell, when built, will import `design_system` for the class and keep its
  own widgets in the app package.

**Revisit when**

- Shared, non-visual layout code accumulates (a responsive grid, the shell)
  and wants a package of its own.
- Material changes its window size class thresholds.
- Desktop becomes a target and needs thresholds beyond these five classes.
