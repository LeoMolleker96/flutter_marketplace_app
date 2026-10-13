# ADR-0003: One repository, many packages — a modular monolith managed with Melos

- **Status:** Accepted
- **Date:** 2026-10-07
- **Milestone:** v0.1 (brought forward from v0.6)

## Context

The app is meant to grow through several features — listings, chat, checkout,
favourites — and to stay understandable while it does. ADR-0001 set dependency
rules between layers (`presentation` never imports `data`, repositories never
reference each other). Until now those rules were **convention**: nothing but
discipline stopped one feature importing another's internals.

The owner wanted the separation of micro-frontends without the overhead of
several repositories, and asked for Melos to manage it. The roadmap had this at
v0.6; it was brought forward because moving now, with one screen and a design
system, is cheap, and moving later, with six features tangled together, is not.

Melos 8 builds on Dart **pub workspaces**: the workspace is declared in the root
`pubspec.yaml`, all packages share one dependency resolution and one
`pubspec.lock`, and Melos adds scripting and filtering on top.

## Decision

**1. A pub workspace with four packages**, under a root that contains no code:

```
pubspec.yaml            # workspace + Melos config
apps/marketplace_app/   # app shell: main, router, platform folders
packages/design_system/ # theme, tokens, shared widgets, the font
features/auth/          # feature_auth
features/listings/      # feature_listings
```

**2. A package boundary is a hard module boundary.** A package can only import
what its own `pubspec.yaml` declares, so "feature A must not use feature B" is
now enforced by pub, not by review. `feature_auth` and `feature_listings` depend
on `design_system` and on nothing else of ours.

**3. Features expose screens, never routes.** The app shell owns every path and
is the only place that knows signing in leads to the listings; it passes that in
as a callback (`SignInView(onSignedIn: ...)`). Features have no dependency on
`go_router`.

**4. Layering stays inside each feature package** (`src/data`, `src/domain`,
`src/presentation`), enforced by the rules in ADR-0001. Packages mark the seams
between features; folders still mark the seams between layers.

**5. Each package exposes a single barrel file** (`design_system.dart`,
`feature_auth.dart`, ...) and keeps everything else under `src/`.

## Alternatives considered

### Several repositories

The "real" micro-frontend shape. Rejected: a change that touches the design
system and two features becomes three pull requests that must land in order,
with versions to publish in between. For one developer, and for a team of any
size working on one product, that is cost with no matching benefit.

### Keep one package and rely on folders and review

What the project did until today. Rejected because it is the setup where
boundaries erode: every shortcut compiles, and the violation is discovered
later, in review, or never.

### The app at the repository root (`useRootAsPackage`)

Fewer files would have moved. Rejected: Melos's own documentation recommends
keeping the root free of an app, since it is where workspace configuration
lives, and a second app later would have forced the move anyway.

### One package per layer per feature

Separate `domain`, `data` and `presentation` packages, so the compiler also
enforces Clean Architecture. Rejected as premature: roughly seven `pubspec.yaml`
files for a handful of source files. Revisit if the layer rules are broken
despite review.

### Shared route constants in a navigation package

Lets any feature `context.go` to any other. Rejected: every feature then
depends on a contract naming every other feature, which is the coupling the
split was meant to remove.

## Consequences

**Positive**

- The dependency rules in ADR-0001 are enforced by the package graph.
- Each package analyses and tests on its own; Melos can run only the packages a
  change touched, which is what makes CI fast later.
- A feature can be developed against the design system without the rest of the
  app, and a second app could reuse the packages unchanged.

**Negative**

- More files: a `pubspec.yaml` and `analysis_options.yaml` per package, and a
  small test helper copied into each package that needs one.
- Assets and fonts belong to the package that declares them. The typeface now
  ships in `design_system`, so every `TextStyle` must name that package or
  Flutter silently falls back to the system font (see `AppTypography.fontPackage`).
- Code generation must run in every package that uses it, via `melos run codegen`.
- The Android Studio project is now opened from the repository root rather than
  from the app, and run configurations point at `apps/marketplace_app`.

**Revisit when**

- A feature grows large enough that its layers should be separate packages.
- A second app (admin, web-only) appears and shares more than the design system.
- Package versions start to matter — for example if a package is published.
