# ADR-0011: The web build serves CanvasKit itself and ships a strict Content Security Policy

- **Status:** Accepted
- **Date:** 2026-10-13
- **Milestone:** v0.1

## Context

Security finding S9. ADR-0005 accepts that on web the session token sits in
`localStorage`, where any script running in the page can read it. A Content
Security Policy (CSP) is the browser-enforced list of where a page may load
code from, so it is the main defence for that weak case. `web/index.html` had
none.

What is true and cannot be changed:

- By default Flutter's web build loads CanvasKit (the renderer, a `.js` plus a
  `.wasm`) from `https://www.gstatic.com/flutter-canvaskit/<engine revision>/`.
  That is a third-party script on the same origin as the token. A policy that
  allowed it would trust Google's CDN with every secret the page holds.
- The same default makes the engine fetch a fallback Roboto font from
  `https://fonts.gstatic.com/s/roboto/v32/...` at start-up.
- A CSP in a `<meta>` tag cannot express everything: `frame-ancestors`,
  `report-uri` and `sandbox` are ignored there.

## Decision

**1. CanvasKit is served from our own origin, by default.**
`apps/marketplace_app/web/flutter_bootstrap.js` is a custom bootstrap (Flutter's
templating fills `{{flutter_js}}` and `{{flutter_build_config}}`) that calls
`_flutter.loader.load({ config: { canvasKitBaseUrl: "canvaskit/" } })`. Every
build does this without anyone remembering a flag. `flutter build web` always
copies `canvaskit/` into `build/web/`, so there is nothing extra to host.

**2. Release builds use `--no-web-resources-cdn`.** The bootstrap alone is not
enough: in Flutter 3.47.5 the engine still fetches its fallback Roboto from
`fonts.gstatic.com` (verified in a browser: the request is attempted and the
CSP blocks it). The flag makes the build bundle Roboto into `assets/fonts/fallback/`
and drops the compile-time gstatic CanvasKit URL. The build command is:

```bash
fvm flutter build web --release --no-web-resources-cdn
```

**3. A strict CSP in a `<meta>` tag in `web/index.html`:**

| Directive | Value | Why |
|---|---|---|
| `default-src` | `'self'` | Anything not listed below may only come from our own origin. |
| `script-src` | `'self' 'wasm-unsafe-eval' 'sha256-MndvH2x...'` | Only our scripts run. `'wasm-unsafe-eval'` lets the browser compile WebAssembly (CanvasKit's `.wasm`) without allowing JavaScript `eval`. No `'unsafe-inline'`: the bootstrap is a file, not inline. The hash allows one specific inline script, see Debug workflow below. |
| `style-src` | `'self' 'unsafe-inline'` | Flutter's engine sets inline styles on the elements it creates; blocking them breaks the app. Style injection is a much smaller risk than script injection. |
| `img-src` | `'self' data: blob:` | Decoded images and the engine's canvases use `blob:` and `data:` URLs. |
| `font-src` | `'self'` | Fonts are bundled assets. |
| `connect-src` | `'self' http://localhost:3000` | Where the app may make requests (`fetch`, XHR, and the engine's own asset fetches): its origin and the development API. |
| `worker-src` | `'self' blob:` | The service worker is ours; the engine can start workers from `blob:` URLs. |
| `object-src` | `'none'` | No plugins. |
| `base-uri` | `'self'` | An injected `<base>` cannot redirect relative URLs to another origin. |
| `form-action` | `'none'` | The app has no HTML forms that post anywhere. |

**4. `connect-src` is deliberately tight for now.** It allows only `'self'` and
`http://localhost:3000`. The production API origin is added with flavors
(v0.6). Until then **a web build whose `API_BASE_URL` points anywhere else is
blocked by the CSP** (its requests fail). Note also that a release build
refuses a non-`https` base URL (CLAUDE.md §3), so the localhost entry only
matters for debug runs.

**5. Header-only protections are the host's job.** `frame-ancestors` (clickjacking),
`X-Content-Type-Options`, `Referrer-Policy` and similar cannot live in a `<meta>`
tag; they must be HTTP response headers set where the app is hosted. Hosting
is not decided yet; when it is, the same policy should also be sent as a header
there (a header policy can additionally use `frame-ancestors`).

## Debug workflow

`fvm flutter run -d web-server` (debug, DDC) also uses `web/index.html`. Its
dev server injects the DWDS client (`dwds/src/injected/client.js`, which carries
hot reload and debugging), and that client executes an inline script. Without
an allowance the browser blocks it and the app never starts: no `main()`, no
render. We observed this in headless Chrome on Flutter 3.47.5; with the hash
below the app renders and starts.

- **A hash, not `'unsafe-inline'`.** `script-src` carries
  `'sha256-MndvH2xoJITJx1vAmJTo0n71uGBofeMZfQTpl28Jz7s='`. The browser runs an
  inline script only if its content hashes to exactly that value, so the
  allowance covers that one script and not any inline script an attacker might
  inject. `'unsafe-inline'` would void `script-src` as a defence.
- **Inert in production.** A release build contains no such inline script, so
  the hash matches nothing there.
- **Tied to the Flutter/dwds version.** The hash is of Flutter 3.47.5's script.
  After a Flutter upgrade, if `flutter run -d web-server` does not start,
  open the browser console: the CSP error prints the hash of the script it
  blocked (`... a hash ('sha256-...') ... is required`). Replace the value in
  `web/index.html` with it.
- **`--no-web-resources-cdn` does not help in debug (verified on 3.47.5).**
  The flag bundles Roboto in release builds (see Decision), but in debug it did
  not: with
  `fvm flutter run -d web-server --no-web-resources-cdn`, debug still asks
  `fonts.gstatic.com` for Roboto and the CSP still blocks it. The flag is
  harmless there, but not worth recommending.
- **Fallback font fetches are blocked and logged in debug.** The engine requests
  Roboto and Noto fonts from `fonts.gstatic.com`; the CSP refuses them
  (`connect-src`), the console fills with errors and text that needs a
  fallback glyph can show boxes. The app still starts and renders. This is the
  known consequence below, and it is the only CSP noise in debug.

## Alternatives considered

### Allow `https://www.gstatic.com` in `script-src` (keep the CDN)

- Smallest change: CanvasKit keeps loading from the CDN and the build command
  stays plain.
- Rejected: it trusts a third-party script on the same origin as the token,
  which is exactly what the CSP is meant to rule out, and `gstatic.com` hosts
  far more than CanvasKit, so the allowance is wider than the need.

### No CSP

- Nothing to maintain and nothing to break.
- Rejected: with the token in `localStorage` (ADR-0005), the CSP is the only
  layer that limits what an injected or third-party script can load, and the
  cost is one meta tag.

### Self-host CanvasKit only through a build flag

- `--dart-define=FLUTTER_WEB_CANVASKIT_URL=...` or only `--no-web-resources-cdn`.
- Rejected as the sole mechanism: a forgotten flag silently falls back to the
  CDN, and the CSP would then just break the app. The bootstrap makes the safe
  behaviour the default. (The flag is still used, for the Roboto reason above.)

### Keep the meta strict and loosen it only by hand for debug (option A)

- No hash in the committed file; whoever debugs edits `index.html` locally.
- Rejected: Flutter has no per-mode `index.html`, so every debug session would
  need an edit that must never be committed. One forgotten revert either ships
  a loosened policy or breaks the next person's debug run.

### Drop the `<meta>` and send the CSP only as an HTTP header at hosting time (option D)

- Debug would be unaffected, since the dev server sends no policy.
- Rejected: hosting is not decided, so until then production would have no CSP
  at all, and the policy would stop being reviewable next to the code it
  constrains.

## Consequences

**Positive** — no third-party script runs on our origin; the renderer and the
fallback font come from our own deployment, so the app no longer depends on the
availability of Google's CDN; the policy is reviewable in one place.

**Negative** — the deployment is larger (`canvaskit/` is about 37 MB on disk, all renderer
variants; a browser fetches only the one it needs, about 5.4 MB of `.wasm` for
Chrome); the build command carries a flag; fallback fonts for glyphs
that no bundled font covers (for example emoji or non-Latin scripts) are still
requested from `https://fonts.gstatic.com/s/` by the engine and the CSP blocks
them, so those characters render as empty boxes until we bundle fallback fonts
or point the engine's `fontFallbackBaseUrl` at our own origin; every new
third-party origin (analytics, crash reporting, an image CDN, the real API)
needs an ADR and a CSP change; `'unsafe-inline'` for styles stays.

**Revisit when** — flavors arrive (v0.6) and the production API origin must be
added to `connect-src`; a host is chosen (add the headers, including
`frame-ancestors`); listings show user text or images in scripts the bundled
fonts do not cover; a Flutter release changes which origins the engine contacts;
or at v0.7 hardening, to see whether `'unsafe-inline'` for styles can go.
