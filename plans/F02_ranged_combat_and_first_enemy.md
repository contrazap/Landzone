# F02 - Ranged combat and first enemy

- Feature status: Planned
- Roadmap dependency: F01 - First expedition and lethal retry (Complete)
- Created: 2026-09-05
- Completed: -
- Current step: S01

## Objective

Add Landzone's first direct combat loop to the authored Basin: the player aims with the mouse,
fires an always-available base pulse from the Surveyor weapon/tool, and defeats one readable
Stalker whose clearly telegraphed committed attack is lethal. Combat deaths retain F01's prompt
shuttle retry and reset the authored encounter without reloading the exterior. This feature
establishes only the concrete projectile, enemy-state, hit-event, and encounter-reset behavior
needed for one enemy rather than a generic combat framework.

## Preflight and actual starting state

- Inspected `AGENTS.md`, `PROGRESS.md`, the approved game design, roadmap, content catalog,
  completed F01 plan, feature-plan template and README, architecture log, all current runtime
  files under `game/`, the F00/F01 tests, and current Git history/status.
- F00 and F01 are complete. `game/project.godot` launches `res://main.tscn` with the Compatibility
  renderer and defines only the four movement actions. No aim or shooting action exists.
- `game/player.gd` owns normalized movement plus one alive/dead transition. It emits `died`,
  disables physics on death, and restores position, velocity, and control through `respawn_at()`.
  It has no facing, weapon, cooldown, projectile, damage, or combat state.
- `game/main.gd` is the concrete exterior/retry owner. It connects the player and one static
  Basin hazard, owns a duplicate-safe one-shot 0.65-second retry, shows redeploy feedback, and
  restores the same player at `BasinSurface/ShuttleSpawn`. It does not reload the Basin.
- `game/basin_surface.tscn` owns a 2160x900 bounded authored route, static shuttle and spawn,
  one avoidable hazard at approximately the route midpoint, and a safe passage. It has no
  encounter spawn or combat arena marker.
- `game/tests/run_tests.gd` preserves the F00 project/renderer/movement-input baseline.
  `game/tests/test_f01_first_expedition.gd` verifies composition, actual movement and wall
  collision, avoidable lethal contact, duplicate rejection, and three exact shuttle retries.
- Planning preflight began from clean `main` at commit `01264b4`, tracking `origin/main`, with no
  unrelated user changes to preserve. The configured remote is
  `https://github.com/contrazap/Landzone.git`.
- On 2026-09-05 the console reported `4.7.1.stable.official.a13da4feb`; headless editor import,
  the F00 test, the complete F01 test, two-frame main-scene smoke, and `git diff --check` all
  exited 0.
- On 2026-09-05 the user explicitly approved the catalog's Surveyor weapon/tool, Base pulse,
  and Stalker candidates as written. F02 may plan those three items; other proposed catalog
  content remains unapproved.
- Previous behavior to preserve: the project launches into the same authored Basin; WASD and
  arrow movement, normalized diagonals, camera, walls, shuttle collision, avoidable hazard,
  one prompt duplicate-safe retry, exact shuttle restoration, and stable repeated retries all
  remain working.

## In scope

- Present the approved Surveyor weapon/tool on the player as the one current weapon and aim it
  toward the mouse in world space while the player is alive.
- Add one direct `shoot` input bound to the primary mouse button and visible firing feedback.
- Fire the approved Base pulse as a focused projectile with centralized speed, lifetime, and a
  short fixed recovery. It is always available after recovery and never consumes ammunition.
- Give world geometry and the first enemy explicit projectile collision intent; a pulse expires
  on the first valid impact or at its lifetime limit and cannot hit more than once.
- Add one focused Stalker scene and one authored encounter spawn in the existing Basin route.
  The Stalker begins concealed but locally hinted, reveals an unmistakable tell when the player
  enters its on-screen trigger range, locks a committed approach direction after the tell, and
  exposes a lethal attack hitbox only during that committed attack.
- Make the Stalker require three Base-pulse impacts to defeat, with visible hit acknowledgement
  and no conventional player health bar. It cannot damage the player before its tell completes.
- Keep attack patterns authored and deterministic. A missed approach enters a readable recovery
  before the same authored cycle can begin again; it does not invent or randomize behavior.
- Extend the current exterior owner just enough to spawn/contain pulses and reset this one
  encounter. A defeated Stalker stays defeated during the current successful life; any player
  death clears active pulses and restores the same Stalker instance at its authored spawn and
  initial state before control returns at the shuttle.
- Expose focused, testable enemy-state transitions and timing values so automated checks can
  prove the nonlethal tell window, committed attack, hit count, defeat, and duplicate-safe reset.
- Record the roadmap's manual observations: whether the player can identify the lethal tell,
  measured death-to-control time, measured shuttle-to-encounter runback time, and whether aiming,
  firing, dodging, defeat, and retry remain readable at the default window size.

## Out of scope

- Additional weapons, alternate fire, the later artifact weapon verb, inventory, ammunition,
  reloading, weapon selection, equipment commands, upgrades, damage numbers, aim assist, gamepad
  aiming, or a generic weapon/component framework.
- Player hit points, armor, healing, invulnerability frames, damage accumulation, a health bar,
  or any nonlethal direct Stalker attack.
- The Spitter, Bulwark, elite variation, boss, procedural encounter selection, randomized attack
  patterns, multiple simultaneous enemies, patrol/pathfinding framework, loot, or resource drops.
- Changing the F01 environmental hazard, shuttle checkpoint, respawn duration, Basin topology,
  camera limits, or verified movement behavior except for the smallest combat presentation
  integration needed on the existing player and route.
- Mothership transitions, durable run state, persistence across application restarts, save data,
  journal/codex systems, command input, coordinates, generated terrain, survival systems, or
  precision blink.
- A global combat manager, autoloaded encounter registry, reusable enemy base class, behavior
  tree, state-machine framework, custom combat `Resource`, or generalized checkpoint service.
- Approval or implementation of any proposed catalog item other than the three explicitly
  approved F02 items.

## Current design

F01 has one local owner with one player and one static Basin. The player owns only locomotion and
whether it can act; the main scene owns cross-entity retry coordination. F02 will preserve those
boundaries: the player interprets direct aim/fire input and enforces its weapon recovery, then
emits a shot request. The current exterior owner creates the concrete pulse under one projectile
container and coordinates that pulse's concrete Stalker hit. The Stalker owns its authored state,
presentation, attack hitbox, and three-hit defeat. The existing main owner resets the encounter
when its already-owned retry completes.

```text
mouse aim + shoot -> player (aim direction + fixed recovery)
                         |
                         +-- pulse request -> main/Projectiles -> base pulse
                                                            |          |
                                                            |          +-- world impact -> expire
                                                            +-- Stalker impact -> hit/defeat

player enters trigger -> Stalker: CONCEALED -> TELEGRAPH -> COMMITTED -> RECOVERY
                                                    |             |
                                                    |             +-- lethal hit -> player.die()
                                                    +-- attack hitbox remains inactive

player.died -> existing main retry -> clear pulses + reset same Stalker -> shuttle respawn
```

This deliberately concrete hit routing makes ownership observable for the first enemy. F07's
second enemy will provide evidence for whether a shared damage target, projectile-hit contract,
or enemy-state abstraction is justified.

## Refactoring assessment

- Observed pressure: F01's local main owner must now coordinate one additional cross-entity
  lifecycle: transient projectiles and a repeatable enemy encounter must reset with the existing
  player retry. The player also needs an action boundary beyond movement/death. There is still
  only one weapon, projectile, and enemy, so no duplication justifies generic combat classes.
- Decision: Keep `main.gd` as the concrete current-exterior owner, extend `BasinExplorer` with
  only direct aim/fire and recovery state, and add focused concrete Base-pulse and Stalker scenes.
  Use signals only for the player-to-owner shot request and observable Stalker state events; use
  clear direct calls for this owner's known pulse hit and encounter reset. Do not refactor F01's
  checkpoint or player lifecycle into a global service.
- Behavior-preserving verification: Run the complete F00 and F01 suites before implementation
  and after every F02 step. A material structural change beyond this planned concrete extension
  requires a separate behavior-preserving step and an architecture-log entry before new combat
  behavior continues.

## Expected files

- Modified: `game/project.godot`
- Modified: `game/main.tscn`
- Modified: `game/main.gd`
- Modified: `game/player.tscn`
- Modified: `game/player.gd`
- Modified: `game/basin_surface.tscn`
- New: `game/base_pulse.tscn`
- New: `game/base_pulse.gd`
- New: `game/stalker.tscn`
- New: `game/stalker.gd`
- New: `game/tests/test_f02_ranged_combat.gd`
- Modified: `game/tests/README.md`
- Modified during planning and implementation: `plans/F02_ranged_combat_and_first_enemy.md`
- Modified during planning and implementation: `PROGRESS.md`
- Modified during planning: `docs/CONTENT_CATALOG.md`
- Modified during planning: `plans/README.md`
- Modified only if implementation establishes a material structural boundary beyond this plan:
  `docs/ARCHITECTURE_EVOLUTION.md`

Godot may generate `.uid` companions for new scripts during import. Completion notes must list
the actual files rather than treating this expected list as fixed.

## Step ledger

Allowed statuses: `Not started`, `In progress`, `Blocked`, `Complete`.

| Step | Outcome | Status | Verification |
| --- | --- | --- | --- |
| S01 | The player can aim the Surveyor weapon/tool and repeatedly fire visible, bounded Base pulses with no ammunition cost. | Not started | Headless import, F00/F01 regressions, focused input/aim/recovery/projectile checks, smoke, and `git diff --check`. |
| S02 | One authored Stalker reveals a nonlethal tell, commits to a lethal approach, acknowledges pulse hits, and can be defeated. | Not started | Focused state/timing/collision/three-hit-defeat checks plus import, regressions, smoke, and diff check. |
| S03 | Combat death and later hazard death both clear transient shots and reset the same Stalker encounter exactly once before shuttle control returns. | Not started | Focused enemy-attack death, defeat persistence, multi-cycle encounter reset, identity, timing, and regression checks. |
| S04 | Full F02 acceptance evidence records readable combat, lethal-attack comprehension, death-to-control time, and runback time. | Not started | Clean full automated suite, ownership/scope inspection, and user-confirmed manual combat/retry observations. |

## Implementation steps

### S01 - Add direct aiming and the Base pulse

**Purpose:** Establish and verify the player's one direct ranged action before enemy state and
lethal combat add another source of failure.

**Changes:** Add only the `shoot` input action with a primary-mouse-button binding. Extend the
player scene with a simple Surveyor weapon/tool presentation, muzzle marker, and visible world-
space aim direction. While alive, the player follows the mouse position, accepts a shot only
when the aim vector is nonzero and the short fixed recovery has elapsed, and emits the muzzle
position and normalized direction to the current exterior owner. Death stops firing and clears
its recovery state consistently for respawn. Add a focused Base-pulse scene/script with simple
cyan placeholder visuals, collision, centralized speed and lifetime, forward motion, one-impact
expiration, and lifetime expiration. Add a `Projectiles` container to the main scene; `main.gd`
creates pulses there from accepted requests and clears them when retry starts. Update the HUD
hint to communicate mouse aim and primary-button fire. Start a focused F02 test and document its
command.

**Do not:** Add an enemy, encounter marker, enemy collision branch, ammunition, heat meter,
alternate fire, artifact behavior, new command, gamepad binding, generic weapon class, or combat
UI. Do not change F01 movement, hazard, or retry timing.

**Verify:** Run:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f01_first_expedition.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f02_ranged_combat.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
git diff --check
```

The F02 test must verify the primary-button `shoot` binding, world-space normalized aim,
weapon/muzzle presence, one accepted shot, rejection during recovery, acceptance immediately
after recovery without ammunition state, forward pulse motion, world-impact expiration, lifetime
expiration, and removal of active pulses when death begins. Import, both earlier suites, smoke,
and diff checks must remain clean.

**Manual checkpoint:** Launch the Basin, move and stand still while aiming around the player,
and confirm the Surveyor weapon/tool visibly follows the mouse without changing movement speed.
Fire in several directions; each pulse must visibly leave the muzzle, travel where aimed, stop at
rock boundaries, and become available again after a short consistent recovery. Hold and tap the
primary button and confirm firing never requires ammunition or reloads. No enemy is expected yet.

### S02 - Add the authored Stalker encounter

**Purpose:** Deliver one learnable enemy whose lethal threat is separated from its tell, then
prove the Base pulse can defeat it without adding player health or generic enemy machinery.

**Changes:** Add one named encounter marker to a clear section of the existing Basin route and
instance one focused Stalker scene from the main composition. The Stalker starts in a concealed
state with only a subtle local hint and cannot attack there. Entering a bounded trigger that fits
within the default camera view starts a visually distinct telegraph. After the configured tell,
the Stalker locks the player's then-current direction and begins one committed approach with its
lethal attack area enabled; it does not home after commitment. A miss ends in a readable recovery
before it conceals and can repeat. Add explicit world/enemy/projectile/attack collision intent.
Route Base-pulse impacts through the current exterior owner to this concrete Stalker. Each valid
pulse expires once and causes one acknowledged hit; three hits defeat and disable the Stalker for
the current life. A committed attack touching the live player calls the existing lethal player
transition. Expose named states, exported timing/motion tuning, and state/attack/hit/defeat signals
needed for verification and later playtest evidence.

**Do not:** Implement encounter reset yet, add random choices, off-screen attacks, contact damage
outside the committed attack, player health, enemy health UI, drops, navigation/pathfinding,
multiple enemies, a shared enemy base class, or later enemy roles. Relaunching the scene is the
temporary way to replay a defeated encounter until S03.

**Verify:** Run the S01 command set again. The F02 test must additionally prove one Stalker and
spawn, no lethal attack or damage before the tell completes, trigger range bounded to the visible
play area, the configured minimum tell duration, direction locked on commitment, active lethal
hitbox only during commitment, recovery before another cycle, exactly one hit per pulse, visible
hit-state acknowledgement, defeat after exactly three valid impacts, no action after defeat, and
actual committed-attack contact causing the existing one-step player death. Earlier movement,
hazard, and retry checks must remain passing.

**Manual checkpoint:** Launch and reach the encounter without firing. Describe the first visual
change that communicates an incoming attack, dodge after the tell, and confirm a missed attack
travels in its committed direction rather than steering back toward the player. Fire three pulses
into the Stalker and confirm each hit reads and the third defeats it. Relaunch, deliberately take
the committed hit, and confirm it is immediately lethal without a health bar. Record any attack
that felt possible before its tell or began outside the visible play area.

### S03 - Reset combat with the shuttle retry

**Purpose:** Make the first encounter safely repeatable and extend F01's verified retry contract
without reloading the exterior or generalizing checkpoints prematurely.

**Changes:** Extend the current main-scene retry flow to clear all active Base pulses and reset the
same Stalker instance to its authored spawn, concealed state, full three-hit requirement, inactive
attack, and clean motion before the player regains control. Ensure one death performs one reset
even if attack/contact events repeat. A Stalker defeated during a successful life remains defeated
while that life continues; a later death to either the environmental hazard or enemy restores it.
Retain F01's exact shuttle marker and retry delay. Add observable reset/count/state evidence to
the concrete encounter only where the tests require it.

**Do not:** Reload or reroll the Basin, replace the player or Stalker instance, persist enemy defeat
across death, add multiple checkpoint policy, add a global encounter/checkpoint manager, or change
the respawn duration to compensate for runback length.

**Verify:** Run the S01 command set again. Extend the F02 test to defeat the Stalker and prove it
remains defeated before death; create an active pulse, then trigger both an enemy-caused retry and
a later hazard-caused retry; and repeat combat death at least three times. Each cycle must start
one retry, clear every pulse, retain the same player/Basin/Stalker identities, restore the Stalker
exactly once at its marker with initial state and three required hits, restore the player exactly
at the shuttle within the existing configured delay, and leave controls and firing usable. The
F01 suite must still prove its original three hazard retries independently.

**Manual checkpoint:** Defeat the Stalker and verify it does not reappear while continuing the
same life. Die to the existing hazard, return from the shuttle, and verify the encounter has
reset. Then die to the Stalker three times; after every prompt shuttle restoration, run back and
confirm the same readable tell, no lingering pulse, no duplicate enemy, immediate movement/aim/
fire control, and unchanged Basin geometry.

### S04 - Verify and accept the first combat loop

**Purpose:** Confirm that the complete F02 loop is fair, legible, and repeatable before F03 adds
scene transitions and state that survives exterior unload/reload.

**Changes:** Run the complete verification set from a clean editor state, inspect exact input,
collision, signal, projectile, enemy-state, and encounter-reset ownership, and record actual
outputs plus the user's manual observations in this plan and `PROGRESS.md`. Measure actual
death-to-control time and shuttle-to-telegraph runback time during the hands-on check. Make only
fixes necessary to meet F02's approved behavior. If evidence requires broader scope or a material
boundary change, revise the plan and explain it before implementing that change.

**Do not:** Begin F03, add unrelated combat polish, credit visual/timing/comprehension evidence
that was not observed, or mark F02 complete while the attack-tell and timing gate is pending.

**Verify:** Run:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --version
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f01_first_expedition.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f02_ranged_combat.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
git status --short
git diff --check
```

The version must remain `4.7.1.stable.official.a13da4feb`; all Godot commands must exit 0; each
focused script must print its explicit pass summary; status must contain only intended F02 and
bookkeeping files; and the diff check must report no errors. Inspection must find no health,
ammo/inventory, later enemy, persistence, command, procedural generation, or speculative global
combat/checkpoint system.

**Manual checkpoint:** At the default window size, use WASD and arrows while aiming and firing
with the mouse. Confirm the weapon direction and pulse path are readable, recovery is consistent,
walls stop pulses, and no ammunition or health UI appears. Reach the Stalker without firing and
state which visual tell predicts danger; dodge at least one committed approach, defeat it with
three readable hits, then deliberately take an attack and confirm immediate death. Repeat combat
death three times and verify exact prompt shuttle restoration, clean controls, and a clean reset
on every runback. Measure and record (1) death-to-control time and (2) shuttle-to-first-telegraph
runback time; record whether either interval feels slow or repetitive and whether any lethal hit
was not preceded by the identified tell.

## Feature acceptance criteria

- [ ] The player visibly aims the approved Surveyor weapon/tool with the mouse and fires the
  approved Base pulse using a direct primary-button action while moving or stationary.
- [ ] Base pulses travel in the aimed world-space direction, stop on their first valid impact or
  lifetime limit, visibly acknowledge firing/impact, and are always available after a short
  fixed recovery without ammunition, reload, inventory, or a heat-management UI.
- [ ] Exactly one approved Stalker occupies one authored, on-screen-readable Basin encounter and
  follows only the authored concealed, telegraph, committed approach, recovery, and defeated
  behavior defined by this plan.
- [ ] The Stalker's lethal hitbox is inactive before its clear tell completes, its approach locks
  direction rather than homing after commitment, and a missed attack gives a readable recovery
  before another cycle.
- [ ] Each Base pulse can register at most one Stalker hit, hits are visibly acknowledged, and
  exactly three valid hits defeat and disable the Stalker for the remainder of that life.
- [ ] Any committed Stalker attack that touches the live player kills immediately through the
  existing player lifecycle, with no hit points, armor, damage accumulation, invulnerability
  ladder, healing, or health bar.
- [ ] A combat or environmental death starts exactly one prompt existing retry, clears transient
  pulses, and resets the same Stalker instance once at its authored spawn and initial state before
  restoring movement, aim, and fire control at the exact shuttle marker.
- [ ] A defeated Stalker remains defeated during the current successful life but returns after
  the next death; repeated retries never duplicate or replace the player, Basin, or Stalker and
  never reroll or alter the authored exterior.
- [ ] The implementation contains no later weapon/enemy role, loot, inventory, mothership,
  persistence, command interface, coordinate system, procedural generation, or speculative
  generic combat/checkpoint framework.
- [ ] Godot import/parser, F00 regression, F01 regression, focused F02, and main-scene smoke checks
  pass with the confirmed Godot 4.7.1 console executable, and `git diff --check` is clean.
- [ ] The user identifies the Stalker's lethal tell, confirms aiming/firing/hit/defeat readability
  and repeatable lethal retry, and reports measured death-to-control and shuttle-to-telegraph
  runback times plus whether either interval feels slow or repetitive.
- [ ] The active plan, content catalog, and `PROGRESS.md` match actual evidence; the architecture
  log changes only if implementation establishes a material boundary beyond this plan.

## Verification plan

### Automated or headless

- Confirm the executable with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --version`; expect
  `4.7.1.stable.official.a13da4feb` and exit 0.
- Import and parse with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit`;
  expect exit 0 without parser/load errors.
- Preserve F00 with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd`;
  expect its explicit pass summary and exit 0.
- Preserve the entire F01 movement/hazard/retry contract with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f01_first_expedition.gd`;
  expect its explicit pass summary and exit 0.
- Run F02 behavior checks with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f02_ranged_combat.gd`;
  expect its explicit pass summary and exit 0 after input, aim, recovery, pulse lifecycle,
  authored enemy states, tell/commit timing, three-hit defeat, lethal attack, and repeated
  encounter-reset assertions.
- Smoke the configured main scene for two frames; expect exit 0 without parser, load, runtime,
  orphan-node, or early collision errors.
- Inspect `git status --short` for intended files only and run `git diff --check`; expect no
  unrelated changes or whitespace errors.

### Manual

- Launch the configured project at its default size. Exercise both movement control sets while
  aiming and firing with the mouse; verify the weapon direction, muzzle feedback, pulse path,
  wall impact, recovery cadence, and absence of ammunition/reload/health UI.
- Reach the encounter without shooting. State the visible event that communicates the incoming
  lethal attack, confirm no hit occurs before it, and dodge after commitment to verify the
  Stalker does not turn back toward the player during that attack.
- Fire three valid pulses and confirm one readable acknowledgement per hit and defeat on the
  third. Continue during the same life to verify the Stalker remains defeated.
- Relaunch or use the next reset, deliberately take a committed hit, and confirm immediate death
  followed by the existing visible shuttle redeployment and usable movement/aim/fire controls.
- Defeat the Stalker, die to the environmental hazard, and verify the same encounter resets.
  Then complete three combat-death/runback cycles and confirm no duplicate enemy, stale attack,
  lingering pulse, changed world, error dialog, or stuck input.
- Measure death-to-control and shuttle-to-first-telegraph runback times with a stopwatch or video
  timestamps. Record the values, whether retry and runback feel prompt rather than repetitive,
  whether the lethal tell was identifiable without reading code, and any attack that felt
  unreadable or off-screen. An unfamiliar-player gate is not required for F02, but the observer
  must report what they actually recognized rather than being credited from automated state tests.

## Completion notes

Fill this section during implementation rather than predicting results:

- Actual files changed:
- Steps completed:
- Commands/tests and results:
- Manual checks performed:
- Deviations from plan:
- Architecture log entries:
- Remaining risks or debt:
- Suggested commit boundary:
