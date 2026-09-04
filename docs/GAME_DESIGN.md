# Landzone - Game Design Document

Document status: Approved baseline for incremental planning
Last updated: 2026-09-05

This document defines the stable product direction. It is not an implementation plan. Feature
plans must satisfy the current slice of this design without prematurely constructing systems
owned by later roadmap features.

## High concept

A scientific explorer enters an anomalous solar system in search of lost technology. From an
interior-only mothership base, the explorer deploys a static shuttle to valid landing sites and
continues on foot through compact, procedurally rearranged path networks. Direct enemy attacks
and failed precision traversals are lethal. Progress comes from observing consistent rules,
recording routes, deciphering alien vocabulary, recovering artifacts, and preparing correctly
for the next expedition.

The first complete slice covers one planet and one artifact-to-boss progression. A larger
three-planet game is a possible expansion only after the first slice is complete and enjoyable.

## Player fantasy

The player is not a soldier becoming stronger through armor and damage statistics. They are a
fragile field scientist becoming more capable through knowledge, preparation, and alien tools.

The intended feeling is:

- Lonely but purposeful scientific exploration.
- Tension when leaving the safety of the shuttle.
- Satisfaction from recording and later retrieving useful observations.
- Fair, fast-retry combat where understanding defeats danger.
- A comforting return to a functional mothership after a difficult expedition.
- Growing unease as natural explanations give way to impossible phenomena.

## Design pillars

### Knowledge is progression

Enemy behaviors, environmental rules, coordinates, vocabulary, routes, and artifact functions
remain consistent enough to be learned. A new run rearranges where evidence appears; it does
not arbitrarily change the truth the evidence describes.

### The mothership is home

The mothership is a static, interior-only base reached through the shuttle. It holds the bridge,
research station, galley, medical station, habitat, armory/workbench, and vehicle-bay exit.
Cooking, sleep, treatment, codex work, loadout preparation, and long-term storage happen here.

### Expeditions are deliberate commitments

On-foot regions are compact but dangerous. A route contains authored combat encounters,
environmental hazards, clues, resources, and meaningful branches rather than empty travel.
The shuttle is the initial regional respawn point; an activated site entrance can become the
closer checkpoint.

### Generated arrangements, authored rules

The game procedurally arranges path topology, modules, clue locations, encounters, and resource
distribution from an explicit run seed. Enemy behavior, boss patterns, traversal mechanics,
landmark modules, vocabulary, clue templates, recipes, and artifact effects are authored and
testable.

## Experience references

References describe design qualities, not cloning targets:

- Dark Souls: consequential checkpoints, readable enemies, boss learning, and knowledge gained
  by failure.
- Hotline Miami and precision-action games: lethal attacks, rapid restart, and decisive play.
- Project Zomboid: physical-condition statuses, preparation, inventory, food, and safe-base
  routines.
- Knowledge-driven exploration games: discoveries and interpretation open progress more than
  numerical leveling.

Because attacks are lethal, combat is not intended to reproduce Dark Souls' health, armor,
healing, or melee-stat systems.

## Core loop

```text
Prepare on the mothership
        -> use the shuttle to deploy to a known landing coordinate
        -> explore a compact branching path network on foot
        -> fight, traverse, gather, observe, and record journal notes
        -> activate a cave/structure entrance checkpoint
        -> recover clues, samples, and an artifact
        -> return to the shuttle and mothership
        -> cook, rest, treat conditions, and use the codex
        -> derive the boss-region landing coordinate
        -> deploy beside the boss gate and complete the expedition
```

## First complete slice

The first complete replayable expedition contains:

- One mothership interior.
- One planet with one generated exterior region.
- One shuttle representation with no playable interior.
- Three meaningful path forks, at least one loop, and four to seven path segments.
- Two surface presentations and one cave or structure presentation.
- One optional resource site, one clue landmark, and one principal site.
- Three ordinary enemy roles, one elite variation, and one authored boss.
- One lethal environmental traversal hazard and one precision-teleport challenge.
- One huntable creature, one food preparation chain, and one treatable condition.
- Hunger, fatigue, and physical-condition statuses without a health bar.
- One authored alien vocabulary set distributed through a generated clue chain.
- One artifact that unlocks traversal/environmental access and a weapon ability.
- A boss landing coordinate derived through the codex.
- A new-run action that preserves the rules but rearranges the expedition from a new seed.

Target experience for a learned successful run: roughly 60-120 minutes. This is a design target,
not a deadline or an acceptance criterion until tested.

## Explicit exclusions for the first slice

- Real-time spacecraft flight.
- A shuttle interior.
- Free landing at arbitrary map positions.
- A large seamless open world.
- Three full planets.
- Multiplayer or networking.
- 3D rendering.
- Armor tiers, health upgrades, or conventional character levels.
- Procedurally invented enemy behavior or boss attack patterns.
- Runtime interpretation of arbitrary player-written prose.
- Runtime LLM dependency.
- A broad crafting tree, farming, fishing, or multiple cooking professions.
- Photorealistic or asset-heavy presentation.

Fishing, additional planets, abandoned orbital structures, more artifacts, and anomaly bosses
are expansion candidates after the first slice, not assumed roadmap work.

## World topology

Each exterior region is a graph of landmarks and path segments, not an open field. A typical
generated region contains:

- A shuttle landing node.
- Two or three forks that create meaningful route choices.
- One or two loops that allow a learned shortcut or safer return.
- Authored encounter modules assigned to path edges or small arenas.
- A main site entrance located several decisions away from the shuttle.
- Optional nodes that reward exploration without blocking progression.

Paths align primarily to eight readable compass directions so written observations such as
"take the northeast branch at the three-way fork" remain useful.

### Generation order

```text
Run seed
  -> progression dependency graph
  -> required landmark assignment
  -> spatial path graph
  -> authored path and encounter modules
  -> optional resources and clues
  -> visual decoration
  -> validation
  -> accepted world or bounded regeneration
```

### Required invariants

- Every mandatory location is reachable when it becomes required.
- No artifact appears behind the hazard that artifact must overcome.
- Each required inference has adequate, reachable evidence.
- The minimum critical path contains sufficient survival resources.
- A valid return path exists from mandatory locations.
- Enemies cannot spawn on the player, shuttle, checkpoint, or traversal destination.
- Lethal attacks cannot originate unreadably from outside the playable view.
- The same seed recreates the same progression and topology.
- Death and ordinary revisits do not reroll the world.
- Generation has bounded attempts and exposes useful diagnostics on failure.

## Coordinates and navigation

Navigation uses two coordinate levels:

- A regional coordinate identifies a valid shuttle landing region.
- A local coordinate identifies the player's position within that generated region.

A location command returns region, local position, and facing. Example presentation:

```text
REGION P1-BASIN-04 | LOCAL N17 E09 | FACING NE
```

The shuttle accepts only valid landing coordinates discovered through exploration or clue
solving. It transitions between the chosen exterior landing site and the mothership; it does
not animate or simulate flight.

## Journal

The journal is a persistent, searchable tool for player-authored knowledge. It is intentionally
more important than an automatically completed map.

A new entry automatically stores:

- Entry identifier.
- Player-authored text.
- Regional coordinate.
- Local coordinate.
- Run seed.
- Discovery time.
- Optional player-assigned tags.

Representative commands:

```text
where
journal add "Three-way fork. Ruin path NE; spore field east."
journal find "ruin"
journal read 14
journal tag 14 route cave
```

Free-form notes are never parsed as authoritative game state. Confirmed facts discovered by
gameplay are stored separately in the codex. The journal and confirmed codex entries survive
death.

## Codex and clue progression

The codex searches authored alien terms, evidence, specimen reports, and confirmed meanings.
Each run creates a solution from a stable vocabulary and then distributes clue instances that
support that solution.

The implementation must generate truth before wording:

```text
selected vocabulary and relationships
  -> required artifact code and destination
  -> reachable evidence assignments
  -> authored clue templates populated from that truth
  -> solvability validation
```

Representative commands:

```text
codex search ACHVNTSAT
codex evidence ACHVNTSAT
journal append 14 "ACHVNTSAT may mean ascent or north"
artifact unlock ACHVNTSAT VEL ORUUN
```

Early implementations may use one fixed clue chain. Procedural distribution is a later feature
and should refactor only boundaries that the fixed implementation proves are needed.

## Input and command interface

Direct controls are used for movement, aiming, shooting, ordinary pickups, and time-critical
combat actions. A paused command interface is used for deliberate operations such as journal
management, codex research, cooking, diagnosis, treatment, route entry, and precision traversal.

The command system uses a bounded grammar with:

- Clear verbs and nouns.
- Quoted free-form journal text.
- Command history.
- Contextual help and completion when appropriate.
- Specific parse and validation errors.
- No requirement for unrestricted natural-language understanding.

Opening the command interface pauses ordinary gameplay while the terminal continues to process
input. This is an intentional real-time-with-paused-planning design decision.

## Combat

Any direct enemy attack is lethal. There is no health bar. Fairness therefore requires:

- Consistent attack anticipation and recovery.
- No unreadable off-screen attacks.
- Fast restart and short checkpoint runbacks.
- Deterministic behavior sufficient for observation and mastery.
- Encounter modules that constrain unfair enemy combinations.
- Boss behavior that is authored and learnable.

The player uses one medium scientific weapon/tool. Its base attack cannot be permanently lost.
Artifacts unlock new verbs rather than simple damage inflation. Candidate modes are maintained
in `docs/CONTENT_CATALOG.md` and must be approved before implementation.

## Precision teleport

Precision teleport is both a traversal tool and a text-command mechanic. The player estimates a
bearing and distance or relative offset using consistent environmental scale. Landing in invalid
terrain, a solid obstacle, or a lethal anomaly kills the player.

Representative forms:

```text
blink --bearing 042 --distance 5.5
blink --offset 4.0 -3.5
```

The mechanic must provide:

- A safe mothership training space before lethal field use.
- Consistent world units and readable scale cues.
- A small documented landing tolerance.
- Command history for adjusting a failed estimate.
- Stable geometry across death and retry.
- A checkpoint before extended precision sequences.

The challenge is spatial estimation and judgment, not parser ambiguity.

## Status and survival

Direct attacks kill; status systems affect capability and expedition decisions.

Initial status dimensions:

- Hunger: reduces sustained exertion and recovery when neglected.
- Fatigue: degrades weapon stability, cooling, or ability regeneration.
- Physical condition: holds explicit injuries, infection, or anomalous exposure.

Statuses must have observable causes and readable effects. They should create pressure to prepare
and return home, not produce arbitrary surprise deaths.

The first slice includes hunting and one food preparation chain. Successful procedures may later
be saved as reusable recipes so discovery does not become repetitive clerical entry.

## Mothership

The mothership is one compact interior scene whose accessible spaces are all functional:

- Bridge: inspect and enter valid deployment coordinates.
- Research station: examine specimens and use the codex.
- Galley: prepare food.
- Medical station: diagnose and treat conditions.
- Habitat: sleep and manage fatigue.
- Armory/workbench: equip the single weapon and artifact abilities.
- Vehicle bay: transition to and from the shuttle.

Closed doors, labels, windows, and background machinery may imply a larger vessel. Empty playable
rooms are out of scope until a mechanic needs them.

## Checkpoints, death, and persistence

Checkpoint priority within an expedition:

1. An activated cave or structure entrance checkpoint.
2. The current shuttle landing point.
3. A safe mothership fallback only if no exterior deployment remains valid.

Death preserves:

- The run seed and generated world.
- Journal entries.
- Confirmed codex facts.
- Critical artifacts and permanent ability unlocks.
- Activated progression gates.

Ordinary unbanked samples or resources may be dropped or lost, subject to later tuning. A site
checkpoint is active only while that site is the current expedition context unless a later
approved design changes this rule.

## Presentation

- 2D top-down play.
- Simple, distinctive procedural sprites and shapes made with Godot-native drawing and nodes.
- Strong color language for safe ground, lethal danger, interactable evidence, and checkpoint
  state.
- Minimal but readable animation focused on anticipation, impact, and recovery.
- Text UI designed for keyboard use, command history, and rapid search.
- Audio and screen feedback eventually communicate lethal attacks and command outcomes, but the
  project does not wait for a large asset library.

## Definition of the first slice being complete

The slice is complete only when a player can:

1. Begin on the mothership and prepare for an expedition.
2. Deploy through the shuttle to a generated valid landing region.
3. Explore meaningful branching paths and record searchable location notes.
4. Survive authored combat and complete a precision traversal challenge.
5. Activate a site checkpoint and recover the required evidence and artifact.
6. Return home to cook, rest, treat conditions, and research discoveries.
7. Derive the boss landing coordinate through the codex.
8. Deploy beside the boss gate, defeat the boss, and finish the expedition.
9. Begin another seed whose layout and evidence placement differ while the learned rules remain
   useful.
10. Save, close, reload, and continue without invalidating the generated world or journal.
