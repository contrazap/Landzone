# Landzone - Progress Ledger

Last documentation update: 2026-09-05

## Current state

- Overall status: F00 implementation in progress.
- Last completed feature or milestone: F00/S02 - Movement-input and focused-verification baseline.
- Current feature: F00 - Project foundation (`In progress`).
- Current step: F00/S03 - Verify and accept the foundation (`Not started`).
- Next action: Implement only F00/S03 from `plans/F00_project_foundation.md`.
- Known blockers: None.
- Unverified manual checks: F00/S03 will require the user to confirm that the placeholder window
  opens and shows `LANDZONE` and `Project foundation` legibly. The runnable shell exists, but
  this visual check has not been claimed from headless evidence.
  Future comprehension, recovery, and pacing checks remain assigned in the roadmap.
- Pending user decisions: Approve or revise the proposed first-slice content in `docs/CONTENT_CATALOG.md` before the feature that consumes each item.

## Canonical status line

`Status: F00 implementation in progress | Last: F00/S02 movement-input and focused-verification baseline | Current: F00/S03 - foundation acceptance not started | Next: implement only F00/S03 | Blockers: none`

Agents must reconstruct this line from verified state rather than copying it blindly.

## Roadmap status

Allowed statuses: `Not started`, `Planned`, `In progress`, `Blocked`, `Complete`.

| ID | Feature | Status | Plan | Implementation evidence | Verification evidence |
| --- | --- | --- | --- | --- | --- |
| F00 | Project foundation | In progress | `plans/F00_project_foundation.md` | S01 added the runnable shell. S02 added only four movement actions with WASD/arrow bindings, `game/tests/run_tests.gd`, its generated UID, and focused-test documentation; no player motion or later-feature action was added. | The focused test reported all project, renderer, movement-input, and scene-load checks passing. Godot 4.7.1 headless editor import, two-frame main-scene smoke, and `git diff --check` passed. |
| F01 | First expedition and lethal retry | Not started | Not generated | None | None |
| F02 | Ranged combat and first enemy | Not started | Not generated | None | None |
| F03 | Static mothership base | Not started | Not generated | None | None |
| F04 | Branching exploration and coordinates | Not started | Not generated | None | None |
| F05 | Searchable journal and basic persistence | Not started | Not generated | None | None |
| F06 | Codex and first knowledge loop | Not started | Not generated | None | None |
| F07 | Seeded path-network generation | Not started | Not generated | None | None |
| F08 | Precision teleport and traversal hazards | Not started | Not generated | None | None |
| F09 | First location, checkpoint, and artifact | Not started | Not generated | None | None |
| F10 | Hunting, inventory, and expedition status | Not started | Not generated | None | None |
| F11 | Mothership cooking, rest, and treatment | Not started | Not generated | None | None |
| F12 | Procedural mystery and progression validation | Not started | Not generated | None | None |
| F13 | Boss expedition and completion | Not started | Not generated | None | None |
| F14 | Replayability, hardening, and release | Not started | Not generated | None | None |

## Verification baseline

A minimal Godot project, main scene, movement-input baseline, and focused automated verification
script now exist. F00/S03 owns the final clean-state acceptance pass. The F00 plan owns:

- Recording the installed Godot version and executable paths.
- Maintaining `game/project.godot` and its minimal runnable main scene.
- Establishing the first repeatable headless import and smoke checks.
- Maintaining the initial `game/tests/` verification entry point.
- Confirming the Compatibility renderer and project layout.

Confirmed executables:

```text
C:\MyFiles\Godot\Godot_v4.7.1-stable_win64.exe
C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe
```

Both files exist with file version `4.7.1`; the console reports
`4.7.1.stable.official.a13da4feb`. F00 implementation must preserve and record this baseline.

## Active blockers and known issues

- No active blockers.
- F00/S01 is complete; the runnable shell now exists.
- F00/S02 is complete; the four movement actions and focused test entry point now exist.
- F00/S03 has not started; full acceptance and the manual runtime-window check remain pending.
- Content names and tuning values in `docs/CONTENT_CATALOG.md` remain proposed until explicitly
  approved; the review approval does not approve all content candidates.

## Latest documentation evidence

- F00/S02 on 2026-09-05 added `move_up`, `move_down`, `move_left`, and `move_right` with paired
  physical WASD and arrow-key bindings. It added one focused SceneTree test and a README with
  the exact local verification commands; no player motion or future-feature input was added.
- S02 verification passed: the focused test confirmed project identity, main-scene setting,
  Compatibility renderer settings/features, all eight required key bindings, and main-scene
  loadability. Headless editor import, the two-frame main-scene smoke run, and
  `git diff --check` also exited 0.
- F00/S01 on 2026-09-05 added a Godot 4.7.1 project with an explicit Compatibility renderer,
  960x540 2D viewport, and `res://main.tscn` as the main scene. The self-contained Control scene
  displays the literal labels `LANDZONE` and `Project foundation` over a plain background.
- S01 verification passed: headless editor import and the two-frame main-scene smoke run both
  exited 0 without parser, load, or runtime errors; `git diff --check` exited 0. The visual
  presentation remains unverified until the explicit S03 manual gate.
- F00 planning preflight on 2026-09-05 inspected the actual placeholder-only `game/` tree,
  confirmed a clean `main` worktree tracking `origin/main`, verified both expected Godot
  executables and console build `4.7.1.stable.official.a13da4feb`, and passed
  `git diff --check`.
- `plans/F00_project_foundation.md` defines three independently requestable steps: create the
  runnable Compatibility-renderer shell, add the movement input and focused test baseline, then
  run full automated acceptance and record the user's manual placeholder-window check. No game
  code or project files were created during planning.
- User approved the review recommendations and requested the necessary changes on 2026-09-05.
- `docs/ROADMAP.md` now moves the fixed knowledge loop to F06, renumbers former F06-F10 to
  F07-F11, assigns every first-slice requirement, and defines staged playtest gates.
- `docs/GAME_DESIGN.md` defines stable meanings versus variable solutions, an early inference
  example, bounded persistent statuses, resource/cache retry rules, checkpoint abandonment,
  basic mothership recovery, and pacing guided by observations rather than a duration minimum.
- `docs/CONTENT_CATALOG.md` assigns content owners and updates approval timing. Proposed content
  remains proposed. `plans/FEATURE_PLAN_TEMPLATE.md` carries ownership, persistence, recovery,
  and applicable manual gates into future plans.
- Prior documentation-review verification inspected the then-clean Git baseline and the
  placeholder-only `game/` scaffold. At that time no active feature plan, `project.godot`, or
  runnable tests existed, and all 15 roadmap features were `Not started`. Documentation
  cross-reference checks and `git diff --check` passed before F00 planning and implementation.
- No gameplay system or architecture refactor was introduced; no architecture-log entry is
  warranted. F00 is now `In progress`; later features remain `Not started`.

## Decision log

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-09-05 | Use the title **Landzone**. | User-selected name; it centers the game on shuttle landing zones and dangerous ground expeditions. |
| 2026-09-05 | Keep the Godot project in `game/` beneath a documentation-oriented repository root. | Agents can manage plans and evidence without mixing process files into `res://`. |
| 2026-09-05 | Use one just-in-time feature plan and one implementation step at a time. | The user can review the complete evolution of the game and later refactors. |
| 2026-09-05 | Make the mothership and shuttle static. | Preserves the expedition fantasy while removing real-time flight and a second vehicle interior. |
| 2026-09-05 | Use compact generated path graphs assembled from authored modules. | Route notes remain meaningful and generated encounters can be validated for fairness. |
| 2026-09-05 | Use lethal direct attacks and no health bar. | Focuses combat on observation, execution, fast retry, and checkpoint mastery. |
| 2026-09-05 | Apply the approved review: move the first knowledge loop to F06 and assign remaining content to explicit owners. | Test observation and inference before generation/survival investment; avoid unassigned work accumulating at release. |
| 2026-09-05 | Introduce recovery with survival, retain bounded statuses on death, and define resource/cache reset rules. | Death should not serve as treatment; repeated failure and finite resources must not prevent another viable expedition. |
| 2026-09-05 | Preserve vocabulary meanings while varying evidenced solutions; use comprehension and pacing playtests. | Reachability tests cannot prove understandable deductions or enjoyable duration. |

## Latest handoff

F00/S01 and S02 are complete. The project has the labelled Compatibility-renderer shell, only
the four planned movement actions with WASD/arrow bindings, and a focused headless test with
documented commands. The focused test, headless editor import, two-frame main-scene smoke run,
and `git diff --check` passed. The exact next action is to implement only F00/S03: rerun the full
acceptance set from a clean editor state, inspect integration points, and record the user's
runtime-window confirmation. Do not begin F01 or generate its plan. No content-catalog approval
is needed for F00; proposed content still needs approval before its consuming later feature.
