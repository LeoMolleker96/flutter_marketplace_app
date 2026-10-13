# ADR-0004: dio as the HTTP client, behind a `network` package

- **Status:** Accepted
- **Date:** 2026-10-09
- **Milestone:** v0.1 (the roadmap listed dio for v0.2)

## Context

Signing in needs the app to talk to a backend. Every feature that follows —
listings, chat, checkout — will too, so how requests are made, and where that
knowledge lives, is decided once or it is decided inconsistently six times.

Several constraints were already true:

- The app ships to **web** as well as mobile, so the client cannot depend on
  `dart:io` (ADR-0002).
- Features must not depend on each other (ADR-0003), yet all need a client.
- Some rules belong to the app, not to HTTP: what an expired session *means*,
  which server to call per environment.
- The owner asked for a client that reports a `401` through a callback it is
  handed, so the package can stay ignorant of what to do about it.

## Decision

**1. We use `dio` 5.x** as the HTTP client.

**2. It lives in its own package, `packages/network`**, which exposes one
function, `createDio({baseUrl, onUnauthorized, ...})`, and re-exports dio's own
types. A feature's data layer imports `network`, never `dio`.

**3. The package knows mechanics, never policy.** It builds a client and runs a
one-shot interceptor that calls `onUnauthorized` the first time any request
answers `401`. The base URL, the callback and the timeouts are all parameters:
the app shell (`apps/marketplace_app/lib/di/dio_provider.dart`) decides them.

**4. The client has timeouts** (15 s to connect, 30 s to send and receive,
overridable). dio has none by default, and without them a server that accepts a
connection and then says nothing leaves a spinner running forever.

**5. The repository translates `DioException` into a domain failure and never
passes the exception on.** Its request body carries the user's password; the
failure's `cause` keeps only the kind, status and endpoint.

> **Amendment (2026-10-13): dio is not hidden.** This ADR first claimed that
> which HTTP library sits underneath "stays the package's business" and that
> swapping it "touches one package". Neither is true. dio's types (`Dio`,
> `DioException`, `DioExceptionType`) are part of `network`'s effective public
> API through the re-export, and feature data layers use them directly
> (`AuthRemoteDataSourceImpl`, `AuthRepositoryImpl`, `RequestFailureCause`).
> Replacing dio would touch every feature's data layer, not just `network`.
> "One client" is a convention the package makes easy, not something it
> enforces: a feature that depended on dio itself would not be stopped by
> anything but review. What the package does give is one place for the
> interceptor, the timeouts and the base URL.

## Alternatives considered

### The `http` package

- Smaller and maintained by the Dart team, and web-safe.
- Rejected: no interceptors, so the `401` reaction would have to be wrapped
  around every call or in a hand-written client class — rebuilding the part of
  dio we actually want. Cancellation and timeouts are also thinner.

### `retrofit` or `chopper` (generated clients)

- Typed, declarative endpoints.
- Rejected for now: a second code generator beside `build_runner` for Riverpod,
  and the API does not exist yet, so there is no stable surface to generate from.
  Either can sit on top of dio later without changing this decision.

### dio called directly from each feature

- No extra package.
- Rejected: every feature would build its own client, so the interceptor, the
  timeouts and the base URL would each exist several times and drift. It also
  lets any feature choose a different HTTP library.

### A `network` package that also decides what a `401` means

- One fewer callback.
- Rejected: it would have to know about sessions, which belong to the app. The
  callback is exactly what keeps the dependency pointing the right way.

## Consequences

**Positive** — one client, one place for cross-cutting request behaviour;
features cannot disagree about timeouts (as long as they use the shared client;
see the amendment above); the package is small enough to test completely (14 tests today).

**Negative** — a package to maintain for one function; dio's types leak through
the re-export, so "ignorant of dio" is true of the features' *imports*, not of
what they hold.

**Revisit when** — we need request signing, retries with backoff or token
refresh (these may justify more of the package, or a different design for the
`401` callback); or when the backend's contract is generated from an OpenAPI
description, which would make a generated client worth its second generator.
