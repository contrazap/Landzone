# Landzone - Progress Ledger

Last documentation update: 2026-09-05

## Current state

- Overall status: F00 implementation in progress.
- Last completed feature or milestone: F00/S01 - Runnable Compatibility-renderer project shell.
- Current feature: F00 - Project foundation (`In progress`).
- Current step: F00/S02 - Establish inputs and focused verification (`Not started`).
- Next action: Implement only F00/S02 from `plans/F00_project_foundation.md`.
- Known blockers: None.
- Unverified manual checks: F00/S03 will require the user to confirm that the placeholder window
  opens and shows `LANDZONE` and `Project foundation` legibly. The runnable shell exists, but
  this visual check has not been claimed from headless evidence.
  Future comprehension, recovery, and pacing checks remain assigned in the roadmap.
- Pending user decisions: Approve or revise the proposed first-slice content in `docs/CONTENT_CATALOG.md` before the feature that consumes each item.

## Canonical status line

`Status: F00 implementation in progress | Last: F00/S01 runnable project shell | Current: F00/S02 - inputs and focused verification not started | Next: implement only F00/S02 | Blockers: none`

Agents must reconstruct this line from verified state rather than copying it blindly.

## Roadmap status

Allowed statuses: `Not started`, `Planned`, `In progress`, `Blocked`, `Complete`.

| ID | Feature | Status | Plan | Implementation evidence | Verification evidence |
| --- | --- | --- | --- | --- | --- |
| F00 | Project foundation | In progress | `plans/F00_project_foundation.md` | S01 added `game/project.godot` and the self-contained Control-based `game/main.tscn`; no script, input, autoload, gameplay, or external asset was added. | Godot 4.7.1 headless editor import and two-frame main-scene smoke run exited 0 without parser, load, or runtime errors; `git diff --check` passed. |
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

A minimal Godot project and main scene now exist. No focused automated verification script
exists yet; F00/S02 owns that next baseline. The F00 plan owns:

- Recording the installed Godot version and executable paths.
- Maintaining `game/project.godot` and its minimal runnable main scene.
- Establishing the first repeatable headless import and smoke checks.
- Creating the initial `game/tests/` verification entry point.
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
- F00/S02 has not started, so movement inputs and the focused test entry point do not yet exist.
- Content names and tuning values in `docs/CONTENT_CATALOG.md` remain proposed until explicitly
  approved; the review approval does not approve all content candidates.

## Latest documentation evidence

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

F00/S01 is complete. `game/project.godot` now selects the self-contained labelled
`game/main.tscn` under the explicit Compatibility renderer. Godot 4.7.1 headless editor import,
the two-frame main-scene smoke run, and `git diff --check` passed. The exact next action is to
implement only F00/S02: add the four planned movement inputs and focused test entry point, then
rerun the S01 checks. Do not perform S03 acceptance or claim its manual visual confirmation.
No content-catalog approval is needed for F00; proposed content still needs approval before its
consuming later feature.
