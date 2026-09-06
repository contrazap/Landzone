# Landzone - Progress Ledger

Last documentation update: 2026-09-06

## Current state

- Overall status: F00-F03 complete; F04 not started.
- Last completed feature: F03 - Static mothership base.
- Last completed project milestone: Static home-to-expedition loop with in-memory revisit state.
- Current feature: F04 - Branching exploration and coordinates (`Not started`).
- Current delivery: None; F04 has no plan yet.
- Exact next action: `Generate the next plan` for F04 - Branching exploration and coordinates.
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
| F04 | Branching exploration and coordinates | Not started | No plan generated. |
| F05 | Searchable journal and basic persistence | Not started | No plan generated. |
| F06 | Codex and first knowledge loop | Not started | No plan generated. |
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
F03's final import, F00/F01/F02/F03 scenarios and two-frame startup smoke all exited 0 with
expected summaries and no reported parser/runtime errors. The non-headless F03 capture driver
exited 0 and produced six inspected 960x540 Compatibility-renderer images covering Kestrel,
both contextual interactions, static transfer, mid-route camera follow and redeployed Basin.
`git diff --check` passed.

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
content catalog did not require a state change. Generate the [F04](docs/ROADMAP.md) plan next; do
not implement it until requested.

## History and document ownership

- [Archived progress through F02](docs/archive/PROGRESS_2026-09-05.md) preserves the old
  ledger, original decisions, timing reports, and superseded intermediate observations.
- Completed feature plans own detailed change and verification records.
- [Code guide](docs/CODE_GUIDE.md) explains current systems and reading order.
- [Architecture evolution](docs/ARCHITECTURE_EVOLUTION.md) records material technical decisions.
- Keep this ledger focused on current state; do not append transcripts or duplicate plan logs.
