# Landzone - Progress Ledger

Last documentation update: 2026-09-05

## Current state

- Overall status: Preproduction scaffold complete; implementation not started.
- Last completed feature or milestone: Project documentation, folder scaffold, and Git repository setup.
- Current feature: No active feature; F00 is not yet planned.
- Current step: None.
- Next action: Generate `plans/F00_project_foundation.md` from the actual local environment.
- Known blockers: None.
- Pending user decisions: Approve or revise the proposed first-slice content in `docs/CONTENT_CATALOG.md` before the feature that consumes each item.

## Canonical status line

`Status: Preproduction complete; implementation not started | Last: repository scaffold | Current: no active feature | Next: generate F00 - Project foundation | Blockers: none`

Agents must reconstruct this line from verified state rather than copying it blindly.

## Roadmap status

Allowed statuses: `Not started`, `Planned`, `In progress`, `Blocked`, `Complete`.

| ID | Feature | Status | Plan | Implementation evidence | Verification evidence |
| --- | --- | --- | --- | --- | --- |
| F00 | Project foundation | Not started | Not generated | None | None |
| F01 | First expedition and lethal retry | Not started | Not generated | None | None |
| F02 | Ranged combat and first enemy | Not started | Not generated | None | None |
| F03 | Static mothership base | Not started | Not generated | None | None |
| F04 | Branching exploration and coordinates | Not started | Not generated | None | None |
| F05 | Searchable journal and basic persistence | Not started | Not generated | None | None |
| F06 | Seeded path-network generation | Not started | Not generated | None | None |
| F07 | Precision teleport and traversal hazards | Not started | Not generated | None | None |
| F08 | First location, checkpoint, and artifact | Not started | Not generated | None | None |
| F09 | Hunting, inventory, and expedition status | Not started | Not generated | None | None |
| F10 | Mothership cooking, rest, and treatment | Not started | Not generated | None | None |
| F11 | Codex and fixed clue chain | Not started | Not generated | None | None |
| F12 | Procedural mystery and progression validation | Not started | Not generated | None | None |
| F13 | Boss expedition and completion | Not started | Not generated | None | None |
| F14 | Replayability, hardening, and release | Not started | Not generated | None | None |

## Verification baseline

No Godot project or automated verification exists yet. F00 owns:

- Recording the installed Godot version and executable paths.
- Creating `game/project.godot` and a minimal runnable main scene.
- Establishing the first repeatable headless import and smoke checks.
- Creating the initial `game/tests/` verification entry point.
- Confirming the Compatibility renderer and project layout.

Expected executables, to be verified rather than assumed:

```text
C:\MyFiles\Godot\Godot_v4.7.1-stable_win64.exe
C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe
```

## Active blockers and known issues

- No active blockers.
- No game files exist yet by design.
- Content names and tuning values in `docs/CONTENT_CATALOG.md` are proposed until approved or implemented.

## Decision log

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-09-05 | Use the title **Landzone**. | User-selected name; it centers the game on shuttle landing zones and dangerous ground expeditions. |
| 2026-09-05 | Keep the Godot project in `game/` beneath a documentation-oriented repository root. | Agents can manage plans and evidence without mixing process files into `res://`. |
| 2026-09-05 | Use one just-in-time feature plan and one implementation step at a time. | The user can review the complete evolution of the game and later refactors. |
| 2026-09-05 | Make the mothership and shuttle static. | Preserves the expedition fantasy while removing real-time flight and a second vehicle interior. |
| 2026-09-05 | Use compact generated path graphs assembled from authored modules. | Route notes remain meaningful and generated encounters can be validated for fairness. |
| 2026-09-05 | Use lethal direct attacks and no health bar. | Focuses combat on observation, execution, fast retry, and checkpoint mastery. |

## Latest handoff

The documentation scaffold is tracked on `main` in the initialized Git repository, but the
Godot project has not been created. The next agent should inspect the environment and generate only
`plans/F00_project_foundation.md`. It must not create the Godot project until the user reviews
the plan and requests its first implementation step.
