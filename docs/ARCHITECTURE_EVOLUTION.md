# Landzone - Architecture Evolution

Last updated: 2026-09-05

This is a learning record of material structural changes. It is not a speculative architecture
blueprint. Add an entry only when implementation pressure causes an actual refactor or establishes
an important boundary.

## Entry template

```markdown
## YYYY-MM-DD - F##/S## - Short decision

- Before: What concrete implementation existed?
- New pressure: Which verified requirement exposed a limitation?
- Change: What boundary or representation changed?
- Why now: Why is the abstraction justified at this point?
- Alternative rejected: What plausible option was not selected, and why?
- Behavior preserved: Which existing checks demonstrate unchanged behavior?
- New capability: What can the new structure support immediately?
- Remaining debt: What is deliberately still simple?
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
