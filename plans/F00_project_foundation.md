# F00 - Project foundation

- Feature status: In progress
- Roadmap dependency: None
- Created: 2026-09-05
- Completed: -
- Current step: S02

## Objective

Create the smallest runnable Godot 4.7.1 project for Landzone: a Compatibility-renderer 2D
project that opens to a clearly labelled placeholder scene, defines only the movement input
needed by the next feature, and has a repeatable headless verification entry point. This
establishes an evidence-backed project and test baseline without prebuilding gameplay systems.

## Preflight and actual starting state

- Inspected `AGENTS.md`, `PROGRESS.md`, the design, roadmap, content catalog, plan template,
  architecture log, plan README, and the actual `game/` tree.
- `game/` contains only `game/.gitkeep` and `game/tests/.gitkeep`; there is no
  `project.godot`, scene, script, imported cache, or automated verification yet.
- `plans/` contains only its README and template; there is no earlier active feature plan.
- Git exists on branch `main`, tracks `origin/main`, and was clean at planning preflight.
- Confirmed these installed executables:
  - `C:\MyFiles\Godot\Godot_v4.7.1-stable_win64.exe` (`4.7.1` file version).
  - `C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe` (`4.7.1` file version).
- Running the console executable with `--version` returned
  `4.7.1.stable.official.a13da4feb` with exit code 0.
- `git diff --check` passed, and there were no uncommitted user changes to preserve.
- There is no previous game behavior to regress. The repository layout and approved design
  documents must remain intact.

## In scope

- Create `game/project.godot` as a Godot 4.7.1 2D project with the Compatibility renderer and
  an explicit main scene.
- Create a minimal repository-native placeholder main scene that visibly identifies Landzone
  and its project-foundation state when launched.
- Define `move_up`, `move_down`, `move_left`, and `move_right` input actions with WASD and arrow
  key bindings as the direct-control baseline consumed by F01.
- Add one focused `SceneTree` verification script under `game/tests/` that checks the F00
  configuration and can load the main scene without relying on a running editor.
- Document and execute repeatable headless import/parser, focused verification, and main-scene
  smoke commands.
- Record automated evidence and the user's manual launch result in the active plan and
  `PROGRESS.md`.

F00 owns no proposed item from `docs/CONTENT_CATALOG.md`, so no content approval is required.

## Out of scope

- Player movement, collision, camera behavior, shuttle/exterior content, hazards, death, or
  respawning; these begin in F01.
- Aim, firing, enemy, command-interface, journal, codex, traversal, survival, or persistence
  inputs and systems owned by later features.
- Autoloads, shared managers, custom resources, save data, procedural generation, or a generic
  test framework before concrete requirements justify them.
- External art, audio, third-party add-ons, export presets, deployment packaging, and release
  automation.
- Approval or implementation of any proposed first-slice content.

## Current design

There is no game architecture yet. F00 will keep ownership flat: `project.godot` selects one
self-contained placeholder scene, and an independently invoked test script reads project
settings and loads that scene. No runtime singleton or cross-scene event boundary is needed.

```text
game/project.godot
        |
        +-- run/main_scene --> game/main.tscn
        |
        +-- input/render settings

game/tests/run_tests.gd --reads settings and loads--> game/main.tscn
```

## Refactoring assessment

- Observed pressure: None. There is no implementation, duplication, ambiguous ownership, or
  existing behavior to restructure.
- Decision: Keep the first project concrete and flat. Add no framework, autoload, or reusable
  gameplay boundary in F00.
- Behavior-preserving verification: Not applicable before initial creation. After each step,
  rerun the existing F00 checks before adding the next increment.

## Expected files

- New: `game/project.godot`
- New: `game/main.tscn`
- New: `game/tests/run_tests.gd`
- New: `game/tests/README.md`
- Modified during implementation: `plans/F00_project_foundation.md`
- Modified during implementation: `PROGRESS.md`
- Modified only if implementation establishes a material structural boundary:
  `docs/ARCHITECTURE_EVOLUTION.md`

## Step ledger

Allowed statuses: `Not started`, `In progress`, `Blocked`, `Complete`.

| Step | Outcome | Status | Verification |
| --- | --- | --- | --- |
| S01 | A Compatibility-renderer Godot project launches its labelled placeholder main scene. | Complete | Godot 4.7.1 headless editor import and two-frame main-scene smoke run exited 0 without parser, load, or runtime errors; `git diff --check` passed. |
| S02 | Movement inputs and a focused F00 test entry point establish the repeatable automated baseline. | Not started | Focused test reports all project, renderer, input, and scene-load checks passing; S01 checks still pass. |
| S03 | Full F00 acceptance evidence is recorded, including the manual visible launch check. | Not started | All automated commands and `git diff --check` pass; user confirms the expected placeholder window. |

## Implementation steps

### S01 - Create the runnable project shell

**Purpose:** Establish the first runnable, inspectable Godot project before adding any testing
or gameplay concerns.

**Changes:** Create `game/project.godot` with the Landzone project name, `game/main.tscn` as the
run scene, 2D defaults, and explicit Compatibility renderer settings. Create a self-contained
Control-based placeholder scene using built-in Godot nodes and theme properties. It must show
the literal text `LANDZONE` and `Project foundation` against a readable plain background.

**Do not:** Add GDScript, inputs, autoloads, gameplay nodes, external assets, plugins, or later
feature scaffolding.

**Verify:** Run:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
git diff --check
```

Both Godot commands must exit 0 without parser, load, or runtime errors. `git diff --check`
must produce no errors.

**Manual checkpoint:** Deferred to S03 so the feature has one explicit visual acceptance gate.

### S02 - Establish inputs and focused verification

**Purpose:** Add the smallest direct-control configuration needed by F01 and make the
foundation independently testable from the command line.

**Changes:** Add `move_up`, `move_down`, `move_left`, and `move_right` actions to
`game/project.godot`, each bound to its WASD key and corresponding arrow key. Create
`game/tests/run_tests.gd` as a focused `SceneTree` script that fails with a nonzero exit code
unless the project name, main-scene path, Compatibility renderer, four input actions and their
bindings, and main-scene loadability match F00. It must print a concise pass summary on success.
Add `game/tests/README.md` with the exact focused and smoke commands and the confirmed local
Godot console path/version.

**Do not:** Implement player motion; add aim, combat, pause, or command actions; build a test
registration framework; or make the test load unrelated future scenes.

**Verify:** Run:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
git diff --check
```

The focused test must report all F00 checks passed and exit 0. The import, smoke, and diff
checks must also exit 0 without parser, load, runtime, or whitespace errors.

**Manual checkpoint:** None; input behavior begins when F01 adds a controllable player.

### S03 - Verify and accept the foundation

**Purpose:** Prove the entire foundation is repeatable and visibly usable before F01 planning.

**Changes:** Run the complete F00 verification set from a clean editor state, inspect the exact
configuration and integration points, record command outputs and the manual result in this
plan and `PROGRESS.md`, and reconcile any documentation that disagrees with the actual files.
Make only fixes necessary for F00 acceptance; if a fix expands scope, stop and revise the plan
instead.

**Do not:** Add gameplay, polish the placeholder into a menu, begin F01, generate F01's plan,
or credit a manual observation that was not actually made.

**Verify:** Run:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --version
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
git status --short
git diff --check
```

The version must remain `4.7.1.stable.official.a13da4feb`; all Godot commands must exit 0;
the focused test must report every F00 assertion passing; the Git inspection must show only
intended F00 and bookkeeping changes; and the diff check must be clean.

**Manual checkpoint:** Launch with
`& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64.exe' --path game`. Confirm that one window opens
without an error dialog, shows `LANDZONE` and `Project foundation` fully and legibly, has no
obvious clipping at its default size, and closes normally. Record the user's report verbatim
enough to distinguish pass from failure.

## Feature acceptance criteria

- [ ] `game/project.godot` opens as a Godot 4.7.1 2D project and explicitly uses the
  Compatibility renderer.
- [ ] Running the project opens `game/main.tscn` and visibly shows `LANDZONE` and
  `Project foundation` without obvious clipping.
- [ ] `move_up`, `move_down`, `move_left`, and `move_right` exist with WASD and arrow-key
  bindings, without unrelated future-feature actions.
- [ ] The focused test verifies project settings, input bindings, and main-scene loadability and
  exits nonzero on failure.
- [ ] Headless import/parser, focused test, and main-scene smoke commands all pass with the
  confirmed `4.7.1.stable.official.a13da4feb` console executable.
- [ ] The project contains no gameplay systems, external dependencies, or speculative
  architecture beyond F00.
- [ ] The user confirms the required manual placeholder presentation check.
- [ ] The active plan and `PROGRESS.md` match the actual state; an architecture entry exists
  only if implementation established a material structural boundary.

## Verification plan

### Automated or headless

- Confirm the executable with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --version`; expect
  `4.7.1.stable.official.a13da4feb` and exit 0.
- Import and parse with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit`;
  expect exit 0 and no parser/load errors.
- Run focused checks with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd`;
  expect its explicit F00 pass summary and exit 0.
- Smoke the configured main scene with
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2`;
  expect exit 0 and no parser, load, or runtime errors.
- Inspect `git status --short` for intended files only and run `git diff --check`; expect no
  whitespace errors.

### Manual

- From the repository root, launch
  `& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64.exe' --path game`.
- Confirm one game window opens without an error dialog and displays both literal labels:
  `LANDZONE` and `Project foundation`.
- Confirm both labels are fully readable at the default window size with no obvious clipping or
  overlap, then close the window normally.
- There is no F00 comprehension, retry, or pacing gate and no unfamiliar-player check. Those
  begin in later roadmap features.

## Completion notes

Fill this section during implementation rather than predicting results:

- Actual files changed: S01 added `game/project.godot` and `game/main.tscn`; bookkeeping updated
  this plan and `PROGRESS.md`.
- Steps completed: S01.
- Commands/tests and results: Godot 4.7.1 headless editor import exited 0; the configured main
  scene smoke run with `--quit-after 2` exited 0; `git diff --check` exited 0 with no whitespace
  errors.
- Manual checks performed: None. The visible placeholder-window check remains deliberately
  deferred to S03.
- Deviations from plan: None.
- Architecture log entries: None; the planned flat project-to-main-scene boundary does not
  constitute a refactor or additional architecture decision.
- Remaining risks or debt: S02 must add and verify only the four planned movement inputs and
  focused test entry point. S03 still owns full acceptance and the user's visual confirmation.
- Suggested commit boundary: F00/S01 runnable project shell and its bookkeeping.
