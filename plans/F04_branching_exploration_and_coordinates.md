# F04 - Branching exploration and coordinates

- Feature status: Complete
- Dependencies: F00-F03 complete
- Created: 2026-09-06
- Completed: 2026-09-06
- Delivery mode: Single delivery
- Current delivery: D01

## Outcome and scope

Extend the authored Basin from its current linear combat strip into a compact, readable path
network. The player can walk six bounded path segments through three meaningful three-way
junctions, use either side of one loop, and reach two surveyed dead-end limits. While exploring,
the player can open a paused command console and enter `where` to read the current regional
coordinate, shuttle-relative local coordinate and eight-way facing.

F04 owns the authored navigation baseline required before procedural replacement in F07:

- Three degree-three route junctions and six path segments.
- One loop with distinct north and south choices and valid return traversal.
- Readable compass-aligned route silhouettes, junction marks and surveyed endpoint limits.
- Region `P1-BASIN-01`, a local coordinate convention and eight-way facing convention.
- A focused paused command console with `where`, usage feedback and unknown-command feedback.
- Pause/focus/input safety across movement, combat, retry and location-transfer lifecycles.
- Preservation of the existing shuttle, lethal field, Stalker encounter, camera follow,
  return/redeployment and same-instance lethal retry contracts.

Explicitly excluded are journal entries/search/save data (F05), clue or codex content (F06),
generated topology and the second surface/enemy (F07), precision blink (F08), map/minimap,
fast travel, new landing regions, new encounters and any shuttle-flight simulation.

## Actual starting state

- Relevant files, scenes, ownership and data lifetimes inspected:
  - `main.gd`/`main.tscn` persist one `RunState` and replace concrete locations through a guarded
    static transfer.
  - `basin_expedition.gd`/`basin_expedition.tscn` own the loaded Basin player, Stalker, pulses,
    retry, camera bounds, exterior HUD and shuttle-return interaction.
  - `basin_surface.tscn` is a 2160 by 900 authored horizontal corridor. It has one shuttle at
    `(302, 450)`, player spawn at `(480, 450)`, lethal field near `(1115, 405)`, Stalker spawn at
    `(1660, 450)`, broad rectangular collision boundaries and no route graph or script.
  - `player.gd` owns direct movement, last aim vector, firing, loaded retry and deferred-safe
    per-location camera ownership. It has no separate navigation-facing value.
  - `stalker.gd` preserves encounter state across a normal unload/revisit but currently clamps a
    restored position to the old corridor's hard-coded range.
  - `project.godot` has direct movement, mouse fire and physical `E` interaction; it has no
    command-console action.
  - There is no command parser, coordinate service, pause-capable interface or disk save.
- Existing behavior to preserve:
  - Kestrel is the initial location; one static transfer deploys to the Basin and the shuttle
    returns to Kestrel.
  - The player starts exactly at the existing shuttle marker, is camera-centered after the
    transfer, can aim/fire only outside, and remains within the visible safe margin while moving.
  - The authored lethal field remains avoidable and the Stalker retains its tell, locked lethal
    commitment, three-hit defeat, normal-revisit snapshot and distinct same-instance death reset.
  - Normal revisits recreate location/player/Stalker nodes and preserve only the intended
    encounter snapshot; death retries retain the loaded instances and return to the shuttle.
- Baseline commands and actual results on 2026-09-06 from the repository root:
  - `Godot_v4.7.1-stable_win64_console.exe --headless --path game --editor --quit` exited 0 with
    no parser or resource errors.
  - `Godot_v4.7.1-stable_win64_console.exe --headless --path game --script
    res://tests/test_f03_mothership_transition.gd` exited 0 and printed the expected F03/D01
    success summary.
  - Immediately before planning, F00, F01, F02 and F03 focused scenarios all exited 0, the staged
    F03 diff check passed, and completed F03 was committed and pushed as `0e81d2e`.
- User changes to preserve: The worktree is clean after the user-authorized F03 commit/push;
  there are no unrelated local changes at this planning boundary.
- Assumptions and required external decisions: No external decision is required. The exact F04
  coordinate scale, route names and command key below are in-scope plan choices. Human enjoyment
  and first-time route comprehension remain optional observations, not implementation gates.

## Content and design decisions

### Authored Basin network

Keep the shuttle and current encounter landmarks near their existing coordinates, expand the
playable/camera bounds to approximately 2400 by 1080, and reshape the rock masses and solid path
edges into this six-segment graph:

```text
                         North Arc
                    /----------------\
SHUTTLE -- Landing Fork                 Reunion Fork -- East Approach -- Far Fork
                    \----------------/                              /          \
                         South Arc                         North Shelf      South Hollow
```

- `Landing Run`: shuttle spawn to `Landing Fork`.
- `North Arc` and `South Arc`: visibly separated compass-diagonal choices from Landing Fork to
  Reunion Fork; together they form the loop.
- `East Approach`: Reunion Fork to Far Fork.
- `North Shelf` and `South Hollow`: short final choices ending at clearly marked survey limits.
- Landing Fork, Reunion Fork and Far Fork each have exactly three traversable incident paths.
  Junction floor rings, small compass ticks and distinct surrounding silhouettes make their
  branch directions visible without adding a map or explanatory modal.
- Endpoint signage says `SURVEY LIMIT` and does not imply the F06 clue landmark, F07 resource
  site or F09 principal structure. The route remains one Basin surface presentation.
- Keep the existing lethal field on one avoidable arc and the Stalker on the other/eastern
  approach so both old mechanics remain present without adding another enemy or hazard.
- Use focused collision bodies along the actual rock edges and outer caps. Broad walls may not
  falsely block an intended branch or permit walking through the surrounding rock mass.

The graph is authored presentation and physics, not generated run data. Named junction,
segment and endpoint nodes make the intended topology inspectable, but F04 will not create the
plain generated graph model, seeded RNG streams or module-selection API owned by F07.

### Coordinate and facing convention

- Regional coordinate is the stable identifier `P1-BASIN-01` already shown in the exterior and
  Kestrel deployment display.
- Local origin is the Basin `ShuttleSpawn`; entering `where` at the exact spawn reports
  `LOCAL N00 E00`.
- One local unit is 80 Godot world pixels. Each axis is rounded to the nearest local unit.
- World `-Y` is north, `+Y` is south, `+X` is east and `-X` is west. Axes are always printed in
  north/south order followed by east/west order, with a minimum of two digits. Zero uses `N00`
  and `E00`, producing stable output such as:
  `REGION P1-BASIN-01 | LOCAL N04 E09 | FACING NE`.
- Facing is the player's last nonzero weapon/aim direction, because that is the only existing
  visible orientation. It is quantized to `N`, `NE`, `E`, `SE`, `S`, `SW`, `W` or `NW` using
  equal 45-degree sectors. Moving without changing aim does not silently redefine facing.
- `player.gd` gains a last-nonzero facing value separate from the shot direction so placing the
  mouse exactly over the player cannot erase a previously readable facing.
- A small focused `CoordinateService` owns conversion and formatting. `BasinExpedition` owns one
  service instance configured from its region identifier and live shuttle-origin marker. No
  autoload, persistence or generated-world dependency is introduced.

### Paused command console

- Add physical `Tab` as `command_console`. The Basin movement hint advertises
  `TAB COMMANDS`; the F00 input baseline checks the binding.
- Pressing Tab during normal live exterior play opens a full-viewport dimmed command panel,
  focuses one `LineEdit`, and pauses the scene tree. The console uses `PROCESS_MODE_ALWAYS`, so
  its LineEdit, submit handling, Tab toggle and Escape close remain responsive while gameplay is
  paused. Opening clears current movement velocity.
- Enter submits. Input is trimmed and command words are matched case-insensitively:
  - exact `where` prints the formatted live location line;
  - `where` with arguments prints `USAGE: where`;
  - any other nonempty command prints `UNKNOWN COMMAND: <verb>`;
  - an empty submission keeps focus and prints `ENTER A COMMAND`.
- The panel visibly includes `AVAILABLE: where`, the last response and a compact
  `ENTER SUBMIT  |  TAB/ESC CLOSE` hint. It keeps only the current response; command history and
  completion arrive with later command pressure.
- `CommandConsole` owns UI focus, raw input, the small F04 parser and balanced pause/unpause.
  `BasinExpedition` provides a `where` callback/result and enables opening only while the player
  is alive and neither retry nor location transfer is active. It closes before any exterior
  teardown and guarantees `SceneTree.paused == false` on exit.
- While open, the player, Stalker, pulses, hazard contact, weapon recovery and retry timers do
  not advance. Movement, firing, contextual return and duplicate console opens do nothing.
  Closing resumes the exact loaded state without synthesizing held actions.
- The console is exterior-local in F04. F05 may move or generalize it if journal access across
  locations demonstrates that need; F04 does not prebuild a command registry or global terminal.

### Refactoring decision

Observed pressure justifies one narrow geometry-boundary refactor: the Basin camera and Stalker
snapshot validation cannot keep separate hard-coded old-corridor limits after the surface grows.
Define the F04 Basin bounds once in `BasinExpedition`, use them for player camera configuration,
and pass an explicit allowed bounds value into Stalker restore. Preserve the F03 capture/restore
fields and collision/presentation rebuild unchanged. A generic world/region definition Resource
is rejected until F07 introduces multiple seeded graph instances.

The command console and coordinate formatter are focused new boundaries, not a general framework.
Their split is warranted because UI pause/focus lifetime and coordinate math have distinct tests
and F05 will consume the live coordinate result without making journal prose authoritative.

No catalog state changes occur during planning. `where` is already the proposed F04 location
command and the Basin surface is already Implemented; implementation will extend that same
surface rather than approve a later landmark, enemy or environment candidate.

## Delivery sizing

F04 is one delivery. The route geometry, coordinate result and paused console are one player
experience and share the same real-scene verification. There is no data migration, disk format,
procedural generator or independently useful intermediate boundary that warrants a split.

| Delivery | Outcome and dependencies | Status | Acceptance IDs |
| --- | --- | --- | --- |
| D01 | Complete authored branching Basin and paused `where` flow while preserving F00-F03 | Complete | A01-A07 |

Delivery statuses: Not started, In progress, Blocked, Complete.

## Delivery implementation checklist

### D01 - Explore and locate within the authored Basin network

- Expected files and responsibilities:
  - `game/basin_surface.tscn`: expanded six-segment route, three junctions, loop, readable
    endpoint limits, rock-edge collision and preserved shuttle/hazard/Stalker markers.
  - `game/navigation/coordinate_service.gd`: shuttle-relative axis conversion, eight-way facing and exact
    `where` formatting.
  - `game/ui/command_console.gd` and `game/ui/command_console.tscn`: focused F04 parser, paused
    overlay, focus and balanced lifecycle.
  - `game/basin_expedition.gd` and `.tscn`: single geometry constants, coordinate/console
    integration, HUD hint and retry/transition command lock.
  - `game/player.gd`: retain last nonzero aim-facing without changing direct aim/fire behavior.
  - `game/stalker.gd`: validate restored position against caller-provided Basin bounds rather
    than the obsolete corridor rectangle.
  - `game/project.godot` and `game/tests/run_tests.gd`: physical Tab command action and baseline
    assertion.
  - `game/tests/test_f04_branching_coordinates.gd`: topology, physics reachability, coordinate,
    real console input, pause/focus, failure and lifecycle scenario.
  - `game/tests/capture_f04_views.gd` and `game/tests/artifacts/f04_*.png`: deterministic rendered
    junction and command-console evidence.
  - `game/tests/README.md`: exact F04 commands, coverage and capture limitations.
  - `docs/CODE_GUIDE.md`, `docs/ARCHITECTURE_EVOLUTION.md`, `PROGRESS.md` and this plan: current
    ownership, material decisions, evidence and continuation.
- [x] Establish the F03 regression baseline and mark F04/D01 In progress before runtime edits.
- [x] Apply the clarified maintainability policy by placing new navigation and UI responsibilities
      in domain folders, with paths, tests and documentation updated together.
- [x] Expand the Basin into the exact authored six-segment/three-junction/one-loop network with
      bounded traversable collision and readable, non-future-content endpoint presentation.
- [x] Centralize Basin bounds and preserve camera, Stalker snapshot and retry behavior across the
      larger surface.
- [x] Implement and integrate the exact coordinate/facing convention and formatter.
- [x] Implement the Tab-opened command console, bounded `where` grammar, error responses,
      focus capture and balanced pause/close/teardown behavior.
- [x] Exercise actual route movement, command input, pause invariants, death, normal revisit and
      earlier regressions; fix in-scope failures.
- [x] Capture and inspect the three junction choices and console response at 960x540 in the
      Compatibility renderer.
- [x] Review the intended diff and update evidence/catalog decision, code guide, architecture
      record, test documentation and progress ledger. A later Git audit established that the
      delivery remains in the worktree; no commit/push is part of current feature acceptance.

## Acceptance and evidence

| ID | Required observable outcome | Agent verification method and expected result | Actual evidence / status |
| --- | --- | --- | --- |
| A01 | The authored Basin contains six bounded path segments, three degree-three junctions, one north/south loop and two surveyed endpoint limits. | Inspect named topology nodes and collision intent, then drive the real player from the shuttle through both loop arcs, through Reunion/Far Fork, to both endpoint markers and back without crossing rock or leaving world bounds. Expected: every intended route is traversable, both loop choices reconnect, endpoint caps stop further travel and unintended rock crossings fail. | Passed: F04 scenario found exactly 6/3/2 grouped nodes, drove the player through Landing Run, both complete arcs, East Approach and both final branches, hit both outer caps and could not cross LoopIsland. |
| A02 | Route choices and junctions are readable in the running 960x540 game while the camera continues following. | Non-headless capture driver positions/moves the real player at Landing Fork, Reunion Fork and Far Fork and saves focused images. Inspect actual pixels for branch silhouettes, junction ticks, endpoint distinction, HUD obstruction, player visibility and camera safe margins. | Passed: six final Compatibility captures show separated branch silhouettes, visible player/aim, cyan Landing/Reunion language, warm Far Fork/limits and full captions. Initial endpoint clipping and distant-caption/HUD overlap were fixed, recaptured and re-inspected. |
| A03 | `where` reports the exact region, shuttle-relative local axes and eight-way facing under the specified convention. | Focused service assertions cover origin, positive/negative axes, rounding boundaries, padding and all eight direction sectors. Through the actual console, query at spawn and at least two branch positions/facings; expected strings match world position and visible aim. | Passed: focused cases covered origin, N/E, S/W and both rounding sides plus all eight sectors. Parsed input returned `REGION P1-BASIN-01 | LOCAL N04 E09 | FACING NE`; the retained console capture independently shows `N03 E09 / NE`. |
| A04 | The command console opens through physical Tab, remains operable while paused, handles its bounded grammar and restores focus/play safely. | Inject real Tab/character/Enter/Escape input through the instantiated main scene. Assert focused LineEdit, `SceneTree.paused`, exact success/empty/usage/unknown responses, ignored duplicate open, close/unpause and immediate movement/aim/fire after release. | Passed: parsed Tab, five character keys, Enter and Escape exercised the real Control/LineEdit. Exact where, mixed-case where, usage, unknown and blank responses passed; duplicate open failed; movement/fire resumed; Tab closed a fresh redeployed console. |
| A05 | Paused planning freezes ordinary gameplay and cannot leak across retry or location teardown. | With live Stalker phase, player velocity, pulse lifetime and weapon recovery sampled, hold the console open across real elapsed time; expected values/positions do not advance and movement/fire/return are rejected. Close and prove they resume. Attempt opening during death retry/transfer, then return/redeploy; expected rejection, one active location/player and an unpaused tree. | Passed: player position, pulse position/elapsed, Stalker elapsed and recovery time stayed fixed for 0.3 real seconds. Valid-proximity return was rejected; retry/transfer opens were rejected; close, return and redeploy all left the tree unpaused. |
| A06 | Existing lethal retry and normal-revisit state lifecycles remain distinct on the larger route. | Extend/reuse F03 scenarios: capture a Stalker position valid outside the old clamp, return/redeploy and verify exact validated restore; trigger lethal hazard/Stalker contact and verify same-instance reset at the shuttle with clean command state. | Passed: F04 preserved a Stalker at `(1400, 690)` through unload/recreation, proving the old Y clamp is gone. F01/F02/F03 retained repeated environmental/attack retry, snapshot and identity coverage on the expanded scene. |
| A07 | The project remains runnable with no introduced parser/runtime errors and all affected regressions pass. | Import/editor check, F00/F01/F02/F03/F04 focused scenarios, two-frame startup smoke, non-headless F04 capture exit/result validation, error-log review, `git diff --check` and final intended-file review all succeed. | Passed on 2026-09-06: import, F00, F01, F02, F03, F04 and smoke exited 0 with expected summaries/no logged errors; final capture exited 0; `git diff --check` and intended-file/path review passed. The F05 starting-state audit found local `HEAD` and `origin/main` still at F03 commit `0e81d2e`, so the earlier push notation was incorrect; F04 remains in the worktree. |

## Verification execution

- Run from the repository root with
  `C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe`:
  - `--headless --path game --editor --quit` for import/parser/resource validation.
  - `--headless --path game --script res://tests/run_tests.gd` for F00/input/main baseline.
  - Existing F01, F02 and F03 commands documented in `game/tests/README.md`.
  - New `--headless --path game --script res://tests/test_f04_branching_coordinates.gd`;
    success must print one exact F04/D01 summary and exit 0.
  - `--headless --path game --quit-after 2` for startup only.
  - Non-headless `--path game --script res://tests/capture_f04_views.gd`; it must validate every
    save and dimension before exiting 0.
- Reuse F01 route containment/lethal retry, F02 combat/reset and F03 transfer/snapshot/camera
  coverage. Update obsolete old-corridor geometry assertions only to express the expanded route's
  behavioral contract; do not weaken collision, retry or camera checks.
- The F04 scenario uses the real main/Kestrel/Basin scenes, real physics movement and parsed input
  events for Tab, typing, Enter and Escape. Plain coordinate tests remain in that same scenario
  because they isolate the axis/sector boundary math.
- Retain useful captures under `game/tests/artifacts/`, expected to include Landing/Reunion/Far
  junction views and an open console showing a non-origin `where` result. Inspect each with the
  available image viewer; capture success alone does not establish readability.
- No save data exists in F04, so save isolation is not applicable. Tests must release synthetic
  input and restore `SceneTree.paused = false` on every exit path.
- Existing non-headless capture infrastructure and local Compatibility renderer provide the
  required capability. A missing/invalid image, input-focus failure, pause leak, route collision
  failure or console mismatch is a required gap and keeps D01 incomplete.

## Optional experiential limitations

- Whether an unfamiliar player remembers each branch without a map is unassessed unless observed.
- Whether Tab and the compact terminal feel pleasant, and whether the six-segment route pacing is
  enjoyable, are unassessed subjective qualities. Functional discoverability, legible text,
  correct coordinates and readable branch silhouettes remain required and will be inspected.

## Completion and continuation record

- Deliveries completed / current status: D01 Complete; feature Complete.
- Actual changed files, responsibility and reason for change:
  - `game/basin_surface.tscn` now owns the 2400 by 1080 authored six-segment route, three marked
    junctions, solid loop/final separators, two survey limits and repositioned singular hazard and
    Stalker markers.
  - `game/navigation/coordinate_service.gd` owns node-free local-axis/eight-facing formatting;
    `game/ui/command_console.gd`/`.tscn` own the focused parser, LineEdit and balanced pause.
  - `game/basin_expedition.gd`/`.tscn`, `player.gd`, `stalker.gd` and `project.godot` integrate
    region bounds, live where context, last-facing, validated restore, Tab input and lifecycle
    locks. New responsibilities use domain folders under the clarified maintainability policy.
  - F00/F01/F03 fixtures were updated only for the new input, solid-island geometry and derived
    camera bound. The new F04 scenario/capture driver and twelve PNG/import artifacts own durable
    behavioral and rendered evidence.
  - `AGENTS.md` preserves the user's maintainability clarification; test README, code guide,
    architecture log, progress ledger and this plan reflect the implemented boundary.
- Acceptance IDs and commands/scenarios/results, including error-log review: A01-A07 passed.
  Final import, F00-F04 and two-frame startup all exited 0; the F04 scenario printed its exact
  success summary. Logs contained no parser/runtime error. Final non-headless capture exited 0.
- Rendered observations and artifact links: Inspected
  `game/tests/artifacts/f04_landing_fork.png`, `f04_reunion_fork.png`, `f04_far_fork.png`,
  `f04_north_shelf_limit.png`, `f04_south_hollow_limit.png` and `f04_where_console.png` at
  960x540. Fork silhouettes, player, route color hierarchy and console response are legible.
  Endpoint signs initially clipped; moving them left fixed both. Junction captions then moved
  above their rings to clear the fixed HUD at vertically clamped endpoints; final recaptures pass.
- Content decisions implemented and tuning deviations: Implemented the planned region, 80-pixel
  grid, eight facings, Tab/Enter/Escape behavior and six-segment graph. Basin bounds resolved to
  exactly 2400 by 1080. No content-catalog candidate changed state: this extends the already
  Implemented Basin surface and location command without consuming later landmarks/content.
- Code guide sections and architecture decision links: Updated
  [authored navigation and where](../docs/CODE_GUIDE.md#authored-navigation-and-where) and recorded
  [the F04 ownership/pause decision](../docs/ARCHITECTURE_EVOLUTION.md#2026-09-06---f04d01---derive-navigation-text-behind-a-pause-owning-local-console).
- Remaining defects, required verification gaps and optional limitations: None required. Human
  route-memory, terminal feel and pacing remain the optional unassessed limitations above.
- If interrupted or split: Not applicable; the single delivery completed coherently.
- Exact next action: Generate the F05 - Searchable journal and basic persistence plan.
