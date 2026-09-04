# Landzone - Agent Instructions

These instructions apply to the entire `Landzone` directory tree.

## Mission

Build Landzone incrementally as a 2D Godot game and a transparent study of feature
implementation, integration, and evidence-driven refactoring. Work from the real repository
state, implement only one approved plan step at a time, leave the project runnable after each
step whenever technically possible, and preserve enough evidence that a fresh agent can
continue without chat history.

The agent writes the game code in this project. The user remains in the loop by approving
plans, requesting one step at a time, reviewing diffs and explanations, running manual checks,
and deciding product-scope changes.

## Sources of truth

Read these before planning or editing, in this order:

1. `AGENTS.md` - workflow and engineering rules.
2. `PROGRESS.md` - current position, verified evidence, blockers, and exact next action.
3. `docs/GAME_DESIGN.md` - approved product scope and design invariants.
4. `docs/ROADMAP.md` - feature order and dependency boundaries.
5. `docs/CONTENT_CATALOG.md` - proposed or approved content definitions.
6. The active file in `plans/`, if one exists.
7. `docs/ARCHITECTURE_EVOLUTION.md` - earlier structural decisions and their causes.
8. The actual files under `game/` and current verification output.

Actual files and verification evidence override stale documentation. If they disagree, do not
guess. Report the discrepancy and reconcile the documentation as part of the authorized task.
Product changes still require the user's approval.

## Status-only response

When the user's sole request is `status`, `check status`, `project status`, or an equivalent
request for current status:

1. Silently read the sources of truth.
2. Inspect the actual project and Git state when they exist.
3. Run safe, quick existing verification when practical.
4. Do not modify files merely to answer status.
5. Return exactly one user-visible line and nothing else:

`Status: <overall state> | Last: <last completed feature or milestone> | Current: <active feature and step> | Next: <exact next action> | Blockers: <none or concise blocker>`

Do not send commentary, a preamble, headings, bullets, evidence, explanations, or follow-up
text for a status-only request. If the user asks for status plus another task, use the normal
workflow instead.

## Interpret common requests

### "Generate the plan for the next feature"

- Inspect the actual project and verification baseline first.
- Select the earliest dependency-satisfied incomplete feature in `docs/ROADMAP.md`.
- Create only `plans/F##_short_name.md` from `plans/FEATURE_PLAN_TEMPLATE.md`.
- Plan against existing files, not an imagined final architecture.
- Split the feature into small ordered steps that can be requested independently.
- Every step must have an observable outcome and focused verification.
- Update `PROGRESS.md` to `Planned` and set the exact next action.
- Do not implement any game code.
- Do not generate later feature plans in advance.

### "Implement the next step"

- Read the active plan and locate its first incomplete dependency-satisfied step.
- Baseline-check behavior that the step could affect.
- Mark only that step `In progress` before substantive edits.
- Implement only that step. Do not continue into the next step because it is convenient.
- Run the step's automated checks and record any manual check still owed by the user.
- Mark the step complete only when its stated evidence exists.
- Update the active plan, `PROGRESS.md`, and architecture log when applicable.
- Report what changed, what passed, and name the next step. Do not restate the whole plan.

If a planned step would necessarily leave parser errors or a non-runnable project, revise the
plan into a smaller safe sequence before implementing it and explain the correction.

### "Implement F##"

Treat this as permission to work on that feature, but still implement only the next incomplete
step unless the user explicitly asks for the complete feature. Confirm dependencies before
editing. Never silently implement prerequisite or later features.

### "Verify" or "verify the current step"

- Run existing automated and headless checks relevant to the current step.
- Inspect the exact files and integration points.
- State which manual observations still require the user.
- Do not claim a visual or hands-on result that was not observed.
- Update completion status only when the plan's evidence standard is satisfied.

## Progress bookkeeping

`PROGRESS.md` is the canonical handoff. After every state-changing task, update:

- Last documentation update.
- Overall status.
- Last completed feature or milestone.
- Active feature and step.
- Exact next action.
- Blockers and unverified manual checks.
- The roadmap row and concise implementation/verification evidence.
- Latest handoff.

Allowed feature statuses are `Not started`, `Planned`, `In progress`, `Blocked`, and `Complete`.
Allowed step statuses are `Not started`, `In progress`, `Blocked`, and `Complete`.

Never mark a feature complete merely because its code exists. All required acceptance criteria
and verification must pass. If the user reports a result that conflicts with documentation,
trust the report, inspect the project, and correct the ledger.

## Feature workflow

1. Inspect `git status` when Git exists and preserve unrelated user work.
2. Read the active plan and the files it names.
3. Run a relevant baseline check.
4. Implement the one requested step with the smallest cohesive change.
5. Verify syntax, runtime behavior, and affected regressions in proportion to risk.
6. Record actual files and evidence, not intended files and assumed results.
7. Update progress and, if structure changed, the architecture evolution log.
8. Stop at the step boundary and hand control back to the user.

## Engineering conventions

- Godot 4.7.1, 2D, GDScript, Compatibility renderer unless the user approves a change.
- The Godot project root is `game/`; keep repository process documents outside it.
- Use `snake_case` for files, variables, methods, groups, and input actions.
- Use `PascalCase` for named classes and `SCREAMING_SNAKE_CASE` for constants.
- Prefer typed GDScript when it improves validation without obscuring the code.
- Build reusable entities as focused scenes with focused scripts.
- Use signals for events crossing ownership boundaries; do not replace clear direct calls with
  signals merely to appear decoupled.
- Use custom `Resource` data only after multiple instances or editor-authored definitions create
  a real need.
- Centralize important tuning values with exported properties, constants, or data definitions.
- Keep generated world data separate from live scene nodes once procedural generation arrives.
- Use deterministic, independently seeded random streams for progression, layout, encounters,
  and decoration once those systems exist.
- Generate and validate progression topology before decorating terrain.
- Keep free-form journal text as player-authored data; never make progression depend on
  interpreting arbitrary prose.
- Use direct controls for movement, aiming, shooting, and ordinary pickups. Use the paused
  command interface for deliberate journal, codex, research, cooking, treatment, and precision
  traversal operations defined by the design.
- Use placeholder visuals made from Godot primitives or small repository-native assets. Do not
  wait for external art.
- Avoid third-party add-ons and runtime dependencies unless approved.
- Do not build a generic framework, speculative extension points, networking, 3D systems,
  real-time spacecraft flight, or a shuttle interior.

## Incremental design and refactoring

Implement the simplest correct design for the current approved requirement. Do not create the
final abstraction before there is evidence for it, and do not intentionally write poor code so
it can be refactored later.

Refactor when pressure is observable, such as:

- A second implementation duplicates behavior.
- Conditionals are obscuring distinct states or strategies.
- Ownership or lifecycle is ambiguous.
- Testing requires unrelated live scenes.
- Persistence or deterministic generation needs plain data.
- A new requirement cannot fit cleanly into the current boundary.

Whenever practical, separate work into independently verifiable changes:

1. Establish or re-run a passing behavioral baseline.
2. Refactor structure without changing behavior.
3. Verify the baseline again.
4. Add the new behavior.

Record material structural changes in `docs/ARCHITECTURE_EVOLUTION.md` with the prior design,
the new pressure, the chosen change, rejected alternative, verification, and remaining debt.

## Scope invariants

The stable baseline is defined in `docs/GAME_DESIGN.md`. In particular:

- The mothership is an interior-only static base.
- The shuttle has no playable interior and does not fly in real time.
- Exploration and combat are on foot in compact procedural path networks.
- Any direct enemy attack is lethal; there is no conventional health bar.
- Hunger, fatigue, injury, infection, and anomalous exposure are status systems, not armor or
  health-upgrade ladders.
- The shuttle and activated site entrances provide respawn checkpoints.
- Boss patterns and enemy behavior are authored; the generator selects fair authored modules.
- The world remains deterministic and stable throughout a run.
- Critical artifacts, verified codex facts, and the journal survive death.

Do not expand or reinterpret these invariants without explicit user approval. Put newly
suggested ideas in a note or discussion rather than silently implementing them.

## Verification standard

Use the strongest checks currently available. As the project grows, this should include:

- Godot headless import/parser checks.
- Focused verification scripts under `game/tests/` for deterministic logic and state changes.
- Main-scene smoke runs where headless execution is meaningful.
- Generator invariant tests across many fixed seeds.
- Regression checks for previously completed behavior touched by the step.
- Visual inspection for layout, telegraphs, readability, pause behavior, and game feel.
- `git diff --check` when Git exists.

The local console executable is expected at:

`C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe`

F00 must confirm it. Never claim a manual check was performed when it was not. Record manual
checks as pending until the user or agent actually observes them.

## Definition of done

A step is complete only when:

- Its in-scope outcome exists.
- It introduces no known parser or runtime error.
- Its focused automated checks pass when applicable.
- Any required manual check is either confirmed or explicitly left pending by the plan.
- The active plan and `PROGRESS.md` reflect reality.

A feature is complete only when:

- All of its steps are complete.
- All feature acceptance criteria pass.
- Relevant earlier behavior still works.
- The project is runnable from its documented main scene.
- Implementation and verification evidence are recorded.
- Architecture changes and known debt are documented.

## Documentation and Git safety

- Keep `docs/GAME_DESIGN.md` stable; change scope only with user approval.
- Keep detailed implementation notes in the active plan or `PROGRESS.md`.
- Use one plan per feature named `plans/F##_short_name.md`.
- Never bulk-generate future plans; they must react to actual implementation history.
- Do not initialize Git, commit, push, create a remote, delete work, or rewrite history unless
  the user explicitly requests that operation.
- When asked to commit, inspect the diff and include only intended project files.
- When asked to push, confirm the configured remote and branch before doing so.
