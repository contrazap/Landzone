# Landzone - Progress Ledger

Last documentation update: 2026-09-05

## Current state

- Overall status: F00-F01 complete.
- Last completed feature or milestone: F01 - First expedition and lethal retry.
- Current feature: None; F02 is not yet planned.
- Current step: None.
- Next action: Request `Generate the plan for the next feature` to inspect and plan only F02 -
  Ranged combat and first enemy; do not implement F02 during planning.
- Known blockers: None.
- Unverified manual checks: None for F01. The user confirmed movement and collision, an avoidable
  lethal hazard, visible respawn feedback, exact shuttle return, and the complete repeated-retry,
  post-respawn control/stability, presentation, camera, diagonal, and both-control-set gate.
- Pending user decisions: Approve or revise proposed first-slice content before the later
  feature that consumes each item. Basin surface is implemented; other proposed items remain
  unapproved.

## Canonical status line

`Status: F00-F01 complete | Last: F01 first expedition and lethal retry | Current: no active feature plan | Next: generate only the F02 plan | Blockers: none`

Agents must reconstruct this line from verified state rather than copying it blindly.

## Roadmap status

Allowed statuses: `Not started`, `Planned`, `In progress`, `Blocked`, `Complete`.

| ID | Feature | Status | Plan | Implementation evidence | Verification evidence |
| --- | --- | --- | --- | --- | --- |
| F00 | Project foundation | Complete | `plans/F00_project_foundation.md` | S01 added the runnable shell. S02 added only four movement actions with WASD/arrow bindings, `game/tests/run_tests.gd`, its generated UID, and focused-test documentation; no player motion or later-feature action was added. | S03 reconfirmed Godot `4.7.1.stable.official.a13da4feb`; clean-state import, focused test, smoke run, and `git diff --check` passed. The user confirmed both placeholder labels were visible, and the window closed normally. |
| F01 | First expedition and lethal retry | Complete | `plans/F01_first_expedition_and_lethal_retry.md` | S01 built the native-shape Basin route, static shuttle, explorer, boundaries, and camera. S02 added one avoidable amber-red contact hazard, explicit collision intent, player death state, main-owned duplicate-safe 0.65-second retry, exact shuttle restoration, and visible redeploy feedback. | S03 reconfirmed Godot 4.7.1, clean import, F00 regression, focused safe-contact/three-retry suite, smoke, scoped status, and diff check. User confirmed the full environment, controls, avoidable lethal contact, visible feedback, repeated prompt shuttle restoration, and stable post-respawn behavior gate. |
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
script now exist, and F00 acceptance is complete. The F00 plan owns:

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
`4.7.1.stable.official.a13da4feb`. Future work must preserve this baseline unless the user
approves a change.

## Active blockers and known issues

- None. F01 acceptance is complete.
- F00/S01 is complete; the runnable shell now exists.
- F00/S02 is complete; the four movement actions and focused test entry point now exist.
- F00/S03 is complete; full automated acceptance passed, the user confirmed both labels were
  visible, and the launched process closed normally.
- Content names and tuning values in `docs/CONTENT_CATALOG.md` remain proposed until explicitly
  approved. Basin surface is implemented; its approval and implementation do not approve
  other content candidates.
- F01/S01 is complete: automated checks cover scene composition, normalized movement, intended
  collision layers, actual wall collision, and camera presence. S03 later closed its hands-on
  checkpoint; S02 extends this verified movement baseline with lethal retry.
- F01/S02 is complete: the local main-scene owner coordinates one one-shot retry and the player
  owns only alive/dead movement state. Automated checks cover safe passage, actual lethal
  overlap, duplicate rejection, timing, and three exact restorations. S03 closed the manual gate.
- F01/S03 and F01 are complete: all automated acceptance passed, the user confirmed the full
  hands-on gate, and no architecture change beyond the planned concrete local ownership was
  needed.

## Latest documentation evidence

- F01/S03 completed on 2026-09-05 after the user answered "yes, worked correctly after respawn"
  to the remaining combined gate covering three consecutive prompt retries, restored controls,
  stable player/world, no health bar/error/stuck input, cyan/amber clarity, camera and diagonal
  feel, and both WASD and arrow controls. Combined with the earlier reports that movement and
  collision worked and that the visible avoidable hazard killed, displayed a respawn message,
  and returned the player to the shuttle spawn, this completes the manual evidence. All automated
  acceptance and ownership/scope inspection had already passed on clean commit `fd969b6`.
- F01/S03 acceptance on 2026-09-05 began from clean pushed commit `fd969b6`. The console version
  remained `4.7.1.stable.official.a13da4feb`; headless editor import, F00 regression, the focused
  F01 suite, main-scene smoke, and `git diff --check` all exited 0. The focused suite again proved
  the safe passage, actual lethal contact, duplicate-safe 0.65-second timer, and three consecutive
  exact shuttle restorations with the same player, Basin, and hazard. Inspection found only the
  planned local owner/player/Basin boundary and no out-of-scope runtime systems. The user reported
  one visible avoidable hazard that kills, displays a respawn message, and returns the player to
  the shuttle spawn. At that point the report did not yet cover three consecutive hands-on retries,
  prompt restored control/stability, absence of health UI/errors, or the remaining
  color/camera/control observations; the later confirmation recorded above closed those gaps.
- F01/S02 on 2026-09-05 began from clean commit `bb91806` on `main`, pushed to `origin/main`.
  It added one amber-red Area2D hazard on collision layer 4 with a traversable safe lane. The
  player now rejects repeated death, zeros velocity, and disables physics until respawn. A local
  `main.gd` owner shows redeploy feedback, rejects overlapping retry requests, runs one 0.65-second
  timer, then restores the same player at the exact shuttle marker with clean velocity and
  control. The extended focused check exercises safe passage, actual hazard overlap, duplicate
  requests, and three consecutive retries while retaining the same player, Basin, and hazard.
  Headless import, F00 regression, focused F01/S02 verification, main-scene smoke, and
  `git diff --check` passed. No health, combat, global checkpoint, persistence, or scene reload
  was added. Manual hazard readability and retry feel remain pending.
- F01/S01 on 2026-09-05 replaced the labelled placeholder with a 2160x900 authored Basin route
  built from Godot-native polygons and lines. It added one static collidable shuttle, a cyan
  landing/checkpoint presentation and exact spawn marker, a focused CharacterBody2D explorer
  with exported speed and normalized four-action input, an enabled bounded follow camera, and
  solid world boundaries. The focused F01 check verifies the composition, S01 scope boundary,
  axial/diagonal/opposing input, real physics motion, and an attempted crossing of a rock wall.
  Headless import, the preserved F00 test, the F01/S01 test, main-scene smoke, and
  `git diff --check` all passed. No hazard, death, retry, main-scene lifecycle script, or later
  feature input was added. The user subsequently confirmed that the player moves correctly and
  that both the boundaries and shuttle block the player as expected. Presentation, camera and
  diagonal feel, explicit use of both control sets, and full-route traversal remain unreported.
- F01 planning on 2026-09-05 inspected the complete F00 project and verified a clean `main`
  worktree before planning. Headless editor import, the F00 focused test, the two-frame main-scene
  smoke run, and `git diff --check` all exited 0. The user approved the Basin surface direction
  after reviewing a generated concept; the reference is stored at
  `docs/concepts/f01_basin_surface_concept.png`. The F01 plan defines three independently
  requestable steps: build the playable authored route, add lethal contact and local shuttle
  retry, then run full automated and manual acceptance. No game code was implemented.
- F00/S03 on 2026-09-05 confirmed console version `4.7.1.stable.official.a13da4feb`. The
  clean-state headless editor import, focused foundation test, main-scene smoke run, and
  `git diff --check` all exited 0. Git status was clean before S03 bookkeeping. The user then
  reported, "Yes. I was able to see the title LANDZONE and content Project foundation," and the
  launched process exited after being closed. F00 is complete.
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
- `docs/CONTENT_CATALOG.md` assigns content owners and updates approval timing. Unapproved
  catalog content remains proposed. `plans/FEATURE_PLAN_TEMPLATE.md` carries ownership,
  persistence, recovery, and applicable manual gates into future plans.
- Prior documentation-review verification inspected the then-clean Git baseline and the
  placeholder-only `game/` scaffold. At that time no active feature plan, `project.godot`, or
  runnable tests existed, and all 15 roadmap features were `Not started`. Documentation
  cross-reference checks and `git diff --check` passed before F00 planning and implementation.
- No gameplay system or architecture refactor was introduced during planning; no
  architecture-log entry is warranted. F00 is complete, F01 is planned, and later features
  remain `Not started`.

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
| 2026-09-05 | Approve the Basin surface visual direction for F01 and its later F07 generation role. | The reviewed concept communicates a readable static shuttle origin, compact rock route, and strong cyan-safe versus amber-red-danger language while remaining reducible to Godot-native placeholder art. |

## Latest handoff

F00 and F01 are complete. F01/S01 is committed as `bb91806`, F01/S02 as `fd969b6`, and S03 has
now recorded full automated and manual acceptance. The project launches into the authored Basin,
supports normalized movement and bounded collision, presents one avoidable lethal hazard, and
restores the same player promptly at the static shuttle without reloading the world. There is no
active feature plan. The exact next action is to request `Generate the plan for the next feature`,
which must inspect the clean baseline and create only the F02 plan without implementing game code.
