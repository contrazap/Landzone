# Landzone - Progress Ledger

Last documentation update: 2026-09-05

## Current state

- Overall status: F00-F02 complete.
- Last completed feature or milestone: F02 - Ranged combat and first enemy.
- Current feature: F03 - Static mothership base (`Not started`; plan not generated).
- Current step: None.
- Next action: Request `Generate the plan for the next feature` to create only the F03 static-
  mothership-base plan; do not implement F03 yet.
- Known blockers: None.
- Unverified manual checks: None for F00-F02.
- Pending user decisions: Surveyor weapon/tool, Base pulse, Stalker, and Basin surface are
  implemented. Other proposed first-slice content remains unapproved and must be approved or
  revised before its consuming feature is planned.

## Canonical status line

`Status: F00-F02 complete | Last: F02 ranged combat and first enemy | Current: F03 not started; plan not generated | Next: generate only the F03 feature plan | Blockers: none`

Agents must reconstruct this line from verified state rather than copying it blindly.

## Roadmap status

Allowed statuses: `Not started`, `Planned`, `In progress`, `Blocked`, `Complete`.

| ID | Feature | Status | Plan | Implementation evidence | Verification evidence |
| --- | --- | --- | --- | --- | --- |
| F00 | Project foundation | Complete | `plans/F00_project_foundation.md` | S01 added the runnable shell. S02 added only four movement actions with WASD/arrow bindings, `game/tests/run_tests.gd`, its generated UID, and focused-test documentation; no player motion or later-feature action was added. | S03 reconfirmed Godot `4.7.1.stable.official.a13da4feb`; clean-state import, focused test, smoke run, and `git diff --check` passed. The user confirmed both placeholder labels were visible, and the window closed normally. |
| F01 | First expedition and lethal retry | Complete | `plans/F01_first_expedition_and_lethal_retry.md` | S01 built the native-shape Basin route, static shuttle, explorer, boundaries, and camera. S02 added one avoidable amber-red contact hazard, explicit collision intent, player death state, main-owned duplicate-safe 0.65-second retry, exact shuttle restoration, and visible redeploy feedback. | S03 reconfirmed Godot 4.7.1, clean import, F00 regression, focused safe-contact/three-retry suite, smoke, scoped status, and diff check. User confirmed the full environment, controls, avoidable lethal contact, visible feedback, repeated prompt shuttle restoration, and stable post-respawn behavior gate. |
| F02 | Ranged combat and first enemy | Complete | `plans/F02_ranged_combat_and_first_enemy.md` | S01 added direct aim/fire and bounded Base pulses. S02 added one eastern Basin Stalker with five authored states, locked approach, three-hit defeat, and concrete pulse routing. S03 resets that same Stalker and transient shots exactly once through the existing retry. | S04 clean version/import, F00/F01/F02, smoke, ownership/collision/scope, intended-file, and diff checks pass. User confirmed the complete loop, three resets, approximately 1-second death-to-control and 4-second runback-to-tell, acceptable pacing, and a reddish tell before every attack. |
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
- F02/S04 and F02 are complete. All four steps, twelve acceptance criteria, automated/ownership/
  scope checks, and hands-on combat/retry/timing gates pass. F03 remains unplanned and unimplemented.
- Surveyor weapon/tool and Base pulse are implemented for F02/S01, and Stalker is implemented for
  F02/S02. Other names and tuning values in `docs/CONTENT_CATALOG.md` remain proposed until
  explicitly approved. Basin surface is implemented; these states do not approve later content.
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

- On 2026-09-05 the user completed the F02/S04 hands-on gate. Death-to-control measured
  approximately 1 second and shuttle-to-first-telegraph approximately 4 seconds. Across three
  Stalker-death retries, the Stalker returned concealed and activated again only on proximity.
  The user found the runback fine and not far, and every attack was preceded by the reddish tell.
  Combined with the passing automated pulse cleanup, identity, duplicate, control, and world-
  stability assertions, this closes S04, all twelve acceptance criteria, and F02.
- F02/S04 automated acceptance ran on 2026-09-05 without requiring a gameplay fix. Godot reported
  `4.7.1.stable.official.a13da4feb`; clean import, F00, F01, focused F02/S03, two-frame main-scene
  smoke, intended-file status, and `git diff --check` all passed/exited 0. Inspection confirmed
  the approved LMB input, explicit collision layers, one player/one Stalker composition, concrete
  player-to-Main shot ownership, guarded pulse impact, Stalker-owned states, and Main-owned exact-
  once retry/reset order. A runtime-only scope scan found no health, armor, ammunition, inventory,
  later enemy, persistence, command, procedural, autoload, or generalized combat/checkpoint system.
  At that point eleven of twelve acceptance criteria had evidence; the later user timing/pacing
  and repeated-run report closed the remaining criterion and completes S04/F02.
- On 2026-09-05 the user confirmed the core F02/S03 hands-on reset: after the Stalker was defeated
  and the player subsequently died, the Stalker returned and attacked again when the player came
  near. This verifies encounter restoration and proximity-gated reactivation. Repeated combat-
  death cleanup, identity, control, and unchanged-geometry observations were carried into S04.
- F02/S03 completed on 2026-09-05. `Stalker.reset_encounter()` now restores the authored marker,
  concealed state, full three-hit requirement, clean motion/direction, inactive attack, enabled
  trigger, and initial presentation on the existing instance. The main retry calls it once at the
  timer timeout before `player.respawn_at()`, while retry start continues to clear all active Base
  pulses and reject duplicate requests. Godot remained `4.7.1.stable.official.a13da4feb`; final
  import, F00, F01, focused F02/S03, smoke, scope inspection, and `git diff --check` passed/exited
  0. The focused suite proves the defeated state persists before death, then exercises one reset
  after defeat, three actual Stalker-contact deaths, and a later hazard death. Across all five
  cycles it proves sequential exact-once reset before player control, pulse cleanup, unchanged
  player/Basin/Stalker identities, no duplicates, exact markers and initial combat state, and
  immediately usable movement/aim/fire. The corresponding hands-on repeated-run check is pending.
- On 2026-09-05 the user deliberately took a committed Stalker hit and confirmed instant death
  followed by respawn at the shuttle. Together with the previously confirmed red tell, locked
  dodgeable approach, repeat cycle, and three-pulse defeat, this closes the complete F02/S02
  hands-on checkpoint. Resetting the Stalker itself after either death source remains S03.
- On 2026-09-05 the user confirmed that the F02/S02 Stalker activates in range with a reddish
  visual, commits toward the player's position and can be dodged by moving out of that path,
  begins another attack cycle after landing, and dies after three pulses. This closes the tell,
  locked-direction dodge, repeat-cycle, and defeat observations. Deliberately taking committed
  contact to confirm immediate lethal behavior without a health bar remains pending.
- F02/S02 completed on 2026-09-05 without adding S03 encounter reset. The authored Basin now has
  one `StalkerSpawn` at `(1660, 450)` in a clear eastern route section, and the main composition
  has exactly one concrete Stalker. It owns concealed, telegraph, committed, recovery, and
  defeated behavior with a 235-unit trigger inside the default camera view, a 0.8-second
  nonlethal tell, one locked 430-unit/second approach for 0.55 seconds, a 0.7-second nonlethal
  recovery, and distinct native-shape presentation for each readable state. The attack Area2D is
  inactive outside commitment and calls the existing player death transition only on committed
  contact. Base pulses now detect enemy layer 16, emit one guarded impact, and the current main
  owner routes only this concrete Stalker hit; three impacts flash visibly and defeat it. Godot
  remained `4.7.1.stable.official.a13da4feb`; headless import, F00, F01, extended F02/S02, smoke,
  runtime scope inspection, and `git diff --check` all passed/exited 0. Tests prove the state
  sequence, minimum tell, locked direction, hitbox timing, exactly one hit per pulse, third-hit
  defeat, post-defeat inactivity, and actual lethal committed contact. No enemy reset, health,
  loot, navigation, random behavior, later enemy, or generic combat framework was added. The
  The later user report closed S02 hands-on combat readability; S03 now owns and implements exact
  retry reset, with only its hands-on repeated-run checkpoint still pending.
- On 2026-09-05 the user confirmed that F02/S01 mouse aiming and Base-pulse firing work with LMB,
  including automatic repeated fire while LMB is held. The user then confirmed movement speed is
  good while aiming, pulses disappear on rock impact, and ammunition is unlimited. Together these
  observations close the complete S01 hands-on checkpoint.
- F02/S01 completed on 2026-09-05 from the clean F02 planning baseline. It added only the
  primary-mouse `shoot` action; a visible player-owned Surveyor weapon, muzzle, world-space aim,
  and 0.24-second fixed recovery; a cyan Base-pulse Area2D with centralized 620-unit speed and
  1.4-second lifetime; and main-owned projectile creation/cleanup through the existing local
  retry. Existing layer-2 Basin bodies stop pulses, so `basin_surface.tscn` needed no change.
  The generated script UIDs and a focused F02 test were added, and the HUD now states mouse aim
  and LMB fire. Godot remained `4.7.1.stable.official.a13da4feb`; final headless import, F00, F01,
  F02/S01, two-frame smoke, scope inspection, and `git diff --check` all passed/exited 0. The
  focused suite proves primary-button binding, normalized aim and weapon rotation, exact muzzle
  requests, recovery rejection and renewed no-ammunition fire, forward travel, first world-
  impact/lifetime expiration, and active-pulse removal at retry start. No enemy, alternate fire,
  health, inventory, command, persistence, or generalized combat/checkpoint system was added.
  Hands-on aim/pulse presentation and firing feel remain explicitly pending; S02 is next.
- F02 planning on 2026-09-05 began from clean commit `01264b4` on `main`, tracking
  `origin/main`. Inspection confirmed the F01 concrete ownership: `BasinExplorer` owns movement
  and alive/dead action state, `main.gd` owns the one local retry timer and exact shuttle
  restoration, and the authored Basin owns static route geometry and its environmental hazard.
  No aim action, weapon, projectile, enemy, damage, combat manager, or persistence system exists.
  The console reported `4.7.1.stable.official.a13da4feb`; headless editor import, F00 regression,
  the complete F01 safe-contact/three-retry suite, two-frame main-scene smoke, and
  `git diff --check` all exited 0. The user explicitly approved the Surveyor weapon/tool, Base
  pulse, and Stalker catalog entries as written. The F02 plan defines four independently
  requestable steps: direct aiming/Base pulse, the authored readable Stalker encounter, exact
  encounter reset through the existing shuttle retry, and full automated/manual acceptance with
  attack-tell comprehension plus measured death-to-control and runback times. No game code was
  implemented.
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
| 2026-09-05 | Approve the Surveyor weapon/tool, always-available Base pulse, and Stalker candidates for F02. | The user explicitly approved the catalog entries as written so F02 can establish one readable direct-combat loop without assuming later equipment or enemies. |

## Latest handoff

F00-F02 are complete. F02's clean automated, ownership, collision, scope, intended-file, smoke,
and diff reviews passed without a gameplay fix. User reports confirm aim/fire, pulse behavior, the
reddish tell, locked dodgeable attack, three-hit defeat, immediate lethality, shuttle respawn, and
repeatable proximity-gated restoration. The final measurements were approximately 1 second from
death to control and 4 seconds from shuttle to first telegraph; the user found the runback fine and
observed the reddish tell before every attack across three retry cycles. No F02 manual or automated
gate remains.
The exact next action is to request `Generate the plan for the next feature`, which must create only
the F03 static-mothership-base plan from the verified repository state and must not implement F03.
