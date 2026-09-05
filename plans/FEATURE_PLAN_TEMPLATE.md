# F## - Feature name

- Feature status: Planned
- Roadmap dependency: F## or none
- Created: YYYY-MM-DD
- Completed: -
- Current step: S01

## Objective

One short paragraph describing the player-visible or engineering outcome delivered by this
feature. State the learning value without turning the feature into a generic framework exercise.

## Preflight and actual starting state

- Files, scenes, systems, and tests inspected.
- Previous behavior that must remain working.
- Exact baseline commands run and their results.
- Assumptions confirmed from actual files.
- Uncommitted user changes that must be preserved.

## In scope

- Required behavior for this feature only.
- Slice requirements and content owned by this feature in `docs/ROADMAP.md`; confirm approval
  of any proposed catalog items before planning their implementation.
- Necessary integration with completed features.
- Diagnostics or test seams required to verify it.

## Out of scope

- Nearby roadmap work deliberately deferred.
- Content still awaiting approval.
- Speculative abstractions and unrelated cleanup.

## Current design

Describe only the current relevant ownership, lifecycle, event flow, and data shape. Include a
small diagram when it materially improves understanding.

## Refactoring assessment

- Observed pressure: Concrete duplication, ownership problem, testability problem, or new
  requirement that justifies structural change; write `None` when absent.
- Decision: Refactor now or keep the current concrete implementation.
- Behavior-preserving verification: Checks required before and after a material refactor.

## Expected files

List anticipated new or modified files. This is planning guidance, not permission for unrelated
changes. Update completion notes if reality differs.

## Step ledger

Allowed statuses: `Not started`, `In progress`, `Blocked`, `Complete`.

| Step | Outcome | Status | Verification |
| --- | --- | --- | --- |
| S01 | Small coherent outcome | Not started | Focused check |
| S02 | Small coherent outcome | Not started | Focused check |

Use roughly three to eight steps. Each step must be safe to request independently and must not
leave known parser errors. Prefer a runnable or inspectable checkpoint after every step.

## Implementation steps

### S01 - Imperative step title

**Purpose:** Why this step exists now.

**Changes:** Concrete files and behavior to add or modify. Do not paste a speculative full
implementation into the plan unless an exact snippet is essential to remove ambiguity.

**Do not:** Boundaries that prevent spilling into S02 or a later feature.

**Verify:** Exact automated command or static check and the expected result.

**Manual checkpoint:** Short interaction and literal expected observation, or `None` when the
step is entirely nonvisual.

### S02 - Imperative step title

Repeat the same structure for each step.

## Feature acceptance criteria

- [ ] Player-visible outcome works as specified.
- [ ] Integration with relevant earlier features remains working.
- [ ] Godot imports and parses without new errors.
- [ ] Focused automated verification passes.
- [ ] Required manual presentation/game-feel checks are confirmed.
- [ ] Progress and architecture documentation match actual state.

Replace generic criteria with concrete feature-specific statements during plan generation.
Include the roadmap's applicable playtest gate and all owned slice requirements. For new durable
state, include death, scene transition, and save/load outcomes. If introducing a penalty or
resource cost, include a usable recovery path in this feature rather than depending on later work.

## Verification plan

### Automated or headless

- Exact command.
- Expected successful result.
- Earlier checks that must be rerun.

### Manual

- Exact setup and actions.
- Literal visible or audible expectations.
- Failure cases to attempt.
- Applicable comprehension, retry, or pacing observations from the roadmap; identify checks
  that require an unfamiliar player rather than developer knowledge of the solution.

## Completion notes

Fill this section during implementation rather than predicting results:

- Actual files changed:
- Steps completed:
- Commands/tests and results:
- Manual checks performed:
- Deviations from plan:
- Architecture log entries:
- Remaining risks or debt:
- Suggested commit boundary:
