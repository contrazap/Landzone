# F06 - Codex and first knowledge loop

- Feature status: In progress
- Dependencies: F00-F05 complete
- Created: 2026-09-06
- Completed: -
- Delivery mode: Single delivery
- Current delivery: D01

## Outcome and scope

Deliver the first complete knowledge-driven decision on the authored Basin. The player observes
reachable alien evidence in the field, records and later retrieves a journal note, returns to
Kestrel's newly active research station, uses the codex to compare evidence, redeploys, rejects an
incorrect landmark pattern and confirms the correct North Shelf Survey Cairn. The fixed chain
establishes three stable vocabulary meanings and keeps observed evidence, player interpretation
and authoritative confirmed facts as separate data.

F06 owns three fixed alien terms, three evidence sites using at least two complementary evidence
forms, the Survey Cairn clue landmark and one explicit decoy, `codex search`, `codex evidence`,
research-station interaction, destination validation, durable evidence/confirmed facts and a
version-1-to-version-2 save migration. It does not add an artifact, unlock ability, boss coordinate,
generated clue arrangement, new landing region, arbitrary prose interpretation, runtime LLM,
specimen system or general station framework.

## Actual starting state

- Relevant files, scenes, ownership and data lifetimes inspected: `LandzoneMain` owns location
  replacement and version-1 save triggers; `RunState` serializes seed, journal and the optional
  Basin encounter; `FieldJournal` owns player prose only. `BasinExpedition` owns the authored
  six-segment surface, coordinate context, retry and its local console. `CommandConsole` owns both
  pause/focus presentation and explicit `where`/journal parsing. `Mothership` has a solid shared
  station bulkhead; Research is a visible `SEALED` door/label with no interaction or run-state
  access. No codex, evidence nodes, confirmed facts or observation UI exists.
- Existing behavior to preserve: F00-F05 movement, direct combat, lethal retry, encounter revisit,
  mothership transfer, all route branches, coordinates, console pause/focus, journal grammar and
  version-1 journal/encounter durability. Journal prose must remain non-authoritative.
- Baseline commands and actual results on 2026-09-06: Godot 4.7.1 headless editor import,
  `test_f04_branching_coordinates.gd` and `test_f05_journal_persistence.gd` each exited 0 with the
  expected summary and no reported parser/runtime errors. F05's just-completed full F00-F05,
  startup, two-process restart and rendered baseline remains recorded in its plan.
- User changes to preserve: the complete F04/F05 worktree and workflow edits are uncommitted over
  local/remote F03 commit `0e81d2e`; no commit, push, history rewrite or unrelated cleanup is
  authorized.
- Assumptions and required external decisions: none. The concrete content below is within approved
  F06 scope and becomes authorized when implementation is requested.

## Content and design decisions

### Stable vocabulary and fixed inference

The F06 authored vocabulary is:

| Token | Stable meaning | Evidence support before confirmation |
| --- | --- | --- |
| `ACHVNTSAT` | `NORTH` | Landing Fork Compass Array places the token only on its standard `N` ray; Reunion Route Slab repeats it beside an upward/north chevron. |
| `VEL` | `THREE` | North Arc Resonance Calibration labels its third tally/three-sample row `VEL`; Route Slab repeats it above a three-disc cluster. |
| `ORUUN` | `SILENT STONE` | Resonance Calibration etches `ORUUN` on the matte sample with `RETURN 0` while a control stone produces visible rings; Route Slab repeats it beside a filled stone with the wave mark deliberately absent. |

The fixed directive on the Reunion Route Slab is `ACHVNTSAT VEL ORUUN`. Read together, its
independent direction, quantity and material properties identify the three matte, non-resonant
stones of the Survey Cairn at the existing North Shelf limit, local `N04 E23`. The South Hollow
limit at `S04 E23` contains a two-stone amber cairn with visible resonance rings. It is a deliberate
decoy that violates direction, quantity and material rather than differing by an arbitrary flag.

Evidence is adequate without claiming unfamiliar-player comprehension: each required meaning is
supported at both a calibration/context site and the separate directive's visual grammar. The
codex presents the observed records verbatim and does not expose the authored English meaning
until gameplay confirms the matching destination. Reaching/interacting with the North cairn after
all three evidence records are observed confirms the three term meanings and destination. Trying
the North cairn early reports insufficient evidence; trying the South cairn after collecting the
chain reports the physical mismatch. Neither invalid attempt mutates confirmed facts.

### Field and research flow

Place the Compass Array at Landing Fork, Resonance Calibration on the safe North Arc near the
existing `MarkerB`, and Route Slab at Reunion Fork before the Stalker. Each has a warm, clearly
interactable world silhouette, one bounded `E` proximity prompt and a pause-owning evidence reader
with title, glyph line and concise observation. The calibration uses Godot-native tally, stone and
visible-ring shapes; no audio asset is required to establish the zero-return contrast. Evidence
records are identified by stable IDs and can be observed repeatedly without duplication.

The intended loop is:

1. Deploy and observe the Compass Array, Resonance Calibration and Route Slab.
2. Near the slab, add a journal note such as `ACHVNTSAT VEL ORUUN: north / three / silent stone.`
   and tag it `clue route`; this remains player prose and confirms nothing.
3. Return through the shuttle. The Research door changes from `SEALED` to `CODEX ONLINE`; physical
   `E` near its accessible aisle-side terminal opens the paused research console.
4. Use `journal find/read` to recover the note and `codex search/evidence` to compare collected
   records. Research can read/tag/append existing journal entries; `journal add` and `where` remain
   unavailable aboard Kestrel because no regional stamp exists.
5. Redeploy, interact with the South Hollow decoy and receive a concrete mismatch without state
   change, then traverse to the North Shelf Survey Cairn and confirm the solution.
6. Returning to Research and searching the term/English meaning shows durable confirmed facts.

The field console keeps its existing `where` and all journal operations. Codex queries are
research-only and return `CODEX AVAILABLE AT KESTREL RESEARCH` if entered in the field. The
research console advertises only its available journal/codex operations and can open only while
the player is within the Research terminal range. Transfer, another pause-owning reader, retry or
teardown cannot leak a pause or permit conflicting interaction.

`codex search <query>` searches only observed alien tokens, observed evidence titles/text and
confirmed English meanings, case-insensitively, with at most five concise matches. An observed but
unconfirmed term reports its evidence count and `MEANING UNCONFIRMED`; after solution confirmation
it reports, for example, `ACHVNTSAT = NORTH | CONFIRMED: NORTH SHELF SURVEY CAIRN`.
`codex evidence <term>` requires one exact known/observed token and lists the collected evidence
records that mention it. Missing queries, unknown/unobserved terms, extra evidence arguments and
unknown codex subcommands return specific bounded errors.

### Ownership, persistence and refactoring

Author the fixed vocabulary/evidence text in one immutable `KnowledgeCatalog` resource using
small custom term/evidence Resources, justified by three reusable definitions and F07's immediate
need to place the same authored content. A node-free `CodexState` owns only per-run observed
evidence IDs, confirmed token-to-meaning facts and confirmed destination ID. It validates IDs
against the catalog, ignores duplicate observation, never reads journal prose and serializes plain
values. `RunState` owns this durable state. Basin owns live evidence/cairn nodes and asks the state
model to observe/validate; Main remains the sole save trigger.

The second command location and domain demonstrate pressure to separate command behavior from UI.
Refactor `CommandConsole` so it retains focus, response and balanced pause ownership while a
node-free explicit `CommandProcessor` owns the existing tokenizer and `where`/journal/codex
dispatch for a configured field or research context. Preserve the F04/F05 grammar verbatim before
adding codex behavior. This is not a generic command registry: supported domains remain explicit,
and later commands are not predeclared.

A focused reusable `EvidenceSite` handles proximity and stable definition identity; authored
scene children provide each site's distinct shapes. `BasinExpedition` coordinates one active site,
durable mutation, target validation and the evidence reader. A focused `EvidenceReader` Control
owns its own balanced pause just as the console does, but console/reader availability is mutually
exclusive. `Mothership` owns Research proximity and configures its console with the shared
RunState models supplied by Main.

Adding codex fields changes the disk schema. Save version 2 writes the new state. Loading version
1 performs one explicit migration that preserves seed, journal and encounter and initializes an
empty `CodexState`; malformed version-2 evidence/facts reject the entire save to the existing fresh
state/diagnostic path. No speculative general migration framework or save-slot UI is introduced.

## Delivery sizing

F06 remains one delivery. Evidence collection, Research access, codex interpretation, destination
validation and durable facts are one player-visible loop; splitting before the destination or
save round trip would not meet the feature outcome. The command separation is a behavior-preserving
refactor inside this delivery and uses the existing F04/F05 suite as its baseline.

| Delivery | Outcome and dependencies | Status | Acceptance IDs |
| --- | --- | --- | --- |
| D01 | Complete fixed evidence-to-codex-to-Survey-Cairn loop, persistence, verification and docs | Complete | A01-A09 |

Delivery statuses: Not started, In progress, Blocked, Complete.

## Delivery implementation checklist

### D01 - First fixed knowledge loop

- Expected files and responsibilities: add authored knowledge Resources/catalog and durable codex
  state under `game/knowledge/`; add reusable evidence-site and evidence-reader scene/scripts;
  extend Basin scene/controller with three evidence sites, correct/decoy cairns and interaction;
  activate Research interaction/console in `mothership.gd/.tscn`; extract explicit parsing from
  `ui/command_console.gd` into a node-free processor; extend `RunState`, save store/migration and
  Main location initialization; add F06 behavioral, restart and capture drivers; update relevant
  existing scenarios, README, catalog, code guide, architecture log, plan and progress.
- [x] Re-run the F04/F05 baseline, refactor command parsing behind the UI-only console, and prove
  exact existing grammar, pause and persistence behavior before adding F06 commands.
- [x] Implement authored vocabulary/evidence definitions and validated durable CodexState with no
  dependency on journal prose.
- [x] Integrate reachable field evidence, repeat-safe observation, pause-safe reader, correct/decoy
  cairns and visually grounded validation into the actual authored Basin.
- [x] Activate Kestrel Research and its proximity-scoped console; integrate journal retrieval plus
  bounded `codex search/evidence` responses and location-specific availability.
- [x] Bump saves to version 2, migrate valid F05 version-1 data, reject invalid F06 state, and save
  evidence/confirmed facts after observation, retry, transition and application restart.
- [x] Exercise the complete actual-interface loop and invalid answers, inspect evidence/research/
  target captures, fix in-scope failures, review the final diff and close all documentation.

## Acceptance and evidence

| ID | Required observable outcome | Agent verification method and expected result | Actual evidence / status |
| --- | --- | --- | --- |
| A01 | Three reachable evidence sites provide adequate, mutually consistent support for every fixed term without revealing a contradictory meaning. | Traverse the real Basin from the shuttle to each proximity area; interact through physical `E`; assert stable IDs, exact displayed records and repeat-safe state. Review the evidence table above against every rendered line/icon and record the deduction supported by each. | Passed. The walked route reaches each site through real physics; physical E opens stable IDs compass_array, resonance_calibration and route_slab, and a repeat press reports EVIDENCE REVIEW. Inspected captures show the N-ray compass ring, the I/II/VEL tally with ORUUN RETURN 0 beside a ringing control stone, and the Route Slab chevron/three-disc/filled-disc directive row: each supports north, three and silent stone, and none contradicts a fixed meaning. |
| A02 | Evidence observation is durable but separate from confirmed facts and journal prose. | Observe one/all records, add/retrieve a journal note, inspect plain models and try unrelated/assertive prose. Expected: observed IDs change once, journal entries change independently, and confirmed mappings remain empty before target validation. | Passed. Observation stores only IDs. A physical-Tab journal entry asserting ACHVNTSAT means south left the codex dictionary byte-identical, and confirmed facts stayed empty until validation. A real lethal-hazard death and retry preserved all three records, the journal entry and the empty fact set, and the retry save on disk still held three records. |
| A03 | Kestrel Research is a functional, bounded command location. | Return normally, physically approach the aisle-side Research terminal and press `E`; verify label/prompt, LineEdit focus, pause ownership, advertised commands, journal find/read/tag/append, unavailable `where`/add, close/resume and rejection away from the terminal/while transferring. | Passed. Real movement along the Kestrel aisle shows the Research prompt; physical E opens the console, focuses its LineEdit and owns the pause. It advertises the codex commands, answers journal find/read/tag/append, reports WHERE UNAVAILABLE and LOCATION UNAVAILABLE for a coordinate-stamped add, closes on Escape without leaking pause, and refuses to open away from the terminal or once a transfer is committed. |
| A04 | Codex search/evidence expose only collected evidence before confirmation and confirmed meanings afterward. | Through the actual Research console, exercise mixed-case token/evidence/meaning queries, exact evidence lookup, five-result bound and empty/unknown/unobserved/extra-argument failures. Before confirmation expect `MEANING UNCONFIRMED`; afterward expect the exact three meanings and confirmed cairn. | Passed. A physically typed codex search north returned the three confirmed meanings; codex evidence ORUUN returned the collected records. Unknown terms, missing arguments, extra arguments and unknown subcommands return their exact bounded usage errors, and the model check requires MEANING UNCONFIRMED before validation and the exact three meanings plus the confirmed cairn afterward. |
| A05 | The fixed evidence leads to North Shelf Survey Cairn at `N04 E23`, while invalid answers do not advance truth. | With all evidence observed, use journal/codex interfaces, redeploy and drive real physics through the route. Interact first with South Hollow's two resonant stones: expect physical mismatch and no facts. Interact with the North target: expect all three properties, mappings and destination confirmed. Also attempt the correct cairn before prerequisites and expect unresolved/no mutation. | Passed. Walking the armed-hazard southern passage to the cairn at zero evidence returns PATTERN UNRESOLVED EVIDENCE 0/3 with no mutation. Fully informed, the South Hollow cairn returns CAIRN MISMATCH SOUTH / II / RESONANT and changes nothing; the North Shelf cairn at N04 E23 confirms all three meanings and the destination. |
| A06 | Confirmed facts and evidence survive death, location replacement and process restart without duplication or reroll. | Observe evidence, die/retry, return/redeploy and compare IDs/facts. Extend the separate writer/reader process protocol using only an isolated F06 save; reader restores exact evidence/facts/destination, reapplies encounter state, repeats interactions without duplicates and queries them through Research. | Passed. The write and read phases run as separate Godot processes sharing only user://landzone_f06_test/restart.json. The reader restored the exact observed IDs, meanings, destination, seed, next journal ID and encounter, reapplied the encounter on deployment, repeated both interactions without duplication, and queried the restored truth through Research. The fixture is removed on success. |
| A07 | Save version 2 preserves F05 data and safely validates F06 state. | Load an isolated valid version-1 F05 fixture and expect seed/journal/encounter preserved plus empty codex, then save/reload version 2. Exercise malformed evidence IDs, invalid confirmed mappings/destination and unsupported versions; expect wholly fresh state plus diagnostics and independent reconstructed objects. | Passed. An isolated version-1 fixture migrates with seed, journal and encounter preserved and an empty codex, then rewrites and reloads as version 2 retaining new evidence. Unknown evidence IDs, contradictory meanings, invalid destinations and unsupported versions are rejected to a wholly fresh state, and round trips reconstruct independent objects. |
| A08 | Evidence, Research and cairn presentation are readable in the running 960x540 game. | Non-headless captures cover Compass Array observation, Resonance Calibration/Route Slab evidence, Research journal+codex responses, South mismatch and North confirmation. Inspect pixels for prompt conflicts, glyph/evidence consistency, hierarchy, clipping, player/landmark visibility and correct/decoy distinction. | Passed. Eight inspected 960x540 Compatibility captures under game/tests/artifacts/: f06_evidence_compass, f06_evidence_resonance, f06_evidence_route_slab, f06_cairn_south_mismatch, f06_cairn_north_confirmed, f06_research_codex, f06_research_evidence and f06_research_journal. Glyph rows match the truth table and the decoy is visibly distinguishable. Inspection found the Research console still titled FIELD COMMAND CONSOLE and advertising the unavailable where command; wording became location-owned and the views were recaptured. |
| A09 | The project remains runnable and all affected behavior regresses cleanly. | Headless import, F00-F06 scenarios, F05 writer/reader compatibility, two-frame startup, final capture, `git diff --check` and intended-file review all exit 0 with expected summaries and no introduced parser/runtime errors. | Passed. Headless import, the F00-F06 scenarios, the F05 and F06 writer/reader phases, the two-frame startup smoke, the F06 capture driver and git diff --check all exited 0 with their expected summaries and no parser or runtime errors. Both isolated test directories are empty after the runs and the default player save is untouched. |

## Verification execution

- Use the confirmed Godot 4.7.1 console from the repository root. Run headless editor import,
  F00-F05 commands from `game/tests/README.md`, a new integrated F06 scenario, separate F06 restart
  writer/reader invocations, two-frame startup and a non-headless F06 capture driver.
- Before adding behavior, run F04 and F05 after the CommandProcessor extraction. Their exact
  `where`, journal errors/results, physical Tab/Enter/Escape, pause, retry, transfer and version-1
  contracts must remain meaningful; update only schema assertions where version-2 migration
  legitimately changes the stored envelope.
- The integrated F06 scenario uses real Main/Kestrel/Basin scenes, physical interaction input and
  actual movement along authored route waypoints. Combat/hazard behavior is not re-proved by
  disabling it and claiming a full expedition; if focused route setup disables either to isolate
  clue logic, retain F02/F04 regressions as separate evidence and state that limitation precisely.
- Verify both invalid answers: premature correct-cairn interaction and fully informed South decoy.
  Record codex model contents before/after, not just a response label. Confirm that arbitrary
  journal prose cannot create evidence, facts or destination completion.
- Save tests use only `user://landzone_f06_test/` exact fixture names. Preserve and migrate a
  version-1 payload, use separate processes for durable F06 state, remove only successful isolated
  fixtures and confirm the default player save remains untouched.
- Capture at 960x540 with the Compatibility renderer. A passing capture driver proves image
  creation/dimensions only; inspect every retained image and compare visible glyph/count/material
  cues with the fixed truth table. Document ambiguity separately from human comprehension.

## Optional experiential limitations

Unfamiliar-player comprehension of the three meanings, satisfaction from the return-to-Research
loop, memorability of the glyph tokens and preferred note wording remain unassessed unless actual
human observations occur. Agent consistency review and successful route execution do not prove
those subjective outcomes and their absence is not a delivery gate.

## Completion and continuation record

- Deliveries completed / current status: D01 Complete; feature Complete.
- Actual changed files, responsibility and reason for change: `game/knowledge/` now contains term/
  evidence Resources, immutable catalog, CodexState, EvidenceSite and its base scene;
  `ui/command_processor.gd` owns preserved grammar plus codex queries while CommandConsole retains
  UI/pause; `ui/evidence_reader.gd/.tscn` owns observation presentation/pause. RunState/save store
  write version 2 and migrate version 1. Basin surface/controller/scene contain five live sites,
  prompt, reader and correct/invalid validation. `test_f06_knowledge_model.gd` covers this boundary.
- Acceptance IDs and commands/scenarios/results, including error-log review: A01-A09 all pass.
  The headless editor import, the F00-F06 scenario scripts, the F05 and F06 write/read restart
  pairs, the two-frame startup smoke, the non-headless capture_f06_views.gd driver and
  git diff --check each exited 0 with the expected summary and no parser or runtime errors. The
  focused F06 scenario was renamed test_f06_codex_knowledge_loop.gd when it grew from a model
  check into the whole feature loop.
- Rendered observations and artifact links, or applicability/required gap: eight inspected
  captures under game/tests/artifacts/f06_*.png. The evidence readers, the South mismatch and the
  North confirmation are legible with no clipping or prompt conflicts, and the glyph cues match the
  fixed truth table. The first Research captures exposed the shared console presenting itself as
  the field console with a where placeholder aboard ship; wording became location-owned and the
  Research views were recaptured and re-inspected. No required rendering gap remains.
- Content decisions implemented and tuning deviations: the Survey Cairn and the codex commands are
  now Implemented in the content catalog, with the planned meanings, evidence text and destinations
  unchanged. Two in-scope corrections came from evidence: CoordinateService stamp formatting became
  static so journal retrieval renders recorded coordinates at Research instead of
  LOCATION UNAVAILABLE, and console title, placeholder and response wording became location-owned.
- Verification limitation: the integrated route stills the Stalker physics so the clue walk is
  deterministic. The lethal hazard stays armed, is avoided through the authored safe passage and is
  then deliberately contacted for the durability check; F02 and F03 retain live combat,
  committed-attack death and encounter-reset evidence.
- Code guide sections and architecture decision links: pending implementation.
- Remaining defects, required verification gaps and optional limitations: no F06 full route,
  two-process restart or capture evidence exists. Research still needs physical-key/focus and full
  journal/lifecycle coverage. Live sites use base silhouettes pending rendered refinement.
- Exact next action: extend the integrated scenario through physical field observation, journal
  retrieval at Research, redeployment and actual route movement; then add restart/capture evidence.
