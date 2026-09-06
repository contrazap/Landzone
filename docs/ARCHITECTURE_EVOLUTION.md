# Landzone - Architecture Evolution

Last updated: 2026-09-06

This is a learning record of material structural changes. It is not a speculative architecture
blueprint. Add an entry only when implementation pressure causes an actual refactor or establishes
an important boundary.

Use [CODE_GUIDE.md](CODE_GUIDE.md) for current ownership, file navigation and walkthroughs.
This log explains decisions; completed feature plans own detailed changes and acceptance output.
Add entries during delivery, not at a separate user checkpoint. F00-F02 plans preserve their
original rationale and step evidence. The 2026-09-06 workflow migration changes documentation,
not game architecture; it does not retrospectively invent a refactor or decision.

## Entry template

```markdown
## YYYY-MM-DD - F##/D## - Short decision

- Before: What concrete implementation existed?
- New pressure: Which verified requirement exposed a limitation?
- Change: What boundary or representation changed?
- Why now: Why is the abstraction justified at this point?
- Alternative rejected: What plausible option was not selected, and why?
- Behavior preserved: Which existing checks demonstrate unchanged behavior?
- New capability: What can the new structure support immediately?
- Remaining debt: What is deliberately still simple?
- Code guide and files: Current walkthrough and implementation links.
```

## Initial constraints, not implementations

The following repository-level constraints exist before F00 and do not imply specific classes:

- Process documentation remains outside `game/`.
- The game is 2D GDScript on Godot 4.7.1 with the Compatibility renderer unless changed by the user.
- Free-form journal prose is distinct from structured progression truth.
- Generated run data must become deterministic and testable before procedural progression ships.
- The mothership and shuttle are static; no architecture for real-time flight is needed.
- Direct play controls and paused deliberate commands are separate input modes.

Before F01, no gameplay code architecture had been established. F01's first concrete
player/Basin/local-retry ownership matches its approved plan and is recorded there; no
implementation-pressure refactor has yet warranted an evolution entry.

## 2026-09-06 - F03/D01 - Separate application lifetime from loaded locations

- Before: `main.tscn` permanently contained the authored Basin, player, Stalker, projectiles,
  retry timer and HUD. `main.gd` was both application root and the only visit controller; all
  encounter state survived only because those nodes were never unloaded.
- New pressure: F03 requires a static home location, real exterior unload/recreation, encounter
  continuity across normal visits, and a distinct same-instance death retry.
- Change: `LandzoneMain` is now a small persistent coordinator with one active-location container,
  guarded static transfer and in-memory `RunState`. The prior integration moved intact into
  `BasinExpedition`; `Mothership` owns Kestrel interaction. Stalker capture/validated restore is
  plain data and rebuilds live collision/presentation on a new instance. Per-location player
  configuration claims and snaps its Camera2D immediately and once deferred: the outgoing
  location camera unregisters after the swap callback and otherwise clears the incoming claim.
- Why now: Hiding or retaining the old Basin nodes could display a mothership but would not prove
  the required run-state versus scene-state boundary. Two actual locations now justify one
  application-level owner.
- Alternative rejected: Visibility/process toggles or reparenting were rejected because live
  exterior state would remain authoritative. A generic scene registry, autoload and disk save
  were also rejected because one route and one in-memory encounter do not justify those systems.
- Behavior preserved: Updated F00-F02 checks deploy through the new root and pass the existing
  movement, hazard, pulse, Stalker, defeat and same-instance retry contracts.
- New capability: Kestrel and Basin replace one another cleanly; normal revisit state survives
  unload while transients do not; death remains a local loaded reset.
- Remaining debt: Route validation names two concrete locations, `RunState` holds one Basin
  snapshot, and no application-restart persistence exists. F05 owns disk persistence; later
  location/encounter scale must demonstrate the need for further generalization.
- Code guide and files: [current ownership and flows](CODE_GUIDE.md),
  [main.gd](../game/main.gd), [run_state.gd](../game/run_state.gd),
  [mothership.gd](../game/mothership.gd), and
  [basin_expedition.gd](../game/basin_expedition.gd).

## 2026-09-06 - F04/D01 - Derive navigation text behind a pause-owning local console

- Before: The Basin was one horizontal corridor with camera and encounter validation bounds
  repeated at their consumers. Only direct movement/fire/interact input existed; no coordinate
  convention, command focus or paused-planning lifetime had been exercised.
- New pressure: F04 adds a physically branching surface, live shuttle-relative `where` output
  and a terminal that must keep accepting UI input while every ordinary gameplay owner stops.
  The new maintainability policy also requires new mixed responsibilities to enter clear domain
  folders rather than deepening the flat runtime root.
- Change: `BasinExpedition` now centralizes region, camera/encounter bounds and coordinate scale.
  It owns a node-free `CoordinateService` under `game/navigation/` and supplies live player data
  to a focused `CommandConsole` under `game/ui/`. The console explicitly owns a balanced global
  tree pause only while visible, processes input in `PROCESS_MODE_ALWAYS`, and refuses entry
  during retry or transfer. Stalker restore receives the active region's allowed bounds instead
  of embedding the superseded corridor range. Player aim retains a separate last-nonzero facing.
- Why now: Position formatting has a second consumer in F05 journal metadata, while pause/focus
  behavior is independently failure-prone and already spans player, combat, timers and location
  teardown. These two small boundaries isolate actual lifetimes without inventing later data.
- Alternative rejected: A global autoload, generalized command registry and manual per-node
  process toggles were rejected. F04 has one exterior-local command; SceneTree pause already gives
  the intended atomic freeze, and broad dispatch/save ownership belongs to later requirements.
  Moving every established F00-F03 runtime file was also deferred because the new `ui/` and
  `navigation/` folders solve the immediate organization pressure without a disruptive rename.
- Behavior preserved: F00-F03 scenarios continue to pass after expanding the world, updating the
  old wall fixture to the solid loop island and deriving the F03 camera limit from the Basin
  constant. Normal-revisit Stalker snapshots and same-instance loaded retries remain distinct.
- New capability: Six authored paths form three forks and one loop; `where` returns stable region,
  local axes and eight-way facing; the console freezes and resumes live gameplay without leaking
  pause state across retries or location replacement.
- Remaining debt: The topology is scene-authored rather than generated, the console is Basin-local
  and has only `where`, and coordinates are not saved. F05 owns journal/disk lifetime; F07 owns a
  deterministic plain-data path graph and may justify broader runtime directory reorganization.
- Code guide and files: [authored navigation and where](CODE_GUIDE.md#authored-navigation-and-where),
  [coordinate_service.gd](../game/navigation/coordinate_service.gd),
  [command_console.gd](../game/ui/command_console.gd),
  [basin_expedition.gd](../game/basin_expedition.gd), and
  [basin_surface.tscn](../game/basin_surface.tscn).

## 2026-09-06 - F05/D01 - Persist plain run models behind the application root

- Before: `RunState` held only one in-memory Stalker snapshot. `CoordinateService` produced a
  display string, and the Basin-local console directly recognized only `where`; closing the
  application discarded every fact.
- New pressure: Player-authored notes need structured creation metadata, monotonic identity,
  search/tag/append mutations and application-restart durability. Existing encounter state also
  becomes subject to the save/load contract once a disk representation exists.
- Change: Node-free `JournalEntry` and `FieldJournal` models now own journal validation, search and
  plain serialization. `CoordinateService` exposes a structured stamp used by both `where` and
  journal creation. `RunState` serializes the journal, authored-run seed and optional encounter;
  a focused `RunSaveStore` validates version-1 JSON and replaces the save through exact temporary
  and backup paths. `LandzoneMain` loads before Kestrel activation and remains the only save
  trigger owner. The console gained a bounded quoted tokenizer and explicit journal dispatch but
  still owns no durable data.
- Why now: Journal mutation is the first state created inside a replaceable location that must
  survive both death and process termination. Reusing formatted `where` text as storage would make
  search/save data depend on presentation, while serializing live nodes would violate the F03
  lifetime boundary.
- Alternative rejected: A global autoload, generic command registry, database/index service and
  multiple save slots were rejected. One persistent Main, fewer than six command verbs and a
  small bounded journal need none of them. Saving only journal entries was also rejected because
  it would silently drop the already-owned encounter snapshot from the new durable run contract.
- Behavior preserved: Headless F00-F04 scenarios pass with persistence disabled before each test
  Main enters the tree. The F04 pause/focus/`where` scenario passes unchanged after tokenizer and
  response-control growth.
- New capability: Notes retain exact coordinate/facing, seed and UTC creation time; text/tags are
  searchable; saves reject partial invalid data; separate writer/reader Godot processes restore
  journal IDs/data and the encounter before applying it on deployment.
- Remaining debt: Version 1 has one automatic slot and no migration chain, resume-location state,
  player-facing load/new-run controls or generated seed. The console remains Basin-local and uses
  explicit dispatch. Later features extend `RunState` and its validation only as new durable facts
  arrive.
- Code guide and files: [journal and save lifetime](CODE_GUIDE.md#journal-and-save-lifetime),
  [field_journal.gd](../game/journal/field_journal.gd),
  [journal_entry.gd](../game/journal/journal_entry.gd),
  [run_save_store.gd](../game/persistence/run_save_store.gd),
  [run_state.gd](../game/run_state.gd), [main.gd](../game/main.gd), and
  [command_console.gd](../game/ui/command_console.gd).

## 2026-09-06 - F06/D01 (in progress) - Separate command UI from knowledge interpretation

- Before: `CommandConsole` owned pause/focus presentation, tokenization and every `where`/journal
  branch. `RunState` had no evidence or confirmed-fact representation, and save version 1 knew
  only journal and encounter data.
- New pressure: F06 needs the same console UI in a second location with different available
  domains, while observed evidence, confirmed meanings and player prose must retain distinct
  authority and survive restart.
- Change: Node-free `CommandProcessor` now owns the existing tokenizer and explicit command
  branches; `CommandConsole` retains only Control/focus/response/pause behavior. Immutable custom
  Resources define three terms and evidence records, while `CodexState` owns validated per-run IDs
  and facts. Save version 2 serializes it and explicitly migrates valid version-1 data. Reusable
  `EvidenceSite` and `EvidenceReader` boundaries now drive the five authored Basin interactions.
- Why now: Two command contexts and a second durable prose-adjacent domain are concrete, current
  consumers. Keeping parsing in the Control or putting meanings in the journal would conflate
  unrelated lifetimes and authority.
- Alternative rejected: A global command registry/autoload and runtime prose interpretation remain
  unnecessary. Supported command domains are still explicit, catalog truth is authored, and Main
  remains the save owner.
- Behavior preserved: After extraction and live-site integration, F04 and F05 scenarios pass their
  exact command, pause, retry, transition and persistence contracts. The new focused F06 scenario
  passes catalog, migration, command, proximity, reader-pause and cairn-state checks.
- New capability: Evidence can be observed once and reviewed repeatedly; premature/counterexample
  patterns cannot create facts; the complete North pattern confirms the fixed meanings; version 1
  saves retain F05 data while gaining an empty codex.
- Completed on 2026-09-06: the walked full loop, cross-process F06 restart and rendered inspection
  passed. Inspecting the Research captures showed the shared console still presenting itself as the
  field console and advertising the unavailable `where`, so console wording became location-owned
  (`set_station_text`) and `CoordinateService` stamp formatting became static so journal retrieval
  renders its recorded coordinates anywhere.
- Remaining debt: the loop is one fixed authored solution with one decoy. Generated clue placement,
  partial-deduction feedback and any codex history or dedicated screen remain future work.
- Code guide and files: [current in-progress map](CODE_GUIDE.md),
  [command_processor.gd](../game/ui/command_processor.gd),
  [codex_state.gd](../game/knowledge/codex_state.gd),
  [knowledge_catalog.tres](../game/knowledge/knowledge_catalog.tres), and
  [evidence_reader.gd](../game/ui/evidence_reader.gd).
