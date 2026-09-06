# Code guide

Last checked against implementation: Not yet inspected.

Populate from actual code during implementation. Do not describe planned systems as existing.
Use this as the current learning map; plans own change/evidence details and the architecture log
owns significant decisions. At release consolidate all sections against the final implementation.

## Suggested reading order

Link the runtime entry point, composition/root, core domain behavior, data/persistence and a
representative verification scenario. Explain what the reader will learn at each stop.

## System map

| System responsibility | Actual file links and entry points | State owner / lifetime | Main collaborators |
| --- | --- | --- | --- |

## Runtime walkthroughs

Trace a small number of meaningful flows from user input/event through owners, domain changes,
storage and visible output. Include error/recovery paths and precise method/file links.
Use a diagram only where it clarifies relationships better than prose.

## Data and lifecycle

Explain transient versus durable state, initialization/shutdown, schema/migration contracts,
and ownership across reloads or transitions where those systems exist.

## Where to make changes

Give concrete extension examples tied to current boundaries and the checks they affect. Explain
why boundaries exist without prescribing a speculative final framework.

## Limitations and decision links

List real debt and verification gaps, separate from optional subjective limitations. Link material
architecture decisions and relevant completed plans. Remove obsolete descriptions as code evolves.
