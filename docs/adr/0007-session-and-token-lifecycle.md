# ADR-0007: What happens to the session token after it is stored

- **Status:** Proposed — the design that the next milestone needs
- **Date:** 2026-10-09
- **Milestone:** v0.2

## Context

Signing in or up stores a token (ADR-0005). Nothing yet reads it. So today:

- no request carries it, so no authenticated call can be made;
- nothing restores a session when the app starts, so every launch asks for
  credentials, even after "Remember me";
- nothing clears it, so there is no sign-out;
- `onUnauthorized` in `dioProvider` is an empty function, so an expired token
  would be reported and ignored;
- `/listings` can be opened by URL without a session.

The interceptor in `packages/network` also cannot tell a `401` that means
"your session expired" from one that means "that password is wrong", and it
fires only once for the life of the client. Once `onUnauthorized` means "sign
out", one mistyped password would trigger a sign-out and use up the only report;
a real expiry afterwards would go unnoticed. The owner has said the backend will
not answer `401` to calls that need no token, which would remove the ambiguity;
but the sign-in contract *does* answer `401` for wrong credentials. The two
statements have to be reconciled with the backend.

## Decision

**Proposed.** Introduce a **session** as its own piece of state, owned by
`feature_auth` and exposed to the shell, rather than reading the token wherever
it is needed:

1. A `Session` provider (an `AsyncNotifier`) whose state is signed-out,
   signed-in, or restoring. On start it reads the stored token (`restoring`
   while it does), so the first screen can be chosen without a flash of the
   wrong one.
2. `AuthLocalDataSource` gains `readToken()` and `clearToken()`. Clearing is what
   sign-out calls, and what makes the stored token revocable from the device.
3. The app shell attaches the token to requests with an interceptor it supplies
   to `createDio` — `network` still knows nothing about sessions.
4. `onUnauthorized` calls sign-out on the `Session`, from `dioProvider`.
5. The router redirects by session state: signed-out users cannot reach
   `/listings`, and signed-in users are sent past the sign-in screen. The backend
   must still refuse unauthenticated calls; the client redirect is only
   courtesy.
6. The `401` ambiguity is settled by marking the auth endpoints as exempt from
   the `onUnauthorized` report, and by resetting the one-shot latch whenever a
   new session starts.

## Alternatives considered

### Read the token from storage on every request

- No session state to keep in sync.
- Rejected: an asynchronous platform read on every call, and still no answer for
  what the UI shows while signed out.

### Keep the token in a plain provider with no storage involvement

- Simple; fine for "forget on close".
- Rejected as the whole answer: it cannot implement "Remember me".

### Refresh tokens

- Short-lived access tokens with a refresh flow, the usual production design.
- Not chosen yet: it needs a backend that issues them. The decision above does
  not prevent it — a refresh would sit in the interceptor from point 3.

## Consequences

**Positive** — one source of truth for "who is signed in", which routing,
requests and sign-out all read; the stored token finally has a reader; the `401`
design becomes workable.

**Negative** — more machinery before the first real API call; a restoring state
every screen decision must respect; it needs the backend's token format and
lifetime, which do not exist.

**Revisit when** — the backend is designed (token expiry, refresh, and the
meaning of `401` decide half of this); or when a second feature needs to know
who is signed in.
