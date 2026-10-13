# ADR-0005: The session token is kept with `flutter_secure_storage`

- **Status:** Accepted
- **Date:** 2026-10-09
- **Milestone:** v0.1 (the roadmap listed secure storage for v0.7)

## Context

A successful sign-in answers with `{"token": "..."}`. The token is a credential:
whoever holds it is the user. The owner asked that the repository hand it to a
local data source to be kept "securely, secure storage comes to mind".

What is true and cannot be changed:

- The app runs on iOS, Android and **web**. A mechanism that works on one but
  not another is a blocker (CLAUDE.md §11).
- On web, anything a page stores for itself lives where a script injected into
  that page can also read it.
- The sign-in screen offers a "Remember me" box. It is about remembering the
  user's *password*, not about whether the session exists, so it has no bearing
  on the token: the token is always stored.

## Decision

**1. We use `flutter_secure_storage` 11.x**, inside `feature_auth`, behind the
`AuthLocalDataSource` interface. The token is stored under one key.

**2. The package lives in the feature, not in a shared package.** Nothing else
stores secrets yet; a shared `storage` package is premature. If a second feature
needs one, it moves down then.

**3. The token is always stored**, on every successful sign-in and sign-up,
replacing any previous one. "Remember me" does not touch it. What the box will
do — remembering the *password* — is a separate decision that is not made here:
storing a password is a heavier choice than storing a revocable token, and it
needs its own ADR (it should prefer the platform's credential manager and
autofill over keeping the password itself).

**4. A failure to store is its own failure**, `SessionNotSavedFailure`, not a
raw exception. The server has already said yes — after a sign-up the account
exists — so the screen says that the session could not be kept (and, for
sign-up, to sign in) instead of inviting a retry that would be refused.

**5. Android backups are off** (`allowBackup="false"`). The package keeps its
encryption key in the Keystore, which is never backed up; restoring the
encrypted data onto another device leaves it unreadable.

**6. We accept the weak case, in the open: on web the token sits in
`localStorage`**, encrypted with an experimental WebCrypto scheme that works
only over HTTPS or on localhost. This raises the bar; it does not close the
door, because the key is stored beside the data.

## Alternatives considered

### `shared_preferences`

- Works everywhere, no native surface.
- Rejected: plaintext on every platform. On mobile that gives up the Keychain
  and Keystore for nothing.

### An encrypted local database (Hive, drift with encryption)

- Would double as the offline store planned for v0.5.
- Rejected for a token: an encryption key must still be kept somewhere, which
  is the problem the Keychain and Keystore solve. It stays an option for data.

### Memory only, never written

- No stored secret to steal, and the simplest web story.
- Rejected: the user would sign in on every launch.

### An `HttpOnly` cookie set by the backend (web)

- The strongest answer for web: script cannot read it.
- Not available: it needs a backend that sets it and a same-site deployment, and
  neither exists. This is the main thing to revisit (below).

## Consequences

**Positive** — mobile tokens sit in the platform's secure store; the web
weakness is documented where the code is, not discovered later.

**Negative** — a native dependency with a pull of platform packages; the web
path is experimental; the package behaves differently per platform, so tests
use its in-memory mock and cannot prove the real behaviour; *nothing reads the
token back yet*, so for now this stores a value no one uses (ADR-0007); and
the "Remember me" checkbox is still decoration until its own decision is made.

**Revisit when** — the backend can issue an `HttpOnly` cookie for web; the
package's web support stops being experimental or is dropped; a second feature
needs to store a secret; or at v0.7, when hardening includes a content
security policy that protects the web `localStorage` exposure.
