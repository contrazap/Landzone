# Landzone - Code guide

Last checked against implementation: 2026-09-06 (F00-F02).

This guide explains the current game for later study. It is an implementation map, not a
blueprint of unbuilt systems. [PROGRESS.md](../PROGRESS.md) owns current delivery state;
[architecture evolution](ARCHITECTURE_EVOLUTION.md) and completed plans explain decisions/history.

## Start here

1. Read [project.godot](../game/project.godot) for the main scene, viewport, rendering and inputs.
2. Open [main.tscn](../game/main.tscn) and [main.gd](../game/main.gd) together to see composition
   and the owner that connects player, encounter, pulses and retry.
3. Read [player.gd](../game/player.gd) beside [player.tscn](../game/player.tscn) for direct controls
   and the boundary between requesting a shot and creating one.
4. Follow the combat/retry walkthroughs below into the pulse and Stalker files.
5. Read [verification coverage](../game/tests/README.md), then the related scenarios to see which
   outcomes are executable evidence and which presentation claims need rendered inspection.

The runnable game starts directly in the authored Basin. There is no mothership, command
overlay, saved run, inventory, procedural generator or boss yet.

## System and file map

| Responsibility | Implementation | State owned |
| --- | --- | --- |
| Composition, pulse creation/routing and shuttle retry | [main.gd](../game/main.gd), [main.tscn](../game/main.tscn) | Retry flag/timer, active pulse container, redeploy feedback and references to the one encounter |
| Authored route and markers | [basin_surface.tscn](../game/basin_surface.tscn) | Static shuttle, boundary geometry, safe passage, lethal Area2D, shuttle/Stalker spawn positions |
| Movement, aim and firing eligibility | [player.gd](../game/player.gd), [player.tscn](../game/player.tscn) | Alive/dead state, velocity, aim direction, weapon recovery timer and follow camera |
| One projectile's movement and lifetime | [base_pulse.gd](../game/base_pulse.gd), [base_pulse.tscn](../game/base_pulse.tscn) | Direction, elapsed lifetime and expiration guard |
| One authored enemy encounter | [stalker.gd](../game/stalker.gd), [stalker.tscn](../game/stalker.tscn) | State, elapsed time, remaining hits, locked attack direction, hitbox/presentation and player reference |

There are no autoload services. Main explicitly connects the concrete current entities.
Scene nodes hold session state; nothing is serialized to disk. Exported tuning stays beside
the behavior it controls. Generated .gd.uid files maintain script resource identity.

## Aim, fire and hit

1. BasinExplorer._process reads the world mouse position and held shoot action. Aim rotates
   the SurveyorWeapon child; zero-length aim is rejected.
2. try_shoot checks alive state, aim and the recovery timer (default 0.24 seconds). It starts
   recovery and emits shot_requested with the muzzle's global position and direction.
3. Main receives the event, instantiates BasePulse beneath Projectiles, connects impacted,
   and launches it. The player does not own live projectile creation or enemy routing.
4. BasePulse advances in physics frames, expires after its lifetime, and emits impacted on
   first body contact. Main routes contact with its specific Stalker to receive_pulse_hit.
5. The Stalker acknowledges hits and enters DEFEATED after three by default. The pulse disables
   further processing/monitoring and queues deletion on impact or expiration.

See [F02's scenario](../game/tests/test_f02_ranged_combat.gd) for recovery, travel, impact,
third-hit defeat and lifecycle evidence. Tests mix direct state calls with actual physics
interactions; their scope does not establish every possible input or rendered outcome.

## Enemy behavior

The Stalker owns an explicit enum and authored transitions:

    CONCEALED -> TELEGRAPH -> COMMITTED -> RECOVERY -> CONCEALED
    Any active state -- third pulse hit --> DEFEATED
    Retry -- reset_encounter --> CONCEALED

Proximity to a living player starts a tell. At commitment, the Stalker samples the target
direction once and moves along it; it does not continuously steer toward the player during
that attack. The lethal area is active only during commitment. Contact calls player.die();
successful lethal contact ends the attack into recovery. Presentation follows current state.

Defaults: 235-unit trigger range, 0.8-second tell, 0.55-second approach at 430 units/second,
and 0.7-second recovery. These are centralized exported values, not promised final balance.
Encounter reset restores the authored position, initial combat/presentation state and three-hit
requirement on the existing instance. It retains the current player reference.

## Death and shuttle retry

1. The Basin hazard contact handled by Main, or committed Stalker contact, calls player.die().
2. The player rejects repeated death, clears velocity and shot recovery, disables process and
   physics controls, sets is_alive false, and emits died.
3. Main starts one guarded retry, queues live pulses for deletion, hides the player, shows
   redeploy feedback and starts its default 0.65-second one-shot timer.
4. At timeout Main resets the Stalker before calling player.respawn_at at the shuttle marker.
5. The player restores position, clean velocity, alive state, recovery and processing. Main
   shows the player, hides feedback, clears its retry flag and emits retry_completed.

| Current state | Effect of retry |
| --- | --- |
| Player position and controls | Restored to shuttle marker; velocity/recovery cleared |
| Live pulses | Queued for deletion at retry start |
| Stalker | Same instance reset to authored initial state at retry completion |
| Basin and shuttle geometry | Same instances retained |
| Defeated encounter before death | Remains defeated until a retry; no current normal scene transitions |
| Durable progression/inventory | Not implemented |

The public request_retry coordinates a retry; actual lethal callers first pass through
player.die to disable controls. Read that calling contract before reusing the method.
[F01](../game/tests/test_f01_first_expedition.gd) exercises safe/lethal contact and three retries;
[F02](../game/tests/test_f02_ranged_combat.gd) also checks encounter reset ordering and combat
restoration. These scenarios currently assert exact node paths and instance identity.

## Collision and presentation

The scenes use explicit collision bits: player 1, world 2, environmental hazard 4, projectile 8,
enemy 16 and enemy attack 32. Inspect the scene masks as well as these layers when changing
contact behavior. Signals connect actual overlaps to script state changes.

Polygons and lines supply the Basin, player, weapon and enemy visuals. The player scene owns
the bounded follow camera; Main owns the HUD and redeploy feedback. The project uses a 960x540
viewport with canvas_items stretching and Compatibility rendering. No external art dependency
is needed to follow or run the current systems.

## Where changes belong

- Adjust movement/fire recovery in the player's exports; retain normalized movement and
  firing eligibility checks.
- Adjust the authored enemy's timing or tells in its exports and presentation/state methods;
  verify hitbox timing and actual contact alongside visual changes.
- Change the current route in basin_surface.tscn; keep collision, markers, camera bounds and
  existing scenario assumptions consistent with the intended behavior.
- New enemies or scene transitions may justify changing Main's concrete routing/ownership.
  Inspect actual pressure in that feature's plan before choosing a broader abstraction.

## Current limits and study history

Main refers directly to one Stalker and fixed scene paths; that is the current scale, not a
generic encounter architecture. Tests also couple to some of that structure. Scene transitions
in F03 will need a clear distinction between preserving revisits and resetting deaths.
Persistence and procedural plain-data ownership are future requirements, not existing services.
No reusable rendered-capture pipeline exists; headless visible flags do not establish legibility.

For original implementation choices and evidence, consult the completed
[F00](../plans/F00_project_foundation.md),
[F01](../plans/F01_first_expedition_and_lethal_retry.md), and
[F02](../plans/F02_ranged_combat_and_first_enemy.md) plans. The
[archived ledger](archive/PROGRESS_2026-09-05.md) preserves the original user observations.
This guide was reconstructed from those files and current code during the workflow migration;
it does not imply new gameplay work or a retrospective refactor.

## Maintaining this guide

Update affected sections during each delivery. Describe current responsibilities, links,
ownership, data lifetime, a representative flow and meaningful limitations. Keep detailed
acceptance output in the plan and significant tradeoffs in the architecture log. At F14 verify
the final map and reading order, consolidate obsolete descriptions, and trace the full
expedition/save/retry/new-run flows against the final code.
