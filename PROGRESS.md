# Landzone - Progress Ledger

Last documentation update: 2026-09-05

## Current state

- Overall status: Preproduction review incorporated; implementation not started.
- Last completed feature or milestone: Approved development-plan review revisions: earlier knowledge loop, content ownership, recovery rules, and playtest gates.
- Current feature: No active feature; F00 is not yet planned.
- Current step: None.
- Next action: Generate `plans/F00_project_foundation.md` from the actual local environment.
- Known blockers: None.
- Unverified manual checks: No playable build exists yet. Future comprehension, recovery, and
  pacing checks are assigned in the roadmap; none have been performed or credited as passing.
- Pending user decisions: Approve or revise the proposed first-slice content in `docs/CONTENT_CATALOG.md` before the feature that consumes each item.

## Canonical status line

`Status: Preproduction review incorporated; implementation not started | Last: development-plan review revisions | Current: no active feature | Next: generate F00 - Project foundation | Blockers: none`

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
| F06 | Codex and first knowledge loop | Not started | Not generated | None | None |
| F07 | Seeded path-network generation | Not started | Not generated | None | None |
| F08 | Precision teleport and traversal hazards | Not started | Not generated | None | None |
| F09 | First location, checkpoint, and artifact | Not started | Not generated | None | None |
| F10 | Hunting, inventory, and expedition status | Not started | Not generated | None | None |
| F11 | Mothership cooking, rest, and treatment | Not started | Not generated | None | None |
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
- Content names and tuning values in `docs/CONTENT_CATALOG.md` remain proposed until explicitly
  approved; the review approval does not approve all content candidates.

## Latest documentation evidence

- User approved the review recommendations and requested the necessary changes on 2026-09-05.
- `docs/ROADMAP.md` now moves the fixed knowledge loop to F06, renumbers former F06-F10 to
  F07-F11, assigns every first-slice requirement, and defines staged playtest gates.
- `docs/GAME_DESIGN.md` defines stable meanings versus variable solutions, an early inference
  example, bounded persistent statuses, resource/cache retry rules, checkpoint abandonment,
  basic mothership recovery, and pacing guided by observations rather than a duration minimum.
- `docs/CONTENT_CATALOG.md` assigns content owners and updates approval timing. Proposed content
  remains proposed. `plans/FEATURE_PLAN_TEMPLATE.md` carries ownership, persistence, recovery,
  and applicable manual gates into future plans.
- Verification: inspected the clean pre-edit Git baseline and actual `game/` scaffold (only
  `.gitkeep` placeholders). No active feature plan, `project.godot`, or runnable tests exist.
  Documentation checks passed: all 15 feature IDs/names match between roadmap and ledger, all
  remain `Not started`, all numeric feature references resolve, and no game code or feature
  plans were created. `git diff --check` passed. Reviewed ownership and dependency boundaries
  against the slice requirements; gameplay and manual checks remain unavailable until implemented.
- No game implementation or architecture refactor was performed; no architecture-log entry is
  warranted. All feature statuses remain `Not started`.

## Decision log

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-09-05 | Use the title **Landzone**. | User-selected name; it centers the game on shuttle landing zones and dangerous ground expeditions. |
| 2026-09-05 | Keep the Godot project in `game/` beneath a documentation-oriented repository root. | Agents can manage plans and evidence without mixing process files into `res://`. |
| 2026-09-05 | Use one just-in-time feature plan and one implementation step at a time. | The user can review the complete evolution of the game and later refactors. |
| 2026-09-05 | Make the mothership and shuttle static. | Preserves the expedition fantasy while removing real-time flight and a second vehicle interior. |
| 2026-09-05 | Use compact generated path graphs assembled from authored modules. | Route notes remain meaningful and generated encounters can be validated for fairness. |
| 2026-09-05 | Use lethal direct attacks and no health bar. | Focuses combat on observation, execution, fast retry, and checkpoint mastery. |
| 2026-09-05 | Apply the approved review: move the first knowledge loop to F06 and assign remaining content to explicit owners. | Test observation and inference before generation/survival investment; avoid unassigned work accumulating at release. |
| 2026-09-05 | Introduce recovery with survival, retain bounded statuses on death, and define resource/cache reset rules. | Death should not serve as treatment; repeated failure and finite resources must not prevent another viable expedition. |
| 2026-09-05 | Preserve vocabulary meanings while varying evidenced solutions; use comprehension and pacing playtests. | Reachability tests cannot prove understandable deductions or enjoyable duration. |

## Latest handoff

The approved review revisions are incorporated in the design, roadmap, content catalog, and
feature-plan template. Use the revised IDs: F06 is the first knowledge loop, F07 generation,
F08 blink, F09 artifact/site, F10 survival/basic recovery, and F11 full mothership procedures.
No Godot project or feature plan has been created. The exact next action remains to inspect the
local environment and generate only `plans/F00_project_foundation.md` when requested. The user
then reviews that plan and requests its first implementation step. Content candidates still
need approval before their consuming plans, now including vocabulary before F06. Review edits
form a self-contained documentation milestone; the next product action remains F00 planning.
