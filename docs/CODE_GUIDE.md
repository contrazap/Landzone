# Landzone - Code guide

Last checked against implementation: 2026-09-06 (F06 in-progress model/live-site boundary).

This guide explains the current game for later study. It is an implementation map, not a
blueprint of unbuilt systems. [PROGRESS.md](../PROGRESS.md) owns current delivery state;
[architecture evolution](ARCHITECTURE_EVOLUTION.md) and completed plans explain decisions/history.

## Start here

1. Read [project.godot](../game/project.godot) for the main scene, viewport, rendering and direct
   movement, firing, contextual `interact` and command-console inputs.
2. Open [main.tscn](../game/main.tscn) and [main.gd](../game/main.gd) together. This persistent
   root owns location replacement, the transfer guard/overlay, one `RunState` and its save/load
   boundary.
3. Read [mothership.gd](../game/mothership.gd) with
   [mothership.tscn](../game/mothership.tscn), then
   [basin_expedition.gd](../game/basin_expedition.gd) with
   [basin_expedition.tscn](../game/basin_expedition.tscn), to compare the two concrete location
   controllers.
4. Follow the authored navigation and command walkthrough below into
   [CoordinateService](../game/navigation/coordinate_service.gd) and
   [CommandConsole](../game/ui/command_console.gd).
5. Read [FieldJournal](../game/journal/field_journal.gd),
   [JournalEntry](../game/journal/journal_entry.gd), [RunState](../game/run_state.gd) and
   [RunSaveStore](../game/persistence/run_save_store.gd) in that order for durable ownership.
6. Follow the normal revisit and lethal retry walkthroughs. Their different object lifetimes are
   the important F03 boundary, now preserved across the larger F04 route.
7. Read [player.gd](../game/player.gd) and [stalker.gd](../game/stalker.gd) for facing, location
   configuration and encounter snapshot rules.
8. Use [verification coverage](../game/tests/README.md) to find executable scenarios and retained
   rendered evidence.

The game starts aboard the static, interior-only survey vessel Kestrel. The bridge deploys to
the one valid landing `P1-BASIN-01`; the exterior shuttle returns to Kestrel. The Basin has one
authored branching network and a paused field console with `where` plus searchable journal
commands. Version-2 JSON persistence retains journal, codex, authored-run seed and the captured
Basin encounter, with explicit version-1 migration. F06's authored Basin evidence/cairn sites and
Kestrel Research console are integrated, but the complete knowledge loop is not yet delivered. There is
no flight, shuttle interior, inventory, procedural generator or boss yet.

## System and file map

| Responsibility | Implementation | State owned |
| --- | --- | --- |
| Application lifetime, location swapping and save trigger | [main.gd](../game/main.gd), [main.tscn](../game/main.tscn) | Active location, transition guard/timer/overlay, pending destination, load warning, save path and one `RunState` |
| Durable run state | [run_state.gd](../game/run_state.gd) | Stable authored-run seed, journal and optional typed Basin/Stalker snapshot; no live nodes |
| Versioned disk adapter | [run_save_store.gd](../game/persistence/run_save_store.gd) | Save path, version-1 JSON validation, temporary/backup replacement and last error |
| Journal model | [field_journal.gd](../game/journal/field_journal.gd), [journal_entry.gd](../game/journal/journal_entry.gd) | Monotonic IDs, prose, coordinate/seed/time metadata, tags, mutation validation, search and plain serialization |
| Authored knowledge and per-run codex | [knowledge_catalog.tres](../game/knowledge/knowledge_catalog.tres), [codex_state.gd](../game/knowledge/codex_state.gd) | Three stable terms/evidence records; observed IDs, confirmed meanings and destination remain separate from prose |
| Live knowledge sites and reader | [evidence_site.gd](../game/knowledge/evidence_site.gd), [evidence_reader.gd](../game/ui/evidence_reader.gd) | Proximity identity, correct/decoy interaction and balanced observation pause |
| Kestrel location | [mothership.gd](../game/mothership.gd), [mothership.tscn](../game/mothership.tscn) | Current player, bridge proximity/prompt and local transition lock |
| Basin visit, command context, combat routing and lethal retry | [basin_expedition.gd](../game/basin_expedition.gd), [basin_expedition.tscn](../game/basin_expedition.tscn) | Loaded player, coordinate-service configuration, command availability, Stalker, projectiles, retry state/UI and shuttle-return proximity |
| Authored route and markers | [basin_surface.tscn](../game/basin_surface.tscn) | Six named segments, three junctions, one loop, two survey limits, static shuttle, solid rock boundaries, lethal Area2D and encounter markers |
| Local coordinates and facing snapshots | [coordinate_service.gd](../game/navigation/coordinate_service.gd) | Configured region identifier, shuttle origin and local-unit scale; derives structured stamps and display text |
| Paused command presentation and processing | [command_console.gd](../game/ui/command_console.gd), [command_processor.gd](../game/ui/command_processor.gd), [command_console.tscn](../game/ui/command_console.tscn) | Console owns focus/response/pause; node-free processor owns quoted `where`/journal/codex dispatch |
| Movement, aim and firing eligibility | [player.gd](../game/player.gd), [player.tscn](../game/player.tscn) | Alive/dead state, velocity, current aim, last nonzero facing, weapon recovery and per-location camera/weapon configuration |
| One projectile's movement and lifetime | [base_pulse.gd](../game/base_pulse.gd), [base_pulse.tscn](../game/base_pulse.tscn) | Direction, elapsed lifetime and expiration guard |
| One authored enemy encounter | [stalker.gd](../game/stalker.gd), [stalker.tscn](../game/stalker.tscn) | State/elapsed time, position, remaining hits, committed direction, collision/presentation and player reference |

There are no autoload services. Main connects only the current concrete location and rejects
requests from any other instance. Location nodes own live physics and presentation and are freed
during a normal transfer; serializable `RunState` data outlives them and is written by Main.

## Authored navigation and commands

`basin_surface.tscn` expresses one fixed six-edge topology through named scene nodes:

```text
                         North Arc
                    /----------------\
SHUTTLE -- Landing Fork                 Reunion Fork -- East Approach -- Far Fork
                    \----------------/                              /          \
                         South Arc                         North Shelf      South Hollow
```

The North and South arcs form a physical loop around `LoopIsland`; the Far Fork's solid wedge
separates the two surveyed limits. Top/bottom rock masses and outer caps constrain travel. The
cyan Landing/Reunion markings, warm Far Fork/limit markings and labels are presentation; the
`route_segment`, `route_junction` and `route_endpoint` groups expose authored intent for focused
verification, not a generated graph model. F07 owns that replacement.

`BasinExpedition` configures one `CoordinateService` with region `P1-BASIN-01`, the live
`ShuttleSpawn` as origin and 80 pixels per local unit. The service is plain derived data:
world `-Y/+Y` becomes `N/S`, `+X/-X` becomes `E/W`, and the player's last nonzero visible aim is
quantized into eight equal compass sectors. It returns a structured region/north/east/facing
stamp and formats the same data, for example:

```text
REGION P1-BASIN-01 | LOCAL N04 E09 | FACING NE
```

Tab opens the Basin-local `CommandConsole`. Its always-processing Control takes LineEdit focus,
then pauses the scene tree. Exact case-insensitive `where` calls back to the expedition for the
live formatted result. A small quoted tokenizer dispatches the five F05 `journal` subcommands;
it deliberately is not a registry for later command domains. Arguments, blank input, broken
quotes, invalid identifiers and unknown verbs have specific bounded errors.
While the panel owns the pause, player/weapon, pulses, Stalker, hazard and timers remain paused.
Tab or Escape releases focus and the pause. Retry and transfer disable opening, and `_exit_tree`
is a final balance guard so a freed exterior cannot leave the application paused. The console
keeps presentation/input state only; its configured `FieldJournal` owns journal data.

## Journal and save lifetime

`JournalEntry` stores an ID, player prose, original coordinate/facing, run seed, UTC discovery
time and normalized tags. `FieldJournal` assigns never-reused ascending IDs, validates new prose
and tags, searches text/tags case-insensitively newest-first, and returns at most five matches.
Appending adds a prose line without changing discovery metadata. Neither model references nodes
or interprets prose as a progression fact.

The Basin console exposes:

```text
journal add "<text>"
journal find <query>
journal read <id>
journal tag <id> <tag> [tag...]
journal append <id> "<text>"
```

During F06, parsing moved without behavior changes into `CommandProcessor`; `CommandConsole` now
owns only Control/input/pause behavior. The processor also has bounded `codex search/evidence`,
currently configured as Research-only, so the Basin directs codex queries back to Kestrel.

Each location owns its console wording through `set_station_text`, because the same panel serves
the field and a ship station with different available commands: Kestrel Research titles itself
`KESTREL RESEARCH CODEX` and never advertises the surveyed-region `where`. Journal entries carry
their own recorded coordinate stamp, so `CoordinateService` formats stamps statically and retrieval
stays readable at Research, away from the region that produced the entry.

Successful mutations call Main's persistence callback immediately. A write failure is visible in
the response and leaves the in-memory mutation intact for a later retry. When the Basin is active,
Main first asks it to refresh the plain encounter snapshot so the same save represents both
journal and encounter state. `RunSaveStore` writes version-2 JSON through an exact `.tmp` path,
stages an existing file as `.bak`, installs the new file, then removes the backup. Loading accepts
version 2 and explicitly migrates version 1 by preserving F05 data and adding an empty codex. It
reconstructs new journal, codex and encounter objects only after every record validates. Missing
files start fresh. Malformed JSON,
unsupported versions or invalid records produce a Main load warning and a wholly fresh state;
partial data is never accepted.

Production uses `user://landzone_save.json`. Main loads it before creating Kestrel. Tests inject
isolated F05 paths or set `persistence_enabled = false` before adding Main to the tree, so older
regressions and rendered captures never touch player data. The current authored run uses stable
seed `51005`; F07 will consume a generated seed but must preserve this lifetime contract.

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
   direction. Main saves that snapshot alongside the journal, seed and next journal ID. The
   expedition clears live pulses and player recovery because they are visit-transient.
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
   displays redeployment feedback. Shuttle return and command opening are blocked during retry.
3. At timeout it resets the same Stalker instance to its authored spawn/full three-hit state
   before respawning the same player instance at the shuttle marker, then stores and saves that
   reset encounter snapshot.
4. Basin, player and Stalker identities remain unchanged. Movement, aim and firing return
   immediately. No normal-visit snapshot is captured and Kestrel is never entered. The journal
   remains in RunState and each prior journal mutation was already saved.

This distinction is covered after repeated normal visits by
[the F03 scenario](../game/tests/test_f03_mothership_transition.gd). F01/F02 keep the original
movement, hazard, combat, timing, defeat and same-instance retry contracts after deploying
through the new application root.

## Aim, fire and encounter behavior

`BasinExplorer` emits shot requests; `BasinExpedition` creates `BasePulse` instances, routes
Stalker impacts and owns cleanup. The player cannot fire when its Surveyor is holstered aboard
Kestrel or while transition-locked. Basin defaults remain a 0.24-second recovery and bounded
pulse lifetime. `aim_direction` may become zero when the mouse exactly overlaps the player;
`facing_direction` deliberately retains the last nonzero visible aim for navigation output.

The Stalker still follows:

    CONCEALED -> TELEGRAPH -> COMMITTED -> RECOVERY -> CONCEALED
    Any active state -- third pulse hit --> DEFEATED
    Death retry -> authored CONCEALED/full-hit reset on the same instance

Normal revisits instead use `capture_encounter` and `restore_encounter`. Restore clamps state,
position to the caller-provided Basin bounds, elapsed time and hit count; it normalizes a committed direction and rebuilds valid
trigger/attack collision plus matching presentation. Defaults remain a 235-unit trigger,
0.8-second tell, 0.55-second 430-unit/second commitment, 0.7-second recovery and three hits.

## Collision and presentation

Collision bits remain player 1, world 2, hazard 4, projectile 8, enemy 16 and enemy attack 32.
Kestrel's hull, navigation console and sealed station bulkhead also use world layer 2. The same
player scene remains movable in both locations.

Kestrel fits the 960x540 viewport and uses a bounded camera, cool steel/cyan zoning and warm aisle
lights. Vehicle bay and bridge are accessible; research, galley, medical, habitat and workshop
are labelled `SEALED` behind a physical boundary until their owning features. The Basin retains
its wider follow camera and dark-rock palette. F04 adds cyan/warm junction language, solid dark
route separators and orange surveyed limits. F05 expands the console panel and uses a wrapped
multi-line response for add/search/read output. Retained captures under
[tests/artifacts](../game/tests/artifacts/) show the F03 location/transfer states, F04 navigation,
and F05's coordinate-stamped add, full five-match search and metadata-rich read views.

## Where changes belong

- Add another concrete location only when its owning feature requires one; extend Main's valid
  routes then rather than introducing a generic registry now.
- Add new application-lifetime facts to `RunState` only when they must outlive a location. Extend
  both its plain serialization and save validation when a later feature adds durable state.
- Keep Basin combat, pulse routing and death retry in `BasinExpedition` while it owns one concrete
  encounter. Generalize only when later encounter scale demonstrates pressure.
- Keep coordinate conversion in the node-free service under `game/navigation/`; callers supply
  live origin/position/facing and decide whether the result is UI, journal metadata or a test.
- Extend the focused console under `game/ui/` only with commands owned by the current feature.
  Keep domain facts in their model rather than turning explicit console dispatch into a
  speculative global registry.
- Keep free-form journal prose in `FieldJournal`. F06 codex evidence and confirmed meanings are
  authoritative facts and must use separate durable data even when commands present both.
- Adjust per-location weapon/camera behavior through `configure_for_location`; preserve direct
  movement and death locks.
- Change Stalker snapshot fields together in `RunState`, capture and validated restore, then
  extend the normal-revisit scenario.

## Current limits and study history

Only one fixed landing is valid. Kestrel's later stations are sealed presentation boundaries,
not functional rooms. The exterior remains one authored six-segment Basin with one hazard and one
Stalker; seed `51005` is durable metadata but does not generate content yet. The journal console is
Basin-local, has no command history and supports one bounded result page rather than a separate
journal screen. Saves have one automatic slot and version only; no player-facing load/new-run UI,
migration chain or reusable general location registry exists.

F06 is complete: the Basin carries Compass Array, Resonance Calibration, Route Slab, the North
Shelf Survey Cairn and the South Hollow decoy, and Kestrel Research answers codex and journal
queries. The knowledge loop has one fixed authored solution and one decoy; it does not generate
clues, rank partial deductions, or offer codex history, hints or a dedicated codex screen. Codex
queries are Research-only and return at most five bounded results.

For original choices and evidence, consult completed [F00](../plans/F00_project_foundation.md),
[F01](../plans/F01_first_expedition_and_lethal_retry.md),
[F02](../plans/F02_ranged_combat_and_first_enemy.md), and
[F03](../plans/F03_static_mothership_base.md), and
[F04](../plans/F04_branching_exploration_and_coordinates.md), and
[F05](../plans/F05_searchable_journal_and_basic_persistence.md). The
[archived ledger](archive/PROGRESS_2026-09-05.md) preserves early user observations.

## Maintaining this guide

Update affected sections during each delivery. Describe current responsibilities, links,
ownership, runtime flow, data lifetime and meaningful limitations. Keep detailed acceptance
output in the owning plan and significant tradeoffs in the architecture log. At F14 verify the
final map and reading order and trace the complete expedition/save/retry/new-run flows.
