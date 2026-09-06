# Landzone - Progress Ledger

Last documentation update: 2026-09-06

## Current state

- Overall status: F00-F06 complete; F07 not started.
- Last completed feature: F06 - Codex and first knowledge loop.
- Last completed project milestone: First complete evidence-to-codex-to-destination knowledge loop
  with durable confirmed facts.
- Current feature: None active. F07 - Seeded path-network generation is next and has no plan.
- Current delivery: None active.
- Exact next action: Generate the F07 plan on request; do not implement before it exists.
- Blockers / required verification gaps: None for completed work.
- Pending user decisions: None. Future content selections belong in their consuming plans;
  requesting implementation authorizes those selections within the approved game scope.
- Experiential limitations: F00-F02 user observations remain valid historical evidence.
  Future first-time comprehension, enjoyment, and subjective pacing are not human acceptance
  gates and must not be claimed as verified without actual observations.

## Roadmap status

Feature statuses: `Not started`, `Planned`, `In progress`, `Blocked`, `Complete`.

| ID | Feature | Status | Evidence / plan |
| --- | --- | --- | --- |
| F00 | Project foundation | Complete | [Plan](plans/F00_project_foundation.md): runnable shell, input baseline, automated checks and user presentation confirmation. |
| F01 | First expedition and lethal retry | Complete | [Plan](plans/F01_first_expedition_and_lethal_retry.md): authored Basin, movement/collision, lethal hazard, repeated exact shuttle retry; automated and user observations passed. |
| F02 | Ranged combat and first enemy | Complete | [Plan](plans/F02_ranged_combat_and_first_enemy.md): aim/fire, bounded pulses, authored Stalker, encounter reset; automated and user observations passed. |
| F03 | Static mothership base | Complete | [Plan](plans/F03_static_mothership_base.md): Kestrel, transitions, revisit/retry lifecycles and deferred-safe active-camera ownership pass behavioral and rendered verification. |
| F04 | Branching exploration and coordinates | Complete | [Plan](plans/F04_branching_exploration_and_coordinates.md): six traversable segments, three forks, one loop, local coordinates and pause-safe `where` passed behavioral/rendered verification. |
| F05 | Searchable journal and basic persistence | Complete | [Plan](plans/F05_searchable_journal_and_basic_persistence.md): coordinate-stamped journal commands, versioned save and true restart verification passed. |
| F06 | Codex and first knowledge loop | Complete | [Plan](plans/F06_codex_and_first_knowledge_loop.md): walked three-term evidence chain, Kestrel Research codex, correct/decoy Survey Cairns and version-2 durability passed behavioral, restart and rendered verification. |
| F07 | Seeded path-network generation | Not started | No plan generated. |
| F08 | Precision teleport and traversal hazards | Not started | No plan generated. |
| F09 | First location, checkpoint, and artifact | Not started | No plan generated. |
| F10 | Hunting, inventory, and expedition status | Not started | No plan generated. |
| F11 | Mothership cooking, rest, and treatment | Not started | No plan generated. |
| F12 | Procedural mystery and progression validation | Not started | No plan generated. |
| F13 | Boss expedition and completion | Not started | No plan generated. |
| F14 | Replayability, hardening, and release | Not started | No plan generated. |

## Verification and environment

Confirmed console: `C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe`.
Build: `4.7.1.stable.official.a13da4feb`; Godot project: `game/`; main scene:
`res://main.tscn`; renderer: Compatibility. GUI executable recorded by F00:
`C:\MyFiles\Godot\Godot_v4.7.1-stable_win64.exe`.

[Verification instructions](game/tests/README.md) own exact commands and coverage.
F06's final import, the F00-F06 scenarios, both the F05 and F06 writer/reader restart phases and
the two-frame startup smoke all exited 0 with expected summaries and no unexpected parser/runtime
errors. The non-headless F06 capture driver exited 0 and produced eight 960x540 Compatibility
images covering the three evidence readers, the South mismatch, the North confirmation and the
three Research responses; all were inspected. Both isolated test directories are empty after the
runs and the default player save is untouched. `git diff --check` passed.

## Latest handoff

On 2026-09-06 F03/D01 completed. The game now starts aboard Kestrel with an accessible vehicle
bay and bridge, five visibly sealed future stations, one valid `P1-BASIN-01` display, physical
`E` interactions and guarded 0.25-second static transfers. `LandzoneMain` persists coordination
and `RunState`; Kestrel and `BasinExpedition` are replaced locations. Normal returns preserve a
validated Stalker snapshot across unload/recreation while clearing pulses/recovery; repeated
hazard and committed-attack deaths after revisiting still reset the same loaded encounter at the
shuttle in 0.65 seconds. F00-F03 regressions, import, startup, capture and final diff checks passed.
Six retained images were inspected after fixing title/prompt overlap and capture settling; no
required F03 gap remains. After two user camera screenshots, a next-frame check isolated the
outgoing Camera2D's deferred cleanup clearing the incoming claim. The player now claims and snaps
its camera immediately and again after the scene tree settles; next-frame centered-spawn,
two-axis safe-margin movement assertions and inspected shuttle/mid-route captures cover it. The
content catalog did not require a state change. F03 was committed and pushed to `origin/main`
as `0e81d2e` under the standing delivery Git rule.

On 2026-09-06 the [F04 plan](plans/F04_branching_exploration_and_coordinates.md) was generated
from the clean F03 boundary. It selects six authored path segments, three degree-three junctions,
one north/south loop, two surveyed limits, an 80-pixel shuttle-relative local grid, eight-way
aim-facing, and a physical-Tab paused console with the bounded `where` command. Import and F03
baseline checks passed before planning. No gameplay was changed and no catalog candidate changed
state. F04/D01 then moved In progress under the standing roadmap implementation authorization;
its completion includes F00-F04 regression, rendered route/console inspection and documentation.

On 2026-09-06 the engineering policy was clarified for the project's later study and maintenance:
idiomatic Godot organization and established maintainable practices are defaults even before a
separate feature creates acute refactoring pressure. Material abstractions still require evidence,
while safe directory organization must occur before the runtime tree becomes difficult to navigate.
No gameplay, feature scope, delivery status or next action changed.

F04/D01 then completed on 2026-09-06. The authored Basin is now a 2400 by 1080 bounded network
of six path segments: Landing Fork splits into north/south arcs around a solid island, Reunion
Fork reconnects the loop, and Far Fork leads to North Shelf and South Hollow survey limits.
Physical Tab opens an always-processing console that owns a balanced SceneTree pause; exact
case-insensitive `where` reports region `P1-BASIN-01`, 80-pixel shuttle-relative N/S and E/W axes,
and the player's last nonzero eight-way aim-facing. Empty, extra-argument and unknown commands
give bounded feedback. Retry/transfer disable console entry, teardown cannot leak pause, and
Stalker revisit validation now receives the expanded Basin bounds.

The F04 scenario drove real physics through both complete loop arcs and final branches, checked
solid separators/caps, coordinate sectors/rounding, parsed Tab/text/Enter/Escape, a 0.3-second
gameplay freeze, resumption, retry/transfer rejection and an outside-old-clamp Stalker revisit.
Final import, F00-F04, startup and capture commands all exited 0. Six final images were inspected;
endpoint-sign clipping and junction-caption/HUD overlap found in initial captures were fixed and
recaptured. New UI/navigation files follow the clarified domain-folder policy. No catalog entry
changed state and no required gap remains. A later F05 starting-state audit established that local
`HEAD` and `origin/main` remain at the F03 commit `0e81d2e`; F04 is complete in the worktree but
was not committed or pushed. Generate only the F05 plan next.

On 2026-09-06 the [F05 plan](plans/F05_searchable_journal_and_basic_persistence.md) was generated
from the completed F04 worktree. It selects monotonic journal IDs, quoted add/append prose,
case-insensitive text/tag search, normalized bounded tags, structured coordinate/seed/UTC metadata,
immediate versioned JSON saves and safe invalid-save fallback. F05 remains a single delivery and
adds a two-process isolated-save scenario so application restart is verified rather than inferred
from an in-process reload. Headless import and the complete F00-F04 baseline passed before
planning. No gameplay or catalog state changed. Implement only F05/D01 next.

F05/D01 moved In progress under the continuing implementation request. The previously recorded
F00-F04 baseline is current; implementation begins with the structured journal model, coordinate
snapshot and versioned save boundary before console/scene integration.

F05/D01 completed on 2026-09-06. The Basin field console now supports quoted `journal add` and
`append`, case-insensitive `find`, metadata-rich `read`, and normalized bounded `tag`. Entries use
monotonic IDs and preserve region/local/facing, authored seed `51005`, UTC discovery time, prose
and tags; journal text remains separate from authoritative progression facts. Main loads and saves
version-1 JSON at an injectable path, rejects partial/invalid data to a fresh state with a
diagnostic, and persists the journal plus the current Stalker snapshot. Retry completion saves the
authored encounter reset so stale pre-death state cannot return after restart.

The integrated F05 scenario passed exact command, invalid-input, five-result ordering, failed-save
retention, death, transition, missing/corrupt/version-invalid save and no-alias checks. Separate
writer and reader Godot processes restored the exact journal, next ID, seed and encounter, applied
the encounter on deployment, and continued at entry #2 using only the isolated test save; cleanup
left no test or default player save. Import, F00-F05, startup, capture and final diff checks passed.
Three final journal captures were inspected after fixing initial scroll/clipping; all bounded
results and appended prose are legible. Catalog journal commands are Implemented, documentation is
current, no required gap remains, and no commit/push was performed. Generate only the F06 plan next.

On 2026-09-06 the [F06 plan](plans/F06_codex_and_first_knowledge_loop.md) was generated from the
verified F05 boundary. It fixes `ACHVNTSAT=NORTH`, `VEL=THREE` and `ORUUN=SILENT STONE`; Compass
Array, Resonance Calibration and Route Slab evidence support the directive. The correct three
silent-stone Survey Cairn is at North Shelf `N04 E23`; a South Hollow `S04 E23` two-resonant-stone
decoy and premature target attempt provide grounded invalid answers. F06 activates Kestrel
Research for journal retrieval and `codex search/evidence`, separates observed records from
confirmed facts, and plans version-2 saves with explicit F05 migration. Import plus current F04
and F05 scenarios passed before planning. No gameplay/catalog state changed. Implement only
F06/D01 next.

F06/D01 moved In progress under the continuing implementation request. The current F04/F05
baseline and import passed; implementation starts with immutable knowledge definitions, separate
durable CodexState and the version-2 migration before live evidence/Research integration.

F06/D01 implementation reached a verified intermediate boundary first. Three stable term Resources
and three authored evidence records feed a separate CodexState; journal prose cannot mutate it.
Version 2 saves the new state, explicitly migrates version 1 while preserving seed/journal/
encounter, and rejects unknown evidence or contradictory facts. Command parsing moved intact from
CommandConsole to a node-free explicit CommandProcessor, then gained bounded research-only codex
queries. The Basin gained three evidence sites plus North/South cairns and a pause-owning
EvidenceReader, and Kestrel Research became `CODEX ONLINE`.

F06/D01 then completed on 2026-09-06. The remaining acceptance was established by walking the whole
loop through the real scenes rather than by teleporting: physical `E` deployment from the Kestrel
vehicle bay, the authored southern safe passage past an armed hazard to a premature `EVIDENCE 0/3`
rejection at the North Shelf cairn, the northern arc to all three evidence sites with physical
`E`/Escape and a repeat-safe review, physical-Tab journal prose that leaves codex truth
byte-identical, a real lethal-hazard death whose retry keeps the collected evidence on disk, the
fully informed `SOUTH / II / RESONANT` decoy mismatch, the North confirmation of all three
meanings, and the walk back to Kestrel Research for typed codex queries plus journal
find/read/tag/append. A separate writer/reader process pair sharing only an isolated F06 save
restored the exact evidence, meanings, destination, seed, next journal ID and encounter, reapplied
the encounter on deployment and repeated both interactions without duplication.

Two in-scope defects were found by evidence rather than assumed absent. Inspecting the first
Research captures showed the shared console still titled `FIELD COMMAND CONSOLE` with a `where`
placeholder while docked aboard ship, so console title/placeholder/response wording became
location-owned through `set_station_text`. Journal retrieval aboard Kestrel had rendered
`LOCATION UNAVAILABLE` because stamp formatting required the Basin's coordinate service, so
`CoordinateService` stamp formatting became static and entries now render their own recorded
coordinates anywhere. Both fixes were re-verified and re-captured.

The focused scenario was renamed `test_f06_codex_knowledge_loop.gd` when it grew from a model check
into the whole feature loop, and it now also owns the F06 `--phase write` / `--phase read` restart
protocol. Eight captures were inspected; the glyph rows match the fixed truth table and the decoy
is visibly distinguishable. Survey cairn and Codex are now Implemented in the content catalog. The
knowledge loop is one fixed authored solution with one decoy: generated clue placement,
partial-deduction feedback and any codex history or dedicated screen remain future work. The
integrated route stills the Stalker physics so the clue walk is deterministic, and F02/F03 retain
live combat, committed-attack death and encounter-reset evidence. No required gap remains.

Under the goal to finish and publish F06, the accumulated F04, F05 and F06 work was committed and
pushed to `origin/main`; before this the repository had been left at the F03 commit `0e81d2e`
while three features existed only in the worktree. Generate only the F07 plan next.

## History and document ownership

- [Archived progress through F02](docs/archive/PROGRESS_2026-09-05.md) preserves the old
  ledger, original decisions, timing reports, and superseded intermediate observations.
- Completed feature plans own detailed change and verification records.
- [Code guide](docs/CODE_GUIDE.md) explains current systems and reading order.
- [Architecture evolution](docs/ARCHITECTURE_EVOLUTION.md) records material technical decisions.
- Keep this ledger focused on current state; do not append transcripts or duplicate plan logs.
