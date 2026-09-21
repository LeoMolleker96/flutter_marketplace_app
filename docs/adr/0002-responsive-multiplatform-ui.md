# ADR-0002: Ship mobile and web from one codebase with window-size-driven adaptive UI

- **Status:** Accepted
- **Date:** 2026-09-21
- **Milestone:** pre-v0.1

## Context

The app must run on **mobile (iOS/Android) and web**. This was established before any UI existed, which matters: retrofitting responsiveness is one of the most expensive refactors in a Flutter codebase, because layout assumptions leak into widget trees and, worse, into state.

The environments differ in ways that rule out treating "web" as "mobile, but bigger":

- Browser windows are **continuously resizable**, so there is no stable screen size to design against.
- The same app may run in split-screen, picture-in-picture, on a foldable's inner or outer display, or in a ChromeOS window — all on "mobile" devices.
- Web brings deep linking, the back button, hover, and keyboard input as baseline expectations.

The project also needs a rule about *where* responsive logic is allowed to live, because that is the part that determines whether the layering in ADR-0001 survives contact with real screens.

## Decision

**1. One codebase, adaptive at runtime.** No separate web build or web-specific fork.

**2. Layout decisions are driven by available window space**, read through `LayoutBuilder` constraints or `MediaQuery.sizeOf`, classified by the **Material 3 window size classes**: compact `<600`, medium `600–839`, expanded `840–1199`, large `1200–1599`, extra-large `≥1600`. Breakpoints are declared once in `core/`.

**3. Responsive logic is confined to the presentation layer.** Views know the size class; **view models never do**. No `isTablet` flag on a notifier, no width-dependent data. The invariant: resizing the window must never rebuild a view model or refetch data.

**4. We build the adaptive shell ourselves** from `NavigationBar`, `NavigationRail`, and `NavigationDrawer`, living in `core/`.

**5. Both unit and widget tests cover multiple widths**; a view tested at one width is not considered tested.

## Alternatives considered

### Branch on platform or device type

`Platform.isAndroid`, `defaultTargetPlatform`, or the common `shortestSide > 600` "is tablet" heuristic. Rejected — and explicitly banned in `CLAUDE.md`. Device type does not tell you available space: a phone in split-screen has a tablet's device class and a compact window, a browser at 400px wide is a "desktop", and a foldable changes class while running. Flutter's own best-practices guidance names these as anti-patterns. Window size is the only honest input.

### Drive layout from orientation

`OrientationBuilder` or `MediaQuery.orientation`. Rejected for the same reason: orientation is not space. A landscape phone and a portrait tablet can present identical widths and need different layouts, and neither tells you anything in a resizable window.

### Use `flutter_adaptive_scaffold`

The obvious ready-made answer, and the one most tutorials reach for. Rejected because **the package is discontinued on pub.dev** (last release 0.3.3+1, May 2025). Adopting an unmaintained package for the navigation shell — the single most structural widget in the app — would be a liability at exactly the layer that is hardest to replace later. Building it from the three Material navigation widgets is a modest amount of code and is itself worth learning.

### Let view models expose a size class

Convenient — a view model could return a different model shape per breakpoint and keep the widgets dumb. Rejected because it couples business state to window geometry: every resize would invalidate state, the same feature would need per-width test coverage at the state layer, and `presentation`-only concerns would have leaked into logic that is supposed to be screen-agnostic. It would quietly undo ADR-0001's layering.

### Separate web application

Rejected outright. Two codebases means two implementations of every feature, and the project's entire premise is one long-lived codebase evolved through milestones.

## Consequences

**Positive**

- Responsive constraints are in place before the first widget, so the v0.4 refactor does not also have to be a responsiveness retrofit.
- The "view models are screen-agnostic" invariant gives a sharp, testable definition of a layering violation.
- Foldables, split-screen, and resizable browser windows are handled by the same mechanism as phone-versus-desktop, with no extra cases.

**Negative**

- Every view costs more to build and test — at minimum two widths, plus goldens per breakpoint from v0.7.
- The adaptive shell is hand-built and must be maintained as Material's navigation guidance evolves.
- Package selection is constrained: anything without web support is a blocker, which narrows the options for camera, file, and storage features later.

**Revisit when**

- A maintained, officially endorsed replacement for `flutter_adaptive_scaffold` appears.
- Desktop (macOS/Windows/Linux) is added as a target — the size classes already cover it, but input and window-management assumptions would need review.
- Material updates its window size class breakpoints.
