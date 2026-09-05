# Landzone - First-Slice Content Catalog

Last updated: 2026-09-05

This file keeps authored gameplay content finite and discussable before implementation. Entries
marked **Proposed** are design candidates, not implementation authorization. An agent must ask
for or infer approval only from an explicit user statement before a consuming feature is planned.

Allowed states: `Proposed`, `Approved`, `Implemented`, `Cut`.

Feature owners below use the revised roadmap IDs. Assigning an owner does not approve a
proposed name, behavior variant, or tuning value. Required slice roles are approved scope;
their specific content candidates remain subject to approval before the consuming plan.

## Player equipment

| Content | State | Owner | Purpose |
| --- | --- | --- | --- |
| Surveyor weapon/tool | Proposed | F02 | The player's single medium weapon; fires a reliable low-damage pulse and also interfaces with artifacts. |
| Base pulse | Proposed | F02 | Always available direct attack; constrained by heat or recovery rather than finite ammunition. |
| Precision blink | Proposed | F08 | Paused-command traversal ability using bearing/distance or relative offset; invalid landings are lethal. |
| Resonance interrupt | Proposed | F09 | Artifact ability that interrupts a clearly telegraphed enemy or environmental action rather than increasing raw damage. |
| Artifact environmental/traversal effect (pairing undecided) | Proposed | F09 | The same artifact also grants access through one authored environmental/traversal obstacle; its own acquisition route must not require this effect. |

The first artifact should unlock one traversal/environmental protection and one related weapon
verb. The exact pairing must be approved before F09 planning. Precision blink is already
available in F08 and is not locked behind this artifact. F09 owns both new artifact effects.

## Enemy roles

| Working name | State | Owner | Readable role |
| --- | --- | --- | --- |
| Stalker | Proposed | F02 | Conceals itself, reveals a clear tell, then commits to a lethal approach. Tests observation and spacing. |
| Spitter | Proposed | F07 | Projects a visible delayed hazard onto ground and forces route changes. It cannot attack unreadably from off-screen. |
| Bulwark | Proposed | F09 | Protected from the front and defeated through positioning or an artifact verb rather than higher damage. |
| Scavenger elite | Proposed | F10 | A variation of an existing ordinary role that attempts to take dropped samples and retreat. Reclaiming them transfers existing items, never generates duplicate loot. |
| Site Guardian | Proposed | F13 | Authored boss combining previously learned tells, traversal positioning, and one artifact interaction. |

The generator selects approved encounter modules containing these roles. It does not invent new
behaviors or combine arbitrary enemies without an authored fairness rule.

## Environment and locations

| Content | State | Owner | Purpose |
| --- | --- | --- | --- |
| Basin surface | Implemented | F01; F07 generation | Readable rock paths, compass-aligned forks, and the initial landing region; hunting resources arrive in F10. |
| Spore margin | Proposed | F07; F10 exposure | Alternate surface presentation and authored ground-hazard modules; status exposure activates only with F10 recovery support. |
| Silent structure | Proposed | F09 | Principal cave/ruin site holding the first artifact and entrance checkpoint. |
| Survey cairn | Proposed | F06; F07 placement | Reusable clue landmark whose form remains recognizable when its location changes. |
| Optional resource site | Proposed | F07 reachable node; F10 content | Optional branch containing the huntable creature and ordinary resources; mandatory progression cannot depend on exhausting it. |
| Phase fault | Proposed | F08 | Lethal gap/anomaly used for the first precision-blink challenge. |
| Boss gate | Proposed | F12 coordinate; F13 encounter | Authored final encounter entrance with a nearby shuttle landing and immediate checkpoint. |

The user approved the Basin surface direction on 2026-09-05 after reviewing
`docs/concepts/f01_basin_surface_concept.png`. The image is a mood, palette, and readability
reference rather than a requirement for asset-level fidelity; F01 remains limited to simple
Godot-native placeholder visuals. The approval also preserves Basin surface as F07's first
generated surface presentation, without approving any other proposed F07 content.

F01 implemented the first authored Basin presentation on 2026-09-05 with a static shuttle,
bounded route, safe cyan origin, and avoidable lethal hazard. F07 still owns converting this
presentation into generated arrangements; no other F07 catalog item is approved by F01.

## Statuses and survival content

| Content | State | Owner | Purpose |
| --- | --- | --- | --- |
| Hunger | Proposed | F10; F11 food procedures | Bounded exertion/recovery penalty; emergency nourishment permits recovery and prepared food provides a longer useful expedition interval. |
| Fatigue | Proposed | F10; F11 sleep procedure | Bounded weapon-stability, cooling, or ability-regeneration penalty; basic rest is available immediately. |
| Spore exposure | Proposed | F10; F11 diagnosis/treatment | Initial condition with a readable environmental cause, bounded effects, and basic mothership care from introduction. |
| Huntable grazer | Proposed | F10 | Predictable non-hostile or defensive creature providing the first meat resource; retry does not replenish its harvested yield. |
| Grilled field meat | Proposed | F11 | First cooking chain: prepare, season, heat, check, and optionally save as a known recipe. |

The bounded penalties, death persistence, checkpoint abandonment, and resource-independent
basic recovery in `GAME_DESIGN.md` are required behavior. These proposed content choices must
fit that contract; F10 may not defer all recovery to F11.

## Alien language and clue chain

Working tokens are placeholders until the content pass before F06:

| Token | State | Candidate semantic family |
| --- | --- | --- |
| `ACHVNTSAT` | Proposed | Ascent, north, above, or climb. |
| `VEL` | Proposed | Three, triad, or third. |
| `ORUUN` | Proposed | Silent stone, sealed structure, or dormant place. |

The first clue chain should use only three to five tokens and at least two forms of evidence for
any interpretation required to finish the run. Exact words, meanings, code structure, and clue
templates for the first local inference must be approved before F06. Approve any additions
needed for artifact integration before F09 and generated destinations before F12. Once a token
has an approved meaning, new seeds do not change it. Vary the selected referent, landmark
relationships, and destination with adequate evidence, as described in `GAME_DESIGN.md`.

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
