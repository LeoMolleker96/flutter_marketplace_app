# Documentation

This project documents itself in three places. Each answers a different question.

| Where | Answers | Written when |
|---|---|---|
| Dartdoc (`///` in `lib/`) | *What is this code for, and what constrains it?* | With the code, always |
| `docs/concepts/` | *What did I learn here, and how does it work?* | At the end of each milestone |
| `docs/adr/` | *Why did we choose this over the alternatives?* | When a decision is made |

## `docs/concepts/`

One explainer per milestone, named `v0.N-<topic>.md`. Its audience is the author six months from now: it should explain the Riverpod and architecture concepts that milestone introduced from first principles, with references to the real code in this repo that uses them.

A concept doc is not a summary of what changed — `git log` does that. It explains the *idea*.

## `docs/adr/`

Architecture Decision Records, numbered sequentially from `0001`. Copy `0000-template.md` to start one.

Write an ADR when:

- adding, replacing, or removing a dependency,
- changing the layering or the dependency rules,
- choosing between state-management or data-flow patterns,
- picking a backend, database, or hosting approach,
- deliberately accepting a trade-off someone would otherwise "fix" later.

An ADR is immutable once accepted. To change a decision, write a new ADR that supersedes it and update the old one's status — never edit the original's substance. The record of a decision that turned out wrong is more valuable than a tidy history.
