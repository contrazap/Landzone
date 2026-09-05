# Landzone - Incremental Roadmap

Last updated: 2026-09-05

This roadmap describes player-visible increments and the architectural pressure each may reveal.
It does not prescribe final internals. Generate one detailed feature plan only when that feature
is next and after inspecting the actual project.

Every feature must leave a playable, demonstrable increment. Later features may generalize an
earlier concrete implementation, but they must preserve already verified behavior unless the
design explicitly changes it.

| ID | Feature | Player-visible increment | Expected learning/refactoring pressure |
| --- | --- | --- | --- |
| F00 | Project foundation | A minimal project launches and displays a labelled placeholder scene. | Establish folders, renderer, input baseline, tests, headless verification, and environment evidence. |
| F01 | First expedition and lethal retry | Walk through one authored exterior path from a static shuttle; touch a lethal hazard and respawn quickly at the shuttle. | Player lifecycle, scene ownership, collision layers, retry speed, and checkpoint baseline. |
| F02 | Ranged combat and first enemy | Aim and fire the base weapon; defeat one readable enemy while any enemy attack remains lethal. | Projectile ownership, attack state, telegraphs, hit events, encounter reset, and fairness instrumentation. |
| F03 | Static mothership base | Return through the shuttle to a compact mothership and redeploy without losing exterior state. | Scene transitions, run state versus scene state, persistence across unload/reload, and functional room boundaries. |
| F04 | Branching exploration and coordinates | Explore an authored three-way fork and use `where` to read region, local coordinate, and facing. | Direction conventions, coordinate service, command overlay, pause processing, and route readability. |
| F05 | Searchable journal and basic persistence | Add coordinate-stamped notes, search/read/tag them, die, restart the application, and retain them. | Structured journal entries, parser growth, save format/version, indexing, and separation from codex truth. |
| F06 | Codex and first knowledge loop | Observe two forms of authored evidence, record and retrieve a note, interpret a small fixed vocabulary through the codex, and reach an existing exterior landmark using the inferred local destination. | Evidence versus interpretation data, clue readability, durable confirmed facts, and whether knowledge changes a player's decisions. |
| F07 | Seeded path-network generation | Replace the authored route with a deterministic compact graph; preserve the fixed clue solution, introduce the second surface presentation and second ordinary enemy in fair authored modules. | Plain generated data versus live nodes, RNG stream separation, graph validation, generation diagnostics, and regression fixtures. |
| F08 | Precision teleport and traversal hazards | Train safely, then enter a measured blink command to cross a lethal field obstacle. | Ability boundary, spatial validation, input history, death consistency, and testable geometry queries. |
| F09 | First location, checkpoint, and artifact | Reach the principal cave/structure, activate its entrance checkpoint, use fixed clues to unlock an artifact with an environmental/traversal effect and a weapon verb, and encounter the third ordinary enemy. | Multiple checkpoint sources, site lifecycle, progression state, and pressure to generalize a second weapon/traversal ability. |
| F10 | Hunting, inventory, and expedition status | Hunt one creature at an optional resource site, carry resources, meet the elite variation, experience bounded statuses, recover a death cache, and return home for basic recovery. | Item data, inventory ownership, timed status effects, finite resource identity, checkpoint retreat, and UI observability. |
| F11 | Mothership cooking, rest, and treatment | Prepare one food chain, sleep, diagnose and treat the initial condition through functional stations, and bank resources; preserve the basic recovery fallback. | Command registration, station interactions, recipes, time advancement, storage, and reusable procedures. |
| F12 | Procedural mystery and progression validation | Select the run's solution before layout, distribute reachable evidence, derive a valid boss landing coordinate, and validate structural solvability plus human understanding. | Progression graph, clue compiler, multi-seed invariant tests, bounded regeneration, and diagnostic tooling. |
| F13 | Boss expedition and completion | Land beside a boss gate, use accumulated knowledge and abilities, defeat an authored boss, and complete the expedition. | Multi-state boss behavior, checkpoint runback, terminal-state coordination, complete-loop balance, and presentation polish. |
| F14 | Replayability, hardening, and release | Start a new seed, observe meaningful rearrangement, resume a saved run, and export a stable playable build. | Save compatibility, generation variety metrics, profiling, regression suite, accessibility options, and release workflow. |

## Review revision and dependency boundaries

The 2026-09-05 review moved the former F11 fixed clue feature to F06, ahead of procedural
generation and survival. Former F06-F10 became F07-F11; F00-F05 and F12-F14 retained their IDs.
No feature plans or game code existed at this revision.

- F06 depends only on the authored exterior, coordinates, command overlay, journal, and save
  support from F00-F05. Its destination is a local landmark, not an artifact gate or boss region.
  It introduces only the codex operations needed for that inference. Exact clue content must
  be approved before its plan is generated.
- F06 completion requires a player unfamiliar with the solution to connect the evidence,
  retrieve a useful note, and explain how they chose the destination without developer hints.
  Record confusion and revisions. This manual check is required before F07 planning; reachable
  clues and passing parser tests alone do not establish that the knowledge loop works.
- F07 generates against F06's fixed progression requirements and preserves their evidence and
  destination relationships. F09 extends that fixed chain to the artifact. F12 later varies
  the solution and supplies it to layout generation first; it does not place required evidence
  after accepting an arbitrary layout. Each intervening feature validates the requirements it
  introduces, including F08 traversal, F09 artifact access, and F10 survival resources.
- F10 introduces basic recovery before activating status penalties. F11 expands the procedures
  without removing the resource-independent fallback. Neither feature may rely on death as
  treatment or on a future feature to make the current build recoverable.
- From F05 onward, each feature extends save/load checks for its new durable state. F14 hardens
  the accumulated behavior; basic persistence must not wait until release.

## First-slice ownership

These are delivery obligations, not approval of the catalog's proposed names or exact tuning.
Owning plans must turn them into specific acceptance criteria; F13/F14 integrate and verify
already delivered content rather than absorbing unassigned requirements.

| Slice requirement | Delivery owner and integration |
| --- | --- |
| Mothership, shuttle, and on-foot deployment | F01 shuttle/exterior; F03 mothership and return/redeployment; F11 functional preparation stations. |
| Three meaningful forks, at least one loop, four to seven path segments | F04 authored navigation baseline; F07 complete generated topology and route-choice checks. |
| Two surface presentations and one cave/structure presentation | F01 first surface; F07 second surface; F09 principal site interior. |
| Optional resource site, clue landmark, principal site | F06 clue landmark; F07 reserves reachable optional and principal nodes; F09 principal site; F10 resource-site gameplay. |
| Three ordinary enemies | F02 first role (candidate Stalker); F07 second (Spitter); F09 third (Bulwark), with fair modules and focused behavior checks at introduction. |
| One elite variation and one authored boss | F10 elite (candidate Scavenger) with recoverable sample ownership; F13 boss (Site Guardian), gate, and nearby landing/checkpoint. |
| Lethal hazard, precision blink, and safe training | F01 lethal retry baseline; F08 measured traversal, scale cues, tolerance, history, and mothership training. |
| One artifact with environmental/traversal access and a weapon verb | F09 both effects and fixed clue unlock; F12 integrates generated dependencies; F13 exercises learned abilities. |
| Hunting, one food chain, hunger, fatigue, and one treatable condition | F10 creature, inventory, statuses, drops, and basic recovery; F11 food preparation, full rest/treatment procedures, and storage. |
| Journal, vocabulary, codex, and generated clue chain | F05 journal; F06 approved vocabulary and fixed inference; F09 artifact integration; F12 variable solution and evidence validation. |
| Boss landing coordinate and expedition completion | F12 derives and registers the coordinate; F13 makes that destination playable and completes the expedition. |
| Stable world, death persistence, application resume, and new run | F01/F02 retry rules; F03 scene transitions; F05 save baseline; F06-F13 extend persistence as state arrives; F14 player-facing new run, isolation between seeds, and release checks. |

## Playtest and pacing gates

- F02 measures death-to-control time, runback time, and whether the player can identify a lethal
  attack's tell. F08 repeats this for failed traversal, including command re-entry effort.
- F06 records inference attempts and note retrieval, including where the player needed help.
  F12 repeats this with unfamiliar solutions across multiple seeds; automated graph checks
  establish structural validity, while manual checks assess evidence and comprehension.
- F10/F11 verify recovery after repeated deaths and resource depletion, and record time spent
  preparing versus exploring. Hunting and cooking should give a visible preparation benefit
  over emergency recovery without making depleted resources a permanent progression blocker.
- F13/F14 measure successful play, retries, travel, preparation, and command entry separately.
  The provisional 60-120 minute duration is not a minimum. Adjust pacing from observations;
  do not extend travel, repetition, or waiting to meet it. Product-scope changes still require
  user approval.

## Dependency rule

Features normally proceed in order. If a later feature appears desirable early, record the idea
without implementing it. Reordering requires explicit user approval and an updated roadmap and
progress ledger.

## Refactoring rule

The roadmap's final column names likely pressure, not permission to prebuild an abstraction.
Feature plans must inspect actual evidence and state whether a refactor is now justified. When a
refactor is material, prefer a behavior-preserving step and commit before adding new behavior.

## Expansion gate

Do not add planets two and three, fishing, orbital structures, anomaly bosses, real-time ship
systems, or a large content roster to F00-F14. After F14, use player evidence to decide whether
to expand the game, deepen the first planet, or finish it at the completed-slice scope.
