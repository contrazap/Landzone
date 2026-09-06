# Landzone - Progress Ledger

Last documentation update: 2026-09-06

## Current state

- Overall status: F00-F02 complete; feature-sized delivery workflow adopted.
- Last completed feature: F02 - Ranged combat and first enemy.
- Last completed project milestone: Agent delivery workflow and reusable project template.
- Current feature: F03 - Static mothership base (`Not started`; no active plan).
- Current delivery: None.
- Exact next action: `Generate the next plan` for F03; inspect its baseline and choose one
  delivery unless a substantial integration or verification boundary justifies a split.
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
| F03 | Static mothership base | Not started | No plan generated. |
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
The 2026-09-06 migration reran the documented import, F00/F01/F02 scenarios and two-frame
startup smoke: all exited 0 with expected results and no reported parser/runtime errors.
`git diff --check` passed. Startup evidence does not establish rendered quality.
No automated rendered-capture or interaction pipeline is established yet; a feature that
changes presentation must establish the agent-run evidence it needs.

## Latest handoff

On 2026-09-06 the user approved feature-sized delivery, plans on demand, agent-owned
verification, routine content selection through plans, and documentation for later study.
This documentation migration implements that approach; game code and completed F00-F02 plans
are preserved. It adds [the code guide](docs/CODE_GUIDE.md) and
[the reusable starter](templates/agent_project/README.md), and replaces future manual gates
with explicit agent evidence requirements and honest experiential limitations.
Migration verification checked 26 Markdown/template documents and resolved all 62 local links;
new/updated current documents have no trailing whitespace. The archived ledger matches the
original tracked ledger content (line endings normalized). Git diff inspection confirms no
runtime code, scene, project configuration or completed F00-F02 plan changes; the only change
under game/ is verification documentation. No new feature plan, commit or push was made.
F03 remains unplanned and unimplemented. Generate only its plan next.

## History and document ownership

- [Archived progress through F02](docs/archive/PROGRESS_2026-09-05.md) preserves the old
  ledger, original decisions, timing reports, and superseded intermediate observations.
- Completed feature plans own detailed change and verification records.
- [Code guide](docs/CODE_GUIDE.md) explains current systems and reading order.
- [Architecture evolution](docs/ARCHITECTURE_EVOLUTION.md) records material technical decisions.
- Keep this ledger focused on current state; do not append transcripts or duplicate plan logs.
