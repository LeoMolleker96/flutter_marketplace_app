# CLAUDE.md — `marketplace_app`

Standards for this repository. Every session must read this before writing code.

---

## 1. What this project is

A secondhand-marketplace app (listings, chat, cart/checkout, favorites, reviews) built as a **single long-lived codebase that evolves through milestones** rather than a series of throwaway demos.

It targets **mobile (iOS/Android) and web** from that one codebase, and every screen must adapt to every window size (§6).

It is simultaneously a product and a learning vehicle. The owner:

- has **mastered Bloc** and is learning **Riverpod** from scratch,
- is **new to backend development**,
- is working toward a **Flutter architect** skill set (clean architecture, modularization, DI, testing strategy, CI/CD).

### The learning contract — read this before you write code

This repo deliberately trades speed for understanding. In this project you must:

- **Teach, don't just deliver.** Explain the concept before or while writing the code that uses it. A correct implementation the owner cannot explain back is a failed change.
- **Compare to Bloc when it clarifies.** The owner's mental model is Bloc; use it as the bridge (see the translation table in §5).
- **Do exactly what was asked — nothing more.** "Create the folders" means create the folders, not the code that will live in them. Finish the request, then stop and say what the obvious next step would be. Scope creep is not generosity here: unrequested code has to be read, judged, and usually deleted, and it takes the learning away from the owner.
- **Work in small, reviewable steps.** One concept at a time. Never dump a large multi-file implementation in a single pass.
- **Ask before adding any dependency.** Every package is an architectural decision and needs an ADR (§9).
- **Never silently "fix" architecture violations.** Point them out and explain why they violate the rules in §4.

This contract intentionally overrides the usual defaults of writing minimal comments and moving fast.

---

## 2. Toolchain

| Tool | Pinned version |
|---|---|
| Flutter | **3.47.5** (stable) |
| Dart | **3.13.4** — ships with that Flutter; never install Dart separately |
| Version manager | **FVM** (`fvm` 4.1.2) |

The SDK is managed by FVM, **not** by a system-wide Flutter install. Consequences:

- **Never run `flutter upgrade`.** It mutates the FVM version directory in place and breaks the pin. To change versions, use `fvm install <version>` + `fvm use <version>`.
- Prefer `fvm flutter ...` / `fvm dart ...` inside this project so the pinned version is always used.

```bash
fvm install 3.47.5
```

```bash
fvm use 3.47.5
```

> `fvm use` writes `.fvmrc`. **Commit it** — it pins the project regardless of what the FVM global is set to, so a fresh clone only needs `fvm install`.

### Commands

| Purpose | Command |
|---|---|
| Static analysis | `fvm flutter analyze` |
| Run tests | `fvm flutter test` |
| Format | `fvm dart format .` |
| Code generation (one-off) | `fvm dart run build_runner build --delete-conflicting-outputs` |
| Code generation (while working) | `fvm dart run build_runner watch --delete-conflicting-outputs` |

Code generation is **mandatory** after any change to a `@riverpod` or `@freezed` annotation — generated `.g.dart` / `.freezed.dart` files are committed.

---

## 3. Milestone roadmap

The app grows through these milestones. Each is a git tag.

| Tag | Adds | Concepts it exists to teach |
|---|---|---|
| `v0.1` | Auth screens + local draft listings (no backend) + adaptive navigation shell | `Notifier`, provider families, `autoDispose`, `ref.watch/read/listen`, breakpoints |
| `v0.2` | Real listings from an API, search + pagination | `AsyncNotifier`, `AsyncValue`, repositories over a real service |
| `v0.3` | Cart, favorites, checkout flow | derived providers, invalidation, mutations, first full test suite |
| `v0.4` | **Refactor** all features onto the layering in §4 | repository pattern, use-cases, refactoring live code |
| `v0.5` | Offline-cached listings + local-first chat | local database, sync, conflict resolution, offline persistence |
| `v0.6` | Split into packages (melos), design-system package, flavors | module boundaries, monorepo, environments |
| `v0.7` | CI, golden/integration tests, crash reporting, secure storage | production hardening, release engineering |

> **Current milestone: `v0.1`, starting — UI first.**
>
> Riverpod dependencies are installed, but **no Riverpod code exists yet** — nothing has run through `build_runner`, and there is no `data/` or `domain/` code.
>
> Built: the design system in `core/` (colours, type scale, spacing and radius tokens, `context.colors` / `context.textStyles`, and the `AppTextField` / `AppCheckbox` / `AppPrimaryButton` / `AppTitle` / `AppSubtitle` / `AppFootnote` widgets), `go_router` with `LoginView` at `/` and a `ListingsView` placeholder at `/listings`, and 45 tests. Presentation only — no behaviour behind the buttons.
>
> Plus Jakarta Sans is bundled in `assets/fonts/` and committed, so a clone builds without extra setup.
>
> *Each session that completes a milestone must update this line.*

---

## 4. Architecture

**Feature-first folders, Clean Architecture layers, Flutter's official component names** (views, view models, repositories, services).

```
lib/
  core/                      # cross-feature only: theme, router, errors, extensions, shared widgets
  features/
    <feature>/
      data/                  # DTOs, services, repository implementations
      domain/                # entities, repository interfaces, use-cases
      presentation/          # views (widgets) + view models (Riverpod notifiers)
```

### Component responsibilities

- **View** — widgets. Display state and forward user intent. Contains only layout, animation, and trivial conditionals. No business logic, no direct repository access.
- **View model** — a Riverpod `Notifier`/`AsyncNotifier`. Holds UI state, exposes commands, transforms domain models into what the view renders. This is the Bloc/Cubit equivalent.
- **Repository** — the **single source of truth** for a type of data. Owns caching, retry, error translation, and refresh. Returns domain entities, never DTOs.
- **Service** — the lowest layer, wrapping one external source (REST endpoint, local database, platform API). **Stateless**; exposes only `Future`/`Stream`.
- **Use-case** — a single business operation. Added *only* when logic spans repositories, is genuinely complex, or is reused by several view models. Not one per repository method.

### Dependency rules (non-negotiable)

- `presentation` → `domain` only. **It must never import `data`.**
- `data` → `domain` (it implements the interfaces declared there). It must never import `presentation`.
- `domain` imports neither of the other layers, and **no Flutter SDK types** — it must be testable in pure Dart.
- **Repositories never reference other repositories.** If two are needed together, that is a use-case.
- Services never reference repositories or each other.

Dependencies point inward, toward `domain`. A change that makes an arrow point outward is wrong even if it compiles.

---

## 5. State management — Riverpod 3

This project uses **`flutter_riverpod` 3.x** with **code generation**. Riverpod 3 changed substantially from Riverpod 2, and most material you will find online (and most of what a language model recalls by default) is Riverpod 2. **Follow this section over prior knowledge.**

### Rules

- **Code generation only.** Declare providers with `@riverpod` on a function or `Notifier` class. Do not hand-write `Provider(...)` declarations.
- **Banned APIs** — moved to `package:riverpod/legacy.dart` in v3 and not to be used here:
  - `StateProvider`
  - `StateNotifierProvider`
  - `ChangeNotifierProvider`
- Use **`Notifier`** (sync) and **`AsyncNotifier`** (async) only.
- `AutoDisposeNotifier` **no longer exists** — auto-dispose is folded into `Notifier` and controlled by codegen (`keepAlive`). `FamilyNotifier` is likewise fused into `Notifier`.
- **`Ref` is unified.** There are no provider-specific `Ref` subclasses any more.
- **`AsyncValue` is `sealed`** — prefer exhaustive `switch` pattern matching; `.when()` remains available where it reads better. Note `valueOrNull` is now just **`value`**.
- **Always check `ref.mounted` after an async gap** before writing state, exactly as you would check `BuildContext.mounted`.
- Reading rules:
  - `ref.watch` — inside `build` methods and provider bodies (reactive).
  - `ref.read` — inside callbacks only. Never in `build`.
  - `ref.listen` — for side effects (navigation, snackbars). This is the `BlocListener` equivalent.
- Providers now **retry automatically** on initialization failure with exponential backoff (200ms doubling to 6.4s). Do not hand-roll retry in a view model; configure it or handle it in the repository.

### Features to adopt at later milestones (currently experimental)

- **Mutations** — models the loading/success/error state of a side effect such as form submission. Adopt at `v0.3` for checkout.
- **Offline persistence** — opt-in provider caching to a local database, restored on restart. Adopt at `v0.5`.

### Bloc → Riverpod translation

| Bloc | Riverpod 3 |
|---|---|
| `Cubit` / `Bloc` | `Notifier` / `AsyncNotifier` |
| `emit(newState)` | `state = newState` |
| Event classes | plain methods on the notifier |
| `BlocProvider` | `@riverpod` declaration + `ProviderScope` at the root |
| `BlocBuilder` | `ref.watch` inside a `ConsumerWidget` |
| `BlocListener` | `ref.listen` |
| `BlocSelector` | `ref.watch(p.select(...))` |
| `RepositoryProvider` | just another provider |
| `bloc_test` | `ProviderContainer.test()` + overrides |

The key difference: in Bloc, dependency injection and state management are separate concerns. **In Riverpod, the provider graph is both** — which is why provider structure is an architectural decision here, not a detail.

---

## 6. Responsive and adaptive UI

The app ships to **mobile (iOS/Android) and web** from one codebase. Every screen must be usable at every window size — this is a hard requirement, not a polish pass at the end. A feature that only works at phone width is not done.

Flutter's own vocabulary distinguishes the two halves of this:

- **Responsive** — *fitting* the available space: reflowing, resizing, constraining.
- **Adaptive** — *changing what the UI is* for the available space: bottom navigation becomes a side rail, a list becomes a list-plus-detail pane.

We need both.

### Breakpoints

Use the Material 3 window size classes. These are **window** widths in logical pixels, never device sizes.

| Class | Width | Typical | Navigation |
|---|---|---|---|
| Compact | `< 600` | phone portrait, narrow browser window | `NavigationBar` (bottom) |
| Medium | `600 – 839` | tablet portrait, unfolded foldable | `NavigationRail` |
| Expanded | `840 – 1199` | tablet landscape, small desktop browser | `NavigationRail`, list-detail |
| Large | `1200 – 1599` | large tablet, desktop browser | standard `NavigationDrawer` |
| Extra-large | `≥ 1600` | wide desktop browser | standard `NavigationDrawer`, constrained content column |

Breakpoints are declared **once** in `core/` as named constants. A raw number like `600` must never appear in a widget.

### Rules

**Do:**

- Decide layout from **`LayoutBuilder` constraints** or **`MediaQuery.sizeOf(context)`** — the space actually available to the widget.
- Constrain content width on large screens (`ConstrainedBox` / `maxWidth`). Never let a text field or a line of body text span a 1920px window.
- Prefer `GridView` over `ListView` for the listings feed, using `SliverGridDelegateWithMaxCrossAxisExtent` so column count follows available width instead of being hardcoded.
- Preserve scroll position across resize and rotation with `PageStorageKey`.
- Solve touch first, then add mouse/keyboard affordances (hover, focus, shortcuts) as enhancements — web needs them, mobile does not suffer from them.

**Do not:**

- **Never branch on platform or device type** for layout — no `defaultTargetPlatform`, no `Platform.isAndroid`, no `shortestSide > 600` "is tablet" check. The app runs in resizable browser windows, split-screen, and foldables where device type tells you nothing about available space.
- **Never lock orientation.** No `SystemChrome.setPreferredOrientations`. It breaks foldables and Android large-screen requirements.
- **Never drive layout from `OrientationBuilder` or `MediaQuery.orientation`.** Orientation is not space.
- **Never use `MediaQuery.of(context)`** where `MediaQuery.sizeOf(context)` will do — the former rebuilds on every metric change, not just size.
- **Do not add `flutter_adaptive_scaffold`** — it is discontinued on pub.dev. Build the adaptive shell from `NavigationBar` / `NavigationRail` / `NavigationDrawer` directly.

### Where responsive logic lives — architectural rule

Responsiveness is a **presentation-layer concern only**.

- **Views** read the window size class and choose a layout.
- **View models must be screen-size agnostic.** A `Notifier` never knows the breakpoint, never exposes `isTablet`, and never returns different data for different widths.

The test: rotating the device or resizing the browser must *never* rebuild a view model or refetch data. If changing window width touches anything outside `presentation/`, the boundary has been violated.

Concretely: one view model per feature, several views (or one view with a `LayoutBuilder` switch) rendering it. This is also why the adaptive shell lives in `core/` — it is shared chrome, not feature logic.

### Web specifics

- Routing must support **deep linking and the browser back button** — go_router handles this, but every route needs a real URL; no state-only navigation.
- Check plugin web support before adding any package (§11).
- Test with the browser window genuinely resized, not just at a preset size.

---

## 7. Error handling

1. **Services throw.** They surface raw infrastructure failures (`DioException`, `SocketException`, database errors) and do not interpret them.
2. **Repositories translate.** They catch infrastructure exceptions and rethrow typed domain failures declared in `domain`.
3. **View models surface.** Failures reach the UI as `AsyncValue.error`; views render from the sealed `AsyncValue`.

**No `Either`/`dartz`.** `AsyncValue` already models loading/error/data. Layering `Either` on top duplicates that model and doubles the branching in every widget. This is a deliberate decision — see `docs/adr/0001`.

---

## 8. Testing

Both unit and UI tests are required. A feature is not done without them.

- **Unit tests** — every view model, use-case, and repository.
- **Widget tests** — every view, at **at least compact and expanded widths** (§6). A single-width widget test does not prove a responsive view works.
- **Golden tests** — from `v0.7`, one golden per breakpoint the view actually changes at.
- `test/` **mirrors `lib/` exactly**.
- Fakes use **`mocktail`** (no code-generated mocks — one code generator is enough).

Set the window size in a widget test through the test view, and always reset it:

```dart
tester.view.physicalSize = const Size(1200, 800);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.reset);
```

Riverpod 3 testing APIs to use:

| Need | API |
|---|---|
| Container in a unit test | `ProviderContainer.test()` — auto-disposes at test end |
| Inject fakes into a widget test | `ProviderScope(overrides: [...])` |
| Reach the container from a widget test | `tester.container` |
| Mock only a notifier's `build` | `NotifierProvider.overrideWithBuild()` |
| Stub an async provider's value | `FutureProvider.overrideWithValue()` |

### Definition of done

1. `fvm flutter analyze` reports no issues.
2. `fvm flutter test` passes.
3. Every view was verified at compact and expanded widths (§6).
4. Public APIs carry dartdoc (§9).
5. If a decision was made, an ADR exists (§9).

---

## 9. Documentation

Documentation is a first-class deliverable here, because the repo doubles as a learning record.

### Dartdoc

Every public class, method, and provider carries a `///` comment explaining **why it exists** and any non-obvious constraint or invariant — not a restatement of its name.

```dart
/// Caches listings so the feed survives an app restart.
///
/// Reads always resolve from the local database first; the network is a
/// background refresh, never a blocking dependency. This is what makes the
/// feed usable offline (see docs/adr/0005).
```

### `docs/concepts/`

One explainer per milestone, covering the Riverpod and architecture concepts that milestone introduced, written so the owner can re-read it months later. Written **at the end of each milestone**.

### `docs/adr/`

An Architecture Decision Record for every significant decision — dependencies, layering changes, state-management patterns, backend choices. Use `docs/adr/0000-template.md`. Writing ADRs is itself part of the architect training: record the alternatives rejected and why, not just the choice.

---

## 10. Git conventions

- **Conventional Commits**: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
- Branches: `feature/<name>`, `fix/<name>`.
- One git tag per milestone (`v0.1` … `v0.7`).
- Generated files (`*.g.dart`, `*.freezed.dart`) **are committed**.

---

## 11. Dependencies

Nothing beyond the Flutter SDK is installed yet. The intended stack, with versions verified on 2026-09-21:

| Package | Version | Milestone | Purpose |
|---|---|---|---|
| `flutter_riverpod` | 3.4.3 | v0.1 | state management + DI |
| `riverpod_annotation` / `riverpod_generator` | 4.0.9 | v0.1 | `@riverpod` code generation |
| `build_runner` | 2.16.1 | v0.1 | code generation runner |
| `very_good_analysis` | 11.0.0 | v0.1 | stricter lints (replaces `flutter_lints`) |
| `freezed` | 4.0.2 | v0.2 | immutable models + unions |
| `go_router` | 18.0.1 | v0.2 | declarative routing |
| `dio` | latest | v0.2 | HTTP client |
| `mocktail` | 1.0.5 | v0.1 | test fakes |

Confirm the latest version on pub.dev at the moment of installation rather than trusting this table — and **ask before adding anything not listed here**.

Because the app ships to web, every candidate package must be checked for **web platform support** before it is added; a package that only works on mobile is a blocker, not an inconvenience.

**Banned:** `flutter_adaptive_scaffold` — discontinued on pub.dev (last release 0.3.3+1, May 2025). Build the adaptive shell directly from `NavigationBar` / `NavigationRail` / `NavigationDrawer`.
