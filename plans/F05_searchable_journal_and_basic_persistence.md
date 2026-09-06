# F05 - Searchable journal and basic persistence

- Feature status: Complete
- Dependencies: F00-F04 complete
- Created: 2026-09-06
- Completed: 2026-09-06
- Delivery mode: Single delivery
- Current delivery: D01

## Outcome and scope

Add a durable field journal to the existing paused command console. The player can create a
coordinate-stamped note, retrieve it by identifier, search note text and tags, assign tags, and
append prose. Journal mutations save immediately; entries survive lethal retry, mothership
transitions and a complete application restart. The same versioned save establishes the first
disk representation of `RunState`, including the authored-run seed and any Basin encounter
snapshot already owned by F03.

This feature owns `journal add`, `journal find`, `journal read`, `journal tag` and
`journal append`, the journal data model, bounded command parsing/presentation, save version 1,
safe missing/invalid-save behavior, and isolated persistence verification. Free-form journal text
never changes progression truth. F05 does not add codex facts, interpret prose, expose later
commands, resume directly into an exterior, generate a run, or add player-facing save slots/new
run controls.

## Actual starting state

- Relevant files, scenes, ownership and data lifetimes inspected: `game/main.gd` persistently owns
  one in-memory `RunState` while locations are replaced; `game/run_state.gd` owns only a Basin
  encounter snapshot; `game/basin_expedition.gd` configures a Basin-local `CommandConsole` and
  `CoordinateService`; `game/ui/command_console.gd` parses only exact `where`; the response area
  is sized for one short line. No file under `game/` reads or writes `user://`.
- Existing behavior to preserve: all F00-F04 movement, combat/retry, encounter revisit,
  mothership transfer, authored-route, coordinate/facing, input-focus and balanced-pause
  contracts; the application still starts aboard Kestrel.
- Baseline commands and actual results on 2026-09-06: Godot 4.7.1 headless editor import plus
  `run_tests.gd`, `test_f01_first_expedition.gd`, `test_f02_ranged_combat.gd`,
  `test_f03_mothership_transition.gd` and `test_f04_branching_coordinates.gd` all exited 0 with
  their expected success summaries and no reported parser/runtime errors.
- User changes to preserve: the worktree contains the completed, documented F04 change set on top
  of commit `0e81d2e`; F05 will build on it without reverting or rewriting it. `AGENTS.md` also has
  user-owned workflow changes.
- Assumptions and required external decisions: the authored pre-generation run receives a stable
  integer seed selected during implementation and persisted from the first save; it is metadata,
  not an F07 generator input yet. No external decision is required.

## Content and design decisions

Journal entry identifiers begin at 1, increase monotonically, and are never reused after loading.
An entry stores player-authored text, region identifier, signed local north/east grid values,
eight-way facing at creation, run seed, UTC discovery timestamp and normalized player tags.
The console presents the local stamp using the same 80-pixel shuttle-relative convention as
`where`; coordinate calculation remains owned by `CoordinateService` rather than being reparsed
from display text.

The bounded grammar is:

- `journal add "<text>"` creates and immediately saves one entry. Text is 1-240 characters.
- `journal find <query>` searches text and tags case-insensitively and returns at most five ID,
  tag and text previews; a quoted query preserves spaces.
- `journal read <id>` shows full text plus region/local/facing, seed, discovery time and tags.
- `journal tag <id> <tag> [tag...]` adds one or more unique lowercase tags. Tags use letters,
  digits, `_` or `-`, are at most 24 characters, and an entry holds at most eight.
- `journal append <id> "<text>"` appends 1-240 characters as a new prose line while retaining the
  original discovery stamp.

Unclosed quotes, invalid identifiers, missing arguments, excessive text/tags and unavailable save
state receive specific usage or error responses and do not mutate journal data. Search has no
side effects. The console remains Basin-local for F05: all journal operations are available there,
while broader ship/station command access belongs to features that need it.

`RunState` owns plain journal data for the run. A focused journal model validates mutations,
lookup, search and serialization without referencing scene nodes. `LandzoneMain` owns a focused
save store and the actual save path, loads before activating Kestrel, and saves after every journal
mutation and after the Basin encounter is captured for a normal return. Save version 1 is JSON,
uses plain values only, validates required types/ranges, and reconstructs fresh model objects.
Missing files create a fresh run. Malformed JSON, unsupported versions or invalid records fail to
a fresh in-memory run with a visible/logged load warning rather than crashing or partially loading;
the invalid file is not silently treated as valid evidence. A failed write is reported by the
journal command and retains the in-memory mutation so a later save can retry.

Material refactoring is justified at two demonstrated seams. `CoordinateService` needs a plain
coordinate snapshot because both `where` and durable journal metadata consume the same convention;
it will expose structured values and format them without changing F04 output. The single-command
console now needs quoted arguments, multi-line results and a journal mutation callback; it will
gain a small tokenizer and explicit `where`/`journal` dispatch, not a generic registry or future
command framework. Save ownership stays in `LandzoneMain`; no autoload is introduced because one
run and one persistent root remain sufficient.

## Delivery sizing

F05 is one cohesive delivery. The data model, save boundary, console grammar, scene integration,
restart scenario and response presentation are mutually dependent but form one modest system.
Splitting before disk round-trip or console integration would not produce the roadmap's playable
increment.

| Delivery | Outcome and dependencies | Status | Acceptance IDs |
| --- | --- | --- | --- |
| D01 | Complete durable searchable journal, command/UI integration, verification and docs | Complete | A01-A08 |

Delivery statuses: Not started, In progress, Blocked, Complete.

## Delivery implementation checklist

### D01 - Durable field journal

- Expected files and responsibilities: add focused journal entry/store scripts under
  `game/journal/`; add a versioned disk adapter under `game/persistence/`; extend `run_state.gd`
  with durable data serialization; let `main.gd` load/save and provide mutation persistence;
  extend `navigation/coordinate_service.gd`, `basin_expedition.gd` and the console script/scene for
  structured stamps, journal dispatch and readable multi-line responses; add F05 scenario/capture
  drivers and register their commands in test documentation.
- [x] Establish the F00-F04 baseline, then implement structured entries, validation, monotonic
  identifiers, search, tags, append and plain serialization.
- [x] Implement save version 1 with an injectable path, validated reconstruction, fresh-run
  fallback and actionable load/write failures; connect it to application and encounter lifetime.
- [x] Extend coordinate snapshots and the existing console grammar without changing `where`,
  pause/focus, retry or transfer behavior; make long journal results readable at 960x540.
- [x] Exercise all acceptance scenarios, including two separate Godot processes sharing only an
  isolated F05 save, inspect rendered captures, and fix in-scope failures.
- [x] Review the complete diff for ownership, save safety, prose/truth separation and accidental
  changes; update tests README, code guide, architecture evolution, plan evidence and progress.

## Acceptance and evidence

| ID | Required observable outcome | Agent verification method and expected result | Actual evidence / status |
| --- | --- | --- | --- |
| A01 | A quoted journal note receives ID 1 and the exact current region/local/facing, authored-run seed and UTC discovery time. | Drive the real Basin console after moving/facing the player; add and read the note; compare displayed and structured metadata with `CoordinateService` and injected time. | Passed: the F05 integrated scenario created #1 at `P1-BASIN-01 / N01 E02 / NE`, seed `51005` and injected Unix time `1788710400`; structured fields and read output matched. |
| A02 | Search/read/tag/append are useful and bounded. | Through console submission, add multiple notes, search mixed-case text and tags, verify five-result cap/order, normalize/deduplicate tags, append a new line and read the complete updated entry. | Passed: mixed-case text/tag queries returned newest IDs 7-3 only, duplicate `Route/ROUTE` became one `route`, `cave` remained searchable, append preserved the original stamp and read returned both prose lines. |
| A03 | Invalid journal syntax and data do not mutate state. | Exercise empty/unclosed/oversized text, missing/bad IDs, invalid/excess tags, missing queries and unknown subcommands; assert exact bounded feedback, unchanged entries and unchanged next ID. | Passed: the integrated invalid-command table covered every named class plus unquoted prose and unknown journal verbs; exact errors matched and entry count/next ID did not change. |
| A04 | Journal data survives lethal retry and location replacement. | Add/tag a note, trigger the real lethal hazard and await retry, then return to Kestrel/redeploy through guarded transitions and read/search the same entry. | Passed: #1 text/tags survived actual death completion, return and redeployment. Retry also replaced and saved the encounter snapshot with the authored concealed/full-hit reset before control returned. |
| A05 | A real application restart retains journal and existing durable run data. | Run a write phase and a read phase in two separate Godot 4.7.1 invocations against only `user://landzone_f05_test/restart.json`; verify IDs, text, tags, metadata, next-ID continuity, seed and a Basin encounter snapshot, then remove only that test save. | Passed: writer and reader were separate exit-0 processes with their expected summaries. Reader restored exact prose/tags/stamp/time, seed, next ID and encounter, applied the encounter on deployment, read/searched via the console, saved #2 and removed the isolated save. |
| A06 | Missing and invalid saves fail safely and version 1 round-trips without aliasing or partial acceptance. | Focused save checks use isolated paths for missing, malformed, unsupported-version and invalid-entry files; expect fresh state plus a diagnostic, and prove serializing/reloading produces independent valid objects. | Passed: missing returned a fresh non-error state; malformed JSON, version 99 and a partial entry returned diagnostics with wholly fresh states; valid version 1 reloaded independent journal/encounter objects. |
| A07 | Journal presentation and console lifecycle are readable and safe. | Non-headless driver saves populated add/find/read views at 960x540; inspect wrapping, metadata hierarchy, input focus and clipping. Reuse F04 pause/focus/freeze/retry/transfer checks. | Passed: final `f05_journal_add.png`, `f05_journal_find.png` and `f05_journal_read.png` were inspected. All hierarchy/contrast was clear; five results fit with deliberate ellipsis and read showed full metadata plus both prose lines. Initial scroll/clipping was fixed by expanding the response area and tag-aware preview truncation. F04 lifecycle scenario passed unchanged. |
| A08 | The project imports and all affected earlier behavior remains correct. | Headless editor import, F00-F05 scenarios, two-frame startup and `git diff --check` all exit 0 with expected summaries and no parser/runtime errors. | Passed: final import, F00, F01, F02, F03, F04, integrated F05, restart writer, restart reader, startup and capture commands exited 0 with expected summaries/no unexpected errors; final `git diff --check` passed. |

## Verification execution

- Run from the repository root with
  `C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe`: headless editor import; existing
  F00-F04 scripts documented in `game/tests/README.md`; the new F05 in-process behavioral script;
  separate `--phase write` and `--phase read` persistence invocations; two-frame startup; and a
  non-headless F05 capture driver.
- Reuse F04's actual Tab/text/Enter/Escape, gameplay-freeze, retry/transfer-rejection and
  redeployment coverage. Add durable tests because identifier continuity, no-alias reconstruction,
  mutation-on-error and cross-process disk lifetime are high-risk contracts not covered earlier.
- The integrated scenario operates on `main.tscn` and the real Basin/player/hazard/transition
  nodes. Plain-model cases isolate validation and corrupted-file handling without pretending to
  prove scene integration.
- Capture populated add/find/read responses under `game/tests/artifacts/` at 960x540 with the
  Compatibility renderer. A passing capture driver proves dimensions/write success only; inspect
  the pixels for text clipping, contrast, hierarchy and retained input context.
- All persistence checks use only `user://landzone_f05_test/restart.json` (or sibling explicit
  fixture names), never the default player save. Writer setup and reader cleanup target those exact
  files; failures print the retained path for diagnosis.
- The existing executable provides required headless and rendered capabilities. The two-process
  phase protocol establishes application-restart evidence missing from the current harness.

## Optional experiential limitations

Whether players naturally develop useful tagging habits, prefer command syntax to a graphical
journal, or find five search previews sufficient remains unassessed. These are optional experience
questions, not required F05 verification gaps.

## Completion and continuation record

- Deliveries completed / current status: D01 Complete; feature Complete.
- Actual changed files, responsibility and reason for change: `game/journal/journal_entry.gd` and
  `field_journal.gd` own validated durable journal data; `game/persistence/run_save_store.gd` owns
  version-1 JSON; `run_state.gd` serializes run facts; `main.gd` owns load/save triggers;
  `coordinate_service.gd`, `basin_expedition.gd` and the console script/scene integrate structured
  stamps, encounter capture, grammar and multi-line presentation. F05 test/capture drivers and
  isolation edits protect behavior and player data. Test README, catalog, code guide, architecture
  log, plan and progress record current behavior. Godot generated matching `.uid`/`.import` files.
- Acceptance IDs and commands/scenarios/results, including error-log review: A01-A08 passed. Exact
  headless import, F00-F05, startup, restart writer/reader and non-headless capture commands are in
  `game/tests/README.md`; each final run exited 0 with its expected summary and no unexpected
  parser/runtime errors. `git diff --check` passed.
- Rendered observations and artifact links, or applicability/required gap: inspected
  `game/tests/artifacts/f05_journal_add.png`, `f05_journal_find.png` and
  `f05_journal_read.png` at 960x540. The first search/read capture exposed unnecessary scrolling;
  the response area and preview bound were corrected, recaptured and re-inspected with no clipping.
- Content decisions implemented and tuning deviations: all five catalog journal commands are
  Implemented. Seed `51005`, five newest-first results, 240-character mutation text, eight
  24-character tags and the planned grammar shipped. A 2000-character total-entry ceiling was
  added as a routine bounded-safety detail. Retry completion now saves its encounter reset so a
  stale pre-death snapshot cannot reappear after process restart.
- Code guide sections and architecture decision links: [journal and save lifetime](../docs/CODE_GUIDE.md#journal-and-save-lifetime)
  and [F05 persistence decision](../docs/ARCHITECTURE_EVOLUTION.md#2026-09-06---f05d01---persist-plain-run-models-behind-the-application-root).
- Remaining defects, required verification gaps and optional limitations: none required. Optional
  tagging-habit, command-vs-screen preference and result-page sufficiency questions remain as
  stated above.
- Exact next action: generate the F06 - Codex and first knowledge loop plan; do not implement F06
  until its plan is generated and implementation is requested.
