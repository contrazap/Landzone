# Landzone - Code guide

Last checked against implementation: 2026-09-06 (F00-F03).

This guide explains the current game for later study. It is an implementation map, not a
blueprint of unbuilt systems. [PROGRESS.md](../PROGRESS.md) owns current delivery state;
[architecture evolution](ARCHITECTURE_EVOLUTION.md) and completed plans explain decisions/history.

## Start here

1. Read [project.godot](../game/project.godot) for the main scene, viewport, rendering and direct
   movement, firing and contextual `interact` inputs.
2. Open [main.tscn](../game/main.tscn) and [main.gd](../game/main.gd) together. This persistent
   root owns location replacement, the transfer guard/overlay and one in-memory `RunState`.
3. Read [mothership.gd](../game/mothership.gd) with
   [mothership.tscn](../game/mothership.tscn), then
   [basin_expedition.gd](../game/basin_expedition.gd) with
   [basin_expedition.tscn](../game/basin_expedition.tscn), to compare the two concrete location
   controllers.
4. Follow the normal revisit and lethal retry walkthroughs below. Their different object
   lifetimes are the important F03 boundary.
5. Read [player.gd](../game/player.gd), [stalker.gd](../game/stalker.gd), and
   [run_state.gd](../game/run_state.gd) for location configuration and snapshot rules.
6. Use [verification coverage](../game/tests/README.md) to find executable scenarios and retained
   rendered evidence.

The game starts aboard the static, interior-only survey vessel Kestrel. The bridge deploys to
the one valid landing `P1-BASIN-01`; the exterior shuttle returns to Kestrel. There is no flight,
shuttle interior, command overlay, disk save, inventory, procedural generator or boss yet.

## System and file map

| Responsibility | Implementation | State owned |
| --- | --- | --- |
| Application lifetime and location swapping | [main.gd](../game/main.gd), [main.tscn](../game/main.tscn) | Active location, transition guard/timer/overlay, pending destination and one `RunState` |
| In-memory run state | [run_state.gd](../game/run_state.gd) | Optional typed Basin/Stalker snapshot; no live nodes and no disk serialization |
| Kestrel location | [mothership.gd](../game/mothership.gd), [mothership.tscn](../game/mothership.tscn) | Current player, bridge proximity/prompt and local transition lock |
| Basin visit, combat routing and lethal retry | [basin_expedition.gd](../game/basin_expedition.gd), [basin_expedition.tscn](../game/basin_expedition.tscn) | Loaded player, Basin, Stalker, projectiles, retry state/UI and shuttle-return proximity |
| Authored route and markers | [basin_surface.tscn](../game/basin_surface.tscn) | Static shuttle, boundaries, safe passage, lethal Area2D and spawn positions |
| Movement, aim and firing eligibility | [player.gd](../game/player.gd), [player.tscn](../game/player.tscn) | Alive/dead state, velocity, aim, weapon recovery and per-location camera/weapon configuration |
| One projectile's movement and lifetime | [base_pulse.gd](../game/base_pulse.gd), [base_pulse.tscn](../game/base_pulse.tscn) | Direction, elapsed lifetime and expiration guard |
| One authored enemy encounter | [stalker.gd](../game/stalker.gd), [stalker.tscn](../game/stalker.tscn) | State/elapsed time, position, remaining hits, committed direction, collision/presentation and player reference |

There are no autoload services. Main connects only the current concrete location and rejects
requests from any other instance. Run state is application-memory only. Location nodes own live
physics and presentation and are freed during a normal transfer.

## Normal deployment and revisit

1. `Mothership` places one holstered player at `VehicleBayArrival`. Its bounded bridge Area2D
   shows `E - DEPLOY TO P1-BASIN-01`; the same action away from the console does nothing.
2. A valid request reaches `LandzoneMain`, which locks the current player, shows the static
   transfer overlay, rejects races, and waits the configured 0.25 seconds.
3. Main frees Kestrel, instantiates `BasinExpedition`, and configures its new player for Basin
   camera bounds, deferred-safe viewport-camera ownership and Surveyor use. The camera resets
   smoothing so the first Basin frame is centered rather than catching up from the origin. A
   first visit uses authored Stalker defaults; a later visit
   restores `RunState.basin_encounter`.
4. Near the shuttle, `E - RETURN TO KESTREL` requests the reverse transfer. Before the swap,
   `BasinExpedition` captures the Stalker's position, phase, elapsed phase time, hits and committed
   direction. It clears live pulses and player recovery because they are visit-transient.
5. Main frees the exterior and creates a new Kestrel. Time aboard does not mutate the plain-data
   snapshot. Redeployment creates new Basin/player/Stalker instances and applies the validated
   snapshot, including collision and presentation intent.

| State | Normal return/redeployment |
| --- | --- |
| Basin, player and Stalker nodes | Freed; new instances on redeployment |
| Stalker encounter | Position, phase/time, damage, direction and defeat preserved in `RunState` |
| Live pulses / player firing recovery | Cleared before leaving |
| Player placement | New location's arrival marker; Basin always starts at shuttle marker |
| Time aboard Kestrel | Does not advance the unloaded encounter |

## Death and loaded retry

Death deliberately does not use the location-transition path:

1. The Basin hazard or a committed Stalker attack calls `player.die()`.
2. `BasinExpedition` starts one guarded 0.65-second retry, clears pulses, hides the player and
   displays redeployment feedback. Shuttle return is blocked during retry.
3. At timeout it resets the same Stalker instance to its authored spawn/full three-hit state
   before respawning the same player instance at the shuttle marker.
4. Basin, player and Stalker identities remain unchanged. Movement, aim and firing return
   immediately. No normal-visit snapshot is captured and Kestrel is never entered.

This distinction is covered after repeated normal visits by
[the F03 scenario](../game/tests/test_f03_mothership_transition.gd). F01/F02 keep the original
movement, hazard, combat, timing, defeat and same-instance retry contracts after deploying
through the new application root.

## Aim, fire and encounter behavior

`BasinExplorer` emits shot requests; `BasinExpedition` creates `BasePulse` instances, routes
Stalker impacts and owns cleanup. The player cannot fire when its Surveyor is holstered aboard
Kestrel or while transition-locked. Basin defaults remain a 0.24-second recovery and bounded
pulse lifetime.

The Stalker still follows:

    CONCEALED -> TELEGRAPH -> COMMITTED -> RECOVERY -> CONCEALED
    Any active state -- third pulse hit --> DEFEATED
    Death retry -> authored CONCEALED/full-hit reset on the same instance

Normal revisits instead use `capture_encounter` and `restore_encounter`. Restore clamps state,
position, elapsed time and hit count; it normalizes a committed direction and rebuilds valid
trigger/attack collision plus matching presentation. Defaults remain a 235-unit trigger,
0.8-second tell, 0.55-second 430-unit/second commitment, 0.7-second recovery and three hits.

## Collision and presentation

Collision bits remain player 1, world 2, hazard 4, projectile 8, enemy 16 and enemy attack 32.
Kestrel's hull, navigation console and sealed station bulkhead also use world layer 2. The same
player scene remains movable in both locations.

Kestrel fits the 960x540 viewport and uses a bounded camera, cool steel/cyan zoning and warm aisle
lights. Vehicle bay and bridge are accessible; research, galley, medical, habitat and workshop
are labelled `SEALED` behind a physical boundary until their owning features. The Basin retains
its wider follow camera and dark-rock palette. Retained captures under
[tests/artifacts](../game/tests/artifacts/) show the home view, bridge prompt, static transfer,
shuttle return, mid-route Basin camera follow and redeployed Basin.

## Where changes belong

- Add another concrete location only when its owning feature requires one; extend Main's valid
  routes then rather than introducing a generic registry now.
- Add new application-lifetime facts to `RunState` only when they must outlive a location. Disk
  persistence belongs to F05 and must serialize data rather than live nodes.
- Keep Basin combat, pulse routing and death retry in `BasinExpedition` while it owns one concrete
  encounter. Generalize only when later encounter scale demonstrates pressure.
- Adjust per-location weapon/camera behavior through `configure_for_location`; preserve direct
  movement and death locks.
- Change Stalker snapshot fields together in `RunState`, capture and validated restore, then
  extend the normal-revisit scenario.

## Current limits and study history

Only one fixed landing is valid. Kestrel's later stations are sealed presentation boundaries,
not functional rooms. `RunState` is lost when the application closes. The exterior remains one
authored linear Basin with one Stalker. No reusable general location registry or save schema is
present.

For original choices and evidence, consult completed [F00](../plans/F00_project_foundation.md),
[F01](../plans/F01_first_expedition_and_lethal_retry.md),
[F02](../plans/F02_ranged_combat_and_first_enemy.md), and
[F03](../plans/F03_static_mothership_base.md). The
[archived ledger](archive/PROGRESS_2026-09-05.md) preserves early user observations.

## Maintaining this guide

Update affected sections during each delivery. Describe current responsibilities, links,
ownership, runtime flow, data lifetime and meaningful limitations. Keep detailed acceptance
output in the owning plan and significant tradeoffs in the architecture log. At F14 verify the
final map and reading order and trace the complete expedition/save/retry/new-run flows.
