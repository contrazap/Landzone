# Landzone - Agent Instructions

These instructions apply to the entire Landzone directory tree. The approved 2026-09-06
workflow replaces individually requested implementation steps and required user playtests.
Completed F00-F02 plans and archived ledgers retain historical rules and evidence only.

## Mission

Build the approved 2D Godot game through feature-sized deliveries. The user requests plans on
demand and then asks for implementation; the agent owns implementation, integration, fixes,
verification, and documentation within that delivery. Leave the project runnable at delivery
boundaries and preserve a concise handoff so another session can continue without chat history.

The user studies the systems and code later. Write readable, maintainable code and a current
code guide; do not slow delivery to manufacture teaching steps or speculative abstractions.
Landzone remains in Godot; the user's separate Unreal Engine learning does not migrate it.

## Sources of truth and context

At a new session, read in this order:

1. This file and PROGRESS.md for workflow, active state, blockers, and exact next action.
2. docs/GAME_DESIGN.md for product scope and invariants.
3. docs/ROADMAP.md for order, dependencies, and ownership.
4. Relevant entries in docs/CONTENT_CATALOG.md.
5. The active feature plan, if one exists.
6. Relevant sections of docs/CODE_GUIDE.md and docs/ARCHITECTURE_EVOLUTION.md.
7. Actual implementation files, integration points, and verification instructions/output.

Within the same session, reread only changed or newly relevant material. Follow references when
needed; do not load completed plans, archives, unrelated systems, or reusable templates by
default. Use the code guide as an index, not a substitute for inspecting affected code.

Actual files and verification evidence override stale implementation documentation. Report and
reconcile discrepancies within the authorized task. They do not silently override approved
product scope; resolve an actual scope conflict with the user.

## Status and next-action requests

For status-only requests such as "status", "check status", or "project status", silently inspect
current documents and Git/project state, run quick relevant existing checks when practical,
modify nothing, and return exactly one user-visible line:

`Status: <overall state> | Last: <last completed feature or milestone> | Current: <feature and delivery> | Next: <exact next action> | Blockers: <none or concise blocker>`

Do not send commentary or extra text for status-only requests.
"Check next step" or "what next" is also read-only: report the next plan or delivery and why it
is next. Neither request authorizes generating a plan or implementing code.

## Plan on demand

"Generate the next plan" and "Generate the plan for the next feature":

- Inspect the actual starting state and relevant verification baseline.
- Select the earliest dependency-satisfied incomplete feature in docs/ROADMAP.md.
- If it already has an unfinished plan, reconcile that plan instead of planning a later feature.
- Create only plans/F##_short_name.md using plans/FEATURE_PLAN_TEMPLATE.md.
- Default to one delivery containing the complete feature, integration, verification, and docs.
- Select concrete in-scope content in the plan, including names, behavior, and initial tuning.
  Proposed catalog entries need no separate approval before planning. Do not mark them approved
  merely because a plan was generated.
- State acceptance criteria, how the agent will establish each, expected files, boundaries,
  assumptions, refactoring needs, and reasons for any split.
- Update PROGRESS.md and the feature to Planned. Do not implement gameplay or future plans.

A request to implement the generated plan authorizes its stated in-scope content choices.
Update catalog states as authorized content is implemented. Routine tuning and implementation
details can change with recorded reasons. A core product change still requires user direction.

## Delivery sizing and execution

"Implement the plan", "Implement F##", and the legacy "Implement the next step" execute the
next incomplete dependency-satisfied delivery of the active feature plan. A single-delivery plan
means the whole feature. A split plan means one substantial delivery per request, unless the user
explicitly requests all its deliveries. "Continue implementation" resumes the current delivery.

If no plan exists, generate the requested feature's plan and stop for the user's implementation
request. Do not silently implement prerequisites, change roadmap order, or start another feature.

Split only for substantial integration/verification boundaries, multiple major systems, risky
state migrations, or an early outcome needed to determine later design. File creation, signal
wiring, testing, documentation, and routine refactoring are internal tasks, not separate user
requests. Do not impose a fixed number of steps, files, tokens, or sessions.

For each delivery:

1. Inspect Git status and preserve unrelated work; read the plan and affected code.
2. Run relevant existing baseline checks. Mark the delivery and feature In progress before edits.
3. Complete its internal checklist autonomously, including cohesive refactoring and integration.
4. Exercise behavior, inspect errors and affected regressions, and fix in-scope failures.
5. Review the final diff for ownership, readability, lifecycle, scope, and accidental changes.
6. Record acceptance evidence in the plan; update the code guide, decisions when material,
   catalog when applicable, and concise progress ledger.
7. Stop at the delivery boundary and report the outcome, verification, limitations, and next action.

If unexpected complexity requires a split, revise the active plan with the reason, preserve
completed work, define a coherent runnable boundary and remaining acceptance, and record the
exact continuation. Do not mark an unfinished delivery complete or drop criteria to fit a session.
If interrupted, leave an accurate In progress handoff: changed files, checks already run,
known failures, and first remaining action. Context compaction alone is not a reason to stop.

## Verification owned by the agent

Use game/tests/README.md for commands, coverage, and limitations. No required user manual checks.
Choose evidence by risk, not a test quota:

- Import/parser checks and meaningful runtime scenarios for changed scene/script integration.
- Existing regression checks for affected behavior; retain useful tests already in the repo.
- Agent-inspected rendered captures and exercised input flows for presentation/UI changes.
  A visible flag, node presence, or headless run does not prove the rendered result.
- Durable behavioral tests for save/load, resource ownership, progression, retry, pause, and
  deterministic generation when introduced or changed.
- Many fixed seeds for generator invariants, with bounded failure diagnostics.
- Export and execution of the exported build for release.
- git diff --check when Git exists.

Do not write tests for every function, trivial property, or cosmetic change. Prefer extending
useful scenarios over duplicating setup or adding a framework. Check real scenes/physics/input
where integration matters; use focused plain-data checks where they isolate important logic.
When structure changes, update obsolete path/identity assertions while preserving the behavioral
contract. Never weaken a valid test solely to make a failure disappear.

Record exact commands, result summaries, tested paths/scenarios and any capture artifacts.
Use isolated test saves when persistence arrives; never damage real player data.
Treat nonzero exits, missing success summaries, timeouts, and parser/runtime errors as failures
to investigate. Two startup frames prove startup only.

Establish a missing essential check through safe in-scope tooling when practical. If the
criterion still cannot be verified, record a required verification gap and leave the affected
delivery incomplete/Blocked; do not turn it into homework for the user or assume it passed.
Ask only for an actual external decision or capability needed to proceed.

Subjective enjoyment, unfamiliar-player clue comprehension, and experiential pacing remain
unassessed unless observed. They are optional feedback, not delivery or later-planning gates.
Agent walkthroughs and structural tests must not be described as proof of those human outcomes.
Known functional or rendering failures cannot be relabeled subjective to bypass completion.

"Verify" reruns relevant checks and reviews integration, without starting new roadmap work.
It can update evidence/status when justified. Implementation requests already authorize fixing
their in-scope failures; a verification-only request reports newly discovered defects.

## Definition of done and bookkeeping

Feature statuses: Not started, Planned, In progress, Blocked, Complete.
Delivery statuses: Not started, In progress, Blocked, Complete.

A delivery is Complete only when its outcome exists, required acceptance evidence passes,
no known introduced parser/runtime error remains, affected regressions pass, its boundary is
runnable, and the plan/progress/code guide reflect reality. List optional experiential limitations
separately from required verification gaps. A feature is Complete only after all deliveries and
all feature acceptance criteria pass. Release additionally requires the planned packaged build
evidence; code existence alone does not establish production readiness.

After each state-changing task update PROGRESS.md with date, overall state, last completed
feature/milestone, active feature/delivery, exact next action, blockers/gaps, concise roadmap
evidence links, and latest handoff. Keep detailed results in the owning plan.
For documentation-only work, record evidence in the handoff without inventing a gameplay feature.

## Engineering conventions

- Godot 4.7.1, 2D, GDScript, Compatibility renderer; project root game/.
- snake_case for files, variables, methods, groups and input actions; PascalCase for classes;
  SCREAMING_SNAKE_CASE for constants. Prefer useful types and centralized tuning.
- Treat maintainability and idiomatic Godot organization as default requirements, not optional
  cleanup that needs a separate feature justification. Put new files in clear feature/domain
  folders once responsibilities extend beyond a small cohesive set, and reorganize existing files
  at a safe delivery boundary before a flat or mixed-purpose directory becomes difficult to
  navigate. Update resource paths, tests and documentation together and verify the moves.
- Focused reusable scenes/scripts with explicit state ownership and lifecycle.
- Signals for events crossing ownership boundaries; clear direct calls within ownership.
- Custom Resources when multiple instances or editor-authored definitions justify them.
- Keep generated world data separate from live nodes. Use deterministic, independently seeded
  progression, layout, encounter, and decoration streams when those systems exist.
- Generate and validate progression topology before terrain decoration.
- Keep player-authored journal prose separate from authoritative progression facts.
- Direct movement, aim, fire, and ordinary pickup controls; paused commands for the deliberate
  operations specified in the design.
- Godot-native placeholder shapes or small repository-native assets; do not wait for external art.
- No third-party add-ons or runtime dependencies unless approved.
- No generic framework, speculative extension points, networking, 3D, real-time spacecraft flight,
  or shuttle interior.

## Architecture and learning record

Implement the simplest correct design for current requirements. Refactor for demonstrated
duplication, unclear ownership/lifecycle, distinct states obscured by conditionals, persistence,
generation, or integration needs. Within the delivery, establish a baseline, refactor, verify
preserved behavior, then add behavior where practical; separate approval sessions are unnecessary.
The demonstrated-pressure rule governs material abstractions and disruptive refactors; it does not
permit knowingly fragile, non-idiomatic or poorly organized code when an established, comparably
simple practice is available. Prefer the conventional maintainable approach by default. Record a
project-specific departure when its tradeoff is material.

Keep docs/CODE_GUIDE.md current: system responsibilities, file links, entry points, ownership,
important runtime flows, data lifetime, extension examples, reading order, and known limitations.
Explain why at non-obvious boundaries; avoid comments that merely restate code.
Record material decisions in docs/ARCHITECTURE_EVOLUTION.md with prior design, pressure,
chosen change, alternatives, evidence, and remaining debt. Do not invent historical rationale.
Completed plans own actual changed files, deviations and acceptance evidence. At F14 consolidate
the guide against the final implementation and check its links and examples.

## Scope and Git safety

Preserve docs/GAME_DESIGN.md invariants: static interior-only mothership; no shuttle interior or
real-time flight; on-foot compact procedural paths; lethal direct attacks without a health bar;
bounded condition systems; shuttle/site checkpoints; authored enemies/boss patterns; stable
deterministic runs; critical artifacts, verified facts, and journal surviving death.
Change scope or roadmap order only with explicit user approval.

Do not initialize Git, commit, push, create a remote, delete unrelated work, or rewrite history
unless explicitly requested. Inspect intended diffs before commits and remote/branch before
pushes. Preserve completed plans and historical observations; archive long history with a link.
Templates under templates/agent_project/ are starter material, not Landzone runtime instructions.
