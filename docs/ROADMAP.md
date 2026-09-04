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
| F06 | Seeded path-network generation | Replace the authored route with a deterministic compact graph assembled from authored modules. | Plain generated data versus live nodes, RNG stream separation, graph validation, generation diagnostics, and regression fixtures. |
| F07 | Precision teleport and traversal hazards | Train safely, then enter a measured blink command to cross a lethal field obstacle. | Ability boundary, spatial validation, input history, death consistency, and testable geometry queries. |
| F08 | First location, checkpoint, and artifact | Reach a fixed cave/structure, activate its entrance checkpoint, complete it, and unlock one artifact ability. | Multiple checkpoint sources, site lifecycle, progression state, and pressure to generalize a second weapon/traversal ability. |
| F09 | Hunting, inventory, and expedition status | Hunt one creature, carry resources, and experience readable hunger, fatigue, and one physical condition. | Item data, inventory ownership, timed status effects, drops on death, and UI observability. |
| F10 | Mothership cooking, rest, and treatment | Return home to cook one food chain, sleep, diagnose, and treat the initial condition. | Command registration, station interactions, recipes, time advancement, storage, and reusable procedures. |
| F11 | Codex and fixed clue chain | Discover authored evidence, search the codex, derive a fixed artifact/boss code, and receive a landing coordinate. | Evidence versus interpretation data, dependency graph shape, clue presentation, and anti-brute-force feedback. |
| F12 | Procedural mystery and progression validation | Generate the known solution first, distribute reachable evidence, and prove the run is solvable before play. | Progression graph, clue compiler, multi-seed invariant tests, bounded regeneration, and diagnostic tooling. |
| F13 | Boss expedition and completion | Land beside a boss gate, use accumulated knowledge and abilities, defeat an authored boss, and complete the expedition. | Multi-state boss behavior, checkpoint runback, terminal-state coordination, complete-loop balance, and presentation polish. |
| F14 | Replayability, hardening, and release | Start a new seed, observe meaningful rearrangement, resume a saved run, and export a stable playable build. | Save compatibility, generation variety metrics, profiling, regression suite, accessibility options, and release workflow. |

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
