# F03 - Static mothership base

- Feature status: Complete
- Dependencies: F00-F02 complete
- Created: 2026-09-06
- Completed: 2026-09-06
- Delivery mode: Single delivery
- Current delivery: D01 (`Complete`)

## Outcome and scope

The game begins aboard the static interior-only survey vessel **Kestrel**. The player can walk
between its functional vehicle-bay arrival area and bridge deployment console, inspect the one
currently valid landing coordinate (`P1-BASIN-01`), deploy by static transition to the existing
Basin shuttle, return through that shuttle, and redeploy repeatedly. Returning to the mothership
unloads the exterior but preserves the current Basin encounter; death while deployed remains the
distinct F01/F02 retry path and resets that encounter on the still-loaded exterior.

F03 owns the compact base shell, direct contextual transition interaction, the first explicit
in-memory run-state boundary, location swapping, and verification of normal revisit versus retry
semantics. The bridge and vehicle bay are the only accessible spaces in this feature and both
have a current purpose. Closed, labelled research, galley, medical, habitat, and workshop
bulkheads imply the approved later stations without creating empty playable rooms.

Out of scope: shuttle interior or flight, multiple landing choices, free coordinate entry,
`shuttle land`/`shuttle return` commands, the F04 command overlay and local coordinates,
save files or application-restart persistence, research/codex, inventory/storage, cooking,
rest, treatment, survival status, procedural generation, and later station gameplay.

## Actual starting state

- Relevant files, scenes, ownership and data lifetimes inspected:
  - `game/main.tscn` directly composes the Basin surface, player, one Stalker, projectiles,
    retry timer, and HUD; `game/main.gd` owns all combat routing and retry integration.
  - `game/basin_surface.tscn` owns static shuttle/encounter spawn markers, route geometry,
    lethal hazard, and boundaries but has no return interaction.
  - `game/player.gd`/`player.tscn` own movement, aim, firing eligibility, weapon presentation,
    and a Basin-sized follow camera. They have no location configuration or interaction input.
  - `game/stalker.gd` owns live encounter state only. Its authored reset API exists, but no
    capture/restore contract exists for unloading a normal visit.
  - No autoload, run-state object, alternate location, scene-transition owner, or disk save
    exists. Every gameplay node currently lives for the whole application session.
- Existing behavior to preserve: normalized direct movement; aim/fire and pulse lifecycle;
  authored Basin geometry and safe passage; readable Stalker cycle and three-hit defeat; lethal
  environmental and Stalker contact; guarded 0.65-second death retry; retry-time projectile
  cleanup; and exact same-instance player/Basin/Stalker restoration during each loaded retry.
  Normal mothership visits are new and deliberately use new scene instances on redeployment.
- Baseline commands and actual results, from the repository root on 2026-09-06:
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit`
    exited 0; import/editor scan completed with no reported parser/runtime error.
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd`
    exited 0 with `F00 checks passed`.
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f01_first_expedition.gd`
    exited 0 with `F01/S02 checks passed`.
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f02_ranged_combat.gd`
    exited 0 with `F02/S03 checks passed`.
- User changes to preserve: `git status --short --branch` reported
  `## main...origin/main` with no changed or untracked files before planning.
- Assumptions and required external decisions, if any: no external decision is required.
  `P1-BASIN-01`, Kestrel, labels, interaction wording, palette, and initial transition timing are
  in-scope F03 content selections. They may receive routine implementation tuning with reasons.

## Content and design decisions

### Mothership presentation and interaction

- Name the mothership **Kestrel** and present one compact top-down interior with a cool steel/cyan
  hull language, warm habitable lighting, solid outer walls, and readable floor zoning distinct
  from the dark rock Basin. Keep it Godot-native polygons, lines, labels, and collision shapes.
- The player starts at the vehicle-bay arrival marker. The accessible deck connects that arrival
  area to the bridge/navigation console; it must be compact enough to reach the console in a few
  seconds at the current 220-unit movement speed.
- The bridge display visibly reports `SELECTED LANDING: P1-BASIN-01` and `STATUS: VALID`.
  Nearby interaction displays `E - DEPLOY TO P1-BASIN-01`. The exterior shuttle interaction
  displays `E - RETURN TO KESTREL`. Prompts are absent outside their bounded interaction areas.
- Add one `interact` input action bound to physical `E`. Use it for these time-sensitive spatial
  interactions; do not introduce the paused text-command system early.
- Transitions are static: a guarded 0.25-second full-screen fade/message swaps locations with no
  flyable craft, shuttle interior, animation of travel, or simulated travel time. Repeated input
  during a transition is rejected, and only one player and one active location may exist.
- The Surveyor remains part of the player scene but is holstered/non-firing on the mothership.
  Deployment restores normal aim/fire. Movement and collision remain active in both locations.

### State ownership and lifecycle

- Refactor `Main` into the application-lifetime coordinator. It owns one small `RunState`, the
  active-location container, transition guard/overlay, and location change requests. It does not
  own future save serialization, a generic world registry, or later-feature state.
- Extract the current exterior composition and F01/F02 integration into a focused
  `BasinExpedition` scene/controller. It continues to own the loaded player, Basin, Stalker,
  projectiles, HUD, and death retry. This preserves the existing direct combat routing at its
  demonstrated one-encounter scale.
- `RunState` is an in-memory `RefCounted` plain-data object with only the concrete Basin encounter
  snapshot needed now. It outlives location nodes but is not an autoload or Resource and is not
  written to disk. This keeps run data separate from live nodes without prebuilding F05 saves or
  F07 generation.
- On a normal shuttle return, capture Stalker position, behavior state, elapsed state time,
  remaining hits, and committed direction before freeing the exterior. Clear live pulses and
  player weapon recovery as transient scene state. Time spent aboard Kestrel does not advance the
  captured encounter. On redeployment, instantiate a new exterior and player, restore the
  snapshot including collision/presentation intent, and place the player cleanly at the current
  shuttle marker. A defeated or damaged Stalker remains defeated or damaged.
- On death, do not capture a normal-visit snapshot and do not enter the mothership. The existing
  loaded `BasinExpedition` clears pulses, resets the same Stalker instance to its authored spawn
  and full three-hit state, then restores the same player instance at the shuttle after the
  configured 0.65 seconds. This is the explicit distinction between revisit and retry.
- An active transition blocks death/retry and input races; a retry in progress blocks shuttle
  return. Location controllers disconnect naturally when freed, and `Main` accepts transition
  requests only from its current location so stale signals cannot swap scenes.

### Refactoring decision

Observed pressure: `main.tscn` and `main.gd` are currently both the application root and the
entire Basin visit. Keeping that shape would require hiding the exterior forever or make it
impossible to prove state survives unload/reload. The chosen boundary is a persistent, small
location coordinator plus focused Mothership and Basin location scenes and concrete in-memory
run data. The rejected alternative is merely toggling visibility/process state or reparenting
the existing Basin nodes; that retains live scene state and would not establish the roadmap's
scene-state/run-state distinction. A generic scene manager, encounter registry, autoload, and
disk serialization are also rejected because one alternate location and one encounter do not
justify them yet. Existing F00-F02 checks establish behavior before refactoring; updated versions
must establish the same outcomes after deploying into the extracted Basin.

No catalog state changes occur when generating this plan. F03's ship name, landing identifier,
and station labels are plan-owned presentation details rather than existing catalog candidates;
implementation authorization approves them for F03 only.

## Delivery sizing

F03 is one delivery because the mothership is not a coherent feature without transitions, and
transition correctness cannot be established without the run-state extraction and retry/revisit
verification. Scene extraction, state capture, presentation, regression adaptation, rendered
inspection, and documentation form one integration boundary. None is a useful separately
approved or separately shippable player outcome.

| Delivery | Outcome and dependencies | Status | Acceptance IDs |
| --- | --- | --- | --- |
| D01 | Complete static Kestrel base, normal return/redeployment with Basin state preservation, and distinct death retry; depends on F00-F02 | Complete | A01-A08 |

Delivery statuses: Not started, In progress, Blocked, Complete.
`Implement the plan` completes D01 and therefore the whole feature when every criterion passes.

## Delivery implementation checklist

### D01 - Kestrel base and stateful expedition transitions

- Expected files and responsibilities:
  - Modify `game/main.gd` and `game/main.tscn`: persistent location coordinator, current-location
    container, transition guard/overlay, starting location, and scene swapping.
  - Add `game/run_state.gd`: concrete typed in-memory snapshot for the one Basin/Stalker state.
  - Add `game/basin_expedition.gd` and `game/basin_expedition.tscn`: extracted existing Basin,
    player, combat/projectile routing, HUD, return interaction, and death-retry ownership.
  - Add `game/mothership.gd` and `game/mothership.tscn`: Kestrel interior, collisions, player
    arrival, bridge display/deploy interaction, prompts, and closed station boundaries.
  - Modify `game/player.gd` and, only as needed, `game/player.tscn`: explicit per-location weapon
    enablement and camera limits without changing exterior movement/combat defaults.
  - Modify `game/stalker.gd`: focused capture/restore API that rebuilds valid processing,
    collision, velocity, and presentation from the concrete snapshot while retaining reset.
  - Modify `game/project.godot`: physical `E` `interact` action.
  - Update `game/tests/run_tests.gd`, `test_f01_first_expedition.gd`, and
    `test_f02_ranged_combat.gd` for the legitimate location boundary while preserving their
    behavioral assertions; add `game/tests/test_f03_mothership_transition.gd` for transition,
    input, lifecycle, and state contracts.
  - Add a focused capture driver such as `game/tests/capture_f03_views.gd` and retain useful
    960x540 captures under `game/tests/artifacts/` for agent inspection.
  - Update `game/tests/README.md`, `docs/CODE_GUIDE.md`, and, if the implemented boundary remains
    material after verification, `docs/ARCHITECTURE_EVOLUTION.md`; finish this plan and
    `PROGRESS.md` with actual evidence. `docs/CONTENT_CATALOG.md` needs no update unless an
    implementation decision genuinely changes a catalog entry.
- [x] Establish the passing F00-F02 baseline, then extract the current Basin as a focused
  location while preserving its combat, collision, and same-instance death retry.
- [x] Add the minimal in-memory `RunState` and Stalker capture/restore contract; validate restored
  state rather than trusting arbitrary snapshot values.
- [x] Build the compact Kestrel interior, its accessible functional areas, sealed later-station
  boundaries, player setup, labels, prompts, and contextual bridge deployment.
- [x] Add proximity-gated exterior shuttle return, guarded static transition feedback, clean
  location/player replacement, and transient pulse/weapon cleanup.
- [x] Extend scenarios to exercise real input routing, repeated normal visits, state preservation,
  death after a revisit, transition races, and the affected F00-F02 behaviors.
- [x] Run and inspect deterministic rendered captures of the mothership, bridge prompt, exterior
  shuttle return prompt, and redeployed Basin; fix clipping, illegible text, camera, collision,
  color-language, or runtime-log failures.
- [x] Review the final diff for ownership, lifecycle, scope, obsolete identity assumptions,
  accidental files, and warnings; update exact acceptance evidence, verification docs, code
  guide, material architecture decision, and progress ledger.

## Acceptance and evidence

| ID | Required observable outcome | Agent verification method and expected result | Actual evidence / status |
| --- | --- | --- | --- |
| A01 | A new session starts on one compact Kestrel interior with one controllable player; vehicle-bay arrival and bridge/navigation console are accessible and functional, while later stations are visibly labelled but physically closed rather than empty playable rooms. | Import, F03 scene assertions, actual player movement/collision, and inspected 960x540 mothership/bridge captures show the required composition, readable labels and prompts, distinct safe-home presentation, bounded camera, and no parser/runtime errors. | **Passed.** F03 traversed the real bay-to-bridge aisle, collided with the hull, found four hull boundaries plus the sealed-station boundary, and verified one holstered player. It also proves the deployed Camera2D becomes viewport-current and follows real Basin movement while keeping the player onscreen. Inspected captures show readable zoning, landing display and five sealed labels. |
| A02 | The bridge exposes only the valid `P1-BASIN-01` landing, and pressing physical `E` while in range performs one guarded static deployment to the Basin shuttle; input away from the console or repeated during transition does nothing. | F03 scenario drives the real `interact` action both outside and inside the Area2D, checks transition events/0.25-second configuration, location replacement, one player/current location, exact shuttle spawn, exterior camera/weapon configuration, and no duplicate swap. | **Passed.** F03 verified physical-E mapping/action polling, out-of-range rejection, prompt gating, exact 0.25-second guard, duplicate rejection, old-location freeing, one new player at the shuttle, Basin camera bounds and restored Surveyor. |
| A03 | Pressing physical `E` near the exterior shuttle returns to Kestrel; the same input away from the shuttle, during retry, or during an active transition cannot return or duplicate nodes. | F03 scenario exercises actual input/proximity and guarded failure cases, then verifies the exterior is freed, Kestrel is newly active at its vehicle-bay arrival, transient pulses are gone, and one player remains. Inspect the exterior return-prompt capture for placement and legibility. | **Passed.** The actual action near the shuttle returned through one guarded swap; retry/transition duplicates were rejected. New Kestrel arrival and one-player ownership passed. The inspected prompt is clear of the shuttle and legible. |
| A04 | A normal return/redeployment unloads and recreates the exterior while preserving the current Stalker encounter and pausing it aboard Kestrel. Damage, position, behavior phase/elapsed time, direction, and defeat persist; projectiles and player weapon recovery do not. | F03 scenario damages and repositions the Stalker, returns, waits aboard Kestrel, redeploys and compares snapshot/restored values and valid collision/presentation. It verifies new exterior/player/Stalker instance IDs, no elapsed encounter advance, zero live pulses, and clean player spawn. Repeat with a defeated Stalker and through at least three normal visit cycles. | **Passed.** F03 compared a damaged mid-commit snapshot with nonzero locked direction and a defeated snapshot across three normal cycles. Position, phase/time, hits, direction, collision/presentation and pause aboard Kestrel matched; all live instance IDs changed while pulse/recovery state cleared. |
| A05 | Death remains distinct from a normal visit: it never sends the player to Kestrel and resets the current loaded encounter once before restoring control at the shuttle within the existing 0.65-second contract. | Updated F01/F02 and F03 scenarios kill the player through real hazard and committed Stalker contact after a normal revisit. They verify the exterior/player/Stalker IDs remain unchanged during retry, full authored Stalker reset precedes control, pulses clear, duplicate retry/return fails, and movement/aim/fire resume. | **Passed.** After three revisits, real movement into the hazard and an actual committed Stalker hit each stayed in Basin, rejected return/duplicate retry and restored the same Basin/player/Stalker IDs at the shuttle after the configured 0.65 seconds with full encounter reset. |
| A06 | Existing Basin traversal, lethal hazard, Surveyor/Base-pulse combat, readable Stalker cycle, three-hit defeat, and repeated exact shuttle retries remain behaviorally intact after extraction. | Updated `run_tests.gd`, F01, and F02 scenarios deploy through the new root where integration matters and retain real physics/input, collision, timing, hit, defeat, cleanup, and retry assertions. All commands exit 0 with their explicit success summaries. | **Passed.** Final F00, F01 and F02 commands exited 0 with `F00 checks passed`, `F01/S02 checks passed` and `F02/S03 checks passed`; the full movement/collision/combat/retry contracts remain exercised after root deployment. |
| A07 | The changed presentation is actually rendered correctly in both locations and transitions communicate context without implying real-time flight or a shuttle interior. | Run a deterministic non-headless capture driver through actual location swaps; inspect retained `game/tests/artifacts/f03_mothership.png`, `f03_bridge_prompt.png`, `f03_shuttle_return.png`, and `f03_basin_redeployed.png` with the image viewer. Record dimensions and concrete visual observations; any clipping, blank capture, illegible prompt/label, camera exposure, or rendering error is a failure. | **Passed.** Non-headless Compatibility capture exited 0 and saved six 960x540 PNGs, including `f03_static_transfer.png` and `f03_basin_camera_follow.png`. Image-viewer inspection found clear home/exterior palettes, readable labels/prompts, unoccluded interactables, a centered player in the mid-route camera view, and an explicit static-transfer message with no flight/interior implication. Initial title/prompt overlap, an unsettled glyph frame and the reported inactive Basin camera were fixed and recaptured. |
| A08 | The integrated delivery imports and starts cleanly, has no known introduced parser/runtime errors, passes affected regressions, and its documentation matches actual ownership and evidence. | Run import/editor check, all F00-F03 scenario commands, a main-scene startup smoke, capture run/log review, `git diff --check`, and intended-file diff/status inspection. Expected: zero exits, named success summaries, no error lines, clean whitespace, and only scoped changes. | **Passed.** Import, F00-F03, two-frame startup and capture commands exited 0 with expected summaries/no parser or runtime errors. Final whitespace/status/scoped-diff review found only F03 implementation, evidence and documentation files. |

## Verification execution

- Run from repository root with
  `C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe` (confirmed
  `4.7.1.stable.official.a13da4feb`). Required commands:
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit`
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd`
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f01_first_expedition.gd`
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f02_ranged_combat.gd`
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f03_mothership_transition.gd`
  - `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2`
  - Run the F03 capture driver without `--headless` so the Compatibility renderer produces real
    viewport images; require all six 960x540 PNGs and a zero exit, then inspect each image.
  - `git diff --check`, `git status --short`, and scoped `git diff` review.
- Existing checks to reuse: F00 project/input/main loadability; F01 real movement, collision,
  lethal contact, duplicate-safe retry, delay, and repeatability; F02 real pulse impacts, Stalker
  timing/collision/defeat, transient cleanup, and retry ordering. Update exact node paths only
  where extraction legitimately changes structure, and retain same-instance assertions for a
  loaded death retry. Do not apply those assertions to a normal unload/reload.
- New persistent risk check: `test_f03_mothership_transition.gd` protects the first run/live-state
  boundary, actual contextual input, transition exclusivity, snapshot completeness, pause while
  unloaded, repeated revisits, retry distinction, and duplicate-node/signal regressions. These are
  durable lifecycle contracts likely to affect every later location and save feature.
- Runtime scenarios use real scenes, physics, collision Areas, and `Input.action_press/release`
  for changed interaction routing. Focused direct state setup may establish damaged/defeated
  snapshot fixtures, but direct method calls alone do not prove the interaction path.
- Rendered captures: the driver must wait for settled frames, place the player deterministically
  in prompt areas, use real transition APIs/input, save separate 960x540 images under
  `game/tests/artifacts/`, and exit with a success summary only after file and image-size checks.
  The agent will inspect them using the local image viewer and record what is actually visible.
- Save isolation and cleanup strategy: disk persistence is out of scope, so no user save path may
  be read or written. Capture outputs are limited to the named repository test-artifact directory;
  implementation may replace only its own prior F03 captures after resolving the exact paths.
- Missing verification capabilities: none for F03. D01 established the focused capture driver and
  retained inspectable nonblank rendered images. Later visual features may extend or replace it
  according to their own risk.

## Optional experiential limitations

The agent can establish compact travel distance, correct controls, visible hierarchy, readable
labels/prompts, and a calmer visual distinction from the Basin. Whether Kestrel feels comforting,
whether returning home is emotionally satisfying, and whether a first-time player naturally
understands the bridge/vehicle-bay relationship remain unassessed without human observation.
These are optional experiential limitations, not required user tasks or delivery gates.

## Completion and continuation record

- Deliveries completed / current status: D01 `Complete`; feature `Complete`.
- Actual changed files, responsibility and reason for change:
  - `game/main.gd`/`.tscn`: persistent location coordinator and guarded transfer overlay.
  - `game/run_state.gd`: typed application-memory Basin encounter snapshot.
  - `game/basin_expedition.gd`/`.tscn`: extracted Basin composition, combat, retry and return.
  - `game/mothership.gd`/`.tscn`: Kestrel shell, accessible bay/bridge, sealed stations and deploy.
  - `game/player.gd`, `game/stalker.gd`, `game/project.godot`: per-location player setup, validated
    encounter capture/restore and physical-E interaction.
  - F00-F03 tests, capture driver, six PNG artifacts and verification README: updated regression,
    lifecycle/input and rendered evidence. Godot-generated `.gd.uid` files retain script identity.
  - `docs/CODE_GUIDE.md`, `docs/ARCHITECTURE_EVOLUTION.md`, this plan and `PROGRESS.md`: current
    ownership, decision, evidence and handoff.
- Acceptance IDs and commands/scenarios/results, including error-log review: A01-A08 passed. The
  final import, F00, F01, F02, F03 and startup commands all exited 0; named scenario summaries were
  present and output contained no parser/runtime errors.
- Rendered observations and artifact links: the non-headless driver exited 0 using the Compatibility
  renderer and produced inspected 960x540
  [`f03_mothership.png`](../game/tests/artifacts/f03_mothership.png),
  [`f03_bridge_prompt.png`](../game/tests/artifacts/f03_bridge_prompt.png),
  [`f03_static_transfer.png`](../game/tests/artifacts/f03_static_transfer.png),
  [`f03_basin_camera_follow.png`](../game/tests/artifacts/f03_basin_camera_follow.png),
  [`f03_shuttle_return.png`](../game/tests/artifacts/f03_shuttle_return.png), and
  [`f03_basin_redeployed.png`](../game/tests/artifacts/f03_basin_redeployed.png). Concrete results
  are recorded under A07.
- Content decisions implemented and tuning deviations: Kestrel, `P1-BASIN-01`, physical `E`, the
  0.25-second transfer and planned room labels/palette were implemented. Prompt/title placement was
  tuned after rendered inspection; no scope or catalog decision changed, so the catalog stayed
  untouched.
- Code guide sections and architecture decision links: the code guide now maps both location flows,
  snapshot lifetime and retry distinction; architecture evolution records the application/location
  separation decision.
- Remaining defects, required verification gaps and optional limitations: none known for F03.
  Optional experiential limitations remain as listed above.
- If interrupted or split: not applicable; the single delivery completed without a split.
- Exact next action: `Generate the next plan` for F04 - Branching exploration and coordinates.

### Post-completion camera correction

On 2026-09-06 the user reported that the Basin camera did not follow the player. Initial
reproduction proved the deployed camera was not viewport-current after real movement. A first
immediate `make_current()` appeared to pass, but the user's fresh-run screenshot and a new
next-frame assertion exposed the actual ordering fault: the outgoing location camera's deferred
viewport cleanup cleared the incoming camera claim after the swap callback. The camera now claims
the viewport immediately, reasserts ownership after the tree settles, and resets smoothing at both
points so the first visible Basin frame is centered instead of catching up from the origin.
F03 permanently checks next-frame active-camera identity and centered shuttle spawn, drives the
player from X 600 past X 1000, requires the camera center to advance, and requires both transformed
screen axes to remain inside a 24-pixel safe margin. The updated scenario, import, F00-F02
regressions, startup, non-headless six-image capture and diff checks pass; the capture driver uses
real down/right movement and inspected `f03_basin_camera_follow.png` shows the player centered on
the mid-Basin route.
