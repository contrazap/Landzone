# Landzone - First-Slice Content Catalog

Last updated: 2026-09-05

This file keeps authored gameplay content finite and discussable before implementation. Entries
marked **Proposed** are design candidates, not implementation authorization. An agent must ask
for or infer approval only from an explicit user statement before a consuming feature is planned.

Allowed states: `Proposed`, `Approved`, `Implemented`, `Cut`.

## Player equipment

| Content | State | Purpose |
| --- | --- | --- |
| Surveyor weapon/tool | Proposed | The player's single medium weapon; fires a reliable low-damage pulse and also interfaces with artifacts. |
| Base pulse | Proposed | Always available direct attack; constrained by heat or recovery rather than finite ammunition. |
| Precision blink | Proposed | Paused-command traversal ability using bearing/distance or relative offset; invalid landings are lethal. |
| Resonance interrupt | Proposed | Artifact ability that interrupts a clearly telegraphed enemy or environmental action rather than increasing raw damage. |

The first artifact should unlock one traversal/environmental protection and one related weapon
verb. The exact pairing must be approved before F08 planning.

## Enemy roles

| Working name | State | Readable role |
| --- | --- | --- |
| Stalker | Proposed | Conceals itself, reveals a clear tell, then commits to a lethal approach. Tests observation and spacing. |
| Spitter | Proposed | Projects a visible delayed hazard onto ground and forces route changes. It cannot attack unreadably from off-screen. |
| Bulwark | Proposed | Protected from the front and defeated through positioning or an artifact verb rather than higher damage. |
| Scavenger elite | Proposed | Attempts to take dropped samples and retreat, creating a recovery problem without adding another damage sponge. |
| Site Guardian | Proposed | Authored boss combining previously learned tells, traversal positioning, and one artifact interaction. |

The generator selects approved encounter modules containing these roles. It does not invent new
behaviors or combine arbitrary enemies without an authored fairness rule.

## Environment and locations

| Content | State | Purpose |
| --- | --- | --- |
| Basin surface | Proposed | Readable rock paths, compass-aligned forks, sparse hunting resources, and the initial landing region. |
| Spore margin | Proposed | Alternate surface presentation with delayed ground hazards and status exposure. |
| Silent structure | Proposed | Principal cave/ruin site holding the first artifact and entrance checkpoint. |
| Survey cairn | Proposed | Reusable clue landmark whose form remains recognizable when its location changes. |
| Phase fault | Proposed | Lethal gap/anomaly used for the first precision-blink challenge. |
| Boss gate | Proposed | Authored final encounter entrance with a nearby shuttle landing and immediate checkpoint. |

## Statuses and survival content

| Content | State | Purpose |
| --- | --- | --- |
| Hunger | Proposed | Reduces sustained exertion or recovery when neglected; restored through prepared food. |
| Fatigue | Proposed | Degrades weapon stability, cooling, or ability regeneration; restored through sleep. |
| Spore exposure | Proposed | Initial diagnosable physical condition acquired from a readable environmental cause and treated on the mothership. |
| Huntable grazer | Proposed | Predictable non-hostile or defensive creature providing the first meat resource. |
| Grilled field meat | Proposed | First cooking chain: prepare, season, heat, check, and optionally save as a known recipe. |

## Alien language and clue chain

Working tokens are placeholders until the content pass before F11:

| Token | State | Candidate semantic family |
| --- | --- | --- |
| `ACHVNTSAT` | Proposed | Ascent, north, above, or climb. |
| `VEL` | Proposed | Three, triad, or third. |
| `ORUUN` | Proposed | Silent stone, sealed structure, or dormant place. |

The first clue chain should use only three to five tokens and at least two forms of evidence for
any interpretation required to finish the run. Exact words, meanings, code structure, and clue
templates must be approved before F11.

## Initial command vocabulary

| Domain | Proposed commands |
| --- | --- |
| Location | `where` |
| Journal | `journal add`, `journal find`, `journal read`, `journal tag`, `journal append` |
| Codex | `codex search`, `codex evidence` |
| Deployment | `shuttle land`, `shuttle return` |
| Traversal | `blink --bearing --distance`, `blink --offset` |
| Survival | `diagnose`, `treat`, `cook`, `sleep` |
| Equipment | `search weapon`, `equip ability` |
| Artifact | `artifact inspect`, `artifact unlock` |

Plans should introduce commands only when their feature owns the behavior. Do not build the full
registry during the first command feature.
