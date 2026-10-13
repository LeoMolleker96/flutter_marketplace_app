# ADR-0006: The sign-up contract, and what it reveals about who has an account

- **Status:** Proposed — needs the owner's decision, and ultimately the backend's
- **Date:** 2026-10-09
- **Milestone:** v0.1

## Context

The backend does not exist, so the contract between app and server is written
here and in `AuthRemoteDataSourceImpl`, and the backend will have to meet it.
Sign-in's half was given by the owner (`POST /auth/sign-in` answering
`{"token": ".."}`, with `401` for wrong credentials). The sign-up half was
**proposed by the app** to mirror it, not agreed:

- `POST /auth/sign-up` with `{"email": "..", "password": ".."}`.
- Success answers `{"token": ".."}`, so the new user starts signed in.
- `409` means an account already exists for that email, and the screen says so.

A security review pointed out the cost of that last line. A distinct answer for
"this email is registered" lets anyone script sign-up over a list of leaked
addresses and learn which belong to people with an account — useful for
targeted phishing and for credential-stuffing the sign-in endpoint. Sign-in
avoids it by answering wrong username and wrong password identically.

## Decision

**Proposed, not yet accepted:** keep the `409` contract for now, because it is
the best experience and the app cannot fix enumeration alone, and make the
backend responsible for the mitigation. Concretely, the backend must:

1. rate-limit both `/auth/sign-in` and `/auth/sign-up` per address and per
   account;
2. enforce the password rules itself (the app's 8-character minimum is a
   convenience; add a maximum length and normalise the email, since the app only
   trims it);
3. be able to move to the alternative below without a client change beyond the
   message.

## Alternatives considered

### Never reveal it: always answer "check your inbox"

- Sign-up always succeeds from the client's point of view; an email is sent
  either way — a welcome link to a new address, a "you already have an account"
  note to an existing one.
- The right answer for a product that holds anything sensitive. Costs a mail
  service, a verification step and a flow where the user is *not* signed in
  straight away, which changes ADR-0005's "creating an account always stores a
  session".
- Not chosen yet: there is no backend or mail service to build it on, and the
  v0.1 goal is a working sign-in and sign-up to learn from.

### A CAPTCHA on sign-up

- Raises the cost of scripting it.
- Not chosen: bot detection is a product and backend decision, and a CAPTCHA
  needs a web and a mobile integration of its own.

### Accept enumeration without mitigation

- Simplest.
- Rejected: for a marketplace where accounts are linked to people, it hands
  attackers a free membership oracle.

## Consequences

**Positive** — the proposal is written down where the backend author will see
it; the risk is named instead of discovered; the client's failure type
(`EmailAlreadyInUseFailure`) isolates the decision, so changing it later edits
one message and one mapping.

**Negative** — until the backend rate-limits, the oracle exists; and every
sign-up detail here is the app's guess at a contract it does not own.

**Revisit when** — the backend is designed (decide this with it, not before); an
email service exists; or the marketplace stores anything beyond a name and
listings.
