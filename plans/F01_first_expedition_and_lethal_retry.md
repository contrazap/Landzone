# F01 - First expedition and lethal retry

- Feature status: Complete
- Roadmap dependency: F00 - Project foundation (Complete)
- Created: 2026-09-05
- Completed: 2026-09-05
- Current step: Complete

## Objective

Turn the project shell into its first playable expedition: the player walks from a static
shuttle through one compact authored Basin surface path, can deliberately touch one readable
lethal environmental hazard, and quickly regains control at the shuttle checkpoint. This
feature establishes only the concrete movement, collision, player-lifecycle, and local retry
boundaries needed now, while leaving combat, scene transitions, persistence, and generalized
checkpoint behavior to their owning features.

## Preflight and actual starting state

- Inspected `AGENTS.md`, `PROGRESS.md`, the approved design, roadmap, content catalog, completed
  F00 plan, plan template and README, architecture log, and every current file under `game/`.
- F00 is complete. `game/project.godot` selects `res://main.tscn`, uses Godot 4.7.1 with the
  Compatibility renderer, and defines only the four movement actions with WASD and arrow keys.
- `game/main.tscn` is a self-contained `Control` placeholder containing the visible labels
  `LANDZONE` and `Project foundation`. No gameplay scene, gameplay script, physics body,
  collision layer, checkpoint, hazard, camera, or runtime state owner exists yet.
- `game/tests/run_tests.gd` is the focused F00 verification entry point. It checks project and
  renderer settings, input bindings, and main-scene loadability. There is no generic test
  registry and no need to create one for F01.
- Planning preflight started from a clean `main` worktree tracking `origin/main`; there were no
  unrelated user changes to preserve.
- The Godot 4.7.1 headless editor import, F00 focused test, two-frame main-scene smoke run, and
  `git diff --check` all exited 0 on 2026-09-05.
- The user approved the proposed Basin surface visual direction after reviewing its concept
  image. The reference is preserved at `docs/concepts/f01_basin_surface_concept.png`; it guides
  palette, readability, and mood but is not a requirement for asset-level fidelity.
- Previous behavior to preserve: the project launches through `res://main.tscn`, remains a 2D
  Compatibility-renderer project, retains both bindings for every movement action, and keeps
  the F00 focused check passing.

## In scope

- Replace the labelled placeholder presentation with one runnable, authored Basin exterior
  composition using Godot-native nodes, shapes, and repository-native placeholder visuals.
- Deliver the approved Basin surface as the first surface presentation: a compact, bounded,
  mostly linear rock path with a clear safe area around a static exterior shuttle.
- Add a focused player scene with readable top-down representation, collision, camera follow,
  four-direction movement from the existing actions, normalized diagonal speed, and centralized
  movement tuning.
- Add one visually distinct environmental contact hazard placed so the player can deliberately
  touch it but can also traverse the authored path safely. It kills immediately without a
  health bar or damage ladder.
- Treat the shuttle spawn marker as the one concrete checkpoint. The current exterior owner
  coordinates a short death/redeploy delay, clears player movement, returns the player to that
  marker, and restores control without reloading or rerolling the scene.
- Prevent one death from starting duplicate retry sequences, and make repeated hazard deaths
  restore the same safe position and usable controls.
- Add focused headless verification for movement, scene composition, collision-layer intent,
  death, and repeated shuttle retry while preserving the F00 regression checks.
- Record the automated evidence and the user's manual presentation, movement, hazard
  readability, and retry observations.

## Out of scope

- Aiming, shooting, projectiles, enemies, encounter reset, and lethal enemy attacks; F02 owns
  them and will extend the retry contract established here.
- Returning to or constructing the mothership, shuttle travel, exterior unload/reload, or
  preservation across scene transitions; F03 owns those behaviors.
- Forks, loops, coordinates, facing display, `where`, or any command overlay; these begin in
  F04. F01 contains one authored route without navigation decisions.
- Journal, codex, saves, run seeds, generated terrain, durable progression, inventory,
  survival status, death caches, site checkpoints, precision blink, or traversal challenges.
- Making the concept image a runtime asset or reproducing its detail exactly. F01 uses simple
  native placeholder art with the approved safe/danger color language.
- A global checkpoint manager, autoloaded run-state service, custom checkpoint resource, generic
  hazard framework, or speculative lifecycle abstraction for later features.
- Approval or implementation of any proposed content catalog item other than Basin surface.

## Current design

The current runtime has no gameplay ownership: `project.godot` launches one flat placeholder
`Control` scene. F01 will introduce the smallest concrete scene boundary justified by a movable
entity and a local retry. The main exterior composition owns the active player reference, the
single shuttle spawn marker, and the retry timer. The focused player scene owns movement and
its live/dead control state. The authored Basin scene owns static presentation and collision,
including the shuttle, path boundaries, and one hazard.

```text
project.godot -> main.tscn (current exterior/retry owner)
                         |
                         +-- basin_surface.tscn
                         |      +-- static shuttle
                         |      +-- shuttle spawn marker
                         |      +-- path walls and lethal hazard
                         |
                         +-- player.tscn (movement, collision, camera)
                         |
                         +-- minimal death/redeploy feedback

player death signal -> main exterior owner -> short delay -> shuttle spawn + restored control
```

This is not yet a persistent run-state or generalized checkpoint architecture. F02 can use the
same local death event for encounter reset; F03 will provide the first evidence about state
that must survive a scene transition.

## Refactoring assessment

- Observed pressure: None. The placeholder contains no gameplay ownership or reusable behavior,
  so there is no behavioral structure to refactor before adding F01.
- Decision: Replace the placeholder presentation directly and introduce only a focused player
  scene plus a concrete main-scene retry owner. Keep the one hazard and one shuttle checkpoint
  specific to this authored exterior until a second implementation creates real reuse pressure.
- Behavior-preserving verification: Run the F00 focused test before and after each F01 step;
  retain the configured main-scene path, renderer, and movement bindings. No separate refactor
  step or architecture-log entry is justified during planning.

## Expected files

- Modified: `game/main.tscn`
- New: `game/main.gd`
- New: `game/basin_surface.tscn`
- New: `game/player.tscn`
- New: `game/player.gd`
- New: `game/tests/test_f01_first_expedition.gd`
- Modified: `game/tests/README.md`
- New planning reference: `docs/concepts/f01_basin_surface_concept.png`
- Modified during planning: `docs/CONTENT_CATALOG.md`
- Modified during planning and implementation: `plans/F01_first_expedition_and_lethal_retry.md`
- Modified during planning and implementation: `PROGRESS.md`
- Modified during planning: `plans/README.md`
- Modified only if implementation establishes a material structural boundary not already
  described here: `docs/ARCHITECTURE_EVOLUTION.md`

Godot may generate `.uid` companions for new scripts during import. Completion notes must list
the actual files rather than treating this expected list as fixed.

## Step ledger

Allowed statuses: `Not started`, `In progress`, `Blocked`, `Complete`.

| Step | Outcome | Status | Verification |
| --- | --- | --- | --- |
| S01 | The player can walk from the static shuttle through a bounded authored Basin path with correct collision and camera behavior. | Complete | Headless import, F00 regression, F01 composition/movement/physics-collision checks, main-scene smoke, and `git diff --check` pass. The user confirmed movement and blocking; S03 later closed the remaining presentation/camera gate. |
| S02 | Contact with the readable lethal hazard causes one prompt retry and restores the player at the shuttle with clean movement state. | Complete | Focused checks prove an avoidable safe lane, actual lethal contact, a 0.65-second delay, disabled control, duplicate rejection, exact clean restoration, and the same player/Basin across three cycles; import, regressions, smoke, and diff checks pass. S03 later closed the manual readability/retry gate. |
| S03 | Full F01 acceptance evidence is recorded, including manual environment, hazard-readability, and lethal-retry observations. | Complete | Godot version, clean import, F00 regression, focused three-retry suite, smoke run, scoped Git status, diff check, and ownership inspection pass. The user confirmed the complete hands-on presentation, controls, hazard, prompt repeated retry, and post-respawn stability gate. |

## Implementation steps

### S01 - Build the playable Basin route

**Purpose:** Establish the first real gameplay scene and verify direct movement before death or
retry behavior adds another state transition.

**Changes:** Replace the placeholder content in `game/main.tscn` with a 2D exterior composition.
Create `game/basin_surface.tscn` as one compact, authored, mostly linear rock route containing a
static shuttle representation, a safe landing area, a named shuttle spawn marker, and solid
path boundaries. Create `game/player.tscn` and `game/player.gd` as a focused `CharacterBody2D`
entity with a simple visible shape, collision, camera follow, exported movement speed, input
from the four existing actions, normalized diagonals, and `move_and_slide()` collision. Keep the
approved concept's muted Basin palette and cyan safety accents at a simple native-placeholder
fidelity. Add `game/tests/test_f01_first_expedition.gd` with focused scene-composition and
movement checks, and document its command in `game/tests/README.md`.

**Do not:** Add the lethal hazard, death state, retry timer, checkpoint abstraction, combat,
interactions, commands, scene transitions, procedural layout, persistence, external art, or
later-feature inputs. Do not turn the single route into a fork or navigation puzzle.

**Verify:** Run:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f01_first_expedition.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
git diff --check
```

The import and smoke commands must exit 0 without parser, load, or runtime errors. The F00 test
must retain its explicit pass summary. The F01 test must instantiate the configured main scene,
find one player and one shuttle spawn, exercise both positive and opposing movement inputs,
confirm diagonal movement is not faster than axial movement, and confirm the player's intended
physics collision setup. `git diff --check` must report no errors.

**Manual checkpoint:** Launch the project and confirm a static shuttle, cyan safe area, explorer,
and one clear rock route are visible. Walk with both WASD and arrow keys, confirm the camera
keeps the explorer readable, confirm diagonal motion does not feel faster, traverse the route
in both directions, and confirm solid rock boundaries prevent leaving the playable path. No
hazard or death behavior is expected yet.

### S02 - Add lethal contact and shuttle retry

**Purpose:** Deliver the feature's lethal-retry loop on top of already verified movement and
establish clear local ownership before F02 adds enemies and encounter reset.

**Changes:** Add one highly visible environmental contact hazard to the authored Basin scene,
placed so a safe route past it remains possible. Configure explicit player, world, and hazard
collision layers/masks. Add the minimal live-to-dead transition needed to stop movement and
emit one death event. Add `game/main.gd` as the current exterior owner: it receives that event,
shows brief repository-native redeploy feedback, rejects duplicate retry requests, waits a
short fixed delay no greater than one second, resets player velocity and transient movement,
places the player at the shuttle spawn marker, and restores control. The Basin scene and hazard
remain unchanged by retry. Extend the F01 focused test to exercise actual hazard contact where
practical, the death signal, disabled control during the delay, exact spawn restoration, clean
velocity, no duplicate retry, and at least three consecutive retry cycles.

**Do not:** Add hit points, damage accumulation, a health bar, invulnerability tuning, enemies,
projectiles, resource loss, scene reload, randomized reset, multiple checkpoint priority,
persistent state, a global manager, or F02 encounter behavior. The hazard is contact-readable,
not the measured precision-blink challenge owned by F08.

**Verify:** Run the S01 command set again. The F01 focused test must additionally prove that one
hazard contact produces one retry sequence, the configured retry delay is at most one second,
the player returns to the same shuttle marker with zero movement and restored control, repeated
deaths do not accumulate timers or player instances, and the authored exterior does not reload
or change. All F00, import, smoke, and diff checks must still pass.

**Manual checkpoint:** Launch, walk safely past the hazard once, then deliberately touch it.
Confirm contact is immediately lethal, movement stops during brief redeploy feedback, and
control returns at the shuttle within roughly one second. Repeat at least three times and
confirm every retry uses the same safe position, the path and hazard remain unchanged, controls
work immediately, and no health bar appears.

### S03 - Verify and accept the first expedition

**Purpose:** Confirm the entire F01 slice is readable and repeatable before combat builds on its
player-lifecycle boundary.

**Changes:** Run the complete verification set from a clean editor state, inspect the exact
scene ownership, signals, collision layers, and retry timing, and record actual outputs and the
user's manual report in this plan and `PROGRESS.md`. Make only fixes necessary to meet F01's
approved behavior. If evidence demands a material boundary change or broader scope, revise the
plan and explain it before implementing that change.

**Do not:** Begin F02, add polish unrelated to the acceptance failures, credit a visual or
hands-on observation that was not made, or mark F01 complete while its required manual check is
pending.

**Verify:** Run:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --version
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f01_first_expedition.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
git status --short
git diff --check
```

The version must remain `4.7.1.stable.official.a13da4feb`; every Godot command must exit 0;
both focused scripts must print their explicit pass summaries; the Git inspection must contain
only intended F01 and bookkeeping files; and `git diff --check` must report no errors.

**Manual checkpoint:** Launch with
`& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64.exe' --path game`. Confirm the static shuttle and
safe cyan spawn area read as the expedition origin; the muted rock Basin, traversable route,
explorer, and amber-red lethal hazard are distinct at the default window size; movement and
wall collision remain responsive; a safe route exists; hazard contact is unmistakably lethal;
and each of three deaths restores control at the shuttle within roughly one second without a
health bar, duplicate player, changed environment, error dialog, or stuck input. Record any
confusion about the safe/danger colors and whether the retry feels prompt. No unfamiliar-player
comprehension gate is assigned to F01.

## Feature acceptance criteria

- [x] The project launches directly into one compact, authored Basin surface presentation
  whose palette and safe/danger language follow the approved concept at placeholder fidelity.
- [x] A static exterior shuttle and its cyan safe area clearly identify the expedition origin
  and the one current respawn checkpoint.
- [x] The player can traverse the route with either WASD or arrow keys, diagonals are normalized,
  the camera keeps play readable, and collisions prevent leaving the authored path.
- [x] One visually distinct hazard can be avoided during traversal and kills immediately on
  contact without hit points, damage accumulation, or a health bar.
- [x] One death starts one retry, disables movement during a fixed delay no greater than one
  second, clears movement state, restores the player at the exact shuttle marker, and promptly
  returns control.
- [x] At least three consecutive deaths restore the same player and authored exterior without
  duplicate retries, duplicate player instances, changed geometry, or a scene reroll.
- [x] The implementation introduces no combat, mothership transition, command, branching route,
  persistence, survival, procedural generation, or speculative global checkpoint system.
- [x] Godot import/parser, F00 regression, F01 focused, and main-scene smoke checks pass with the
  confirmed Godot 4.7.1 console executable, and `git diff --check` is clean.
- [x] The user confirms the manual environment, movement, hazard-readability, and repeated-retry
  observations at the default window size.
- [x] The active plan and `PROGRESS.md` match actual evidence; the architecture log changes only
  if implementation establishes a material boundary beyond the planned concrete ownership.

## Verification plan

### Automated or headless

- Confirm the executable with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --version`; expect
  `4.7.1.stable.official.a13da4feb` and exit 0.
- Import and parse with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit`;
  expect exit 0 and no parser/load errors.
- Preserve F00 with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd`;
  expect its explicit F00 pass summary and exit 0.
- Run the F01 behavior checks with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f01_first_expedition.gd`;
  expect its explicit pass summary and exit 0 after movement, composition, collision, death,
  timing, and repeated-retry assertions.
- Smoke the configured main scene with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2`;
  expect exit 0 without parser, load, runtime, or orphan-node errors.
- Inspect `git status --short` for intended files only and run `git diff --check`; expect no
  unrelated changes or whitespace errors.

### Manual

- Launch the configured project at its default size and identify the shuttle, cyan safe area,
  explorer, bounded Basin path, rock walls, and amber-red hazard without developer explanation.
- Use both WASD and arrow keys, including diagonal input. Traverse to the far end and back,
  confirm the camera remains readable, and attempt to push through several rock boundaries.
- Pass the hazard safely once to establish that it is avoidable, then contact it deliberately.
  Confirm immediate death feedback and restoration at the shuttle with usable controls within
  roughly one second.
- Repeat the lethal contact at least three times. Confirm the world does not reroll, no extra
  player appears, no retry overlaps, no health bar appears, and input never remains stuck.
- Record whether the safe and lethal colors were understandable and whether the retry felt
  prompt. F02 will add formal attack-tell and runback timing observations; F01 supplies only the
  initial environmental retry baseline.

## Completion notes

Fill this section during implementation rather than predicting results:

- Actual files changed for S01: replaced `game/main.tscn`; added `game/basin_surface.tscn`,
  `game/player.tscn`, `game/player.gd`, `game/player.gd.uid`,
  `game/tests/test_f01_first_expedition.gd`, and its generated UID; updated
  `game/tests/README.md`, this plan, and `PROGRESS.md`.
- Actual files changed for S02: modified `game/basin_surface.tscn`, `game/main.tscn`,
  `game/player.gd`, `game/tests/test_f01_first_expedition.gd`, and `game/tests/README.md`; added
  `game/main.gd` and its generated UID; updated this plan and `PROGRESS.md`.
- Actual files changed for S03: updated this plan, `PROGRESS.md`,
  `docs/CONTENT_CATALOG.md`, and `docs/ARCHITECTURE_EVOLUTION.md` only; no game code changed.
- Steps completed: S01-S03. F01 is complete.
- Commands/tests and results: the Godot headless editor import, F00 focused regression,
  F01/S01 focused check, two-frame main-scene smoke, and `git diff --check` all exited 0.
  The F01 check instantiated the configured main scene, verified one player, shuttle, spawn,
  camera, collision setup, and no hazard; exercised positive, diagonal, and opposing inputs;
  confirmed real CharacterBody2D motion and collision against an upper rock boundary.
- S02 commands/tests and results: after commit `bb91806` was pushed to `origin/main`, a clean
  baseline re-passed the F00 and F01/S01 tests and main-scene smoke. The S02 headless import,
  F00 regression, extended F01 focused check, main-scene smoke, and `git diff --check` all exited
  0. The extended test proved that the authored lower lane is safe, actual hazard overlap kills,
  the retry delay is 0.65 seconds, control and velocity stop on death, duplicate requests are
  rejected, and three consecutive cycles restore the same player at the exact shuttle marker
  with zero velocity without replacing the Basin or hazard.
- S03 commands/tests and results: from clean pushed commit `fd969b6`, the console reported
  `4.7.1.stable.official.a13da4feb`; headless editor import, F00 regression, the complete focused
  F01 suite, two-frame main-scene smoke, and `git diff --check` all exited 0. The focused suite
  again passed its safe passage, actual lethal overlap, duplicate rejection, timing, and three
  consecutive exact-restoration checks. Git status contained only this plan and `PROGRESS.md`
  after S03 bookkeeping. Inspection confirmed the player owns only live/dead movement state,
  `main.gd` owns the one retry timer and shuttle restoration, the Basin owns the static hazard
  and geometry, and no health, combat, autoloaded checkpoint, persistence, or scene reload exists.
- Manual checks performed: On 2026-09-05 the user reported, "Player moves fine. Boundaries and
  shuttle block player as expected." This confirms working player movement and collision against
  both route boundaries and the static shuttle. The static-shuttle/cyan-area presentation,
  explorer and camera readability, explicit testing of both control sets, diagonal feel, and
  two-way full-route traversal were not stated and remain pending; the complete hazard/retry
  manual gate remains pending for S03.
- During S03 on 2026-09-05, the user reported, "I have played. One hazard that kills player and
  shows a respawn message. Player respawned at the shuttle spawn point. can traverse around the
  hazard." This confirms a visible avoidable hazard, lethal contact, visible retry feedback, and
  correct shuttle restoration. The report does not state three consecutive hands-on deaths,
  perceived sub-second retry/control restoration, stable world/player across retries, absence of
  a health bar or error, safe/danger color clarity, camera/diagonal feel, or both control sets.
  When asked to confirm that complete remaining gate after three consecutive deaths, the user
  replied, "yes, worked correctly after respawn." This closes the hands-on acceptance gate.
- Deviations from plan: No behavior deviation. `game/main.gd` was not added because S01 needs no
  main-scene logic; it remains planned for S02 when local retry ownership becomes real.
- Architecture log entries: None. `docs/ARCHITECTURE_EVOLUTION.md` now states that the first
  concrete ownership exists and remains documented here, but no implementation-pressure
  refactor or broader abstraction warranted an evolution entry.
- Remaining risks or debt: No known F01 acceptance gap. Route-wall, hazard, and checkpoint
  ownership are deliberately concrete and local; F02 may extend the same local death event for
  encounter reset without prebuilding a global checkpoint system.
- Suggested commit boundary: F01/S01 is committed and pushed as `bb91806`; F01/S02 is the current
  completed lethal-retry commit boundary at `fd969b6`; F01/S03 acceptance bookkeeping is the
  final documentation-only boundary for this feature.
