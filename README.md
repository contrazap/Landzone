# Landzone

Landzone is a 2D science-fiction expedition game for Godot. A vulnerable
scientific explorer investigates a procedurally rearranged planet, records routes in a
searchable journal, deciphers alien clues, and returns to a static mothership to prepare for
the next expedition.

The repository is intentionally developed one small, playable feature at a time. Detailed
feature plans are written just in time from the actual state of the game, then implemented
one step at a time with the user reviewing every step.

## Repository layout

```text
AGENTS.md                         instructions for every coding agent
PROGRESS.md                       authoritative current status and next action
docs/GAME_DESIGN.md               stable game vision, scope, and rules
docs/ROADMAP.md                   ordered feature ladder
docs/CONTENT_CATALOG.md           proposed and approved gameplay content
docs/ARCHITECTURE_EVOLUTION.md    why architecture changed over time
plans/FEATURE_PLAN_TEMPLATE.md    contract for just-in-time feature plans
plans/F##_short_name.md           one active plan per feature, created when needed
game/                             the Godot project; project.godot will live here
```

## Working title and repository name

- Display title: **Landzone**
- Suggested GitHub repository: `landzone`
- Local Godot project directory: `game/`

## Technology baseline

- Godot 4.7.1
- 2D
- GDScript
- Compatibility renderer
- Placeholder visuals made from Godot nodes or small repository-native assets
- No third-party add-ons unless explicitly approved

The local Godot executables expected by the initial setup are:

```text
C:\MyFiles\Godot\Godot_v4.7.1-stable_win64.exe
C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe
```

F00 must verify and record the actual available version before relying on these paths.

## Starting development

From this repository root, ask an agent:

```text
Generate the plan for the next feature.
```

After reviewing the generated F00 plan, ask:

```text
Implement the next step.
```

Repeat one step at a time. Ask `check status` at any point for the canonical one-line handoff.

No Godot project has been created yet. That is intentionally the responsibility of F00 so
project creation, environment verification, and the initial test baseline are captured as
part of the incremental history.
