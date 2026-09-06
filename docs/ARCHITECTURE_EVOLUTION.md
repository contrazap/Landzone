# Landzone - Architecture Evolution

Last updated: 2026-09-06

This is a learning record of material structural changes. It is not a speculative architecture
blueprint. Add an entry only when implementation pressure causes an actual refactor or establishes
an important boundary.

Use [CODE_GUIDE.md](CODE_GUIDE.md) for current ownership, file navigation and walkthroughs.
This log explains decisions; completed feature plans own detailed changes and acceptance output.
Add entries during delivery, not at a separate user checkpoint. F00-F02 plans preserve their
original rationale and step evidence. The 2026-09-06 workflow migration changes documentation,
not game architecture; it does not retrospectively invent a refactor or decision.

## Entry template

```markdown
## YYYY-MM-DD - F##/D## - Short decision

- Before: What concrete implementation existed?
- New pressure: Which verified requirement exposed a limitation?
- Change: What boundary or representation changed?
- Why now: Why is the abstraction justified at this point?
- Alternative rejected: What plausible option was not selected, and why?
- Behavior preserved: Which existing checks demonstrate unchanged behavior?
- New capability: What can the new structure support immediately?
- Remaining debt: What is deliberately still simple?
- Code guide and files: Current walkthrough and implementation links.
```

## Initial constraints, not implementations

The following repository-level constraints exist before F00 and do not imply specific classes:

- Process documentation remains outside `game/`.
- The game is 2D GDScript on Godot 4.7.1 with the Compatibility renderer unless changed by the user.
- Free-form journal prose is distinct from structured progression truth.
- Generated run data must become deterministic and testable before procedural progression ships.
- The mothership and shuttle are static; no architecture for real-time flight is needed.
- Direct play controls and paused deliberate commands are separate input modes.

Before F01, no gameplay code architecture had been established. F01's first concrete
player/Basin/local-retry ownership matches its approved plan and is recorded there; no
implementation-pressure refactor has yet warranted an evolution entry.

## 2026-09-06 - F03/D01 - Separate application lifetime from loaded locations

- Before: `main.tscn` permanently contained the authored Basin, player, Stalker, projectiles,
  retry timer and HUD. `main.gd` was both application root and the only visit controller; all
  encounter state survived only because those nodes were never unloaded.
- New pressure: F03 requires a static home location, real exterior unload/recreation, encounter
  continuity across normal visits, and a distinct same-instance death retry.
- Change: `LandzoneMain` is now a small persistent coordinator with one active-location container,
  guarded static transfer and in-memory `RunState`. The prior integration moved intact into
  `BasinExpedition`; `Mothership` owns Kestrel interaction. Stalker capture/validated restore is
  plain data and rebuilds live collision/presentation on a new instance. Per-location player
  configuration claims and snaps its Camera2D immediately and once deferred: the outgoing
  location camera unregisters after the swap callback and otherwise clears the incoming claim.
- Why now: Hiding or retaining the old Basin nodes could display a mothership but would not prove
  the required run-state versus scene-state boundary. Two actual locations now justify one
  application-level owner.
- Alternative rejected: Visibility/process toggles or reparenting were rejected because live
  exterior state would remain authoritative. A generic scene registry, autoload and disk save
  were also rejected because one route and one in-memory encounter do not justify those systems.
- Behavior preserved: Updated F00-F02 checks deploy through the new root and pass the existing
  movement, hazard, pulse, Stalker, defeat and same-instance retry contracts.
- New capability: Kestrel and Basin replace one another cleanly; normal revisit state survives
  unload while transients do not; death remains a local loaded reset.
- Remaining debt: Route validation names two concrete locations, `RunState` holds one Basin
  snapshot, and no application-restart persistence exists. F05 owns disk persistence; later
  location/encounter scale must demonstrate the need for further generalization.
- Code guide and files: [current ownership and flows](CODE_GUIDE.md),
  [main.gd](../game/main.gd), [run_state.gd](../game/run_state.gd),
  [mothership.gd](../game/mothership.gd), and
  [basin_expedition.gd](../game/basin_expedition.gd).
