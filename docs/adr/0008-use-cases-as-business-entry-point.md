# ADR-0008: Keep a use case per user-facing auth operation as the entry point for business rules

- **Status:** Accepted
- **Date:** 2026-10-13
- **Milestone:** v0.1

This ADR amends [ADR-0001](0001-architecture-and-state-management.md) for `feature_auth`.

## Context

ADR-0001 and `CLAUDE.md` §4 say a use case is added **only** when logic spans repositories, is genuinely complex, or is reused by several view models, and that there is not one per repository method.

A review of `feature_auth` found that `SignInUseCase` and `SignUpUseCase` were pass-throughs: each was a single call to `AuthRepository`, and each was used by exactly one controller (`SignInController`, `SignUpController`). By the ADR-0001 rule they should not exist.

Two further facts shaped the decision:

- The sign-up business rules (`SignUpRules`: a valid email, a password with a minimum length, an uppercase letter, a number and a symbol) lived in `domain`, but nothing in `domain` enforced them. `SignUpRules.isComplete` was only read by the view, to enable or disable its button. A different caller of the repository would have sent invalid input to the server.
- The owner wants an explicit place for business rules, and wants to practise the use-case pattern in this project, which doubles as a learning vehicle.

## Decision

We will keep one use case per user-facing auth operation (`SignInUseCase`, `SignUpUseCase`) as the **single entry point for that operation's business rules**. Presentation calls the use case and never the repository directly.

`SignUpUseCase` now enforces the rules itself: before calling the repository it checks the email and the password with `SignUpRules`, and throws `InvalidSignUpFailure` — without calling the repository — when either breaks a rule. The view's disabled button stays as the UX guard that spares the person the error; the use case is the guarantee that the server is never called with input the app already knows is invalid. (The password confirmation is a field of the form, not of `SignUpParams`, so it remains the form's concern.)

`SignInUseCase` has no rules today and stays a pass-through. It is the place they will go.

## Alternatives considered

### Delete the use cases and let the controllers call `AuthRepository`

- Each controller would depend on `AuthRepository` (the interface in `domain`) and the shell would keep injecting `AuthRepositoryImpl` through `authRepositoryProvider`.
- This would **not** break the layer rule: presentation would depend on a `domain` interface, never on `data`, and dependencies would still point inward. It is the approach ADR-0001 prescribes, and it would have removed two classes, two providers and their tests.
- Rejected because the owner wants an explicit, named place for business rules and the practice of the pattern. That is a learning and design preference, not a technical necessity, and it is recorded as such.

### Keep them as pure pass-throughs and write nothing down

- The code stays as it was and the disagreement with ADR-0001 is left unsaid.
- Rejected because it contradicts ADR-0001 silently: a reader following the documented rule would conclude the code is wrong, or that the rule is not followed anywhere. A deliberate exception has to be written down where the rule is.

## Consequences

**Positive**

- Business rules have one home that is neither a widget nor a view model nor a repository, and it is testable in pure Dart.
- Sign-up input is validated by `domain`, not only by the view's button, so any future caller gets the same guarantee.
- The sign-in and sign-up operations have symmetrical structure, which makes the pattern easy to read and to extend.

**Negative**

- One extra class, one provider and one test file per operation, for code that is a single line in the sign-in case.
- A pass-through use case is acceptable in `feature_auth` only while it is the entry point for that operation's rules. If `SignInUseCase` never gains a rule, it is the kind of boilerplate ADR-0001 warned about.
- The rules now exist in two places in effect: the view's button reads them to guide the user, and the use case enforces them. Both read the same `SignUpRules`, so they cannot disagree, but a new rule must be added through `SignUpRules` and not in either caller.

**Revisit when**

- A second feature wants the same exception. ADR-0001's guidance still applies to new features unless a new ADR says otherwise.
- `SignInUseCase` has stayed a pass-through for a long time with no rule in sight.
- The v0.4 refactor reviews every feature onto the layering in `CLAUDE.md` §4.
