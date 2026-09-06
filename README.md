# Landzone

Landzone is a 2D science-fiction expedition game for Godot. Explore a compact planet on foot,
record searchable route notes, interpret alien clues, recover artifacts, and return to a static
mothership. See [the game design](docs/GAME_DESIGN.md) for approved scope.

F00-F02 are implemented: an authored Basin route, movement and collision, lethal hazard and
shuttle retry, mouse aim/fire, and one Stalker encounter. The mothership and later systems are
future work. [PROGRESS.md](PROGRESS.md) owns current status.

## Development workflow

Plans are generated on demand from the actual repository. A request to implement a plan delivers
the complete feature by default, including integration, agent-run verification, and documentation.
Large features may define substantial deliveries; one delivery is implemented per request.
Internal checklist items require no separate prompts or user manual checks.

| Prompt | Outcome |
| --- | --- |
| Check status | One-line current state; no edits. |
| Check next step | Explain the exact next action; no edits. |
| Generate the next plan | Plan the next dependency-satisfied feature; no game implementation. |
| Implement the plan | Complete the next delivery (normally the whole feature), verify and document it. |
| Continue implementation | Resume an interrupted delivery. |
| Verify | Run relevant checks and report/update evidence. |

Content details are selected in the plan; requesting implementation authorizes those in-scope
choices. Product changes still need user direction. Agents record required verification gaps
honestly; optional human feedback on enjoyment or first-time understanding never blocks delivery.
See [AGENTS.md](AGENTS.md) for the full contract.

## Run and verify

Open [game/project.godot](game/project.godot) in Godot 4.7.1 and run the main scene
(`res://main.tscn`). Current controls: WASD/arrows to move, mouse to aim, LMB to fire.
The project uses GDScript, 2D, Compatibility rendering, and native placeholder visuals.
No third-party add-ons are required.

Confirmed local console: `C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe`.
See [verification commands and limitations](game/tests/README.md).
Launching the game yourself is optional; it is not an acceptance obligation.

## Repository and study guide

| Location | Purpose |
| --- | --- |
| [PROGRESS.md](PROGRESS.md) | Compact current handoff and next action |
| [Game design](docs/GAME_DESIGN.md) | Product rules and scope |
| [Roadmap](docs/ROADMAP.md) | Feature order, dependencies and ownership |
| [Content catalog](docs/CONTENT_CATALOG.md) | Content candidates and implementation state |
| [Code guide](docs/CODE_GUIDE.md) | Current system map, file reading order and runtime walkthroughs |
| [Architecture evolution](docs/ARCHITECTURE_EVOLUTION.md) | Significant technical decisions and tradeoffs |
| [Feature plans](plans/README.md) | On-demand plans and detailed completion evidence |
| [Historical progress](docs/archive/PROGRESS_2026-09-05.md) | Preserved F00-F02 development observations |
| [game/](game/) | Runnable Godot project and focused scenarios |
| [Reusable project starter](templates/agent_project/README.md) | Apply this workflow to other games and applications |

For learning, begin with the code guide, follow a runtime flow into its linked files, then read
the relevant decision or completed plan for context. The guide grows with implementation and
receives a final consolidation at release.
