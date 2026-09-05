# Landzone - Progress Ledger

Last documentation update: 2026-09-05

## Current state

- Overall status: F00 planned; implementation not started.
- Last completed feature or milestone: Approved development-plan review revisions: earlier knowledge loop, content ownership, recovery rules, and playtest gates.
- Current feature: F00 - Project foundation (`Planned`).
- Current step: F00/S01 - Create the runnable project shell (`Not started`).
- Next action: Implement only F00/S01 from `plans/F00_project_foundation.md`.
- Known blockers: None.
- Unverified manual checks: F00/S03 will require the user to confirm that the placeholder window
  opens and shows `LANDZONE` and `Project foundation` legibly. No playable build exists yet.
  Future comprehension, recovery, and pacing checks remain assigned in the roadmap.
- Pending user decisions: Approve or revise the proposed first-slice content in `docs/CONTENT_CATALOG.md` before the feature that consumes each item.

## Canonical status line

`Status: F00 planned; implementation not started | Last: development-plan review revisions | Current: F00/S01 - runnable project shell not started | Next: implement only F00/S01 | Blockers: none`

Agents must reconstruct this line from verified state rather than copying it blindly.

## Roadmap status

Allowed statuses: `Not started`, `Planned`, `In progress`, `Blocked`, `Complete`.

| ID | Feature | Status | Plan | Implementation evidence | Verification evidence |
| --- | --- | --- | --- | --- | --- |
| F00 | Project foundation | Planned | `plans/F00_project_foundation.md` | None | Planning preflight confirmed both Godot 4.7.1 executables, console build `4.7.1.stable.official.a13da4feb`, placeholder-only `game/` tree, clean Git state, and clean `git diff --check`. |
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

No Godot project or automated verification exists yet. The F00 plan now owns:

- Recording the installed Godot version and executable paths.
- Creating `game/project.godot` and a minimal runnable main scene.
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
- No game files exist yet by design.
- F00 is planned but no implementation step has started.
- Content names and tuning values in `docs/CONTENT_CATALOG.md` remain proposed until explicitly
  approved; the review approval does not approve all content candidates.

## Latest documentation evidence

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
- Verification: inspected the clean pre-edit Git baseline and actual `game/` scaffold (only
  `.gitkeep` placeholders). No active feature plan, `project.godot`, or runnable tests exist.
  Documentation checks passed: all 15 feature IDs/names match between roadmap and ledger, all
  remain `Not started`, all numeric feature references resolve, and no game code or feature
  plans were created. `git diff --check` passed. Reviewed ownership and dependency boundaries
  against the slice requirements; gameplay and manual checks remain unavailable until implemented.
- No game implementation or architecture refactor was performed; no architecture-log entry is
  warranted. All feature statuses remain `Not started`.

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

F00 is planned in `plans/F00_project_foundation.md`; no implementation has started and `game/`
still contains only `.gitkeep` placeholders. The installed GUI and console executables are
present, and the console reports `4.7.1.stable.official.a13da4feb`. The exact next action is to
implement only F00/S01: create `game/project.godot` and the self-contained labelled
`game/main.tscn`, then run its headless import, smoke, and diff checks. Do not add inputs or the
test runner until S02. F00/S03 owns the user's visual confirmation. No content-catalog approval
is needed for F00; proposed content still needs approval before its consuming later feature.
