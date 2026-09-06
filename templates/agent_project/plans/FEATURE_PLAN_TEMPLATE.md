# F## - Feature outcome

- Feature status: Planned
- Dependencies: Specify completed prerequisite outcomes.
- Created: YYYY-MM-DD
- Completed: -
- Delivery mode: Single delivery by default; justify any split.
- Current delivery: D01

## Outcome and boundaries

Describe the concrete user-visible or engineering outcome, owned roadmap requirements,
necessary integration and exclusions. Select routine content/details here; requesting
implementation authorizes in-scope choices. Identify core scope changes separately.

## Actual starting state

Record files/owners/interfaces inspected, existing behavior to preserve, baseline commands and
actual results, user changes to preserve, and assumptions. Do not plan against imagined code.

## Design and sizing

Describe ownership, data lifetime, interfaces/error handling and any justified refactoring.
Name the pressure, alternative and behavior-preserving checks for a material structural change.
Explain why one delivery is sufficient or identify substantial integration/verification boundaries.
Do not divide file creation, wiring, tests and docs into separately requested steps.

| Delivery | Coherent outcome and dependencies | Status | Acceptance IDs |
| --- | --- | --- | --- |
| D01 | Complete feature with integration, checks and docs | Not started | A01 |

Delivery statuses: Not started, In progress, Blocked, Complete.
For split plans, each delivery leaves a runnable boundary. Implement the next delivery per
request unless the user asks for all deliveries; a single-delivery plan completes the feature.

## Internal implementation checklist

For each delivery name expected files/responsibilities and concrete tasks for implementation,
refactoring, integration, verification/fixes and documentation. Execute the whole checklist
without pauses between tasks. Expected files are guidance, not authorization for unrelated changes.

## Acceptance and evidence

| ID | Required observable outcome / error case | Agent method and expected result | Actual evidence/status |
| --- | --- | --- | --- |
| A01 | Replace with feature-specific behavior | Exact scenario, command or rendered observation | Pending |

Cover every owned requirement, affected regressions and relevant build/runtime/rendering checks.
Include persistence, security, recovery or determinism when the behavior introduces those needs.
Reference docs/VERIFICATION.md for confirmed tools. Choose persistent tests by risk, not quota;
reuse scenarios. Record how missing essential tooling will be established within this delivery.

All required criteria must pass before completion. Required gaps leave the delivery incomplete.
Record human experiential qualities separately as unassessed/nonblocking when not observed;
do not create user manual gates or waive known functional/rendering defects.

## Completion and continuation

- Actual changed files and reasons:
- Deliveries completed and acceptance evidence:
- Exact commands, scenarios, log review, artifact links and observed results:
- Content/tuning decisions and deviations:
- Code guide and architecture decision updates:
- Required gaps/defects versus optional experiential limitations:
- If interrupted/split: reason, boundary reached, checks already run and first remaining task:
- Exact next action:

Keep detailed evidence here; update the compact PROGRESS.md with links. Complete a feature only
after all deliveries and feature criteria pass. Stop before starting a later feature.
