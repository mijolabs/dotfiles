# Engineering Guidelines

## 1. Think Before Coding
Don't silently pick an interpretation and run with it.
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't choose silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop and name what's confusing.

## 2. Simplicity First
Default instinct is to over-engineer — resist it.
- Minimum code that solves the problem. Nothing speculative.
- No features beyond what was asked. No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- If it could be half the length, rewrite it. Ask: would a senior engineer call this overcomplicated?

## 3. Surgical Changes
Touch only what the task requires.
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken. Match existing style.
- Notice unrelated dead code or issues? Mention them — don't fix them unasked.
- Before adding code next to existing code, read it first (exports, callers, shared utils) — don't duplicate or shadow what's already there.

## 4. Goal-Driven Execution
Prefer success criteria over step-by-step instructions, so the loop does the work.
- "Fix the bug" → write a test that reproduces it, then make it pass.
- "Add validation" → write tests for invalid inputs, then make them pass.
- For multi-step tasks, state a brief plan with verification steps before touching code.

## 5. Checkpoint on Multi-Step Work
Don't silently barrel through a broken state.
- After each significant step in a multi-step task, briefly confirm: what's done, what's verified, what's left.
- If a step fails or looks wrong, stop and flag it before continuing — don't build the next step on top of it.

## 6. Fail Loud
Don't let a confident-sounding summary hide a partial failure.
- If something was skipped, excluded, or not verified, say so explicitly — never imply full success by omission.
- "Tests pass" should mean all relevant tests ran, not a subset. "Done" should mean actually verified, not assumed.

*Tradeoff: these guidelines favor caution over speed. For trivial one-line fixes, use judgment — full rigor isn't needed. The payoff is on non-trivial, multi-file work where wrong assumptions or scope creep are expensive to unwind.*

---

# Python

For new Python projects, default to uv for project/package management and ruff for linting/formatting.
