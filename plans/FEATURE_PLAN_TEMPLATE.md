# F## - Feature name

- Feature status: Planned
- Dependencies: F## or none
- Created: YYYY-MM-DD
- Completed: -
- Delivery mode: Single delivery (default), or split with the reason below
- Current delivery: D01

## Outcome and scope

Describe the concrete player-visible or engineering outcome.
List the owned roadmap requirements, necessary integration, and explicit exclusions.
Do not plan later features or paste a speculative implementation.

## Actual starting state

- Relevant files, scenes, ownership and data lifetimes inspected:
- Existing behavior to preserve:
- Baseline commands and actual results:
- User changes to preserve:
- Assumptions and required external decisions, if any:

## Content and design decisions

Select exact content needed by this feature from the catalog or specify an in-scope alternative.
Include behavior, meanings, initial tuning, and reasons. Proposed content can be planned without
prior separate approval; the user's implementation request authorizes the plan's selections.
Keep scope changes explicit and unresolved until approved.

Describe resulting ownership, interfaces, state lifetime, error handling and integration points.
For material refactoring: identify observed pressure, chosen boundary, alternative rejected,
and behavior-preserving checks. Write None when no refactor is justified.

## Delivery sizing

Explain why this feature can be completed and verified as one delivery, or identify substantial
boundaries that require a split. Do not split by file creation, wiring, testing, or documentation.
A split delivery must leave a runnable coherent outcome. Do not mandate an arbitrary step count.

| Delivery | Outcome and dependencies | Status | Acceptance IDs |
| --- | --- | --- | --- |
| D01 | Complete feature, including integration and verification | Not started | A01, A02 |

Delivery statuses: Not started, In progress, Blocked, Complete.
For a split plan, add only justified deliveries and keep them in this feature's plan.
"Implement the plan" completes the next delivery; a single-delivery plan completes the feature.

## Delivery implementation checklist

### D01 - Outcome title

- Expected files and their responsibilities:
- [ ] Implement the cohesive behavior and necessary refactoring.
- [ ] Integrate with affected existing systems.
- [ ] Exercise acceptance scenarios and fix in-scope failures.
- [ ] Review the diff and update evidence, catalog, code guide, decisions and progress.

Replace these prompts with concrete internal tasks. The agent executes the entire checklist
without pausing for user approval. For split features repeat this section per delivery.

## Acceptance and evidence

| ID | Required observable outcome | Agent verification method and expected result | Actual evidence / status |
| --- | --- | --- | --- |
| A01 | Feature-specific behavior, including a failure case | Exact scenario/command and assertions | Pending |
| A02 | Affected earlier behavior remains correct | Named regression scenario and success result | Pending |

Cover every owned scope requirement. Include imports, runtime errors, appropriate regressions,
and rendered evidence for changed presentation. For durable state include death, transitions and
save/load. For penalties/costs include recovery and depletion in this feature.
All required criteria must pass before their delivery is complete; all deliveries and feature
criteria must pass before the feature is complete.

## Verification execution

- Exact commands, working directory, required tools and success/failure signals:
- Existing checks to reuse; justified new persistent tests and the risk each protects:
- Runtime scenarios exercising real scenes/physics/input or focused plain-data contracts:
- Rendered captures/input interactions to inspect for visual changes; setup and artifact paths:
- Save isolation and cleanup strategy when relevant:
- Missing verification capabilities and how this delivery will establish them:

No test-per-function quota. Cosmetic changes can use rendering inspection and relevant existing
checks. Startup alone cannot verify a feature; headless state flags cannot prove rendering.
Keep important behavioral regressions; update structural assertions only when their contract
has legitimately changed. A missing essential check leaves the delivery incomplete, not passed.

## Optional experiential limitations

Record subjective enjoyment, first-time clue comprehension, and pacing qualities not observed.
These are not required user tasks or gates. Keep them distinct from functional/rendering defects
and required verification gaps. Never claim human understanding from an agent solution walkthrough.

## Completion and continuation record

Fill with actual outcomes during implementation:

- Deliveries completed / current status:
- Actual changed files, responsibility and reason for change:
- Acceptance IDs and commands/scenarios/results, including error-log review:
- Rendered observations and artifact links, or applicability/required gap:
- Content decisions implemented and tuning deviations:
- Code guide sections and architecture decision links:
- Remaining defects, required verification gaps and optional limitations:
- If interrupted or split: coherent boundary reached, changed scope of delivery, checks already
  run, first remaining action, and reason:
- Exact next action:

Do not request a separate documentation/test session merely to close this delivery.
