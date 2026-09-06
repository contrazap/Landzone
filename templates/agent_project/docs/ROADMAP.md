# Feature roadmap

Last updated: Fill during setup.

Derive ordered, cohesive features from PRODUCT.md and actual starting code. Include a foundation
feature only if needed. Assign every first-version requirement to an owner, including data
integrity, recovery and release. No detailed future plans during setup.

| ID | Feature outcome | Dependencies | Owned scope | Likely integration/verification pressure |
| --- | --- | --- | --- | --- |

Default to one delivery per feature. Decide any substantial split in the on-demand plan from
current evidence; do not pre-split every feature into teaching steps or fixed session counts.
Each delivery must leave a runnable coherent boundary. Tests and docs are internal delivery work.

Implement dependencies first. Necessary persistence, recovery or security must accompany the
behavior that needs it, not wait for final hardening. Keep later expansion outside the first
version. Reordering or scope changes need user direction.

The last feature owns complete-journey regression, platform-appropriate packaged/runtime
verification, performance/error evidence, and consolidation of CODE_GUIDE.md against final code.
No human playtest or manual acceptance gate is a dependency for another feature.
